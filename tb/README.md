# 使用说明

### 批处理
双击run_zh.bat或run.bat即可执行  
`run_zh.bat` 采用中文的交互界面，~~但是cmd解释器可能会因为中文引发奇怪的错误~~ **(已修复)**  
~~`run.bat` 只有英文交互界面，备用~~  
输入`[单个字符]`并回车，即可执行对应项目  

### Makefile
在当前目录下的终端输入`make`，显示可执行项目  
在当前目录下的终端输入`make [单个字符]`，执行对应项目  

### 可执行的项目

| 编号 | 功能 |
|---|---|
|0 | 使用iverilog载入inst.txt并仿真|
|1 | 使用iverilog执行RISC-V ISA测试集|
|2 | bin文件转为inst.txt|
|3 | 使用iverilog载入bin文件并仿真|
|4 | 使用gtkwave显示上一次的仿真波形tb.lxt|
|5 | 使用modelsim载入inst.txt并仿真|
|6 | 使用modelsim载入bin文件并仿真|
|c | 清理缓存文件|
