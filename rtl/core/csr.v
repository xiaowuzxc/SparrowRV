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

    //中断处理通道
    //输入
    input wire ex_trap_i,//外部中断标志
    //屏蔽后输出
    output reg ex_trap_o,//外部中断信号
    output reg tcmp_trap_o,//定时器中断信号
    output reg soft_trap_o,//软件中断信号
    //全局中断使能标志
    output reg mstatus_MIE3,//全局中断使能，1表示可以中断
    //中断响应指示
    input wire pex_trap_rsp  ,//外部中断响应
    input wire ptcmp_trap_rsp,//定时器响应
    input wire psoft_trap_rsp,//软件中断响应

    input wire hx_valid//回写使能信号


);
wire tcmp_trap;//定时器中断标志
wire soft_trap;//软件中断标志
reg ex_trap_trig  ;//外部中断信号触发
reg tcmp_trap_trig;//定时器中断信号触发
reg soft_trap_trig;//软件中断信号触发
reg ex_trap_trig_r  ;//外部中断信号触发
reg tcmp_trap_trig_r;//定时器中断信号触发
reg soft_trap_trig_r;//软件中断信号触发

reg mstatus_MPIE7;
wire[`RegBus] misa=32'b01_0000_0000000000000_1_000_1_00000000;//RV32IM
reg mie_MEIE11, mie_MTIE7, mie_MSIE3;//中断屏蔽，1使能，0屏蔽
reg [`RegBus] mtvec;//[32:2]中断入口,[1:0]=0
reg [`RegBus] mscratch;//寄存器
reg [`RegBus] mcause;//中断原因，[31]:1中断,0异常，[30:0]:编号
reg [`RegBus] mtval;//异常原因寄存器
wire mip_MEIP11=ex_trap_trig_r;//外部中断等待
wire mip_MTIP7=tcmp_trap_trig_r;//定时器中断等待
wire mip_MSIP3=soft_trap_trig_r;//软件中断等待
reg [`RegBus] msip;//写非0软件中断
reg [2:0] mtrig;//中断触发控制，功能见-中断相关-

reg [63:0] mcycle;//运行周期计数
reg [63:0] minstret;//指令计数
reg [63:0] mtime;//定时器
reg [63:0] mtimecmp;//定时器比较
reg [3 :0] mcctr;//系统控制
//[0]:mcycle使能
//[1]:minstret使能
//[2]:mtime使能
//[3]:soft_rst写1复位
assign soft_rst = mcctr[3];
wire[`RegBus] mvendorid=32'h0;//Vendor ID
wire[`RegBus] marchid=32'd1;//微架构编号
wire[`RegBus] mimpid=32'd1;//硬件实现编号
wire[`RegBus] mhartid=32'h0;//线程编号

//仿真模式专用
reg [7:0] mprints;//仿真标准输出
reg mends;//仿真结束
//仿真模式专用

//---------------中断相关-------------------
/* mtrig是三条中断的触发控制器
 * [0]外部中断触发方式配置，0:高电平，1:上升沿
 * [1]定时器中断触发方式配置，0:高电平，1:上升沿
 * [2]软件中断触发方式配置，0:高电平，1:上升沿
*/
assign tcmp_trap = (mtime >= mtimecmp) ? 1'b1 : 1'b0;//生成定时器中断标志
assign soft_trap = (msip != 32'h0) ? 1'b1 : 1'b0;//生成软件中断标志
//ex_trap_i  外部中断标志
reg ex_trap_r  ;//外部中断信号打一拍
reg tcmp_trap_r;//定时器中断信号打一拍
reg soft_trap_r;//软件中断信号打一拍
always @(posedge clk) begin//打一拍
    ex_trap_r   <= ex_trap_i;
    tcmp_trap_r <= tcmp_trap;
    soft_trap_r <= soft_trap;
end

//中断触发控制
always @(*) begin
    case (mtrig[0])//外部中断
        1'b0: ex_trap_trig = ex_trap_i;
        1'b1: ex_trap_trig =(ex_trap_i && ~ex_trap_r)?1'b1:1'b0;
    endcase
    case (mtrig[1])//定时器中断
        1'b0: tcmp_trap_trig = tcmp_trap;
        1'b1: tcmp_trap_trig =(tcmp_trap && ~tcmp_trap_r)?1'b1:1'b0;
    endcase
    case (mtrig[2])//软件中断
        1'b0: soft_trap_trig = soft_trap;
        1'b1: soft_trap_trig =(soft_trap && ~soft_trap_r)?1'b1:1'b0;
    endcase
end

//中断等待控制
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ex_trap_trig_r   <= 0;
        tcmp_trap_trig_r <= 0;
        soft_trap_trig_r <= 0;
    end
    else begin
        if(ex_trap_trig_r) begin//外部中断等待中
            if(pex_trap_rsp)//外部中断被响应
                ex_trap_trig_r <= 0;//清除等待
            else
                ex_trap_trig_r <= ex_trap_trig_r;//不变
        end
        else begin//没有外部中断
            if(ex_trap_trig)//外部中断被触发
                ex_trap_trig_r <= 1;//开始等待
            else
                ex_trap_trig_r <= ex_trap_trig_r;//不变
        end

        if(tcmp_trap_trig_r) begin//定时器中断等待中
            if(ptcmp_trap_rsp)//定时器中断被响应
                tcmp_trap_trig_r <= 0;//清除等待
            else
                tcmp_trap_trig_r <= tcmp_trap_trig_r;//不变
        end
        else begin//没有定时器中断
            if(tcmp_trap_trig)//定时器中断被触发
                tcmp_trap_trig_r <= 1;//开始等待
            else
                tcmp_trap_trig_r <= tcmp_trap_trig_r;//不变
        end

        if(soft_trap_trig_r) begin//软件中断等待中
            if(psoft_trap_rsp)//软件中断被响应
                soft_trap_trig_r <= 0;//清除等待
            else
                soft_trap_trig_r <= soft_trap_trig_r;//不变
        end
        else begin//没有软件中断
            if(soft_trap_trig)//软件中断被触发
                soft_trap_trig_r <= 1;//开始等待
            else
                soft_trap_trig_r <= soft_trap_trig_r;//不变
        end
    end
end

//中断信号门控
always @(posedge clk or negedge rst_n) begin
    if (~rst_n) begin
        ex_trap_o   <= 0;
        tcmp_trap_o <= 0;
        soft_trap_o <= 0;
    end
    else begin
        if(hx_valid) begin
            ex_trap_o   <= (mie_MEIE11)? ex_trap_trig_r   : 1'b0 ;//经过屏蔽处理
            tcmp_trap_o <= (mie_MTIE7) ? tcmp_trap_trig_r : 1'b0 ;//经过屏蔽处理
            soft_trap_o <= (mie_MSIE3) ? soft_trap_trig_r : 1'b0 ;//经过屏蔽处理
        end
        else begin
            ex_trap_o   <= ex_trap_o   ;
            tcmp_trap_o <= tcmp_trap_o ;
            soft_trap_o <= soft_trap_o ;
        end
    end
end
//---------------中断相关-------------------

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
        mtrig <= 6'h0;
        mscratch <= 0;
        mepc <= 0;
        mcause <= 0;
        mtval <= 0;
        msip <= 0;
        mprints <= 0;
        mends <= 0;
        mtimecmp <= 64'hffff_ffff_ffff_ffff;//比较器复位为最大值，防止误触发
        mcctr <= 4'b0;
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
                `CSR_MTRIG: begin
                    mtrig <= idex_csr_wdata_i[5:0];
                end
                `CSR_MSIP: begin
                    msip <= idex_csr_wdata_i;
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
                    mcctr <= idex_csr_wdata_i[3:0];
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
        `CSR_MTRIG: begin
            idex_csr_rdata_o = {26'h0 , mtrig};
        end
        `CSR_MIP: begin
            idex_csr_rdata_o = {20'h0, mip_MEIP11, 3'h0, mip_MTIP7, 3'h0, mip_MSIP3, 3'h0};
        end
        `CSR_MSIP: begin
            idex_csr_rdata_o = msip;
        end
        `CSR_MPRINTS: begin
            idex_csr_rdata_o = {24'h0 , mprints};
        end
        `CSR_MCYCLE: begin
            idex_csr_rdata_o = mcycle[31:0];
        end
        `CSR_MCYCLEH: begin
            idex_csr_rdata_o = mcycle[63:32];
        end
        `CSR_MINSTRET: begin
            idex_csr_rdata_o = minstret[31:0];
        end
        `CSR_MINSTRETH: begin
            idex_csr_rdata_o = minstret[63:32];
        end
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
            idex_csr_rdata_o = {28'h0, mcctr};
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
