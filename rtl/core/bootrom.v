`include "defines.v"
module bootrom #(
    parameter RAM_DEPTH = 65536
)(
	input wire clk,

    input wire wen,
    input wire [`InstBus]din,

	input wire ena,
	input wire [clogb2(RAM_DEPTH-1)-1:0]addra,
	output reg [`InstBus]douta,
	input wire enb,
	input wire [clogb2(RAM_DEPTH-1)-1:0]addrb,
	output reg [`InstBus]doutb
);
reg [`InstBus] BRAM [0:RAM_DEPTH-1];

always @(posedge clk)
    if (ena) 
        douta <= BRAM[addra];
    else
		douta <= douta;

always @(posedge clk)
    if (enb) 
        doutb <= BRAM[addrb];
    else
		doutb <= doutb;
//AXI写
always @(posedge clk) begin
    if(wen)
        BRAM[addrb] <= din;
end

//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction

`ifdef EG4_FPGA //如果定义了宏
initial begin
    $readmemh ("../../tb/btrm.txt", BRAM);
end
`endif

endmodule