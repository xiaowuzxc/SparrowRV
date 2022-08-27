 # 退出之前仿真
quit -sim

# #建立新的工程库
#vlib work
#
# # 映射逻辑库到物理目录
#vmap work work
#
# # 编译文件
#vlog +incdir+./../rtl/  +define+MODELSIM +define+ISA_TEST ./tb_core.sv
#vlog +incdir+./../rtl/  ./../rtl/core/*.v
#vlog +incdir+./../rtl/  ./../rtl/soc/*.v
#vlog +incdir+./../rtl/  ./../rtl/perips/*.v
#vlog +incdir+./../rtl/  ./../rtl/perips/sysio/*.v
#vlog +incdir+./../rtl/  ./../rtl/jtag/*.v
#vlog +incdir+./../rtl/  ./../rtl/*.v

vsim -voptargs=+acc work.tb_core
run -all
exit
