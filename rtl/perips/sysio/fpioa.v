`include "defines.v"
//现场可编程IO阵列
module fpioa (
    input wire clk,
    input wire rst_n,

    input wire[7:0] waddr_i,
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire[7:0] raddr_i,
    input wire rd_i,
    output reg[`MemBus] data_o,
    //通信接口
    input  wire SPI0_SCK ,
    input  wire SPI0_MOSI,
    output wire SPI0_MISO,
    input  wire SPI0_CS  ,
    input  wire SPI1_SCK ,
    input  wire SPI1_MOSI,
    output wire SPI1_MISO,
    input  wire SPI1_CS  ,
    input  wire UART0_TX ,
    output wire UART0_RX ,
    input  wire UART1_TX ,
    output wire UART1_RX ,
    //GPIO
	input wire [31:0]gpio_oe,//输出使能
	input wire [31:0]gpio_out,//输出数据
    output wire [31:0]gpio_in,//输入数据

    //
    inout wire [31:0] fpioa//处理器FPIOA接口
);
/*------------------------------
 * 线网配置方案
 * 32个FPIOA与256个外设端口互联，形成现场可编程IO整列
 * 
 * 1. 输入数据: fpioa -> 外设
 * 32个FPIOA通过选择器，全部相或，输出至唯一外设端口
 * 
 * 2. 输出数据: 外设 -> fpioa; 输出使能: 外设 -> fpioa
 * 256个外设端口，通过256选1多路选择器，输出至唯一FPIOA端口
 * 
 * 特性：每个FPIOA端口，对应唯一外设端口
 * 每个外设端口，可以同时连接多个FPIOA端口
*/

/*------------------------------
 * 外设端口布局
 * 最大支持256个外设端口，外设端口0恒为空端口
 * 端口布局由 [Number/编号] [Function/功能] [描述] 构成，布局列表如下：
 * | Number   | Function        | 描述                      
 * |----------|-----------------|------------------------------------
 * | 0        | DEF_Null        | FPIOA端口默认状态，高阻，输入输出无效
 * | 1        | SPI0_SCK        | SPI0 SCK 时钟输出
 * | 2        | SPI0_MOSI       | SPI0 MOSI 数据输出
 * | 3        | SPI0_MISO       | SPI0 MISO 数据输入
 * | 4        | SPI0_CS         | SPI0 CS 片选输出，低有效
 * | 5        | SPI1_SCK        | SPI1 SCK 时钟输出
 * | 6        | SPI1_MOSI       | SPI1 MOSI 数据输出
 * | 7        | SPI1_MISO       | SPI1 MISO 数据输入
 * | 8        | SPI1_CS         | SPI1 CS 片选输出，低有效
 * | 9        | UART0_TX        | UART0 Tx 串口数据输出
 * | 10       | UART0_RX        | UART0 Rx 串口数据输入
 * | 11       | UART1_TX        | UART1 Tx 串口数据输出
 * | 12       | UART1_RX        | UART1 Rx 串口数据输入
 * | 13       | GPIO0           | 
 * | 14       | GPIO1           | 
 * | 15       | GPIO2           | 
 * | 16       | GPIO3           | 
 * | 17       | GPIO4           | 
 * | 18       | GPIO5           | 
 * | 19       | GPIO6           | 
 * | 20       | GPIO7           | 
 * | 21       | GPIO8           | 
 * | 22       | GPIO9           | 
 * | 23       | GPIO10          | 
 * | 24       | GPIO11          | 
 * | 25       | GPIO12          | 
 * | 26       | GPIO13          | 
 * | 27       | GPIO14          | 
 * | 28       | GPIO15          | 
 * | 29       | GPIO16          | 
 * | 30       | GPIO17          | 
 * | 31       | GPIO18          | 
 * | 32       | GPIO19          | 
 * | 33       | GPIO20          | 
 * | 34       | GPIO21          | 
 * | 35       | GPIO22          | 
 * | 36       | GPIO23          | 
 * | 37       | GPIO24          | 
 * | 38       | GPIO25          | 
 * | 39       | GPIO26          | 
 * | 40       | GPIO27          | 
 * | 41       | GPIO28          | 
 * | 42       | GPIO29          | 
 * | 43       | GPIO30          | 
 * | 44       | GPIO31          | 
 * | 45       |                 | 
 * | 46       |                 | 
 * | 47       |                 | 
 * | 48       |                 | 
 * | 49       |                 | 
 * | 50       |                 | 
 * | 51       |                 | 
 * | 52       |                 | 
 * | 53       |                 | 
 * | 54       |                 | 
 * | 55       |                 | 
 * | 56       |                 | 
 * | 57       |                 | 
 * | 58       |                 | 
 * | 59       |                 | 
 * | 60       |                 | 
 * | 61       |                 | 
 * | 62       |                 | 
 * | 63       |                 | 
 * | 64       |                 | 
 * | 65       |                 | 
 * | 66       |                 | 
 * | 67       |                 | 
 * | 68       |                 | 
 * | 69       |                 | 
 * | 70       |                 | 
 * | 71       |                 | 
 * | 72       |                 | 
 * | 73       |                 | 
 * | 74       |                 | 
 * | 75       |                 | 
 * | 76       |                 | 
 * | 77       |                 | 
 * | 78       |                 | 
 * | 79       |                 | 
 * | 80       |                 | 
 * | 81       |                 | 
 * | 82       |                 | 
 * | 83       |                 | 
 * | 84       |                 | 
 * | 85       |                 | 
 * | 86       |                 | 
 * | 87       |                 | 
 * | 88       |                 | 
 * | 89       |                 | 
 * | 90       |                 | 
 * | 91       |                 | 
 * | 92       |                 | 
 * | 93       |                 | 
 * | 94       |                 | 
 * | 95       |                 | 
 * | 96       |                 | 
 * | 97       |                 | 
 * | 98       |                 | 
 * | 99       |                 | 
 * | 100      |                 | 
 * | 101      |                 | 
 * | 102      |                 | 
 * | 103      |                 | 
 * | 104      |                 | 
 * | 105      |                 | 
 * | 106      |                 | 
 * | 107      |                 | 
 * | 108      |                 | 
 * | 109      |                 | 
 * | 110      |                 | 
 * | 111      |                 | 
 * | 112      |                 | 
 * | 113      |                 | 
 * | 114      |                 | 
 * | 115      |                 | 
 * | 116      |                 | 
 * | 117      |                 | 
 * | 118      |                 | 
 * | 119      |                 | 
 * | 120      |                 | 
 * | 121      |                 | 
 * | 122      |                 | 
 * | 123      |                 | 
 * | 124      |                 | 
 * | 125      |                 | 
 * | 126      |                 | 
 * | 127      |                 | 
 * | 128      |                 | 
 * | 129      |                 | 
 * | 130      |                 | 
 * | 131      |                 | 
 * | 132      |                 | 
 * | 133      |                 | 
 * | 134      |                 | 
 * | 135      |                 | 
 * | 136      |                 | 
 * | 137      |                 | 
 * | 138      |                 | 
 * | 139      |                 | 
 * | 140      |                 | 
 * | 141      |                 | 
 * | 142      |                 | 
 * | 143      |                 | 
 * | 144      |                 | 
 * | 145      |                 | 
 * | 146      |                 | 
 * | 147      |                 | 
 * | 148      |                 | 
 * | 149      |                 | 
 * | 150      |                 | 
 * | 151      |                 | 
 * | 152      |                 | 
 * | 153      |                 | 
 * | 154      |                 | 
 * | 155      |                 | 
 * | 156      |                 | 
 * | 157      |                 | 
 * | 158      |                 | 
 * | 159      |                 | 
 * | 160      |                 | 
 * | 161      |                 | 
 * | 162      |                 | 
 * | 163      |                 | 
 * | 164      |                 | 
 * | 165      |                 | 
 * | 166      |                 | 
 * | 167      |                 | 
 * | 168      |                 | 
 * | 169      |                 | 
 * | 170      |                 | 
 * | 171      |                 | 
 * | 172      |                 | 
 * | 173      |                 | 
 * | 174      |                 | 
 * | 175      |                 | 
 * | 176      |                 | 
 * | 177      |                 | 
 * | 178      |                 | 
 * | 179      |                 | 
 * | 180      |                 | 
 * | 181      |                 | 
 * | 182      |                 | 
 * | 183      |                 | 
 * | 184      |                 | 
 * | 185      |                 | 
 * | 186      |                 | 
 * | 187      |                 | 
 * | 188      |                 | 
 * | 189      |                 | 
 * | 190      |                 | 
 * | 191      |                 | 
 * | 192      |                 | 
 * | 193      |                 | 
 * | 194      |                 | 
 * | 195      |                 | 
 * | 196      |                 | 
 * | 197      |                 | 
 * | 198      |                 | 
 * | 199      |                 | 
 * | 200      |                 | 
 * | 201      |                 | 
 * | 202      |                 | 
 * | 203      |                 | 
 * | 204      |                 | 
 * | 205      |                 | 
 * | 206      |                 | 
 * | 207      |                 | 
 * | 208      |                 | 
 * | 209      |                 | 
 * | 210      |                 | 
 * | 211      |                 | 
 * | 212      |                 | 
 * | 213      |                 | 
 * | 214      |                 | 
 * | 215      |                 | 
 * | 216      |                 | 
 * | 217      |                 | 
 * | 218      |                 | 
 * | 219      |                 | 
 * | 220      |                 | 
 * | 221      |                 | 
 * | 222      |                 | 
 * | 223      |                 | 
 * | 224      |                 | 
 * | 225      |                 | 
 * | 226      |                 | 
 * | 227      |                 | 
 * | 228      |                 | 
 * | 229      |                 | 
 * | 230      |                 | 
 * | 231      |                 | 
 * | 232      |                 | 
 * | 233      |                 | 
 * | 234      |                 | 
 * | 235      |                 | 
 * | 236      |                 | 
 * | 237      |                 | 
 * | 238      |                 | 
 * | 239      |                 | 
 * | 240      |                 | 
 * | 241      |                 | 
 * | 242      |                 | 
 * | 243      |                 | 
 * | 244      |                 | 
 * | 245      |                 | 
 * | 246      |                 | 
 * | 247      |                 | 
 * | 248      |                 | 
 * | 249      |                 | 
 * | 250      |                 | 
 * | 251      |                 | 
 * | 252      |                 | 
 * | 253      |                 | 
 * | 254      |                 | 
 * | 255      |                 | 
 * |----------|-----------------|------------------------------------
 */

/*
 * 配置寄存器
 * 一个FPIOA端口对应一个8bit空间，最大可以连接至256个外设端口
 * 有如下映射关系：
 * 接口fpioa[x] 对应 fpioa_reg[(x+1)*8-1:x*8]*/
reg [7:0]fpioa_reg[0:31];
wire [255:0]fpioa_sw[0:31];//位宽256，对应256个外设。深度32，对应32个IO口
wire [31:0]fpioa_in,fpioa_oe,fpioa_out;//FPIOA输入数据，输出使能，输出数据
wire [255:0]perips_in,perips_oe,perips_out;//外设端口输入数据，输出使能，输出数据
genvar i,j;//for循环指示变量

//外设端口perips_in数据输入
localparam Enable = 1'b1;//开启
localparam Disable = 1'b0;//关闭
//assign = perips_in[0];
assign SPI0_MISO = perips_in[3];
assign SPI1_MISO = perips_in[7];
assign UART0_RX = perips_in[10];
assign UART1_RX = perips_in[12];

//外设端口perips_oe输出使能
assign perips_oe[0]  = Disable;
assign perips_oe[1]  = Enable;
assign perips_oe[2]  = Enable;
assign perips_oe[3]  = Disable;
assign perips_oe[4]  = Enable;
assign perips_oe[5]  = Enable;
assign perips_oe[6]  = Enable;
assign perips_oe[7]  = Disable;
assign perips_oe[8]  = Enable;
assign perips_oe[9]  = Enable;
assign perips_oe[10] = Disable;
assign perips_oe[11] = Enable;
assign perips_oe[12] = Disable;
assign perips_oe[44:13] = gpio_oe;
assign perips_oe[255:45] = 0;


//外设端口perips_out输出数据
assign perips_out[0]  = 1'b0;
assign perips_out[1]  = SPI0_SCK ;
assign perips_out[2]  = SPI0_MOSI;
assign perips_out[3]  = Disable;
assign perips_out[4]  = SPI0_CS  ;
assign perips_out[5]  = SPI1_SCK ;
assign perips_out[6]  = Disable;
assign perips_out[7]  = SPI1_MISO;
assign perips_out[8]  = SPI1_CS  ;
assign perips_out[9]  = UART0_TX ;
assign perips_out[10] = Disable ;
assign perips_out[11] = UART1_TX ;
assign perips_out[12] = Disable ;
assign perips_out[44:13] = gpio_out;
assign perips_out[255:45] = 0;

// 总线接口 写
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        fpioa_reg[ 0] <= 8'h0;
        fpioa_reg[ 1] <= 8'h0;
        fpioa_reg[ 2] <= 8'h0;
        fpioa_reg[ 3] <= 8'h0;
        fpioa_reg[ 4] <= 8'h0;
        fpioa_reg[ 5] <= 8'h0;
        fpioa_reg[ 6] <= 8'h0;
        fpioa_reg[ 7] <= 8'h0;
        fpioa_reg[ 8] <= 8'h0;
        fpioa_reg[ 9] <= 8'h0;
        fpioa_reg[10] <= 8'h0;
        fpioa_reg[11] <= 8'h0;
        fpioa_reg[12] <= 8'h0;
        fpioa_reg[13] <= 8'h0;
        fpioa_reg[14] <= 8'h0;
        fpioa_reg[15] <= 8'h0;
        fpioa_reg[16] <= 8'h0;
        fpioa_reg[17] <= 8'h0;
        fpioa_reg[18] <= 8'h0;
        fpioa_reg[19] <= 8'h0;
        fpioa_reg[20] <= 8'h0;
        fpioa_reg[21] <= 8'h0;
        fpioa_reg[22] <= 8'h0;
        fpioa_reg[23] <= 8'h0;
        fpioa_reg[24] <= 8'h0;
        fpioa_reg[25] <= 8'h0;
        fpioa_reg[26] <= 8'h0;
        fpioa_reg[27] <= 8'h0;
        fpioa_reg[28] <= 8'h0;
        fpioa_reg[29] <= 8'h0;
        fpioa_reg[30] <= 8'h0;
        fpioa_reg[31] <= 8'h0;
    end else begin
        if (we_i == 1'b1) begin
            if(sel_i[0])
                fpioa_reg[waddr_i  ] <= data_i[7:0];
            if(sel_i[1])
                fpioa_reg[waddr_i+1] <= data_i[15:8];
            if(sel_i[2])
                fpioa_reg[waddr_i+2] <= data_i[23:16];
            if(sel_i[3])
                fpioa_reg[waddr_i+3] <= data_i[31:24];
        end 
		else begin

        end
    end
end

// 总线接口 读
always @ (posedge clk) begin
    if (rd_i == 1'b1) begin
        data_o <= {fpioa_reg[raddr_i+3],fpioa_reg[raddr_i+2],fpioa_reg[raddr_i+1],fpioa_reg[raddr_i]};
    end
    else begin
        data_o <= data_o;
    end
end

//连接开关阵列
generate
for ( j=0 ; j<32 ; j=j+1 ) begin//选择FPIOA
    for ( i=0 ; i<256 ; i=i+1 ) begin//选择某一位
        assign fpioa_sw[j][i] = (fpioa_reg[j] == i) ? 1'b1 : 1'b0;
    end
end
endgenerate

//输出使能控制
generate
for ( i=0 ; i<32 ; i=i+1 ) begin
    assign fpioa[i] = fpioa_oe[i]?fpioa_out[i]:1'bz;
end
endgenerate
assign fpioa_in = fpioa;//数据输入

//fpioa_out,fpioa_oe
generate
for ( i=0 ; i<32 ; i=i+1 ) begin
    assign fpioa_out[i] = perips_out[fpioa_reg[i]];
    assign fpioa_oe [i] = perips_oe [fpioa_reg[i]];
end
endgenerate

generate
for ( i=0 ; i<256 ; i=i+1 ) begin
        assign perips_in[i] = fpioa_sw[0][i] & fpioa_in[0]
                            |fpioa_sw[1][i] & fpioa_in[1]
                            |fpioa_sw[2][i] & fpioa_in[2]
                            |fpioa_sw[3][i] & fpioa_in[3]
                            |fpioa_sw[4][i] & fpioa_in[4]
                            |fpioa_sw[5][i] & fpioa_in[5]
                            |fpioa_sw[6][i] & fpioa_in[6]
                            |fpioa_sw[7][i] & fpioa_in[7]
                            |fpioa_sw[8][i] & fpioa_in[8]
                            |fpioa_sw[9][i] & fpioa_in[9]
                            |fpioa_sw[10][i] & fpioa_in[10]
                            |fpioa_sw[11][i] & fpioa_in[11]
                            |fpioa_sw[12][i] & fpioa_in[12]
                            |fpioa_sw[13][i] & fpioa_in[13]
                            |fpioa_sw[14][i] & fpioa_in[14]
                            |fpioa_sw[15][i] & fpioa_in[15]
                            |fpioa_sw[16][i] & fpioa_in[16]
                            |fpioa_sw[17][i] & fpioa_in[17]
                            |fpioa_sw[18][i] & fpioa_in[18]
                            |fpioa_sw[19][i] & fpioa_in[19]
                            |fpioa_sw[20][i] & fpioa_in[20]
                            |fpioa_sw[21][i] & fpioa_in[21]
                            |fpioa_sw[22][i] & fpioa_in[22]
                            |fpioa_sw[23][i] & fpioa_in[23]
                            |fpioa_sw[24][i] & fpioa_in[24]
                            |fpioa_sw[25][i] & fpioa_in[25]
                            |fpioa_sw[26][i] & fpioa_in[26]
                            |fpioa_sw[27][i] & fpioa_in[27]
                            |fpioa_sw[28][i] & fpioa_in[28]
                            |fpioa_sw[29][i] & fpioa_in[29]
                            |fpioa_sw[30][i] & fpioa_in[30]
                            |fpioa_sw[31][i] & fpioa_in[31]
        ;
end
endgenerate


endmodule