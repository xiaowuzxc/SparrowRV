`timescale 1ns/1ns
`include "defines.v"
module tb_core(); 

`define CorePath inst_sparrow_soc.inst_core


//测试用信号
logic clk;
logic randem;
logic rst_n;
logic core_ex_trap_valid, core_ex_trap_ready;//外部中断线
logic JTAG_TCK,JTAG_TMS,JTAG_TDI,JTAG_TDO;//jtag
wire spi0_miso;
wire [31:0]fpioa;

logic [63:0] sim_cycle_cnt = '0;//仿真周期计数器

assign fpioa[3:2] = `BOOT_UART_WI;
wire uart0_rx= (sim_cycle_cnt>21045 && sim_cycle_cnt<50000)?randem:1'b1;//1'b1;//fpioa[0]
assign fpioa[0]=uart0_rx;
wire uart0_tx=fpioa[1];//fpioa[1]
assign fpioa[4]=spi0_miso;
wire spi0_mosi=fpioa[5];
wire spi0_clk=fpioa[6];
wire spi0_cs=fpioa[7];



assign fpioa[31] = 1'b1;

integer r;//计数工具人
//寄存器监测
wire [31:0] x3  = `CorePath.inst_regs.regs[3];
wire [31:0] x26 = `CorePath.inst_regs.regs[26];
wire [31:0] x27 = `CorePath.inst_regs.regs[27];
wire mends = `CorePath.inst_csr.mends;//仿真结束标志

// 读入程序
initial begin
    for(r=0; r<`IRamSize; r=r+1) begin
        `CorePath.inst_iram.inst_appram.BRAM[r] = 32'h0;
    end
`ifdef ISA_TEST
    $readmemh ("inst.txt", `CorePath.inst_iram.inst_appram.BRAM);
`else 
    $readmemh ("btrm.txt", `CorePath.inst_iram.inst_appram.BRAM,0,(8192/4)-1);
    $readmemh ("inst.txt", `CorePath.inst_iram.inst_appram.BRAM,(8192/4));
`endif
end

// 生成clk
initial begin
    clk = '0;
    forever #(5) clk = ~clk;
end
// 生成异步信号
initial begin
    randem = '0;
    forever #(7) randem = ~randem;
end


always @(posedge clk) 
    sim_cycle_cnt <= sim_cycle_cnt+1;



//启动仿真流程
initial begin
    sysrst();//复位系统
    #10;
    //ex_trap();

`ifdef ISA_TEST  //通过宏定义，控制是否是指令集测试程序
    wait(x26 == 32'b1);   // x26 == 1，结束仿真
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    if (x27 == 32'b1) begin
    $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
    $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
    $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
    $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end else begin
    $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
    $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    $display("fail testnum = %2d", x3);
    for (r = 1; r < 32; r = r + 1)
        $display("x%2d = 0x%x", r, `CorePath.inst_regs.regs[r]);
    end
    $stop;//结束
`endif

end

initial begin
`ifndef MODELSIM
    #600000;//iverilog
`else 
    #3000000;//modeslsim
`endif
`ifdef ISA_TEST
    $display("*Sim tool:ISA_TEST Timeout, Err");//ISA测试超时
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
`else 
    $display("*Sim tool:Normal Sim Timeout");//普通仿真超时
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
`endif
    $stop;
end

initial begin
    #30;
    wait(mends === 1'b1)//软件控制仿真结束
    $display("*Sim tool:CSR MENDS END, stop sim");
    $display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
    #10;
    $stop;
end

task sysrst;//复位任务
    core_ex_trap_valid=0;
    JTAG_TCK=0;
    JTAG_TMS=0;
    JTAG_TDI=0;
    //rst_n <= '0;
    #15
    //rst_n <= '1;
    #10;
endtask : sysrst

task ex_trap;
    #15000;
    core_ex_trap_valid=1;
    #30;
    wait(core_ex_trap_ready);
    core_ex_trap_valid=0;
endtask : ex_trap


genvar i;//计数工具人
generate
    for ( i=0; i <32 ; i++) begin//fpioa信号弱下拉
        assign (weak1,weak0) fpioa[i] = 1'b0;
    end
endgenerate

always @(posedge clk) begin//显示printf时间
    if(`CorePath.inst_csr.printf_valid && (`CorePath.inst_csr.idex_csr_wdata_i[7:0]=="\n")) begin
        #1;
        //$display("*Sim tool:Sim cycle = %d", sim_cycle_cnt);
    end
    
end

initial begin
    wait(rst_n===1'b1);
    if(`CorePath.inst_iram.inst_appram.BRAM[0]==32'h0) begin//如果inst.txt读入失败，停止仿真
        $display("*Sim tool:Inst load error");
        #10;
        $stop;
    end
end
sparrow_soc inst_sparrow_soc (
    .clk               (clk), 
    .hard_rst_n        (rst_n), 
    .hx_valid          (),

    .JTAG_TCK          (JTAG_TCK),
    .JTAG_TMS          (JTAG_TMS),
    .JTAG_TDI          (JTAG_TDI),
    .JTAG_TDO          (JTAG_TDO),

    .fpioa             (fpioa),//处理器IO接口

    .core_ex_trap_valid(core_ex_trap_valid),
    .core_ex_trap_ready(core_ex_trap_ready)
);

`ifdef Flash25
pullup(WPn);
pullup(HOLDn);
W25Q128JVxIM inst_W25Q128JVxIM (
    .CSn   (spi0_cs),
    .CLK   (spi0_clk),
    .DIO   (spi0_mosi),
    .DO    (spi0_miso),
    .WPn   (WPn),
    .HOLDn (HOLDn)
);
`endif

//输出波形
initial begin
    $dumpfile("tb.vcd");  //生成lxt的文件名称
    $dumpvars(0,tb_core);   //tb中实例化的仿真目标实例名称   
end


endmodule