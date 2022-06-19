`include "defines.v"
//总线、系统控制、阻塞
module sctr (
	input clk,
	input rst_n,

	//信号输入
	input wire  reg_we_i,                    //是否要写通用寄存器
	input wire  csr_we_i,                    //写CSR寄存器请求

	input wire [`MemBus] mem_wdata_i,       //写内存数据
	input wire [`MemAddrBus] mem_addr_i,    //访问内存地址，复用读
	input wire mem_we_i,                    //写内存使能
	input wire [3:0] mem_wem_i,             //写内存掩码
	input wire mem_en_i,                    //访问内存使能，复用读
	output reg [`MemBus] mem_rdata_o,       //读内存数据

	//信号输出
	output reg reg_we_o,                    //是否要写通用寄存器
	output reg csr_we_o,                    //写CSR寄存器请求
	output reg iram_rd_o,      //iram指令存储器读使能

	//阻塞指示
	input wire div_start_i,//除法启动
	input wire div_ready_i,//除法结束
	input wire iram_rstn_i,//iram模块阻塞
	input wire trap_in_i,//进中断指示

	//中断相关
	input wire trap_jump_i,//中断跳转指示，进中断最后一步
	input wire idex_mret_i,//中断返回
	output reg trap_stat_o,//中断状态指示

	//总线接口
	//M -> S
	output reg [`MemBus]		sctr_cmd_wdata,//写数据
	output reg [`MemAddrBus] 	sctr_cmd_addr ,//地址
	output reg 					sctr_cmd_we   ,//写使能
	output reg [3:0]			sctr_cmd_wem  ,//写掩码
	output reg 					sctr_cmd_valid,//主机请求
	input  wire					sctr_cmd_ready,//从机准备好
	//S ->M
	input  wire [`MemBus]		sctr_rsp_rdata,//读数据
	input  wire					sctr_rsp_valid,//从机请求
	output reg					sctr_rsp_ready,//主机准备好
	input  wire					sctr_rsp_error,//总线错误，备用


	//回写使能
	output reg hx_valid//回写使能信号


);

//--------------FSM------------------
//0:初始阶段
//1:结束阶段
reg sta_p;
reg sta_n;
always @(posedge clk or negedge rst_n) begin//状态切换
	if (~rst_n)
		sta_p <= 1'b0;
	else
		sta_p <= sta_n;
end

always @(*) begin//状态转移条件
	if (sta_p == 1'b0) begin
		if( ~trap_in_i & (div_start_i | ((~mem_we_i) & sctr_cmd_valid & sctr_cmd_ready)))//没有中断且(开始除法，或读总线)
			sta_n = 1'b1;
		else
			sta_n = 1'b0;
	end 
	else begin
		if( div_ready_i | trap_in_i | (sctr_rsp_valid & sctr_rsp_ready))//除法结束，或中断，或读返回成功
			sta_n = 1'b0;
		else
			sta_n = 1'b1;
	end
end

always @(*) begin//阻塞条件hx_valid控制
	if (sta_p == 1'b0) begin//初始状态
		if( div_start_i | iram_rstn_i | trap_in_i | (mem_en_i & (~mem_we_i)) | (mem_en_i & mem_we_i & (~sctr_cmd_ready)))//开始除法，或iram复位未结束，或中断，或总线cmd等待
			hx_valid = 1'b0;
		else
			hx_valid = 1'b1;
	end
	else begin//结束状态
		if( ~trap_in_i & (div_ready_i | (sctr_rsp_valid & sctr_rsp_ready)))//没有中断且(除法结束，或读返回成功)
			hx_valid = 1'b1;
		else
			hx_valid = 1'b0;
	end
end
//--------------FSM-End--------------

always @(*) begin//reg,csr,iram写控制
	if(hx_valid) begin
		reg_we_o = 1'b1;
		csr_we_o = 1'b1;
		iram_rd_o = 1'b1;
	end
	else begin
		reg_we_o = 1'b0;
		csr_we_o = 1'b0;
		if(trap_jump_i)
			iram_rd_o = 1'b1;//发生中断，可以寻址
		else
			iram_rd_o = 1'b0;//未中断，不许寻址
	end
end

always @(*) begin//总线控制
	if(sta_p == 1'b0) begin
		mem_rdata_o    = 0;
		sctr_cmd_wdata = mem_wdata_i;
		sctr_cmd_addr  = mem_addr_i;
		sctr_cmd_we    = mem_we_i;
		sctr_cmd_wem   = mem_wem_i;
		sctr_cmd_valid = mem_en_i & ~trap_in_i;//进中断过程中不允许访存
		sctr_rsp_ready = 1'b1;
	end
	else begin
		mem_rdata_o    = sctr_rsp_rdata;
		sctr_cmd_wdata = 0;
		sctr_cmd_addr  = 0;
		sctr_cmd_we    = 1'b0;
		sctr_cmd_wem   = 0;
		sctr_cmd_valid = 1'b0;
		sctr_rsp_ready = 1'b1;
	end
end
/*
	input wire trap_jump_i,//中断跳转指示，进中断最后一步
	input wire idex_mret_i,//中断返回
	output reg trap_stat_o,//中断状态指示
*/
always @(posedge clk or negedge rst_n) begin
	if(~rst_n) begin
		trap_stat_o <= 0;
	end 
	else begin
		if(~trap_stat_o)//未处于中断
			if(trap_jump_i)//若跳转到中断入口
				trap_stat_o <= 1;//切换到中断状态
			else begin end
		else//处于中断
			if(idex_mret_i & hx_valid)//遇到mret指令且写回使能
				trap_stat_o <= 0;//退出中断状态
			else begin end
	end
end

endmodule