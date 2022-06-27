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

	//AXI4-Lite总线接口 s0
    //AW写地址
    input wire [`MemAddrBus]    s0_axi_awaddr ,//写地址
    input wire [2:0]            s0_axi_awprot ,//写保护类型，恒为0
    input wire                  s0_axi_awvalid,//写地址有效
    output reg                  s0_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s0_axi_wdata  ,//写数据
    input wire [3:0]            s0_axi_wstrb  ,//写数据选通
    input wire                  s0_axi_wvalid ,//写数据有效
    output reg                  s0_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s0_axi_bresp  ,//写响应
    output reg                  s0_axi_bvalid ,//写响应有效
    input wire                  s0_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s0_axi_araddr ,//读地址
    input wire [2:0]            s0_axi_arprot ,//读保护类型，恒为0
    input wire                  s0_axi_arvalid,//读地址有效
    output reg                  s0_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s0_axi_rdata  ,//读数据
    output reg [1:0]            s0_axi_rresp  ,//读响应
    output reg                  s0_axi_rvalid ,//读数据有效
    input wire                  s0_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s1
    //AW写地址
    input wire [`MemAddrBus]    s1_axi_awaddr ,//写地址
    input wire [2:0]            s1_axi_awprot ,//写保护类型，恒为0
    input wire                  s1_axi_awvalid,//写地址有效
    output reg                  s1_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s1_axi_wdata  ,//写数据
    input wire [3:0]            s1_axi_wstrb  ,//写数据选通
    input wire                  s1_axi_wvalid ,//写数据有效
    output reg                  s1_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s1_axi_bresp  ,//写响应
    output reg                  s1_axi_bvalid ,//写响应有效
    input wire                  s1_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s1_axi_araddr ,//读地址
    input wire [2:0]            s1_axi_arprot ,//读保护类型，恒为0
    input wire                  s1_axi_arvalid,//读地址有效
    output reg                  s1_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s1_axi_rdata  ,//读数据
    output reg [1:0]            s1_axi_rresp  ,//读响应
    output reg                  s1_axi_rvalid ,//读数据有效
    input wire                  s1_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s2
    //AW写地址
    input wire [`MemAddrBus]    s2_axi_awaddr ,//写地址
    input wire [2:0]            s2_axi_awprot ,//写保护类型，恒为0
    input wire                  s2_axi_awvalid,//写地址有效
    output reg                  s2_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s2_axi_wdata  ,//写数据
    input wire [3:0]            s2_axi_wstrb  ,//写数据选通
    input wire                  s2_axi_wvalid ,//写数据有效
    output reg                  s2_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s2_axi_bresp  ,//写响应
    output reg                  s2_axi_bvalid ,//写响应有效
    input wire                  s2_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s2_axi_araddr ,//读地址
    input wire [2:0]            s2_axi_arprot ,//读保护类型，恒为0
    input wire                  s2_axi_arvalid,//读地址有效
    output reg                  s2_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s2_axi_rdata  ,//读数据
    output reg [1:0]            s2_axi_rresp  ,//读响应
    output reg                  s2_axi_rvalid ,//读数据有效
    input wire                  s2_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s3
    //AW写地址
    input wire [`MemAddrBus]    s3_axi_awaddr ,//写地址
    input wire [2:0]            s3_axi_awprot ,//写保护类型，恒为0
    input wire                  s3_axi_awvalid,//写地址有效
    output reg                  s3_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s3_axi_wdata  ,//写数据
    input wire [3:0]            s3_axi_wstrb  ,//写数据选通
    input wire                  s3_axi_wvalid ,//写数据有效
    output reg                  s3_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s3_axi_bresp  ,//写响应
    output reg                  s3_axi_bvalid ,//写响应有效
    input wire                  s3_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s3_axi_araddr ,//读地址
    input wire [2:0]            s3_axi_arprot ,//读保护类型，恒为0
    input wire                  s3_axi_arvalid,//读地址有效
    output reg                  s3_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s3_axi_rdata  ,//读数据
    output reg [1:0]            s3_axi_rresp  ,//读响应
    output reg                  s3_axi_rvalid ,//读数据有效
    input wire                  s3_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s4
    //AW写地址
    input wire [`MemAddrBus]    s4_axi_awaddr ,//写地址
    input wire [2:0]            s4_axi_awprot ,//写保护类型，恒为0
    input wire                  s4_axi_awvalid,//写地址有效
    output reg                  s4_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s4_axi_wdata  ,//写数据
    input wire [3:0]            s4_axi_wstrb  ,//写数据选通
    input wire                  s4_axi_wvalid ,//写数据有效
    output reg                  s4_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s4_axi_bresp  ,//写响应
    output reg                  s4_axi_bvalid ,//写响应有效
    input wire                  s4_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s4_axi_araddr ,//读地址
    input wire [2:0]            s4_axi_arprot ,//读保护类型，恒为0
    input wire                  s4_axi_arvalid,//读地址有效
    output reg                  s4_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s4_axi_rdata  ,//读数据
    output reg [1:0]            s4_axi_rresp  ,//读响应
    output reg                  s4_axi_rvalid ,//读数据有效
    input wire                  s4_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s5
    //AW写地址
    input wire [`MemAddrBus]    s5_axi_awaddr ,//写地址
    input wire [2:0]            s5_axi_awprot ,//写保护类型，恒为0
    input wire                  s5_axi_awvalid,//写地址有效
    output reg                  s5_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s5_axi_wdata  ,//写数据
    input wire [3:0]            s5_axi_wstrb  ,//写数据选通
    input wire                  s5_axi_wvalid ,//写数据有效
    output reg                  s5_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s5_axi_bresp  ,//写响应
    output reg                  s5_axi_bvalid ,//写响应有效
    input wire                  s5_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s5_axi_araddr ,//读地址
    input wire [2:0]            s5_axi_arprot ,//读保护类型，恒为0
    input wire                  s5_axi_arvalid,//读地址有效
    output reg                  s5_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s5_axi_rdata  ,//读数据
    output reg [1:0]            s5_axi_rresp  ,//读响应
    output reg                  s5_axi_rvalid ,//读数据有效
    input wire                  s5_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s6
    //AW写地址
    input wire [`MemAddrBus]    s6_axi_awaddr ,//写地址
    input wire [2:0]            s6_axi_awprot ,//写保护类型，恒为0
    input wire                  s6_axi_awvalid,//写地址有效
    output reg                  s6_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s6_axi_wdata  ,//写数据
    input wire [3:0]            s6_axi_wstrb  ,//写数据选通
    input wire                  s6_axi_wvalid ,//写数据有效
    output reg                  s6_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s6_axi_bresp  ,//写响应
    output reg                  s6_axi_bvalid ,//写响应有效
    input wire                  s6_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s6_axi_araddr ,//读地址
    input wire [2:0]            s6_axi_arprot ,//读保护类型，恒为0
    input wire                  s6_axi_arvalid,//读地址有效
    output reg                  s6_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s6_axi_rdata  ,//读数据
    output reg [1:0]            s6_axi_rresp  ,//读响应
    output reg                  s6_axi_rvalid ,//读数据有效
    input wire                  s6_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s7
    //AW写地址
    input wire [`MemAddrBus]    s7_axi_awaddr ,//写地址
    input wire [2:0]            s7_axi_awprot ,//写保护类型，恒为0
    input wire                  s7_axi_awvalid,//写地址有效
    output reg                  s7_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s7_axi_wdata  ,//写数据
    input wire [3:0]            s7_axi_wstrb  ,//写数据选通
    input wire                  s7_axi_wvalid ,//写数据有效
    output reg                  s7_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s7_axi_bresp  ,//写响应
    output reg                  s7_axi_bvalid ,//写响应有效
    input wire                  s7_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s7_axi_araddr ,//读地址
    input wire [2:0]            s7_axi_arprot ,//读保护类型，恒为0
    input wire                  s7_axi_arvalid,//读地址有效
    output reg                  s7_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s7_axi_rdata  ,//读数据
    output reg [1:0]            s7_axi_rresp  ,//读响应
    output reg                  s7_axi_rvalid ,//读数据有效
    input wire                  s7_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s8
    //AW写地址
    input wire [`MemAddrBus]    s8_axi_awaddr ,//写地址
    input wire [2:0]            s8_axi_awprot ,//写保护类型，恒为0
    input wire                  s8_axi_awvalid,//写地址有效
    output reg                  s8_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s8_axi_wdata  ,//写数据
    input wire [3:0]            s8_axi_wstrb  ,//写数据选通
    input wire                  s8_axi_wvalid ,//写数据有效
    output reg                  s8_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s8_axi_bresp  ,//写响应
    output reg                  s8_axi_bvalid ,//写响应有效
    input wire                  s8_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s8_axi_araddr ,//读地址
    input wire [2:0]            s8_axi_arprot ,//读保护类型，恒为0
    input wire                  s8_axi_arvalid,//读地址有效
    output reg                  s8_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s8_axi_rdata  ,//读数据
    output reg [1:0]            s8_axi_rresp  ,//读响应
    output reg                  s8_axi_rvalid ,//读数据有效
    input wire                  s8_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s9
    //AW写地址
    input wire [`MemAddrBus]    s9_axi_awaddr ,//写地址
    input wire [2:0]            s9_axi_awprot ,//写保护类型，恒为0
    input wire                  s9_axi_awvalid,//写地址有效
    output reg                  s9_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s9_axi_wdata  ,//写数据
    input wire [3:0]            s9_axi_wstrb  ,//写数据选通
    input wire                  s9_axi_wvalid ,//写数据有效
    output reg                  s9_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s9_axi_bresp  ,//写响应
    output reg                  s9_axi_bvalid ,//写响应有效
    input wire                  s9_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s9_axi_araddr ,//读地址
    input wire [2:0]            s9_axi_arprot ,//读保护类型，恒为0
    input wire                  s9_axi_arvalid,//读地址有效
    output reg                  s9_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s9_axi_rdata  ,//读数据
    output reg [1:0]            s9_axi_rresp  ,//读响应
    output reg                  s9_axi_rvalid ,//读数据有效
    input wire                  s9_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s10
    //AW写地址
    input wire [`MemAddrBus]    s10_axi_awaddr ,//写地址
    input wire [2:0]            s10_axi_awprot ,//写保护类型，恒为0
    input wire                  s10_axi_awvalid,//写地址有效
    output reg                  s10_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s10_axi_wdata  ,//写数据
    input wire [3:0]            s10_axi_wstrb  ,//写数据选通
    input wire                  s10_axi_wvalid ,//写数据有效
    output reg                  s10_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s10_axi_bresp  ,//写响应
    output reg                  s10_axi_bvalid ,//写响应有效
    input wire                  s10_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s10_axi_araddr ,//读地址
    input wire [2:0]            s10_axi_arprot ,//读保护类型，恒为0
    input wire                  s10_axi_arvalid,//读地址有效
    output reg                  s10_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s10_axi_rdata  ,//读数据
    output reg [1:0]            s10_axi_rresp  ,//读响应
    output reg                  s10_axi_rvalid ,//读数据有效
    input wire                  s10_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s11
    //AW写地址
    input wire [`MemAddrBus]    s11_axi_awaddr ,//写地址
    input wire [2:0]            s11_axi_awprot ,//写保护类型，恒为0
    input wire                  s11_axi_awvalid,//写地址有效
    output reg                  s11_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s11_axi_wdata  ,//写数据
    input wire [3:0]            s11_axi_wstrb  ,//写数据选通
    input wire                  s11_axi_wvalid ,//写数据有效
    output reg                  s11_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s11_axi_bresp  ,//写响应
    output reg                  s11_axi_bvalid ,//写响应有效
    input wire                  s11_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s11_axi_araddr ,//读地址
    input wire [2:0]            s11_axi_arprot ,//读保护类型，恒为0
    input wire                  s11_axi_arvalid,//读地址有效
    output reg                  s11_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s11_axi_rdata  ,//读数据
    output reg [1:0]            s11_axi_rresp  ,//读响应
    output reg                  s11_axi_rvalid ,//读数据有效
    input wire                  s11_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s12
    //AW写地址
    input wire [`MemAddrBus]    s12_axi_awaddr ,//写地址
    input wire [2:0]            s12_axi_awprot ,//写保护类型，恒为0
    input wire                  s12_axi_awvalid,//写地址有效
    output reg                  s12_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s12_axi_wdata  ,//写数据
    input wire [3:0]            s12_axi_wstrb  ,//写数据选通
    input wire                  s12_axi_wvalid ,//写数据有效
    output reg                  s12_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s12_axi_bresp  ,//写响应
    output reg                  s12_axi_bvalid ,//写响应有效
    input wire                  s12_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s12_axi_araddr ,//读地址
    input wire [2:0]            s12_axi_arprot ,//读保护类型，恒为0
    input wire                  s12_axi_arvalid,//读地址有效
    output reg                  s12_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s12_axi_rdata  ,//读数据
    output reg [1:0]            s12_axi_rresp  ,//读响应
    output reg                  s12_axi_rvalid ,//读数据有效
    input wire                  s12_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s13
    //AW写地址
    input wire [`MemAddrBus]    s13_axi_awaddr ,//写地址
    input wire [2:0]            s13_axi_awprot ,//写保护类型，恒为0
    input wire                  s13_axi_awvalid,//写地址有效
    output reg                  s13_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s13_axi_wdata  ,//写数据
    input wire [3:0]            s13_axi_wstrb  ,//写数据选通
    input wire                  s13_axi_wvalid ,//写数据有效
    output reg                  s13_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s13_axi_bresp  ,//写响应
    output reg                  s13_axi_bvalid ,//写响应有效
    input wire                  s13_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s13_axi_araddr ,//读地址
    input wire [2:0]            s13_axi_arprot ,//读保护类型，恒为0
    input wire                  s13_axi_arvalid,//读地址有效
    output reg                  s13_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s13_axi_rdata  ,//读数据
    output reg [1:0]            s13_axi_rresp  ,//读响应
    output reg                  s13_axi_rvalid ,//读数据有效
    input wire                  s13_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s14
    //AW写地址
    input wire [`MemAddrBus]    s14_axi_awaddr ,//写地址
    input wire [2:0]            s14_axi_awprot ,//写保护类型，恒为0
    input wire                  s14_axi_awvalid,//写地址有效
    output reg                  s14_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s14_axi_wdata  ,//写数据
    input wire [3:0]            s14_axi_wstrb  ,//写数据选通
    input wire                  s14_axi_wvalid ,//写数据有效
    output reg                  s14_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s14_axi_bresp  ,//写响应
    output reg                  s14_axi_bvalid ,//写响应有效
    input wire                  s14_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s14_axi_araddr ,//读地址
    input wire [2:0]            s14_axi_arprot ,//读保护类型，恒为0
    input wire                  s14_axi_arvalid,//读地址有效
    output reg                  s14_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s14_axi_rdata  ,//读数据
    output reg [1:0]            s14_axi_rresp  ,//读响应
    output reg                  s14_axi_rvalid ,//读数据有效
    input wire                  s14_axi_rready ,//读数据准备好
    //AXI4-Lite总线接口 s15
    //AW写地址
    input wire [`MemAddrBus]    s15_axi_awaddr ,//写地址
    input wire [2:0]            s15_axi_awprot ,//写保护类型，恒为0
    input wire                  s15_axi_awvalid,//写地址有效
    output reg                  s15_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        s15_axi_wdata  ,//写数据
    input wire [3:0]            s15_axi_wstrb  ,//写数据选通
    input wire                  s15_axi_wvalid ,//写数据有效
    output reg                  s15_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            s15_axi_bresp  ,//写响应
    output reg                  s15_axi_bvalid ,//写响应有效
    input wire                  s15_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    s15_axi_araddr ,//读地址
    input wire [2:0]            s15_axi_arprot ,//读保护类型，恒为0
    input wire                  s15_axi_arvalid,//读地址有效
    output reg                  s15_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        s15_axi_rdata  ,//读数据
    output reg [1:0]            s15_axi_rresp  ,//读响应
    output reg                  s15_axi_rvalid ,//读数据有效
    input wire                  s15_axi_rready //读数据准备好
);

//线网定义
reg m0_rvaild,m1_rvaild;//m0,m1读操作占有总线标志
wire m0_wvalid = m0_axi_awvalid & m0_axi_wvalid & ~m1_rvaild;//写地址数据都有效，m1读没有占据总线
wire m0_avalid = m0_axi_arvalid & ~m1_rvaild;//读地址有效，m1读没有占据总线



endmodule