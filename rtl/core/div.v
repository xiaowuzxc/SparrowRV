`include "defines.v"

// 除法模块
// 试商法实现32位整数除法
// 每次除法运算至少需要33个时钟周期才能完成
module div(

    input wire clk,
    input wire rst_n,

    // from ex
    input wire[`RegBus] dividend_i,      // 被除数
    input wire[`RegBus] divisor_i,       // 除数
    input wire start_i,                  // 开始信号，运算期间这个信号需要一直保持有效
    input wire[2:0] op_i,                // 具体是哪一条指令
    input wire[`RegAddrBus] reg_waddr_i, // 运算结束后需要写的寄存器

    // to ex
    output reg[`RegBus] result_o,        // 除法结果，高32位是余数，低32位是商
    output reg ready_o,                  // 运算结束信号
    output reg busy_o,                  // 正在运算信号
    output reg[`RegAddrBus] reg_waddr_o  // 运算结束后需要写的寄存器

);


wire [`RegBus] res_u= (divisor_i==0)?-1:dividend_i/divisor_i;
wire [`RegBus] rem_u= (divisor_i==0)?dividend_i:dividend_i%divisor_i;
wire [`RegBus] res_s= (divisor_i==0)?-1:$signed(dividend_i)/$signed(divisor_i);
wire [`RegBus] rem_s= (divisor_i==0)?dividend_i:$signed(dividend_i)-$signed(res_s)*$signed(divisor_i);

always @(*) begin
ready_o = start_i;
case (op_i)
    `INST_DIV:result_o=res_s;
    `INST_DIVU:result_o=res_u;
    `INST_REM:result_o=rem_s;
    `INST_REMU:result_o=rem_u;

    default : result_o=0;
endcase
end
endmodule

