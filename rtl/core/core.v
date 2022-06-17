`include "defines.v"
module core (
	input wire clk,
	input wire rst_n,

	input wire ex_trap_i//外部中断
	
);

//-------------定义内部线网--------------
wire [`MemBus] mem_wdata;
wire [`MemBus] mem_rdata;
wire [`MemAddrBus] mem_addr;
wire [3:0] mem_wem;
wire [`MemBus] sctr_cmd_wdata;
wire [`MemBus] sctr_rsp_rdata;
wire [`MemAddrBus] sctr_cmd_addr;  
wire [3:0] sctr_cmd_wem;
wire [`RegAddrBus] reg_raddr1;
wire [`RegAddrBus] reg_raddr2;
wire [`RegBus] reg_rdata1;
wire [`RegBus] reg_rdata2;
wire [`RegAddrBus] reg_waddr;
wire [`RegBus] reg_wdata;
wire [`InstAddrBus] pc_n;
wire [`InstAddrBus] pc;
wire [`InstBus] inst;
wire [`MemBus] iram_cmd_wdata;
wire [`MemBus] iram_rsp_rdata;
wire [`MemAddrBus] iram_cmd_addr;  
wire [3:0] iram_cmd_wem;
wire [`CsrAddrBus] idex_csr_addr;
wire [`RegBus] idex_csr_wdata;
wire [`RegBus] idex_csr_rdata;
wire [`RegBus] div_dividend;
wire [`RegBus] div_divisor;
wire [2:0] div_op;
wire [`RegBus] div_result;
wire [`InstAddrBus] mepc;
//-------------定义内部线网--------------
sctr inst_sctr
(
	.clk            (clk),
	.rst_n          (rst_n),
	.reg_we_i       (reg_we_idex),
	.csr_we_i       (csr_we_idex),
	.mem_wdata_i    (mem_wdata),
	.mem_addr_i     (mem_addr),
	.mem_we_i       (mem_we),
	.mem_wem_i      (mem_wem),
	.mem_en_i       (mem_en),
	.mem_rdata_o    (mem_rdata),
	.reg_we_o       (reg_we_sctr),
	.csr_we_o       (csr_we_sctr),
	.iram_rd_o      (iram_rd),
	.div_start_i    (div_start),
	.div_ready_i    (div_ready),
	.iram_rstn_i    (iram_rstn),
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
	.pc_n_i         (pc_n),
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
	.pc_n_o       (pc_n),
	.ecall_o      (),
	.ebreak_o     (),
	.wfi_o        (),
	.inst_err_o   (),
	.mepc         (mepc)
);


div inst_div
(
	.clk         (clk),
	.rst_n       (rst_n),
	.dividend_i  (div_dividend),
	.divisor_i   (div_divisor),
	.start_i     (div_start),
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
	.trap_csr_we_i    (1'b0),
	.trap_csr_addr_i  (12'h0),
	.trap_csr_wdata_i (32'h0),
	.trap_csr_rdata_o (),
	.mepc             (mepc),
	.ex_trap_i        (ex_trap_i),
	.ex_trap_o        (),
	.tcmp_tarp_o      (),
	.soft_trap_o      (),
	.hx_valid         (hx_valid)
);


endmodule