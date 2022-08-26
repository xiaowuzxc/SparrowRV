`include "defines.v"
module iram (
    input wire clk,
    input wire rst_n,
    input wire [`InstAddrBus] pc_n_i,//读地址
    input wire iram_rd_i,//读使能
    output reg [`InstAddrBus] pc_o,//指令地址
    output wire[`InstBus] inst_o,//指令

    output reg iram_rstn_o,//iram模块阻塞

    //AXI4-Lite总线接口 Slave
    //AW写地址
    input wire [`MemAddrBus]    iram_axi_awaddr ,//写地址
    input wire [2:0]            iram_axi_awprot ,//写保护类型，恒为0
    input wire                  iram_axi_awvalid,//写地址有效
    output reg                  iram_axi_awready,//写地址准备好
    //W写数据
    input wire [`MemBus]        iram_axi_wdata  ,//写数据
    input wire [3:0]            iram_axi_wstrb  ,//写数据选通
    input wire                  iram_axi_wvalid ,//写数据有效
    output reg                  iram_axi_wready ,//写数据准备好
    //B写响应
    output reg [1:0]            iram_axi_bresp  ,//写响应
    output reg                  iram_axi_bvalid ,//写响应有效
    input wire                  iram_axi_bready ,//写响应准备好
    //AR读地址
    input wire [`MemAddrBus]    iram_axi_araddr ,//读地址
    input wire [2:0]            iram_axi_arprot ,//读保护类型，恒为0
    input wire                  iram_axi_arvalid,//读地址有效
    output reg                  iram_axi_arready,//读地址准备好
    //R读数据
    output reg [`MemBus]        iram_axi_rdata  ,//读数据
    output reg [1:0]            iram_axi_rresp  ,//读响应
    output reg                  iram_axi_rvalid ,//读数据有效
    input wire                  iram_axi_rready //读数据准备好
);
/* iram是指令存储器，位于处理器内核，由2部分构成
 * 
 * 1. 用户指令存储区
 * 起始地址: 0x0000_0000
 * 长度: 由宏定义文件配置
 * 用途: 存储需要执行的指令
 * 
 * 2. 在系统编程ISP区
 * 起始地址: 0x0800_0000
 * 长度: 
 * 用途: 复位后PC指向此处，完成数据搬移、UART烧录
 * 
*/

wire [31:0] rst_addr = `RstPC;//复位地址
wire [clogb2(`IRamSize-1)-1:0]addra = iram_rstn_o ? rst_addr[clogb2(`IRamSize-1)-1+2:2] : pc_n_i[clogb2(`IRamSize-1)-1+2:2];
wire [`MemBus]douta,doutia;
reg axi_ram_sel,inst_ram_sel;//根据地址选择访问的存储器
assign inst_o = pc_o[27]?doutia:douta;

//AXI4L总线交互
reg [clogb2(`IRamSize-1)-1:0]addrb;
reg web,enb;
reg [3:0] wemb;
wire [`MemBus]doutb,doutib;
reg [`MemBus]dinb;
wire axi_whsk = iram_axi_awvalid & iram_axi_wvalid;//写通道握手
wire axi_rhsk = iram_axi_arvalid & (~iram_axi_rvalid | (iram_axi_rvalid & iram_axi_rready)) & ~axi_whsk;//读通道握手,没有读响应
reg wei;//AXI写ISP
reg [`MemBus]dini;//AXI写ISP

//PC复位
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        iram_rstn_o <= 1'b1;
        pc_o <= `RstPC;
    end 
    else begin
        iram_rstn_o <= 1'b0;
        if(iram_rd_i) begin
            pc_o <= pc_n_i;
            inst_ram_sel <= pc_n_i[27];
        end
        else begin
            pc_o <= pc_o;
            inst_ram_sel <= inst_ram_sel;
        end
    end
end

always @(posedge clk or negedge rst_n)//读响应控制
if (~rst_n)
    iram_axi_rvalid <=1'b0;
else begin
    if (axi_rhsk)
        iram_axi_rvalid <=1'b1;
    else if (iram_axi_rvalid & iram_axi_rready)
        iram_axi_rvalid <=1'b0;
    else
        iram_axi_rvalid <= iram_axi_rvalid;
end

always @(posedge clk) begin
    if(axi_rhsk)
        axi_ram_sel <= iram_axi_araddr[27];
    else
        axi_ram_sel <= axi_ram_sel;
end

always @(*) begin
    iram_axi_awready = axi_whsk;//写地址数据同时准备好
    iram_axi_wready = axi_whsk;//写地址数据同时准备好
    iram_axi_rdata = axi_ram_sel?doutib:doutb;//读数据
    iram_axi_arready = axi_rhsk;//读地址握手
    iram_axi_bvalid = 1'b1;
    iram_axi_bresp = 2'b00;//响应
    iram_axi_rresp = 2'b00;//响应
    dinb = iram_axi_wdata;
    dini = iram_axi_wdata;//AXI写ISP
    enb = axi_whsk | axi_rhsk;
    wemb = iram_axi_wstrb;
    if(axi_whsk) begin//写握手
        addrb = iram_axi_awaddr[clogb2(`IRamSize-1)-1+2:2];
        if(iram_axi_awaddr[27]==1'b0) begin//AXI写ISP
            web = 1;//AXI写iram
            wei = 0;
        end
        else begin
            web = 0;
            wei = 1;//AXI写ISP
        end
    end
    else begin
        web = 0;
        wei = 0;
        addrb = iram_axi_araddr[clogb2(`IRamSize-1)-1+2:2];
    end
end

`ifdef EG4_FPGA //如果定义了宏
    localparam RAM_SEL="EG4_32K";//启用EG4原语
`else 
    localparam RAM_SEL="RTL_MODEL";//否则使用行为级建模
`endif

dpram #(
    .RAM_DEPTH(`IRamSize),
    .RAM_SEL(RAM_SEL)
) inst_dpram (
    .clk    (clk),
    .addra  (addra[clogb2(`IRamSize-1)-1:0]),
    .addrb  (addrb[clogb2(`IRamSize-1)-1:0]),
    .dina   (0),
    .dinb   (dinb),
    .wea    (1'b0),
    .web    (web),
    .wema   (4'h0),
    .wemb   (wemb),
    .ena    (iram_rd_i | iram_rstn_o),
    .enb    (enb),
    .douta  (douta),
    .doutb  (doutb)
);


bootrom #(
    .RAM_DEPTH(1024)
) inst_bootrom (
    .clk   (clk),
    .wen   (wei),
    .din   (dini),
    .ena   (iram_rd_i | iram_rstn_o),
    .addra (addra[clogb2(1024-1)-1:0]),
    .douta (doutia),
    .enb   (enb),
    .addrb (addrb[clogb2(1024-1)-1:0]),
    .doutb (doutib)
);



function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction
endmodule