@chcp 65001
:cmsl
@echo ============================
@echo 输入编号并回车，执行对应项目
@echo ----------------------------
@echo 0:执行处理器的仿真
@echo 1:执行小麻雀内核仿真
@echo c:清理缓存文件
@echo ============================
@set /p cmchc=输入命令编号：

@if %cmchc% == 0 (iverilog -g2005-sv -o tb -y ../rtl/core/ -I ../rtl/core/ tb_soc.sv & echo 开始执行处理器仿真)^
else if %cmchc% == 1 (iverilog -g2005-sv -o tb -y ../rtl/core/ -I ../rtl/core/ tb_core.sv & echo 开始执行数据总线仿真)^
else if %cmchc% == c (del tb *.lxt & @echo 缓存文件已清理 & goto cmsl)^
else (echo 命令未找到 & goto cmsl)


@echo 生成波形
vvp -n tb -lxt2
@echo 显示波形
gtkwave tb.lxt
goto cmsl
pause