`timescale 1ns / 1ns
`include "sm3_cfg.v"
//////////////////////////////////////////////////////////////////////////////////
// Author:        ljgibbs / lf_gibbs@163.com
// Create Date: 2020/07/29
// Design Name: sm3
// Module Name: tb_sm3_core_top
// Description:
//      SM3 顶层 testbench
//          测试 sm3_core_top 
// Dependencies: 
//      inc/sm3_cfg.v
// Revision:
// Revision 0.01 - File Created
// Revision 0.02 - Pass random test with c model
// Revision 0.03 - Pass random test with c model (64bit)
// Revision 0.03 - Add more macro control
//////////////////////////////////////////////////////////////////////////////////
module tb_sm3_core_top;

`ifdef SM3_INPT_DW_32
    localparam [1:0]            INPT_WORD_NUM               =   2'd1;
    bit [31:0]                  urand_num;
`elsif SM3_INPT_DW_64
    localparam [1:0]            INPT_WORD_NUM               =   2'd2;
    bit [63:0]                  urand_num;
`endif



int i;
bit [7:0] data[1050];//TODO buff length limit the inpt data length 
bit [31:0] res[8];
logic [63:0]cnt;
int stat_test_cnt;
int stat_ok_cnt;
int stat_fail_cnt;
bit [60:0]  sm3_inpt_byte_num;

//interface
sm3_if sm3if();

//sm3_core_top
sm3_core_top U_sm3_core_top(
`ifdef EPICSIM
    .clk                (sm3if.clk              ),
    .rst_n              (sm3if.rst_n            ),
    .msg_inpt_d         (sm3if.msg_inpt_d       ),
    .msg_inpt_vld_byte  (sm3if.msg_inpt_vld_byte),
    .msg_inpt_vld       (sm3if.msg_inpt_vld     ),
    .msg_inpt_lst       (sm3if.msg_inpt_lst     ),
    .msg_inpt_rdy       (sm3if.msg_inpt_rdy     ),
    .cmprss_otpt_res    (sm3if.cmprss_otpt_res  ),
    .cmprss_otpt_vld    (sm3if.cmprss_otpt_vld  )
`else
    sm3if
`endif
);

initial begin
    sm3if.clk                     = 0;
    sm3if.rst_n                   = 0;
    sm3if.msg_inpt_d            = 0;
    sm3if.msg_inpt_vld_byte     = 0;
    sm3if.msg_inpt_vld          = 0;
    sm3if.msg_inpt_lst          = 0;

    #100;
    sm3if.rst_n                   =1;

    `ifdef SM3_INPT_DW_32
        $display("LOG: run SM3 example under 32bit mode.");
    `elsif SM3_INPT_DW_64
        $display("LOG: run SM3 example under 64bit mode.");
    `endif

    `ifdef C_MODEL_ENABLE
        $display("LOG: C reference model enable.");
    `endif

    `ifdef VCD_DUMP_ENABLE
        $display("LOG: vcd wave dump enable.");
        $dumpfile("tb.vcd");
        $dumpvars(2, tb_sm3_core_top);
    `endif
    cnt=0;
    @(posedge sm3if.clk); 
    
    sm3if.msg_inpt_vld_byte = 4'b1111;
    while (cnt<=32768) begin
        @(posedge sm3if.clk);
        #1;
        if(sm3if.msg_inpt_rdy) begin
            sm3if.msg_inpt_vld      = 1'b1;
            sm3if.msg_inpt_d        = 32'h6162_6300;
        end
        else begin
            sm3if.msg_inpt_vld      = 1'b0;
            sm3if.msg_inpt_d        = 32'h0000_0000;
        end
    end
    sm3if.msg_inpt_vld      = 1'b0;
    sm3if.msg_inpt_lst      = 1'b1;
    sm3if.msg_inpt_d      = 0;
    @(posedge sm3if.clk);
    sm3if.msg_inpt_lst      = 1'b0;
    wait(sm3if.cmprss_otpt_vld);
    @(posedge sm3if.clk);
    @(posedge sm3if.clk);
    @(posedge sm3if.clk);
    $stop;
end

always @(posedge sm3if.clk) begin
    if(sm3if.msg_inpt_vld)
        cnt=cnt+1;
end


always #5 sm3if.clk = ~sm3if.clk; 



endmodule