module rstc (
	input wire clk,
	input wire hard_rst_n,  //硬件复位信号，低电平有效
	input wire soft_rst_en,
	input wire jtag_rst_en,
	output reg rst_n,
	output reg jtag_rst_n
);
reg [2:0] hw_cnt,soft_cnt;//硬件、软件复位计数器
reg hw_sta,soft_sta;//硬件、软件复位状态
reg hard_rst_r,hard_rst_rr;



always @(posedge clk) begin
	hard_rst_r <= hard_rst_n;
	hard_rst_rr <= hard_rst_r;
end

always @(posedge clk) begin
	if(~hard_rst_rr) begin
		hw_cnt <= 0;
		hw_sta <= 1'b0;
	end
	else begin
		if(hw_cnt >= 3'h6) begin
			hw_cnt <= hw_cnt;
			hw_sta <= 1'b1;
		end
		else begin
			hw_cnt <= hw_cnt + 1;
			hw_sta <= 1'b0;
		end
	end
end

always @(posedge clk) begin
	if(soft_rst_en | jtag_rst_en | ~hard_rst_rr) begin
		soft_cnt <= 0;
		soft_sta <= 1'b0;
	end
	else begin
		if(soft_cnt >= 3'h5) begin
			soft_cnt <= soft_cnt;
			soft_sta <= 1'b1;
		end
		else begin
			soft_cnt <= soft_cnt + 1;
			soft_sta <= 1'b0;
		end
	end
end

always @(*) begin
	rst_n = hw_sta & soft_sta;//复位处理器
	jtag_rst_n = hw_sta;//复位JTAG
end
endmodule