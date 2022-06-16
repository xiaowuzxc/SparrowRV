
`include "defines.v"

// 通用寄存器模块
module regs(

	input wire clk,
	input wire rst_n,

	// core 
	//r
	input wire[`RegAddrBus] raddr1_i,     // 读寄存器1地址
	input wire[`RegAddrBus] raddr2_i,     // 读寄存器2地址
	output reg[`RegBus] rdata1_o,         // 读寄存器1数据
	output reg[`RegBus] rdata2_o,         // 读寄存器2数据
	//w
	input wire we_i,                      // 写寄存器使能
	input wire[`RegAddrBus] waddr_i,      // 写寄存器地址
	input wire[`RegBus] wdata_i,          // 写寄存器数据

	// bus 
	input wire[`RegAddrBus] bus_raddr_i,  // 读寄存器地址
	output reg[`RegBus] bus_data_o       // 读寄存器数据

	);

	reg[`RegBus] regs[31:0];

	// 写寄存器
	always @ (posedge clk or negedge rst_n) begin
		if (~rst_n) begin
			regs[1] <= 32'h0;
			regs[2] <= 32'h0;
			regs[3] <= 32'h0;
			regs[4] <= 32'h0;
			regs[5] <= 32'h0;
			regs[6] <= 32'h0;
			regs[7] <= 32'h0;
			regs[8] <= 32'h0;
			regs[9] <= 32'h0;
			regs[10] <= 32'h0;
			regs[11] <= 32'h0;
			regs[12] <= 32'h0;
			regs[13] <= 32'h0;
			regs[14] <= 32'h0;
			regs[15] <= 32'h0;
			regs[16] <= 32'h0;
			regs[17] <= 32'h0;
			regs[18] <= 32'h0;
			regs[19] <= 32'h0;
			regs[20] <= 32'h0;
			regs[21] <= 32'h0;
			regs[22] <= 32'h0;
			regs[23] <= 32'h0;
			regs[24] <= 32'h0;
			regs[25] <= 32'h0;
			regs[26] <= 32'h0;
			regs[27] <= 32'h0;
			regs[28] <= 32'h0;
			regs[29] <= 32'h0;
			regs[30] <= 32'h0;
			regs[31] <= 32'h0;
		end
		else begin
			if ((we_i == 1) && (waddr_i != 0)) begin
				regs[waddr_i] <= wdata_i;
			end
		end
	end

	// 读寄存器1
	always @ (*) begin
		if (raddr1_i == 0) begin
			rdata1_o = 0;
		end else begin
			rdata1_o = regs[raddr1_i];
		end
	end

	// 读寄存器2
	always @ (*) begin
		if (raddr2_i == 0) begin
			rdata2_o = 0;
		end else begin
			rdata2_o = regs[raddr2_i];
		end
	end

	// bus读寄存器
	always @ (*) begin
		if (bus_raddr_i == 0) begin
			bus_data_o = 0;
		end else begin
			bus_data_o = regs[bus_raddr_i];
		end
	end

endmodule
