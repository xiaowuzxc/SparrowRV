/*--------------------------------
 *          参数配置区           
 *--------------------------------*/
//系统主频，根据具体场景填写
`define CPU_CLOCK_HZ 25_000_000

//iram指令存储器大小，单位为KB
`define IRam_KB 32 

//sram数据存储器大小，单位为KB
`define SRam_KB 32 

//复位后从bootrom(1'b0) / iram(1'b1) 取指
`define PW_BOOT 1'b0

//Vendor ID
`define MVENDORID_NUM 32'h0

//微架构编号
`define MARCHID_NUM 32'd1

//硬件实现编号
`define MIMPID_NUM 32'd1

//线程编号
`define MHARTID_NUM 32'd0

/*--------------------------------
 *          参数配置区           
 *--------------------------------*/


/*--------------------------------
 *          开关配置区           
 *--------------------------------*/
//启用M扩展(乘法/除法)
`define RV32_M_ISA

//启用mcycle运行周期计数器
`define CSR_MCYCLE_EN

//启用minstret指令计数器
`define CSR_MINSTRET_EN

//启用安路EG4 FPGA原语生成BRAM
//`define EG4_FPGA 

//启用w25模型，会降低仿真速度
//`define Flash25 

/*--------------------------------
 *          开关配置区           
 *--------------------------------*/