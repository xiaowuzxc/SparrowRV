`include "defines.v"

//CSR寄存器组
module csr(

    input wire clk,
    input wire rst_n,

    //idex操作通道
    input wire idex_csr_we_i,//写使能
    input wire[`CsrAddrBus] idex_csr_addr_i,//地址
    input wire[`RegBus] idex_csr_wdata_i,//写数据，同步
    output reg[`RegBus] idex_csr_rdata_o,//读数据，异步

    //trap操作通道
    input wire trap_csr_we_i,
    input wire[`CsrAddrBus] trap_csr_addr_i,
    input wire[`RegBus] trap_csr_wdata_i,
    output reg[`RegBus] trap_csr_rdata_o,

    //直接输出通道
    output reg [`RegBus] mepc,//CSR mepc寄存器
    output wire soft_rst,//mcctr[3]软件复位
    output wire insts_sel_o,//选择从哪取指

    //中断处理通道
    //输入
    input wire ex_trap_valid_i,//外部中断标志
    //屏蔽后输出
    output reg ex_trap_valid_o,//外部中断信号
    output reg tcmp_trap_valid_o,//定时器中断信号
    output reg soft_trap_valid_o,//软件中断信号
    //全局中断使能标志
    output reg mstatus_MIE3,//全局中断使能，1表示可以中断

    input wire hx_valid//回写使能信号

);
wire tcmp_trap_valid;//定时器中断请求
wire soft_trap_valid;//软件中断请求


//---CSR寄存器定义---
reg mstatus_MPIE7;//mstatus状态寄存器
`ifdef RV32_M_ISA
    wire[`RegBus] misa=32'b01_0000_0000000000000_1_000_1_00000000;//RV32IM ISA寄存器
`else
    wire[`RegBus] misa=32'b01_0000_0000000000000_0_000_1_00000000;//RV32I ISA寄存器
`endif
reg mie_MEIE11, mie_MTIE7, mie_MSIE3;//中断屏蔽，1使能，0屏蔽
reg [`RegBus] mtvec;//[32:2]中断入口,[1:0]=0
reg [`RegBus] mscratch;//mscratch寄存器
reg [`RegBus] mcause;//中断原因，[31]:1中断,0异常，[30:0]:编号
reg [`RegBus] mtval;//异常原因寄存器
wire mip_MEIP11=ex_trap_valid_i;//MEIP11外部中断等待
wire mip_MTIP7=tcmp_trap_valid;//MEIP7定时器中断等待
wire mip_MSIP3=soft_trap_valid;//MEIP3软件中断等待
reg msip;//软件中断，写1软件中断
`ifdef CSR_MCYCLE_EN
    reg [63:0] mcycle;//运行周期计数
`endif
`ifdef CSR_MINSTRET_EN
    reg [63:0] minstret;//指令计数
`endif
reg [63:0] mtime;//定时器
reg [63:0] mtimecmp;//定时器比较
wire[`RegBus] mvendorid = `MVENDORID_NUM;//Vendor ID
wire[`RegBus] marchid   = `MARCHID_NUM;//微架构编号
wire[`RegBus] mimpid    = `MIMPID_NUM;//硬件实现编号
wire[`RegBus] mhartid   = `MHARTID_NUM;//线程编号

//---自定义CSR---
reg [4 :0] mcctr;//系统控制
//[0]:mcycle使能
//[1]:minstret使能
//[2]:mtime使能
//[3]:soft_rst写1复位
//[4]:从bootrom 0 /iram 1 取指
//---仿真模式专用---
reg [7:0] mprints;//仿真标准输出
reg mends;//仿真结束

//---生成信号---
assign tcmp_trap_valid = (mtime >= mtimecmp) ? 1'b1 : 1'b0;//生成定时器中断标志
assign soft_trap_valid = msip;//生成软件中断标志
assign soft_rst = mcctr[3];//软件复位
assign insts_sel_o = mcctr[4];//选择取指来源
//中断信号门控
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ex_trap_valid_o   <= 0;
        tcmp_trap_valid_o <= 0;
        soft_trap_valid_o <= 0;
    end
    else begin
        if(hx_valid) begin
            ex_trap_valid_o   <= (mie_MEIE11)? ex_trap_valid_i : 1'b0 ;//经过屏蔽处理
            tcmp_trap_valid_o <= (mie_MTIE7) ? tcmp_trap_valid : 1'b0 ;//经过屏蔽处理
            soft_trap_valid_o <= (mie_MSIE3) ? soft_trap_valid : 1'b0 ;//经过屏蔽处理
        end
        else begin
            ex_trap_valid_o   <= ex_trap_valid_o   ;
            tcmp_trap_valid_o <= tcmp_trap_valid_o ;
            soft_trap_valid_o <= soft_trap_valid_o ;
        end
    end
end
//---------------中断相关-------------------
`ifdef CSR_MCYCLE_EN
// mcycle
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mcycle <= 64'h0;
    end 
    else begin
        if(idex_csr_we_i & (idex_csr_addr_i==`CSR_MCYCLE | idex_csr_addr_i==`CSR_MCYCLEH))
            if(idex_csr_addr_i==`CSR_MCYCLE)
                mcycle <= {mcycle[63:32] , idex_csr_wdata_i};
            else 
                if(idex_csr_addr_i==`CSR_MCYCLEH)
                    mcycle <= {idex_csr_wdata_i , mcycle[31:0]};
                else
                    mcycle <= mcycle + 64'b1;
        else
            if(mcctr[0])
                mcycle <= mcycle + 64'b1;
    end
end
`endif

`ifdef CSR_MINSTRET_EN
// minstret
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        minstret <= 64'h0;
    end 
    else begin
        if(idex_csr_we_i & (idex_csr_addr_i==`CSR_MINSTRET | idex_csr_addr_i==`CSR_MINSTRETH))
            if(idex_csr_addr_i==`CSR_MINSTRET)
                minstret <= {minstret[63:32] , idex_csr_wdata_i};
            else 
                if(idex_csr_addr_i==`CSR_MINSTRETH)
                    minstret <= {idex_csr_wdata_i , minstret[31:0]};
                else
                    minstret <= minstret + 64'b1;
        else
            if(hx_valid & mcctr[1])
                minstret <= minstret + 64'b1;
    end
end
`endif

// mtime
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mtime <= 64'h0;
    end 
    else begin
        if(idex_csr_we_i & (idex_csr_addr_i==`CSR_MTIME | idex_csr_addr_i==`CSR_MTIMEH))
            if(idex_csr_addr_i==`CSR_MTIME)
                mtime <= {mtime[63:32] , idex_csr_wdata_i};
            else 
                if(idex_csr_addr_i==`CSR_MTIMEH)
                    mtime <= {idex_csr_wdata_i , mtime[31:0]};
                else
                    mtime <= mtime + 64'b1;
        else
            if(mcctr[2])
                mtime <= mtime + 64'b1;
    end
end


//写CSR
always @ (posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        mstatus_MIE3 <= 1'b0;
        mstatus_MPIE7 <= 1'b0;
        mie_MEIE11 <= 1'b0;
        mie_MTIE7 <= 1'b0;
        mie_MSIE3 <= 1'b0;
        mtvec <= 32'h0;
        mscratch <= 0;
        mepc <= 0;
        mcause <= 0;
        mtval <= 0;
        msip <= 0;
        mprints <= 0;
        mends <= 0;
        mtimecmp <= 64'hffff_ffff_ffff_ffff;//比较器复位为最大值，防止误触发
        mcctr <= {`INSTS_SEL, 4'h0};
    end else begin
        if (idex_csr_we_i) begin //优先idex写
            case (idex_csr_addr_i)
                `CSR_MSTATUS: begin
                    mstatus_MIE3 <= idex_csr_wdata_i[3];
                    mstatus_MPIE7 <= idex_csr_wdata_i[7];
                end
                `CSR_MIE: begin
                    mie_MEIE11 <= idex_csr_wdata_i[11];
                    mie_MTIE7 <=idex_csr_wdata_i[7];
                    mie_MSIE3 <= idex_csr_wdata_i[3];
                end
                `CSR_MTVEC: begin
                    mtvec <= idex_csr_wdata_i;
                end
                `CSR_MSCRATCH: begin
                    mscratch <= idex_csr_wdata_i;
                end
                `CSR_MEPC: begin
                    mepc <= idex_csr_wdata_i;
                end
                `CSR_MCAUSE: begin
                    mcause <= idex_csr_wdata_i;
                end
                `CSR_MTVAL: begin
                    mtval <= idex_csr_wdata_i;
                end
                `CSR_MSIP: begin
                    msip <= idex_csr_wdata_i[0];
                end
                `CSR_MPRINTS: begin
                    mprints <= idex_csr_wdata_i[7:0];
                end
                `CSR_MENDS: begin
                    mends <= idex_csr_wdata_i[0];
                end
                `CSR_MTIMECMP: begin
                    mtimecmp[31:0] <= idex_csr_wdata_i;
                end
                `CSR_MTIMECMPH: begin
                    mtimecmp[63:32] <= idex_csr_wdata_i;
                end
                `CSR_MCCTR: begin
                    mcctr <= idex_csr_wdata_i[4:0];
                end

                default: begin

                end
            endcase
        end 
        else if (trap_csr_we_i) begin//trap写
            case (trap_csr_addr_i)
                `CSR_MSTATUS: begin
                    mstatus_MIE3 <= trap_csr_wdata_i[3];
                    mstatus_MPIE7 <= trap_csr_wdata_i[7];
                end
                `CSR_MTVEC: begin
                    mtvec <= trap_csr_wdata_i;
                end
                `CSR_MEPC: begin
                    mepc <= trap_csr_wdata_i;
                end
                `CSR_MCAUSE: begin
                    mcause <= trap_csr_wdata_i;
                end
                `CSR_MTVAL: begin
                    mtval <= trap_csr_wdata_i;
                end

                default: begin

                end
            endcase
        end
    end
end

//idex读
always @ (*) begin
    case (idex_csr_addr_i)
        `CSR_MSTATUS: begin
            idex_csr_rdata_o = {19'h0, 2'b11 , 3'h0 , mstatus_MPIE7, 3'h0, mstatus_MIE3, 3'h0};
        end
        `CSR_MISA: begin
            idex_csr_rdata_o = misa;
        end
        `CSR_MIE: begin
            idex_csr_rdata_o = {20'h0, mie_MEIE11, 3'h0, mie_MTIE7, 3'h0, mie_MSIE3, 3'h0};
        end
        `CSR_MTVEC: begin
            idex_csr_rdata_o = mtvec;
        end
        `CSR_MSCRATCH: begin
            idex_csr_rdata_o = mscratch;
        end
        `CSR_MEPC: begin
            idex_csr_rdata_o = mepc;
        end
        `CSR_MCAUSE: begin
            idex_csr_rdata_o = mcause;
        end
        `CSR_MTVAL: begin
            idex_csr_rdata_o = mtval;
        end
        `CSR_MIP: begin
            idex_csr_rdata_o = {20'h0, mip_MEIP11, 3'h0, mip_MTIP7, 3'h0, mip_MSIP3, 3'h0};
        end
        `CSR_MSIP: begin
            idex_csr_rdata_o = {31'd0, msip};
        end
        `ifdef CSR_MCYCLE_EN
        `CSR_MCYCLE: begin
            idex_csr_rdata_o = mcycle[31:0];
        end
        `CSR_MCYCLEH: begin
            idex_csr_rdata_o = mcycle[63:32];
        end
        `endif
        `ifdef CSR_MINSTRET_EN
        `CSR_MINSTRET: begin
            idex_csr_rdata_o = minstret[31:0];
        end
        `CSR_MINSTRETH: begin
            idex_csr_rdata_o = minstret[63:32];
        end
        `endif
        `CSR_MTIME: begin
            idex_csr_rdata_o = mtime[31:0];
        end
        `CSR_MTIMEH: begin
            idex_csr_rdata_o = mtime[63:32];
        end
        `CSR_MTIMECMP: begin
            idex_csr_rdata_o = mtimecmp[31:0];
        end
        `CSR_MTIMECMPH: begin
            idex_csr_rdata_o = mtimecmp[63:32];
        end
        `CSR_MCCTR: begin
            idex_csr_rdata_o = {27'h0, mcctr};
        end
        `CSR_MVENDORID: begin
            idex_csr_rdata_o = mvendorid;
        end
        `CSR_MARCHID: begin
            idex_csr_rdata_o = marchid;
        end
        `CSR_MIMPID: begin
            idex_csr_rdata_o = mimpid;
        end
        `CSR_MHARTID: begin
            idex_csr_rdata_o = mhartid;
        end 
        default: begin
            idex_csr_rdata_o = 32'h0;
        end
    endcase
end

//trap读
always @ (*) begin
    case (trap_csr_addr_i)
        `CSR_MSTATUS: begin
            trap_csr_rdata_o = {24'h0, mstatus_MPIE7, 3'h0, mstatus_MIE3, 3'h0};
        end
        `CSR_MTVEC: begin
            trap_csr_rdata_o = mtvec;
        end
        `CSR_MEPC: begin
            trap_csr_rdata_o = mepc;
        end
        `CSR_MCAUSE: begin
            trap_csr_rdata_o = mcause;
        end
        `CSR_MTVAL: begin
            trap_csr_rdata_o = mtval;
        end

        default: begin
            trap_csr_rdata_o = 32'h0;
        end
    endcase
end

always @(posedge clk) begin
    if(idex_csr_we_i & (idex_csr_addr_i == `CSR_MPRINTS))
        $write("%c", idex_csr_wdata_i);
end
endmodule
