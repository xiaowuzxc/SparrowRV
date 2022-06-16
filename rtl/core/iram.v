`include "defines.v"
module iram (
	input wire clk,
	input wire rst_n,
	input wire [`InstAddrBus] pc_n_i,//读地址
	input wire iram_rd_o,//读使能
	output reg [`InstAddrBus] pc_o,//指令地址
	output wire[`InstBus] inst_o,//指令

	output wire iram_rstn_o,//iram模块阻塞

	input  wire [`MemBus]		iram_cmd_wdata,//写数据
	input  wire [`MemAddrBus] 	iram_cmd_addr ,//地址
	input  wire 				iram_cmd_we   ,//写使能
	input  wire [3:0]			iram_cmd_wem  ,//写掩码
	input  wire 				iram_cmd_valid,//主机请求
	output reg					iram_cmd_ready,//从机准备好
	//S ->M
	output reg [`MemBus]		iram_rsp_rdata,//读数据
	output reg					iram_rsp_valid,//从机请求
	input  wire					iram_rsp_ready,//主机准备好
	output reg					iram_rsp_error//总线错误，备用
);
//port a: iram
//port b: bus

//PC复位
reg rstn_r,rstn_rr;
always @(posedge clk) begin
	rstn_r <= rst_n;
	rstn_rr <= rstn_r;
	if(rstn_rr)
		pc_o <= pc_n_i;
	else
		pc_o <= 32'h0;
end
wire [clogb2(`IRamSize-1)-1:0]addra = rstn_rr ? pc_n_i[31:2] : 0;
assign iram_rstn_o = ~rstn_rr;

//总线交互
reg [clogb2(`IRamSize-1)-1:0]addrb;
reg web,enb;
wire [`MemBus]doutb;
wire cmd_hsk = iram_cmd_valid & iram_cmd_ready;//cmd握手
always @(*) begin
	iram_cmd_ready = iram_cmd_valid;
	iram_rsp_rdata = doutb;
	addrb = iram_cmd_addr[31:2];
	iram_rsp_error = 1'b0;
	enb = cmd_hsk;
	web = iram_cmd_we & enb;
end
always @(posedge clk or negedge rst_n)//rsp控制
if (~rst_n)
	iram_rsp_valid <=1'b0;
else begin
	if (cmd_hsk)
		iram_rsp_valid <=1'b1;
	else if (iram_rsp_valid & iram_rsp_ready)
		iram_rsp_valid <=1'b0;
	else
		iram_rsp_valid <= iram_rsp_valid;
end

dpram #(
	.RAM_WIDTH(32),
	.RAM_DEPTH(`IRamSize)
) inst_dpram (
	.clka   (clk),
	.addra  (addra),
	.addrb  (addrb),
	.dina   (),
	.dinb   (iram_cmd_wdata),
	.wea    (1'b0),
	.web    (web),
	.wema   (),
	.wemb   (iram_cmd_wem),
	.ena    (iram_rd_o | ~rstn_rr),
	.enb    (enb),
	.rsta   (),
	.rstb   (),
	.regcea (),
	.regceb (),
	.douta  (inst_o),
	.doutb  (doutb)
);
function integer clogb2;
	input integer depth;
		for (clogb2=0; depth>0; clogb2=clogb2+1)
			depth = depth >> 1;
endfunction
endmodule