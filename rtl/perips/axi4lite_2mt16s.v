`include "defines.v"
module axi4lite_2mt16s #(
    parameter s0_en  = 0,
    parameter s1_en  = 0,
    parameter s2_en  = 0,
    parameter s3_en  = 0,
    parameter s4_en  = 0,
    parameter s5_en  = 0,
    parameter s6_en  = 0,
    parameter s7_en  = 0,
    parameter s8_en  = 0,
    parameter s9_en  = 0,
    parameter s10_en = 0,
    parameter s11_en = 0,
    parameter s12_en = 0,
    parameter s13_en = 0,
    parameter s14_en = 0,
    parameter s15_en = 0
)(
	input clk,    // Clock
	input rst_n,  // Asynchronous reset active low
    //AXI4-Lite总线接口 core->m0
    //AW写地址
    input wire [`MemAddrBus]    m0_axi_awaddr ,//写地址
    input wire [2:0]            m0_axi_awprot ,//写保护类型，恒为0
    input wire                  m0_axi_awvalid,//写地址有效
    output reg                  m0_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        m0_axi_wdata  ,//写数据
    input wire [3:0]            m0_axi_wstrb  ,//写数据选通
    input wire                  m0_axi_wvalid ,//写数据有效
    output reg                  m0_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            m0_axi_bresp  ,//写响应
    output reg                  m0_axi_bvalid ,//写响应有效
    input wire                  m0_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    m0_axi_araddr ,//读地址
    input wire [2:0]            m0_axi_arprot ,//读保护类型，恒为0
    input wire                  m0_axi_arvalid,//读地址有效
    output reg                  m0_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        m0_axi_rdata  ,//读数据
    output reg [1:0]            m0_axi_rresp  ,//读响应
    output reg                  m0_axi_rvalid ,//读数据有效
    input wire                  m0_axi_rready ,//读数据准备好
	//AXI4-Lite总线接口 jtag->m1
    //AW写地址
    input wire [`MemAddrBus]    m1_axi_awaddr ,//写地址
    input wire [2:0]            m1_axi_awprot ,//写保护类型，恒为0
    input wire                  m1_axi_awvalid,//写地址有效
    output reg                  m1_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        m1_axi_wdata  ,//写数据
    input wire [3:0]            m1_axi_wstrb  ,//写数据选通
    input wire                  m1_axi_wvalid ,//写数据有效
    output reg                  m1_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            m1_axi_bresp  ,//写响应
    output reg                  m1_axi_bvalid ,//写响应有效
    input wire                  m1_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    m1_axi_araddr ,//读地址
    input wire [2:0]            m1_axi_arprot ,//读保护类型，恒为0
    input wire                  m1_axi_arvalid,//读地址有效
    output reg                  m1_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        m1_axi_rdata  ,//读数据
    output reg [1:0]            m1_axi_rresp  ,//读响应
    output reg                  m1_axi_rvalid ,//读数据有效
    input wire                  m1_axi_rready ,//读数据准备好

	//AXI4-Lite总线接口 m0
    //AW写地址
    input wire [`MemAddrBus]    m1_axi_awaddr ,//写地址
    input wire [2:0]            m1_axi_awprot ,//写保护类型，恒为0
    input wire                  m1_axi_awvalid,//写地址有效
    output reg                  m1_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        m1_axi_wdata  ,//写数据
    input wire [3:0]            m1_axi_wstrb  ,//写数据选通
    input wire                  m1_axi_wvalid ,//写数据有效
    output reg                  m1_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            m1_axi_bresp  ,//写响应
    output reg                  m1_axi_bvalid ,//写响应有效
    input wire                  m1_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    m1_axi_araddr ,//读地址
    input wire [2:0]            m1_axi_arprot ,//读保护类型，恒为0
    input wire                  m1_axi_arvalid,//读地址有效
    output reg                  m1_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        m1_axi_rdata  ,//读数据
    output reg [1:0]            m1_axi_rresp  ,//读响应
    output reg                  m1_axi_rvalid ,//读数据有效
    input wire                  m1_axi_rready //读数据准备好
);

endmodule