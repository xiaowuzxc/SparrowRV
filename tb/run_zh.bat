@chcp 65001
@echo 全局使用UTF-8编码  
:cmsl
@echo ===============================
@echo 输入编号并回车，执行对应项目 
@echo 编号: 功能--------------工具
@echo 0: 载入inst.txt并仿真---iverilog   
@echo 1: 执行RISC-V ISA测试集-iverilog  
@echo 2: bin文件转为inst.txt 
@echo 3: 载入bin文件并仿真----iverilog  
@echo 4: 显示上一次的仿真波形-gtkwave
@echo 5: 载入inst.txt并仿真---modelsim 
@echo 6: 载入bin文件并仿真----modelsim 
@echo 7: 执行RISC-V ISA测试集-modelsim 
@echo 8: bin文件转为btrm.txt 
@echo 9: bin文件转btrm.txt并仿真 
@echo t: bin文件转串口烧录文件uart.txt 
@echo c: 清理缓存文件  
@echo ===============================

@set /p cmchc=输入命令编号： 

@if %cmchc% == 0 (python tools/isa_test.py sim_rtl & goto cmsl)^
else if %cmchc% == 1 (python tools/isa_test.py all_isa & goto cmsl)^
else if %cmchc% == 2 (python tools/isa_test.py tsr_bin & goto cmsl)^
else if %cmchc% == 3 (python tools/isa_test.py sim_bin & goto cmsl)^
else if %cmchc% == 4 (gtkwave tb.vcd & goto cmsl)^
else if %cmchc% == 5 (python tools/isa_test.py vsim_rtl & goto cmsl)^
else if %cmchc% == 6 (python tools/isa_test.py vsim_bin & goto cmsl)^
else if %cmchc% == 7 (python tools/isa_test.py vsim_isa & goto cmsl)^
else if %cmchc% == 8 (python tools/isa_test.py tsr_isp & goto cmsl)^
else if %cmchc% == 9 (python tools/isa_test.py sim_isp & goto cmsl)^
else if %cmchc% == t (python tools/isa_test.py tsr_app & goto cmsl)^
else if %cmchc% == c (del tb *.lxt *.vcd inst.txt transcript vlog.opt vsim.wlf *.vstf modelsim.ini & rd /s/q work & @echo 缓存文件已清理 & goto cmsl)^
else (echo Err 0: 命令未找到 & goto cmsl)


pause