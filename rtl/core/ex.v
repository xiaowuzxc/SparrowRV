 /*                                                                      
 Copyright 2019 Blue Liang, liangkangnan@163.com
																		 
 Licensed under the Apache License, Version 2.0 (the "License");         
 you may not use this file except in compliance with the License.        
 You may obtain a copy of the License at                                 
																		 
	 http://www.apache.org/licenses/LICENSE-2.0                          
																		 
 Unless required by applicable law or agreed to in writing, software    
 distributed under the License is distributed on an "AS IS" BASIS,       
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and     
 limitations under the License.                                          
 */

`include "defines.v"

// 执行模块
// 纯组合逻辑电路
module ex(
	//读操作通道
		//inst
	input wire[`InstBus] inst_i,            //指令内容
	input wire[`InstAddrBus] pc_i,          //指令地址
		//reg
	input wire[`RegBus] reg_rdata1_i,       //读rs1数据
	input wire[`RegBus] reg_rdata2_i,       //读rs2数据
		//csr
	output reg[`CsrAddrBus] csr_raddr_o,    //读CSR地址
	input wire[`RegBus] csr_rdata_i,        //读CSR寄存器数据
		//mem
	input wire[`MemBus] mem_rdata_i,        //读内存数据
		//div
	output reg[`RegBus] dividend_o,         //被除数
	output reg[`RegBus] divisor_o,          //除数
	output reg[2:0] div_op_o,               //除法指令标志
	output reg div_start_o,                 //除法运算开始标志
	input wire[`RegBus] div_result_i,       //除法运算结果

	//写操作通道
		//reg
	output reg[`RegBus] reg_raddr1_o,       //读rs1地址
	output reg[`RegBus] reg_raddr2_o,       //读rs2地址
	output reg[`RegBus] reg_wdata_o,        //写寄存器数据
	output reg reg_we_o,                    //是否要写通用寄存器
	output reg[`RegAddrBus] reg_waddr_o,    //写通用寄存器地址
		//csr
	output reg[`RegBus] csr_wdata_o,        //写CSR寄存器数据
	output reg csr_we_o,                    //写CSR寄存器请求
	output reg[`CsrAddrBus] csr_waddr_o,    //写CSR寄存器地址
		//mem
	output reg[`MemBus] mem_wdata_o,        //写内存数据
	output reg[`MemAddrBus] mem_addr_o,     //访问内存地址，复用读
	output reg mem_we_o,                    //写内存使能
	output reg mem_en_o,                    //访问内存使能，复用读
		//PC
	output reg[`InstAddrBus] pc_n_o,        //下一条指令地址
		//trap
	output reg ecall_o,                     //指令中断使能
	output reg ebreak_o,                    //指令中断使能
	output reg wfi_o,                       //中断等待使能

	//直连输入通道
	input wire[`RegBus] mepc                //mepc寄存器

);

//指令
wire [6:0] opcode = inst_i[6:0];
wire [2:0] funct3 = inst_i[14:12];
wire [6:0] funct7 = inst_i[31:25];
wire [4:0] rd = inst_i[11:7];//访问地址
wire [`RegBus] zimm = {27'h0 , inst_i[19:15]};//用于CSR的立即数扩展
wire signed[`RegBus] imm12i= {{20{inst_i[31]}} , inst_i[31:20]};//有符号12位立即数扩展，I type，addi,lb,lh,jalr
wire signed[`RegBus] imm12s= {{20{inst_i[31]}} , inst_i[31:25] , inst_i[11:7]};//有符号12位立即数扩展，S type，sb,sh
wire signed[`RegBus] imm12b= imm12s << 1 ;//有符号12位立即数扩展*2，B type，beq
wire [`RegBus] imm20u= {inst_i[31:20] , 12'h0};//20位立即数左移12位，U type，lui,auipc
wire signed[`RegBus] imm20j= {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};;//有符号20位立即数扩展，J type，jal
wire shamt = inst_i[24:20];//rs2位置的立即数

//复用运算单元
//加法器
reg [`RegBus] add1_in1;//加法器1输入1
reg [`RegBus] add1_in2;//加法器1输入2
wire [`RegBus] add1_res = add1_in1 + add1_in2;//加法器1结果
reg [`RegBus] add2_in1;//加法器2输入1
reg [`RegBus] add2_in2;//加法器2输入2
wire [`RegBus] add2_res = add2_in1 + add2_in2;//加法器2结果
//乘法器
reg signed[32:0] mul_in1;//乘法器有符号33位输入1
reg signed[32:0] mul_in2;//乘法器有符号33位输入2
wire signed[65:0]mul_res;//乘法器有符号66位结果
assign mul_res=mul_in1*mul_in2;
wire mul_resl=mul_res[31: 0];//乘法器低32位结果
wire mul_resh=mul_res[63:32];//乘法器高32位结果
//比较器，(in1 >= in2) ? 1 : 0
reg [`RegBus] op_in1;//比较器输入1
reg [`RegBus] op_in2;//比较器输入2
wire op_sres = $signed(op_in1) >= $signed(op_in2);//有符号数比较
wire op_ures = op_in1 >= op_in2;// 无符号数比较
wire op_eres = (op_in1 == op_in2);//相等
//-------------------------------------------



/*
assign sr_shift = reg1_rdata_i >> reg2_rdata_i[4:0];
assign sri_shift = reg1_rdata_i >> inst_i[24:20];
assign sr_shift_mask = 32'hffffffff >> reg2_rdata_i[4:0];
assign sri_shift_mask = 32'hffffffff >> inst_i[24:20];

assign op1_add_op2_res = op1_i + op2_i;
assign op1_jump_add_op2_jump_res = op1_jump_i + op2_jump_i;

assign reg1_data_invert = ~reg1_rdata_i + 1;
assign reg2_data_invert = ~reg2_rdata_i + 1;

// 有符号数比较
assign op1_ge_op2_signed = $signed(op1_i) >= $signed(op2_i);
// 无符号数比较
assign op1_ge_op2_unsigned = op1_i >= op2_i;
assign op1_eq_op2 = (op1_i == op2_i);

assign mul_temp = mul_op1 * mul_op2;
assign mul_temp_invert = ~mul_temp + 1;

assign mem_raddr_index = (reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:20]}) & 2'b11;
assign mem_waddr_index = (reg1_rdata_i + {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]}) & 2'b11;

assign div_start_o = (int_assert_i == `INT_ASSERT)? `DivStop: div_start;

assign reg_wdata_o = reg_wdata | div_wdata;
// 响应中断时不写通用寄存器
assign reg_we_o = (int_assert_i == `INT_ASSERT)? `WriteDisable: (reg_we || div_we);
assign reg_waddr_o = reg_waddr | div_waddr;

// 响应中断时不写内存
assign mem_we_o = (int_assert_i == `INT_ASSERT)? `WriteDisable: mem_we;

// 响应中断时不向总线请求访问内存
assign mem_req_o = (int_assert_i == `INT_ASSERT)? `RIB_NREQ: mem_req;

assign hold_flag_o = hold_flag || div_hold_flag;
assign jump_flag_o = jump_flag || div_jump_flag || ((int_assert_i == `INT_ASSERT)? `JumpEnable: `JumpDisable);
assign jump_addr_o = (int_assert_i == `INT_ASSERT)? int_addr_i: (jump_addr | div_jump_addr);

// 响应中断时不写CSR寄存器
assign csr_we_o = (int_assert_i == `INT_ASSERT)? `WriteDisable: csr_we_i;
assign csr_waddr_o = csr_waddr_i;
*/
//-------------------------------------------


// 执行
always @ (*) begin
	//外部接口
	csr_raddr_o = 0;    //读CSR地址
	dividend_o = 0;     //被除数
	divisor_o = 0;      //除数
	div_op_o = 0;       //除法指令标志
	div_start_o = 0;    //除法运算开始标志
	reg_wdata_o = 0;    //写寄存器数据
	reg_we_o = 0;       //是否要写通用寄存器
	reg_waddr_o = 0;    //写通用寄存器地址
	csr_wdata_o = 0;    //写CSR寄存器数据
	csr_we_o = 0;       //写CSR寄存器请求
	csr_waddr_o = 0;    //写CSR寄存器地址
	mem_wdata_o = 0;    //写内存数据
	mem_addr_o = 0;     //访问内存地址，复用读
	mem_we_o = 0;       //写内存使能
	mem_en_o = 0;       //访问内存使能，复用读
	pc_n_o = 0;         //下一条指令地址
	ecall_o = 0;        //指令中断使能
	ebreak_o = 0;       //指令中断使能
	wfi_o = 0;          //中断等待使能
	//复用运算单元
	add1_in1 = 0;        //加法器1输入1
	add1_in2 = 0;        //加法器1输入2
	add2_in1 = 0;        //加法器2输入1
	add2_in2 = 0;        //加法器2输入2
	mul_in1 = 0;         //乘法器有符号33位输入1
	mul_in2 = 0;         //乘法器有符号33位输入2
	op_in1 = 0;              //比较器输入1
	op_in2 = 0;              //比较器输入1
	//读寄存器
	reg_raddr1_o = inst_i[19:15];   //读rs1地址
	reg_raddr2_o = inst_i[24:20];   //读rs2地址
	case (opcode)
		`INST_TYPE_I: begin
			case (funct3)
				`INST_ADDI: begin
					add1_in1 = reg_rdata1_i;
					add1_in2 = imm12i;
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = add1_res;
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_SLTI: begin
					op_in1 = reg_rdata1_i;
					op_in2 = imm12i;
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = {31'h0 , (~op_sres)};
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_SLTIU: begin
					op_in1 = reg_rdata1_i;
					op_in2 = imm12i;
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = {31'h0 , (~op_ures)};
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_XORI: begin
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = reg_rdata1_i ^ imm12i;
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_ORI: begin
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = reg_rdata1_i | imm12i;
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_ANDI: begin
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = reg_rdata1_i & imm12i;
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_SLLI: begin
					reg_we_o = 1;
					reg_waddr_o = rd;
					reg_wdata_o = reg_rdata1_i << imm12i[4:0];
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				`INST_SRI: begin
					reg_we_o = 1;
					reg_waddr_o = rd;
					if (inst_i[30] == 1'b1) begin
						reg_wdata_o = (reg_rdata1_i >> shamt) | ({32{reg_rdata1_i[31]}} & (~(32'hffffffff >> shamt)));
					end else begin
						reg_wdata_o = reg_rdata1_i >> shamt;
					end
					add2_in1 = pc_i;
					add2_in2 = 4;
					pc_n_o = add2_res;
				end
				default: begin

				end
			endcase
		end
		`INST_TYPE_R_M: begin
			if ((funct7 == 7'b0000000) || (funct7 == 7'b0100000)) begin
				case (funct3)
					`INST_ADD_SUB: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						if (inst_i[30] == 1'b0) begin
							reg_wdata = op1_add_op2_res;
						end else begin
							reg_wdata = op1_i - op2_i;
						end
					end
					`INST_SLL: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = op1_i << op2_i[4:0];
					end
					`INST_SLT: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = {32{(~op1_ge_op2_signed)}} & 32'h1;
					end
					`INST_SLTU: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = {32{(~op1_ge_op2_unsigned)}} & 32'h1;
					end
					`INST_XOR: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = op1_i ^ op2_i;
					end
					`INST_SR: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						if (inst_i[30] == 1'b1) begin
							reg_wdata = (sr_shift & sr_shift_mask) | ({32{reg1_rdata_i[31]}} & (~sr_shift_mask));
						end else begin
							reg_wdata = reg1_rdata_i >> reg2_rdata_i[4:0];
						end
					end
					`INST_OR: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = op1_i | op2_i;
					end
					`INST_AND: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = op1_i & op2_i;
					end
					default: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = `ZeroWord;
					end
				endcase
			end else if (funct7 == 7'b0000001) begin
				case (funct3)
					`INST_MUL: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = mul_temp[31:0];
					end
					`INST_MULHU: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = mul_temp[63:32];
					end
					`INST_MULH: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						case ({reg1_rdata_i[31], reg2_rdata_i[31]})
							2'b00: begin
								reg_wdata = mul_temp[63:32];
							end
							2'b11: begin
								reg_wdata = mul_temp[63:32];
							end
							2'b10: begin
								reg_wdata = mul_temp_invert[63:32];
							end
							default: begin
								reg_wdata = mul_temp_invert[63:32];
							end
						endcase
					end
					`INST_MULHSU: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						if (reg1_rdata_i[31] == 1'b1) begin
							reg_wdata = mul_temp_invert[63:32];
						end else begin
							reg_wdata = mul_temp[63:32];
						end
					end
					`INST_DIV: begin
					end
					`INST_DIVU: begin
					end
					`INST_REM: begin
					end
					`INST_REMU: begin
					end
					default: begin
						jump_flag = `JumpDisable;
						hold_flag = `HoldDisable;
						jump_addr = `ZeroWord;
						mem_wdata_o = `ZeroWord;
						mem_raddr_o = `ZeroWord;
						mem_waddr_o = `ZeroWord;
						mem_we = `WriteDisable;
						reg_wdata = `ZeroWord;
					end
				endcase
			end else begin
				jump_flag = `JumpDisable;
				hold_flag = `HoldDisable;
				jump_addr = `ZeroWord;
				mem_wdata_o = `ZeroWord;
				mem_raddr_o = `ZeroWord;
				mem_waddr_o = `ZeroWord;
				mem_we = `WriteDisable;
				reg_wdata = `ZeroWord;
			end
		end
		`INST_TYPE_L: begin
			case (funct3)
				`INST_LB: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					mem_req = `RIB_REQ;
					mem_raddr_o = op1_add_op2_res;
					case (mem_raddr_index)
						2'b00: begin
							reg_wdata = {{24{mem_rdata_i[7]}}, mem_rdata_i[7:0]};
						end
						2'b01: begin
							reg_wdata = {{24{mem_rdata_i[15]}}, mem_rdata_i[15:8]};
						end
						2'b10: begin
							reg_wdata = {{24{mem_rdata_i[23]}}, mem_rdata_i[23:16]};
						end
						default: begin
							reg_wdata = {{24{mem_rdata_i[31]}}, mem_rdata_i[31:24]};
						end
					endcase
				end
				`INST_LH: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					mem_req = `RIB_REQ;
					mem_raddr_o = op1_add_op2_res;
					if (mem_raddr_index == 2'b0) begin
						reg_wdata = {{16{mem_rdata_i[15]}}, mem_rdata_i[15:0]};
					end else begin
						reg_wdata = {{16{mem_rdata_i[31]}}, mem_rdata_i[31:16]};
					end
				end
				`INST_LW: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					mem_req = `RIB_REQ;
					mem_raddr_o = op1_add_op2_res;
					reg_wdata = mem_rdata_i;
				end
				`INST_LBU: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					mem_req = `RIB_REQ;
					mem_raddr_o = op1_add_op2_res;
					case (mem_raddr_index)
						2'b00: begin
							reg_wdata = {24'h0, mem_rdata_i[7:0]};
						end
						2'b01: begin
							reg_wdata = {24'h0, mem_rdata_i[15:8]};
						end
						2'b10: begin
							reg_wdata = {24'h0, mem_rdata_i[23:16]};
						end
						default: begin
							reg_wdata = {24'h0, mem_rdata_i[31:24]};
						end
					endcase
				end
				`INST_LHU: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					mem_req = `RIB_REQ;
					mem_raddr_o = op1_add_op2_res;
					if (mem_raddr_index == 2'b0) begin
						reg_wdata = {16'h0, mem_rdata_i[15:0]};
					end else begin
						reg_wdata = {16'h0, mem_rdata_i[31:16]};
					end
				end
				default: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
				end
			endcase
		end
		`INST_TYPE_S: begin
			case (funct3)
				`INST_SB: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					reg_wdata = `ZeroWord;
					mem_we = `WriteEnable;
					mem_req = `RIB_REQ;
					mem_waddr_o = op1_add_op2_res;
					mem_raddr_o = op1_add_op2_res;
					case (mem_waddr_index)
						2'b00: begin
							mem_wdata_o = {mem_rdata_i[31:8], reg2_rdata_i[7:0]};
						end
						2'b01: begin
							mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[7:0], mem_rdata_i[7:0]};
						end
						2'b10: begin
							mem_wdata_o = {mem_rdata_i[31:24], reg2_rdata_i[7:0], mem_rdata_i[15:0]};
						end
						default: begin
							mem_wdata_o = {reg2_rdata_i[7:0], mem_rdata_i[23:0]};
						end
					endcase
				end
				`INST_SH: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					reg_wdata = `ZeroWord;
					mem_we = `WriteEnable;
					mem_req = `RIB_REQ;
					mem_waddr_o = op1_add_op2_res;
					mem_raddr_o = op1_add_op2_res;
					if (mem_waddr_index == 2'b00) begin
						mem_wdata_o = {mem_rdata_i[31:16], reg2_rdata_i[15:0]};
					end else begin
						mem_wdata_o = {reg2_rdata_i[15:0], mem_rdata_i[15:0]};
					end
				end
				`INST_SW: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					reg_wdata = `ZeroWord;
					mem_we = `WriteEnable;
					mem_req = `RIB_REQ;
					mem_waddr_o = op1_add_op2_res;
					mem_raddr_o = op1_add_op2_res;
					mem_wdata_o = reg2_rdata_i;
				end
				default: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
				end
			endcase
		end
		`INST_TYPE_B: begin
			case (funct3)
				`INST_BEQ: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = op1_eq_op2 & `JumpEnable;
					jump_addr = {32{op1_eq_op2}} & op1_jump_add_op2_jump_res;
				end
				`INST_BNE: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = (~op1_eq_op2) & `JumpEnable;
					jump_addr = {32{(~op1_eq_op2)}} & op1_jump_add_op2_jump_res;
				end
				`INST_BLT: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = (~op1_ge_op2_signed) & `JumpEnable;
					jump_addr = {32{(~op1_ge_op2_signed)}} & op1_jump_add_op2_jump_res;
				end
				`INST_BGE: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = (op1_ge_op2_signed) & `JumpEnable;
					jump_addr = {32{(op1_ge_op2_signed)}} & op1_jump_add_op2_jump_res;
				end
				`INST_BLTU: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = (~op1_ge_op2_unsigned) & `JumpEnable;
					jump_addr = {32{(~op1_ge_op2_unsigned)}} & op1_jump_add_op2_jump_res;
				end
				`INST_BGEU: begin
					hold_flag = `HoldDisable;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
					jump_flag = (op1_ge_op2_unsigned) & `JumpEnable;
					jump_addr = {32{(op1_ge_op2_unsigned)}} & op1_jump_add_op2_jump_res;
				end
				default: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
				end
			endcase
		end
		`INST_JAL, `INST_JALR: begin
			hold_flag = `HoldDisable;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			jump_flag = `JumpEnable;
			jump_addr = op1_jump_add_op2_jump_res;
			reg_wdata = op1_add_op2_res;
		end
		`INST_LUI, `INST_AUIPC: begin
			hold_flag = `HoldDisable;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			jump_addr = `ZeroWord;
			jump_flag = `JumpDisable;
			reg_wdata = op1_add_op2_res;
		end
		`INST_NOP_OP: begin
			jump_flag = `JumpDisable;
			hold_flag = `HoldDisable;
			jump_addr = `ZeroWord;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			reg_wdata = `ZeroWord;
		end
		`INST_FENCE: begin
			hold_flag = `HoldDisable;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			reg_wdata = `ZeroWord;
			jump_flag = `JumpEnable;
			jump_addr = op1_jump_add_op2_jump_res;
		end
		`INST_SYS: begin
			jump_flag = `JumpDisable;
			hold_flag = `HoldDisable;
			jump_addr = `ZeroWord;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			case (funct3)
				`INST_CSRRW: begin
					csr_wdata_o = reg1_rdata_i;
					reg_wdata = csr_rdata_i;
				end
				`INST_CSRRS: begin
					csr_wdata_o = reg1_rdata_i | csr_rdata_i;
					reg_wdata = csr_rdata_i;
				end
				`INST_CSRRC: begin
					csr_wdata_o = csr_rdata_i & (~reg1_rdata_i);
					reg_wdata = csr_rdata_i;
				end
				`INST_CSRRWI: begin
					csr_wdata_o = {27'h0, uimm};
					reg_wdata = csr_rdata_i;
				end
				`INST_CSRRSI: begin
					csr_wdata_o = {27'h0, uimm} | csr_rdata_i;
					reg_wdata = csr_rdata_i;
				end
				`INST_CSRRCI: begin
					csr_wdata_o = (~{27'h0, uimm}) & csr_rdata_i;
					reg_wdata = csr_rdata_i;
				end
				`INST_SI: begin
					case (inst_i[31:15])
						`INST_ECALL: begin
						end
						`INST_EBREAK: begin
						end
						`INST_MRET: begin
						end
						`INST_WFI: begin
						end
						default : /* default */;
					endcase
				end
				default: begin
					jump_flag = `JumpDisable;
					hold_flag = `HoldDisable;
					jump_addr = `ZeroWord;
					mem_wdata_o = `ZeroWord;
					mem_raddr_o = `ZeroWord;
					mem_waddr_o = `ZeroWord;
					mem_we = `WriteDisable;
					reg_wdata = `ZeroWord;
				end
			endcase
		end
		default: begin
			jump_flag = `JumpDisable;
			hold_flag = `HoldDisable;
			jump_addr = `ZeroWord;
			mem_wdata_o = `ZeroWord;
			mem_raddr_o = `ZeroWord;
			mem_waddr_o = `ZeroWord;
			mem_we = `WriteDisable;
			reg_wdata = `ZeroWord;
		end
	endcase
end

endmodule
