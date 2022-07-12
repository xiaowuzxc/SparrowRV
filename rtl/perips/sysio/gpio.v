`include "defines.v"
module gpio (
    input wire clk,
    input wire rst_n,

    input wire[7:0] waddr_i,
    input wire[`MemBus] data_i,
    input wire[3:0] sel_i,
    input wire we_i,
    input wire[7:0] raddr_i,
    input wire rd_i,
    output reg[`MemBus] data_o,

	output wire [31:0]gpio_oe,//输出使能
	output wire [31:0]gpio_out,//输出数据
	output wire [15:0]gpio_trap_irq,//gpio中断
    input wire [31:0]gpio_in//输入数据
);

// 寄存器(偏移)地址
localparam GPIO_DIN = 8'h0;//输入数据
localparam GPIO_OPT = 8'h4;//输出数据
localparam GPIO_OEC = 8'h8;//输出使能
localparam GPIO_TAI = 8'hc;//外部中断控制

// 输入数据，只读
// [31:0]对应GPIO0-31的当前的高低电平
reg [31:0] gpio_din;

// 输出数据，读写
// [31:0]对应GPIO0-31的输出值
reg [31:0] gpio_opt;

// 输出使能，读写
// [31:0]对应GPIO0-31的输出使能状态
reg [31:0] gpio_oec;

// 输出数据，读写
// GPIO0-15的外部中断使能与控制
// [x*2]:  GPIOx中断使能
// [x*2+1]:GPIOx中断为 1:高电平, 2:低电平触发
reg [31:0] gpio_tai;

// 总线接口 写
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        gpio_opt <= 32'h0;
        gpio_oec <= 32'h0;
		gpio_tai <= 32'h0;
    end else begin
        if (we_i == 1'b1) begin
            case (waddr_i[3:0])
                GPIO_DIN: ;
				GPIO_OPT: gpio_opt <= data_i;
				GPIO_OEC: gpio_oec <= data_i;
				GPIO_TAI: gpio_tai <= data_i;
                default: ;
            endcase
        end 
		else begin

        end
    end
end

// 总线接口 读
always @ (posedge clk) begin
    if (rd_i == 1'b1) begin
        case (raddr_i[3:0])
                GPIO_DIN: data_o <= gpio_din;
				GPIO_OPT: data_o <= gpio_opt;
				GPIO_OEC: data_o <= gpio_oec;
				GPIO_TAI: data_o <= gpio_tai;
            default: begin
                data_o <= 32'h0;
            end
        endcase
    end
    else begin
        data_o <= data_o;
    end
end

//输入打拍
reg [31:0] gpio_in_r;
always @(posedge clk) begin
	gpio_in_r <= gpio_in;
	gpio_din  <= gpio_in_r;
end

assign gpio_oe = gpio_oec;// 输出使能
assign gpio_out = gpio_opt;// 输出数据

//GPIO中断
genvar i;
for (i = 0; i<16; i=i+1) begin
    assign gpio_trap_irq[i] = gpio_tai[i*2] ? (gpio_tai[i*2+1] ? gpio_din[i] : ~gpio_din[i]) : 1'b0;
end
endmodule