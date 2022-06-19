`include "defines.v"
module sparrow_soc (
	input wire clk,    // Clock
	input wire rst_n,  // Asynchronous reset active low
	input wire ex_trap_i//外部中断
);

wire [`MemAddrBus] 	iram_axi_awaddr ;
wire [2:0]			iram_axi_awprot ;
wire 				iram_axi_awvalid;
reg					iram_axi_awready;
wire [`MemBus]	 	iram_axi_wdata  ;
wire [3:0]		 	iram_axi_wstrb  ;
wire 				iram_axi_wvalid ;
reg					iram_axi_wready ;
reg [1:0]			iram_axi_bresp  ;
reg					iram_axi_bvalid ;
wire				iram_axi_bready ;
wire [`MemAddrBus] 	iram_axi_araddr ;
wire [2:0]			iram_axi_arprot ;
wire 				iram_axi_arvalid;
reg					iram_axi_arready;
reg [`MemBus]		iram_axi_rdata  ;
reg [1:0]			iram_axi_rresp  ;
reg					iram_axi_rvalid ;
wire				iram_axi_rready ;

core inst_core
(
	.clk              (clk),
	.rst_n            (rst_n),
	.ex_trap_i        (ex_trap_i),

	.core_axi_awaddr  (iram_axi_awaddr ),
	.core_axi_awprot  (iram_axi_awprot ),
	.core_axi_awvalid (iram_axi_awvalid),
	.core_axi_awready (iram_axi_awready),
	.core_axi_wdata   (iram_axi_wdata  ),
	.core_axi_wstrb   (iram_axi_wstrb  ),
	.core_axi_wvalid  (iram_axi_wvalid ),
	.core_axi_wready  (iram_axi_wready ),
	.core_axi_bresp   (iram_axi_bresp  ),
	.core_axi_bvalid  (iram_axi_bvalid ),
	.core_axi_bready  (iram_axi_bready ),
	.core_axi_araddr  (iram_axi_araddr ),
	.core_axi_arprot  (iram_axi_arprot ),
	.core_axi_arvalid (iram_axi_arvalid),
	.core_axi_arready (iram_axi_arready),
	.core_axi_rdata   (iram_axi_rdata  ),
	.core_axi_rresp   (iram_axi_rresp  ),
	.core_axi_rvalid  (iram_axi_rvalid ),
	.core_axi_rready  (iram_axi_rready ),

	.iram_axi_awaddr  (iram_axi_awaddr ),
	.iram_axi_awprot  (iram_axi_awprot ),
	.iram_axi_awvalid (iram_axi_awvalid),
	.iram_axi_awready (iram_axi_awready),
	.iram_axi_wdata   (iram_axi_wdata  ),
	.iram_axi_wstrb   (iram_axi_wstrb  ),
	.iram_axi_wvalid  (iram_axi_wvalid ),
	.iram_axi_wready  (iram_axi_wready ),
	.iram_axi_bresp   (iram_axi_bresp  ),
	.iram_axi_bvalid  (iram_axi_bvalid ),
	.iram_axi_bready  (iram_axi_bready ),
	.iram_axi_araddr  (iram_axi_araddr ),
	.iram_axi_arprot  (iram_axi_arprot ),
	.iram_axi_arvalid (iram_axi_arvalid),
	.iram_axi_arready (iram_axi_arready),
	.iram_axi_rdata   (iram_axi_rdata  ),
	.iram_axi_rresp   (iram_axi_rresp  ),
	.iram_axi_rvalid  (iram_axi_rvalid ),
	.iram_axi_rready  (iram_axi_rready )
);

endmodule