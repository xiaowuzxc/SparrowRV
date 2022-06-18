`include "defines.v"
module core (
	input wire clk,
	input wire rst_n,

	input wire ex_trap_i//外部中断
	
);

//-------------定义内部线网--------------
wire [`MemBus] mem_wdata;//存储空间写数据
wire [`MemBus] mem_rdata;//存储空间读数据
wire [`MemAddrBus] mem_addr;//存储空间访问地址
wire [3:0] mem_wem;//存储空间写掩码
wire [`MemBus] sctr_cmd_wdata;//存储空间总线写数据
wire [`MemBus] sctr_rsp_rdata;//存储空间总线读数据
wire [`MemAddrBus] sctr_cmd_addr;  //存储空间总线访问地址
wire [3:0] sctr_cmd_wem;//存储空间总线写掩码
wire [`RegAddrBus] reg_raddr1;//rs1地址
wire [`RegAddrBus] reg_raddr2;//rs2地址
wire [`RegBus] reg_rdata1;//rs1数据
wire [`RegBus] reg_rdata2;//rs2数据
wire [`RegAddrBus] reg_waddr;//rd写地址
wire [`RegBus] reg_wdata;//rd写数据
wire [`InstAddrBus] idex_pc_n;//idex下一条指令PC
wire [`InstAddrBus] trap_pc_n;//中断仲裁后的下一条指令PC
wire [`InstAddrBus] pc;//当前指令的PC
wire [`InstBus] inst;//当前指令
wire [`MemBus] iram_cmd_wdata;
wire [`MemBus] iram_rsp_rdata;
wire [`MemAddrBus] iram_cmd_addr;  
wire [3:0] iram_cmd_wem;
wire [`CsrAddrBus] idex_csr_addr;//idex访问csr地址
wire [`RegBus] idex_csr_wdata;//idex写csr数据
wire [`RegBus] idex_csr_rdata;//idex读csr数据
wire [`CsrAddrBus] trap_csr_addr;//trap访问csr地址
wire [`RegBus] trap_csr_wdata;//trap写csr数据
wire [`RegBus] trap_csr_rdata;//trap读csr数据
wire [`RegBus] div_dividend;//被除数
wire [`RegBus] div_divisor;//除数
wire [2:0] div_op;//除法指令
wire [`RegBus] div_result;//除法结果
wire [`InstAddrBus] mepc;//CSR mepc寄存器
//-------------定义内部线网--------------
sctr inst_sctr
(
	.clk            (clk),
	.rst_n          (rst_n),
	.reg_we_i       (reg_we_idex),
	.csr_we_i       (csr_we_idex),
	.mem_wdata_i    (mem_wdata),
	.mem_addr_i     (mem_addr),
	.mem_we_i       (mem_we),//存储空间写使能
	.mem_wem_i      (mem_wem),
	.mem_en_i       (mem_en),
	.mem_rdata_o    (mem_rdata),
	.reg_we_o       (reg_we_sctr),
	.csr_we_o       (csr_we_sctr),
	.iram_rd_o      (iram_rd),
	.div_start_i    (div_start),
	.div_ready_i    (div_ready),
	.iram_rstn_i    (iram_rstn),
	.trap_in_i      (trap_in),
	.trap_jump_i    (trap_jump),
	.idex_mret_i    (idex_mret),
	.trap_stat_o    (),//中断状态指示
	.sctr_cmd_wdata (sctr_cmd_wdata),
	.sctr_cmd_addr  (sctr_cmd_addr ),
	.sctr_cmd_we    (sctr_cmd_we   ),
	.sctr_cmd_wem   (sctr_cmd_wem  ),
	.sctr_cmd_valid (sctr_cmd_valid),
	.sctr_cmd_ready (sctr_cmd_ready),
	.sctr_rsp_rdata (sctr_rsp_rdata),
	.sctr_rsp_valid (sctr_rsp_valid),
	.sctr_rsp_ready (sctr_rsp_ready),
	.sctr_rsp_error (sctr_rsp_error),
	.hx_valid       (hx_valid)
);

regs inst_regs
(
	.clk         (clk),
	.rst_n       (rst_n),
	.raddr1_i    (reg_raddr1),
	.raddr2_i    (reg_raddr2),
	.rdata1_o    (reg_rdata1),
	.rdata2_o    (reg_rdata2),
	.we_i        (reg_we_sctr),
	.waddr_i     (reg_waddr),
	.wdata_i     (reg_wdata),
	.bus_raddr_i (),
	.bus_data_o  ()
);

iram inst_iram
(
	.clk            (clk),
	.rst_n          (rst_n),
	.pc_n_i         (trap_pc_n),
	.iram_rd_i      (iram_rd),
	.pc_o           (pc),
	.inst_o         (inst),
	.iram_rstn_o    (iram_rstn),
	.iram_cmd_wdata (sctr_cmd_wdata),
	.iram_cmd_addr  (sctr_cmd_addr ),
	.iram_cmd_we    (sctr_cmd_we   ),
	.iram_cmd_wem   (sctr_cmd_wem  ),
	.iram_cmd_valid (sctr_cmd_valid),
	.iram_cmd_ready (sctr_cmd_ready),
	.iram_rsp_rdata (sctr_rsp_rdata),
	.iram_rsp_valid (sctr_rsp_valid),
	.iram_rsp_ready (sctr_rsp_ready),
	.iram_rsp_error (sctr_rsp_error)
);


idex inst_idex
(
	.inst_i       (inst),
	.pc_i         (pc),
	.reg_rdata1_i (reg_rdata1),
	.reg_rdata2_i (reg_rdata2),
	.csr_rdata_i  (idex_csr_rdata),
	.mem_rdata_i  (mem_rdata),
	.dividend_o   (div_dividend),
	.divisor_o    (div_divisor),
	.div_op_o     (div_op),
	.div_start_o  (div_start),
	.div_result_i (div_result),
	.reg_raddr1_o (reg_raddr1),
	.reg_raddr2_o (reg_raddr2),
	.reg_wdata_o  (reg_wdata),
	.reg_we_o     (reg_we_idex),
	.reg_waddr_o  (reg_waddr),
	.csr_wdata_o  (idex_csr_wdata),
	.csr_we_o     (idex_csr_we_idex),
	.csr_addr_o   (idex_csr_addr),
	.mem_wdata_o  (mem_wdata),
	.mem_addr_o   (mem_addr),
	.mem_we_o     (mem_we),
	.mem_wem_o    (mem_wem),
	.mem_en_o     (mem_en),
	.pc_n_o       (idex_pc_n),
	.ecall_o      (ecall_trap),
	.ebreak_o     (ebreak_trap),
	.wfi_o        (wfi_trap),
	.inst_err_o   (inst_err_trap),
	.idex_mret_o  (idex_mret),
	.mepc         (mepc)
);


div inst_div
(
	.clk         (clk),
	.rst_n       (rst_n),
	.dividend_i  (div_dividend),
	.divisor_i   (div_divisor),
	.start_i     (div_start & (~trap_in)),//发生中断，立即停止除法
	.op_i        (div_op),
	.reg_waddr_i (),
	.result_o    (div_result),
	.ready_o     (div_ready),
	.busy_o      (),
	.reg_waddr_o ()
);

csr inst_csr
(
	.clk              (clk),
	.rst_n            (rst_n),
	.idex_csr_we_i    (csr_we_sctr),
	.idex_csr_addr_i  (idex_csr_addr),
	.idex_csr_wdata_i (idex_csr_wdata),
	.idex_csr_rdata_o (idex_csr_rdata),
	.trap_csr_we_i    (trap_csr_we),
	.trap_csr_addr_i  (trap_csr_addr),
	.trap_csr_wdata_i (trap_csr_wdata),
	.trap_csr_rdata_o (trap_csr_rdata),
	.mepc             (mepc),
	.ex_trap_i        (ex_trap_i),
	.ex_trap_o        (pex_trap),
	.tcmp_tarp_o      (ptcmp_tarp),
	.soft_trap_o      (psoft_tarp),
	.mstatus_MIE3     (mstatus_MIE3),
	.hx_valid         (hx_valid)
);

trap inst_trap
(
	.clk          (clk),
	.rst_n        (rst_n),
	.csr_rdata_i  (trap_csr_rdata),
	.csr_wdata_o  (trap_csr_wdata),
	.csr_we_o     (trap_csr_we),
	.csr_addr_o   (trap_csr_addr),
	.ecall_i      (ecall_trap),
	.ebreak_i     (ebreak_trap),
	.wfi_i        (wfi_trap),
	.inst_err_i   (inst_err_trap),
	.pex_trap_i   (pex_trap),
	.ptcmp_tarp_i (ptcmp_tarp),
	.psoft_tarp_i (psoft_tarp),
	.mstatus_MIE3 (mstatus_MIE3),
	.pc_n_i       (idex_pc_n),
	.pc_n_o       (trap_pc_n),
	.trap_jump_o  (trap_jump),
	.trap_in_o    (trap_in)
);

endmodule