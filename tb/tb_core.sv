`timescale 1ns/100ps
module tb_core(); /* this is automatically generated */

`define CorePath inst_sparrow_soc.inst_core
//测试用信号
logic clk;
logic rst_n;
logic ex_trap_i;
logic JTAG_TCK,JTAG_TMS,JTAG_TDI,JTAG_TDO;//jtag

integer r;//计数工具人

//寄存器监测
wire [31:0] x3  = `CorePath.inst_regs.regs[3];
wire [31:0] x26 = `CorePath.inst_regs.regs[26];
wire [31:0] x27 = `CorePath.inst_regs.regs[27];

wire [31:0] ra  = `CorePath.inst_regs.regs[1];
wire [31:0] sp  = `CorePath.inst_regs.regs[2];
wire [31:0] gp  = `CorePath.inst_regs.regs[3];
wire [31:0] tp  = `CorePath.inst_regs.regs[4];
wire [31:0] t0  = `CorePath.inst_regs.regs[5];
wire [31:0] t1  = `CorePath.inst_regs.regs[6];
wire [31:0] t2  = `CorePath.inst_regs.regs[7];
wire [31:0] s0  = `CorePath.inst_regs.regs[8];
wire [31:0] s1  = `CorePath.inst_regs.regs[9];
wire [31:0] a0  = `CorePath.inst_regs.regs[10];
wire [31:0] a1  = `CorePath.inst_regs.regs[11];
wire [31:0] a2  = `CorePath.inst_regs.regs[12];
wire [31:0] a3  = `CorePath.inst_regs.regs[13];
wire [31:0] a4  = `CorePath.inst_regs.regs[14];
wire [31:0] a5  = `CorePath.inst_regs.regs[15];
wire [31:0] a6  = `CorePath.inst_regs.regs[16];
wire [31:0] a7  = `CorePath.inst_regs.regs[17];
wire [31:0] s2  = `CorePath.inst_regs.regs[18];
wire [31:0] s3  = `CorePath.inst_regs.regs[19];
wire [31:0] s4  = `CorePath.inst_regs.regs[20];
wire [31:0] s5  = `CorePath.inst_regs.regs[21];
wire [31:0] s6  = `CorePath.inst_regs.regs[22];
wire [31:0] s7  = `CorePath.inst_regs.regs[23];
wire [31:0] s8  = `CorePath.inst_regs.regs[24];
wire [31:0] s9  = `CorePath.inst_regs.regs[25];
wire [31:0] s10 = `CorePath.inst_regs.regs[26];
wire [31:0] s11 = `CorePath.inst_regs.regs[27];
wire [31:0] t3  = `CorePath.inst_regs.regs[28];
wire [31:0] t4  = `CorePath.inst_regs.regs[29];
wire [31:0] t5  = `CorePath.inst_regs.regs[30];
wire [31:0] t6  = `CorePath.inst_regs.regs[31];
wire mends = `CorePath.inst_csr.mends;//仿真结束标志

// 读入程序
initial begin
	$readmemh ("inst.txt", `CorePath.inst_iram.inst_dpram.BRAM);
end

// 生成clk
initial begin
	clk = '0;
	forever #(0.5) clk = ~clk;
end

//启动测试
initial begin
	ex_trap_i=0;
	JTAG_TCK=0;
	JTAG_TMS=0;
	JTAG_TDI=0;
	sysrst();//复位系统
	#30;
	ex_trap_i=1;
	#7;
	ex_trap_i=0;

`ifdef ISA_TEST  //通过宏定义，控制是否是指令集测试程序
	wait(x26 == 32'b1)   // x26 == 1，结束仿真
	#10
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
	$finish;//结束
`endif

end

initial begin
	#30000;
	$display("Timeout");//超时
`ifdef ISA_TEST
	$display("ISA_TEST Err");
`endif
	$finish;
end

initial begin
	#30;
	wait(mends === 1'b1)//软件控制仿真结束
	$display("CSR MENDS END");
	#10;
	$finish;
end

task sysrst;//复位任务
	rst_n <= '0;
	#10
	rst_n <= '1;
	#5;
endtask : sysrst



sparrow_soc inst_sparrow_soc (
	.clk(clk), 
	.hard_rst_n(rst_n), 
	.JTAG_TCK(JTAG_TCK),
	.JTAG_TMS(JTAG_TMS),
	.JTAG_TDI(JTAG_TDI),
	.JTAG_TDO(JTAG_TDO),
	.ex_trap_i(ex_trap_i)
);

// 输出波形
initial begin
	$dumpfile("tb.lxt");  //生成lxt的文件名称
	$dumpvars(0,tb_core);   //tb中实例化的仿真目标实例名称
end

endmodule