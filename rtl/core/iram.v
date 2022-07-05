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
//port a: iram
//port b: axi

//PC复位
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        iram_rstn_o <= 1'b1;
        pc_o <= `RstPC;
    end 
    else begin
        iram_rstn_o <= 1'b0;
        if(iram_rd_i)
            pc_o <= pc_n_i;
        else
            pc_o <= pc_o ;    
    end
end
wire [31:0] rst_addr = `RstPC;
wire [clogb2(`IRamSize-1)-1:0]addra = iram_rstn_o ? rst_addr[31:2] : pc_n_i[31:2];

//AXI4L总线交互
reg [clogb2(`IRamSize-1)-1:0]addrb;
reg web,enb;
reg [3:0] wemb;
wire [`MemBus]doutb;
reg [`MemBus]dinb;
wire axi_whsk = iram_axi_awvalid & iram_axi_wvalid;//写通道握手
wire axi_rhsk = iram_axi_arvalid & (~iram_axi_rvalid | (iram_axi_rvalid & iram_axi_rready)) & ~axi_whsk;//读通道握手,没有读响应

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

always @(*) begin
    iram_axi_awready = axi_whsk;//写地址数据同时准备好
    iram_axi_wready = axi_whsk;//写地址数据同时准备好
    iram_axi_rdata = doutb;//读数据
    iram_axi_arready = axi_rhsk;//读地址握手
    iram_axi_bvalid = 1'b1;
    iram_axi_bresp = 2'b00;//响应
    iram_axi_rresp = 2'b00;//响应
    if(axi_whsk) begin//写握手
        addrb = iram_axi_awaddr[31:2];
        web = 1;
    end
    else begin
        if (axi_rhsk) begin//读握手
            addrb = iram_axi_araddr[31:2];
            web = 0;
        end
        else begin
            addrb = 0;
            web = 0;
        end
    end
    dinb = iram_axi_wdata;
    enb = axi_whsk | axi_rhsk;
    wemb = iram_axi_wstrb;
end


dpram #(
    .RAM_WIDTH(32),
    .RAM_DEPTH(`IRamSize)
) inst_dpram (
    .clka   (clk),
    .addra  (addra),
    .addrb  (addrb),
    .dina   (0),
    .dinb   (dinb),
    .wea    (1'b0),
    .web    (web),
    .wema   (4'h0),
    .wemb   (wemb),
    .ena    (iram_rd_i | iram_rstn_o),
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