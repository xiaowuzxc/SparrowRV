`timescale 1ns/100ps
module tb_core(); /* this is automatically generated */


//测试用信号
logic clk;
logic rst_n;
logic ex_trap_i;

integer r;//计数
//寄存器监测
wire [31:0] x3  = inst_core.inst_regs.regs[3];
wire [31:0] x26 = inst_core.inst_regs.regs[26];
wire [31:0] x27 = inst_core.inst_regs.regs[27];

wire [31:0] ra  = inst_core.inst_regs.regs[1];
wire [31:0] sp  = inst_core.inst_regs.regs[2];
wire [31:0] gp  = inst_core.inst_regs.regs[3];
wire [31:0] tp  = inst_core.inst_regs.regs[4];
wire [31:0] t0  = inst_core.inst_regs.regs[5];
wire [31:0] t1  = inst_core.inst_regs.regs[6];
wire [31:0] t2  = inst_core.inst_regs.regs[7];
wire [31:0] s0  = inst_core.inst_regs.regs[8];
wire [31:0] s1  = inst_core.inst_regs.regs[9];
wire [31:0] a0  = inst_core.inst_regs.regs[10];
wire [31:0] a1  = inst_core.inst_regs.regs[11];
wire [31:0] a2  = inst_core.inst_regs.regs[12];
wire [31:0] a3  = inst_core.inst_regs.regs[13];
wire [31:0] a4  = inst_core.inst_regs.regs[14];
wire [31:0] a5  = inst_core.inst_regs.regs[15];
wire [31:0] a6  = inst_core.inst_regs.regs[16];
wire [31:0] a7  = inst_core.inst_regs.regs[17];
wire [31:0] s2  = inst_core.inst_regs.regs[18];
wire [31:0] s3  = inst_core.inst_regs.regs[19];
wire [31:0] s4  = inst_core.inst_regs.regs[20];
wire [31:0] s5  = inst_core.inst_regs.regs[21];
wire [31:0] s6  = inst_core.inst_regs.regs[22];
wire [31:0] s7  = inst_core.inst_regs.regs[23];
wire [31:0] s8  = inst_core.inst_regs.regs[24];
wire [31:0] s9  = inst_core.inst_regs.regs[25];
wire [31:0] s10 = inst_core.inst_regs.regs[26];
wire [31:0] s11 = inst_core.inst_regs.regs[27];
wire [31:0] t3  = inst_core.inst_regs.regs[28];
wire [31:0] t4  = inst_core.inst_regs.regs[29];
wire [31:0] t5  = inst_core.inst_regs.regs[30];
wire [31:0] t6  = inst_core.inst_regs.regs[31];
// read mem data
initial begin
	$readmemh ("inst.txt", inst_core.inst_iram.inst_dpram.BRAM);
end
// clk
initial begin
	clk = '0;
	forever #(0.5) clk = ~clk;
end

//启动测试
initial begin
	ex_trap_i=0;
	adcrst();//复位系统
	#30;
	ex_trap_i=1;
	#2;
	ex_trap_i=0;

	wait(x26 == 32'b1)   // wait sim end, when x26 == 1
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
		$display("x%2d = 0x%x", r, inst_core.inst_regs.regs[r]);
	end

	$finish;
end

initial begin
	#30000;
	$display("Timeout");
	$finish;
end

task adcrst;//复位任务
	rst_n <= '0;
	#10
	rst_n <= '1;
	#5;
endtask : adcrst



core inst_core (
	.clk(clk), 
	.rst_n(rst_n), 
	.ex_trap_i(ex_trap_i)
);

// 输出波形
initial begin
	$dumpfile("tb.lxt");  //生成lxt的文件名称
	$dumpvars(0,tb_core);   //tb中实例化的仿真目标实例名称
end

endmodule