@chcp 65001
:cmsl
@echo ============================
@echo 输入编号并回车，执行对应项目
@echo ----------------------------
@echo 0: 载入inst.txt并仿真 
@echo 1: 执行所有ISA测试 
@echo 2: bin文件转为inst.txt 
@echo c: 清理缓存文件 
@echo ============================
@set /p cmchc=输入命令编号：

@if %cmchc% == 0 (iverilog -g2005-sv -o tb -y ../rtl/core/ -I ../rtl/core/ tb_core.sv & echo 开始执行单个ISA测试)^
else if %cmchc% == 1 (python tools/isa_test.py all_isa & goto cmsl)^
else if %cmchc% == 2 (python tools/isa_test.py tsr_bin & goto cmsl)^
else if %cmchc% == c (del tb *.lxt inst.txt & @echo 缓存文件已清理 & goto cmsl)^
else (echo 命令未找到 & goto cmsl)


@echo 生成波形
vvp -n tb -lxt2
@echo 显示波形
gtkwave tb.lxt
goto cmsl
pause