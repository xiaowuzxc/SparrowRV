@chcp 65001
:cmsl
@echo ============================
@echo 输入编号并回车，执行对应项目
@echo ----------------------------
@echo 0: 载入inst.txt并仿真 
@echo 1: 执行所有ISA测试 
@echo 2: bin文件转为inst.txt 
@echo 3: 载入bin文件并仿真 
@echo 4: 显示上一次的仿真波形
@echo c: 清理缓存文件 
@echo ============================
@set /p cmchc=输入命令编号：

@if %cmchc% == 0 (python tools/isa_test.py sim_rtl & goto cmsl)^
else if %cmchc% == 1 (python tools/isa_test.py all_isa & goto cmsl)^
else if %cmchc% == 2 (python tools/isa_test.py tsr_bin & goto cmsl)^
else if %cmchc% == 3 (python tools/isa_test.py sim_bin & goto cmsl)^
else if %cmchc% == 4 (gtkwave tb.lxt & goto cmsl)^
else if %cmchc% == c (del tb *.lxt inst.txt & @echo 缓存文件已清理 & goto cmsl)^
else (echo Err 0: 命令未找到 & goto cmsl)


pause