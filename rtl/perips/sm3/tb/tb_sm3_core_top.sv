`timescale 1ns / 1ns
`define SM3_INPT_DW_32
`define INPT_DW    32
`define INPT_DW1        (`INPT_DW - 1)
`define INPT_BYTE_DW1   (`INPT_DW/8 - 1)
`define INPT_BYTE_DW    (`INPT_BYTE_DW1 + 1)
module tb_sm3_core_top;
localparam max_cnt = 32768;

localparam [1:0]            INPT_WORD_NUM               =   2'd1;
bit [31:0]                  urand_num;



int i;
bit [7:0] data[1050];//TODO buff length limit the inpt data length 
bit [31:0] res[8];
logic [63:0]cnt;
int stat_test_cnt;
int stat_ok_cnt;
int stat_fail_cnt;
bit [60:0]  sm3_inpt_byte_num;

//interface
logic                       clk;
logic                       rst_n;
logic [`INPT_DW1:0]         msg_inpt_d;
logic [`INPT_BYTE_DW1:0]    msg_inpt_vld_byte;
logic                       msg_inpt_vld;
logic                       msg_inpt_lst;
logic                       msg_inpt_rdy;

logic                       pad_otpt_ena;
logic [`INPT_DW1:0]         pad_otpt_d;
logic                       pad_otpt_lst;
logic                       pad_otpt_vld;

logic [`INPT_DW1:0]         expnd_otpt_wj; 
logic [`INPT_DW1:0]         expnd_otpt_wjj; 
logic                       expnd_otpt_lst;
logic                       expnd_otpt_vld; 

logic [255:0]               cmprss_otpt_res;
logic                       cmprss_otpt_vld;

//sm3_core_top
sm3_core_top U_sm3_core_top(

    .clk                (clk              ),
    .rst_n              (rst_n            ),
    .msg_inpt_d         (msg_inpt_d       ),
    .msg_inpt_vld_byte  (msg_inpt_vld_byte),
    .msg_inpt_vld       (msg_inpt_vld     ),
    .msg_inpt_lst       (msg_inpt_lst     ),
    .msg_inpt_rdy       (msg_inpt_rdy     ),
    .cmprss_otpt_res    (cmprss_otpt_res  ),
    .cmprss_otpt_vld    (cmprss_otpt_vld  )

);

initial begin
    clk                     = 0;
    rst_n                   = 0;
    msg_inpt_d            = 0;
    msg_inpt_vld_byte     = 0;
    msg_inpt_vld          = 0;
    msg_inpt_lst          = 0;

    #100;
    rst_n                   =1;

    `ifdef SM3_INPT_DW_32
        $display("LOG: run SM3 example under 32bit mode.");
    `elsif SM3_INPT_DW_64
        $display("LOG: run SM3 example under 64bit mode.");
    `endif



        $display("LOG: vcd wave dump enable.");
        $dumpfile("tb.vcd");
        $dumpvars(2, tb_sm3_core_top);

    cnt=0;
    @(posedge clk); 
    
    msg_inpt_vld_byte = 4'b1111;
    while (cnt<max_cnt) begin
        @(posedge clk);
        #1;
        if(cnt>=max_cnt)
            msg_inpt_lst      = 1'b0;
        if(msg_inpt_rdy) begin
            msg_inpt_vld      = 1'b1;
            msg_inpt_d        = 32'h6162_6300;
            if(cnt==max_cnt-1)
                msg_inpt_lst      = 1'b1;
            else
                msg_inpt_lst      = 1'b0;
        end
        else begin
            msg_inpt_vld      = 1'b0;
            msg_inpt_d        = 32'h0000_0000;
        end
    end
    msg_inpt_vld      = 1'b0;
    msg_inpt_lst      = 1'b0;
    msg_inpt_d      = 0;
    @(posedge clk);
    msg_inpt_lst      = 1'b0;
    wait(cmprss_otpt_vld);
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    $stop;
end

always @(posedge clk) begin
    if(msg_inpt_vld)
        cnt=cnt+1;
end


always #5 clk = ~clk; 



endmodule