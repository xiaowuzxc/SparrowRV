/*
dpram生成一个双端口RAM，数据位宽为32位，en使能，we写使能，wem字节写使能
提供两种实现方式
1. 行为级建模
例化参数 RAM_SEL = "RTL_MODEL"，由综合器推断，推荐仿真环境/vivado使用
2. 原语例化
例化参数 RAM_SEL = "EG4_32K"，适用安路EG4S20 FPGA
调用了32K BRAM，因此最大深度为16*1k，即生成64kB的存储器
*/
module dpram #(
    localparam RAM_WIDTH = 32,//RAM数据位宽
    parameter RAM_DEPTH = 2048, //RAM深度
    parameter RAM_SEL = "RTL_MODEL", //选择模型
    parameter BRAM_EN = "32K", //选择模型
    parameter MODE = "DP",
    parameter INIT_FILE = "NONE"
) (
    input [clogb2(RAM_DEPTH-1)-1:0] addra,  // Port A address bus, width determined from RAM_DEPTH
    input [clogb2(RAM_DEPTH-1)-1:0] addrb,  // Port B address bus, width determined from RAM_DEPTH
    input [RAM_WIDTH-1:0] dina,           // Port A RAM input data
    input [RAM_WIDTH-1:0] dinb,           // Port B RAM input data
    input clk,                           // Clock
    input wea,                            // Port A write enable
    input web,                            // Port B write enable
    input [3:0] wema,
    input [3:0] wemb,
    input ena,                            // Port A RAM Enable, for additional power savings, disable port when not in use
    input enb,                            // Port B RAM Enable, for additional power savings, disable port when not in use
    output [RAM_WIDTH-1:0] douta,         // Port A RAM output data
    output [RAM_WIDTH-1:0] doutb          // Port B RAM output data
);
reg [RAM_WIDTH-1:0] BRAM [0:RAM_DEPTH-1];
generate
    case(RAM_SEL)
        "RTL_MODEL": begin
            
            reg [RAM_WIDTH-1:0] ram_data_a = {RAM_WIDTH{1'b0}};
            reg [RAM_WIDTH-1:0] ram_data_b = {RAM_WIDTH{1'b0}};
            always @(posedge clk)
                if (ena) begin
                    if (wea) begin
                        if(wema[0])
                            BRAM[addra][7:0] <= dina[7:0];
                        if(wema[1])
                            BRAM[addra][15:8] <= dina[15:8];
                        if(wema[2])
                            BRAM[addra][23:16] <= dina[23:16];
                        if(wema[3])
                            BRAM[addra][31:24] <= dina[31:24];
                    end
                    else begin
                        ram_data_a <= BRAM[addra];
                    end
                end
            always @(posedge clk)
                if (enb) begin
                    if (web) begin
                        if(wemb[0])
                            BRAM[addrb][7:0] <= dinb[7:0];
                        if(wemb[1])
                            BRAM[addrb][15:8] <= dinb[15:8];
                        if(wemb[2])
                            BRAM[addrb][23:16] <= dinb[23:16];
                        if(wemb[3])
                            BRAM[addrb][31:24] <= dinb[31:24];
                    end
                    else begin
                        ram_data_b <= BRAM[addrb];
                    end
                end
            assign douta = ram_data_a;
            assign doutb = ram_data_b;
        end

        "EG4_32K": begin
            EG_LOGIC_BRAM #( 
                .DATA_WIDTH_A(32),
                .DATA_WIDTH_B(32),
                .ADDR_WIDTH_A(clogb2(RAM_DEPTH-1)),
                .ADDR_WIDTH_B(clogb2(RAM_DEPTH-1)),
                .DATA_DEPTH_A(RAM_DEPTH),
                .DATA_DEPTH_B(RAM_DEPTH),
                .BYTE_ENABLE(8),
                .BYTE_A(4),
                .BYTE_B(4),
                .MODE("DP"),
                .REGMODE_A("NOREG"),
                .REGMODE_B("NOREG"),
                .WRITEMODE_A("NORMAL"),
                .WRITEMODE_B("NORMAL"),
                .RESETMODE("SYNC"),
                .IMPLEMENT(BRAM_EN),
                .INIT_FILE(INIT_FILE),
                .FILL_ALL("NONE"))
            inst(
                .dia(dina),
                .dib(dinb),
                .addra(addra),
                .addrb(addrb),
                .cea(ena),
                .ceb(enb),
                .ocea(1'b0),
                .oceb(1'b0),
                .clka(clk),
                .clkb(clk),
                .wea(1'b0),
                .bea({4{wea}} & wema),
                .web(1'b0),
                .beb({4{web}} & wemb),
                .rsta(1'b0),
                .rstb(1'b0),
                .doa(douta),
                .dob(doutb));
        end
    endcase
endgenerate

//  The following function calculates the address width based on specified RAM depth
function integer clogb2;
    input integer depth;
        for (clogb2=0; depth>0; clogb2=clogb2+1)
            depth = depth >> 1;
endfunction


endmodule