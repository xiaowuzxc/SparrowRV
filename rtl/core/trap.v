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
	input wire ecall_i,
	input wire ebreak_i,
	input wire wfi_i,
	input wire inst_err_i,
	input wire pex_trap_i,
	input wire ptcmp_tarp_i,
	input wire psoft_tarp_i,
	//进中断指示
	output reg trap_in_o//即将进入中断的时候，持续拉高
);

always @(posedge clk) begin
	csr_wdata_o=0;
	csr_we_o=0;
	csr_addr_o=0;
	trap_in_o=0;
end


endmodule : trap