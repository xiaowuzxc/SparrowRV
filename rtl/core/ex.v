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
    output reg[`RegBus] reg_raddr1_o,       //读rs1地址
    output reg[`RegBus] reg_raddr2_o,       //读rs2地址
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
    output reg[`RegBus] reg_wdata_o,        //写寄存器数据
    output reg reg_we_o,                    //是否要写通用寄存器
    output reg[`RegAddrBus] reg_waddr_o,    //写通用寄存器地址
        //csr
    output reg[`RegBus] csr_wdata_o,        //写CSR寄存器数据
    output reg csr_we_o,                    //是否要写CSR寄存器
    output reg[`CsrAddrBus] csr_waddr_o,    //写CSR寄存器地址
        //mem
    output reg[`MemBus] mem_wdata_o,        //写内存数据
    output reg[`MemAddrBus] mem_addr_o,     //访问内存地址，复用读
    output reg mem_we_o,                    //写内存使能
    output reg mem_req_o,                   //请求访问内存，复用读
        //PC
    output reg[`InstAddrBus] pc_n_o,        //下一条指令地址
        //trap
    output reg trap_en_o,                   //指令中断使能
    output reg wfi_en_o,                    //中断等待使能

    //直连输入通道
    input wire[`RegBus] mepc                //mepc寄存器

);

wire[1:0] mem_raddr_index;
wire[1:0] mem_waddr_index;
wire[`DoubleRegBus] mul_temp;
wire[`DoubleRegBus] mul_temp_invert;
wire[31:0] sr_shift;
wire[31:0] sri_shift;
wire[31:0] sr_shift_mask;
wire[31:0] sri_shift_mask;
wire[31:0] op1_add_op2_res;
wire[31:0] op1_jump_add_op2_jump_res;
wire[31:0] reg1_data_invert;
wire[31:0] reg2_data_invert;
wire op1_ge_op2_signed;
wire op1_ge_op2_unsigned;
wire op1_eq_op2;
reg[`RegBus] mul_op1;
reg[`RegBus] mul_op2;
wire[6:0] opcode;
wire[2:0] funct3;
wire[6:0] funct7;
wire[4:0] rd;
wire[4:0] uimm;
reg[`RegBus] reg_wdata;
reg reg_we;
reg[`RegAddrBus] reg_waddr;
reg[`RegBus] div_wdata;
reg div_we;
reg[`RegAddrBus] div_waddr;
reg div_hold_flag;
reg div_jump_flag;
reg[`InstAddrBus] div_jump_addr;
reg hold_flag;
reg jump_flag;
reg[`InstAddrBus] jump_addr;
reg mem_we;
reg mem_req;
reg div_start;

assign opcode = inst_i[6:0];
assign funct3 = inst_i[14:12];
assign funct7 = inst_i[31:25];
assign rd = inst_i[11:7];
assign uimm = inst_i[19:15];

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



// 执行
always @ (*) begin
    reg_we = reg_we_i;
    reg_waddr = reg_waddr_i;
    mem_req = `RIB_NREQ;
    csr_wdata_o = `ZeroWord;

    case (opcode)
        `INST_TYPE_I: begin
            case (funct3)
                `INST_ADDI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = op1_add_op2_res;
                end
                `INST_SLTI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = {32{(~op1_ge_op2_signed)}} & 32'h1;
                end
                `INST_SLTIU: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = {32{(~op1_ge_op2_unsigned)}} & 32'h1;
                end
                `INST_XORI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = op1_i ^ op2_i;
                end
                `INST_ORI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = op1_i | op2_i;
                end
                `INST_ANDI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = op1_i & op2_i;
                end
                `INST_SLLI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    reg_wdata = reg1_rdata_i << inst_i[24:20];
                end
                `INST_SRI: begin
                    jump_flag = `JumpDisable;
                    hold_flag = `HoldDisable;
                    jump_addr = `ZeroWord;
                    mem_wdata_o = `ZeroWord;
                    mem_raddr_o = `ZeroWord;
                    mem_waddr_o = `ZeroWord;
                    mem_we = `WriteDisable;
                    if (inst_i[30] == 1'b1) begin
                        reg_wdata = (sri_shift & sri_shift_mask) | ({32{reg1_rdata_i[31]}} & (~sri_shift_mask));
                    end else begin
                        reg_wdata = reg1_rdata_i >> inst_i[24:20];
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
