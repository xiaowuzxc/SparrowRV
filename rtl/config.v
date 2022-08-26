//系统主频，根据具体场景填写
`define CPU_CLOCK_HZ 25_000_000

//iram指令存储器大小，单位为KB
`define IRam_KB 32 

//sram数据存储器大小，单位为KB
`define SRam_KB 32 

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
