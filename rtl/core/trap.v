`include "defines.v"
module trap (
	input clk,
	input rst_n,

	//csr接口
	input wire[`RegBus] csr_rdata_i,        //读CSR寄存器数据
	output reg[`RegBus] csr_wdata_o,        //写CSR寄存器数据
	output reg csr_we_o,                    //写CSR寄存器请求
	output reg[`CsrAddrBus] csr_addr_o,     //访问CSR寄存器地址

	//中断输入接口
	input wire ecall_i,//ecall指令中断
	input wire ebreak_i,//ebreak指令中断

	input wire inst_err_i,//指令解码错误中断
	input wire pex_trap_i,//外部中断
	input wire ptcmp_tarp_i,//定时器中断
	input wire psoft_tarp_i,//软件中断

	input wire mstatus_MIE3,//全局中断使能标志
	input wire wfi_i,//wfi指令休眠

	//下一个PC控制
	input wire[`InstAddrBus] pc_n_i,          //idex提供的下一条指令地址
	output reg[`InstAddrBus] pc_n_o,          //仲裁后的下一条指令地址
	output reg trap_jump_o,                   //中断跳转指示

	//进中断指示
	output reg trap_in_o//即将进入中断的时候，持续拉高

);

always @(*) begin
	csr_wdata_o=0;
	csr_we_o=0;
	csr_addr_o=0;
	trap_in_o=0;
	trap_jump_o=0;
	pc_n_o=pc_n_i;
end

wire trap_exception_en = ecall_i | ebreak_i | inst_err_i;//有异常到达，不可屏蔽
wire trap_interrupt_en = pex_trap_i | ptcmp_tarp_i | psoft_tarp_i;//有中断到达，可屏蔽

//--------------FSM------------------
reg [2:0]sta_n,sta_p;//下一状态sta_n,当前状态sta_p
//状态定义
localparam IDLE = 3'd0;//空闲状态
localparam SWFI = 3'd1;//等待中断状态
localparam CMIE = 3'd2;//关闭全局中断mstatus->MPIE=MIE,MIE=0
localparam WRPC = 3'd3;//写返回地址mepc=PCn
localparam WMCA = 3'd4;//写异常原因mcause
localparam RTVA = 3'd5;//写异常值寄存器mtval
localparam JVPC = 3'd6;//跳转到中断入口PC=mtvec[31:2]，使能

always @(posedge clk or negedge rst_n) begin//状态切换
	if (~rst_n)
		sta_p <= IDLE;
	else
		sta_p <= sta_n;
end

always @(*) begin //状态转移条件
	case (sta_p)
		IDLE: begin//空闲状态
			if(trap_exception_en)//异常
				sta_n = CMIE;
			else
				if(mstatus_MIE3)//全局中断开
					if(trap_interrupt_en)//中断
						sta_n = CMIE;
					else//没中断
						if(wfi_i)//中断等待
							sta_n = SWFI;
						else//正常执行
							sta_n = IDLE;
				else//全局中断关
					if(wfi_i)//中断等待
						sta_n = SWFI;
					else//正常执行
						sta_n = IDLE;
		end
		SWFI: begin//等待中断状态
			if(trap_exception_en)//异常
				sta_n = CMIE;
			else
				if(mstatus_MIE3)//全局中断开
					if(trap_interrupt_en)//中断
						sta_n = CMIE;
					else//没中断
						sta_n = SWFI;
				else//全局中断关
					if(trap_interrupt_en)//中断
						sta_n = IDLE;
					else//正常执行
						sta_n = SWFI;
		end
		CMIE: begin//关闭全局中断mstatus->MPIE=MIE,MIE=0
			sta_n = WRPC;
		end
		WRPC: begin//写返回地址mepc=PCn
			sta_n = WMCA;
		end
		WMCA: begin//写异常原因mcause
			sta_n = RTVA;
		end
		RTVA: begin//写异常值寄存器mtval
			sta_n = JVPC;
		end
		JVPC: begin//跳转到中断入口PC=mtvec[31:2]，使能
			sta_n = IDLE;
		end
		default: sta_n = IDLE;
	endcase
end

always @(*) begin //输出
	csr_wdata_o=0;
	csr_we_o=0;
	csr_addr_o=0;
	trap_in_o=0;
	trap_jump_o=0;
	pc_n_o=pc_n_i;
	case (sta_p)
		IDLE: begin//空闲状态
		end
		SWFI: begin//等待中断状态
		end
		CMIE: begin//关闭全局中断mstatus->MPIE=MIE,MIE=0
		end
		WRPC: begin//写返回地址mepc=PCn
		end
		WMCA: begin//写异常原因mcause
		end
		RTVA: begin//写异常值寄存器mtval
		end
		JVPC: begin//跳转到中断入口PC=mtvec[31:2]，使能
		end
		default: ;
	endcase
end

endmodule