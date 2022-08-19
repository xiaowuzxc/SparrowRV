# 小麻雀处理器
![rvlogo](/pic/img/rvlogo.bmp)[已被RISC-V官网收录](https://riscv.org/exchange/?_sf_s=sparrowrv)  
![teelogo](/pic/img/giteetj.bmp)[Gitee推荐项目](https://gitee.com/explore/risc-v)  
## 简介
小麻雀处理器(SparrowRV)是一款单周期32位，支持RV32IM指令集的嵌入式处理器。它的控制逻辑简单，没有复杂的流水线控制结构，没有冗余的线网连接，代码注释完备，适合用于学习。  

**设计指标：**  
- 兼容RV32IM指令集  
- 支持CSR，支持中断，仅支持机器模式  
- 哈佛结构，指令存储器映射至存储器空间  
- 支持C语言  
- 支持AXI4-Lite总线  
- JTAG调试支持  
- 片外Flash启动支持  

**功能框图**  
![soc架构](/pic/img/soc架构.svg)  

软件开发请参阅[板级支持包BSP](#板级支持包bsp)  
仿真环境搭建请参阅[仿真流程](#仿真)  

## 设计进度
```
SoC RTL
 ├─内核
 │   ├─译码执行 (完成)
 │   ├─iram (完成)
 │   ├─CSR  (Debug 99%)
 │   ├─寄存器组 (完成)
 │   ├─总线接口 (Debug 98%)
 │   ├─中断控制 (Debug 95%)
 │   └─多周期指令控制 (OK)
 ├─外设 (30%)
 └─调试 (移植完成)

软件部分
 ├─指令仿真 (完成)
 └─BSP (随设计扩展驱动程序)
```
**当前任务**  
- ISP系统，UART下载  
- 大改FPIOA
- FPGA板级调试  

**未来任务**  
- 向量化的中断系统  
- 完善的文档  
- 资源优化  


## 开发工具
- 处理器RTL设计采用Verilog-2001可综合子集。此版本代码密度更高，可读性更强，并且受到综合器的广泛支持。  
- 处理器RTL验证采用System Verilog-2005。此版本充分满足仿真需求，并且受到仿真器的广泛支持。   
- 数字逻辑仿真采用iverilog。开源免费跨平台的轻量级HDL仿真器，适合仿真中小模块。  
- 提供Modelsim仿真脚本，便于相关用户群体使用。  
- 脚本采用 Batchfile批处理(Win)/Makefile(Linux) + Python3。发挥各种脚本语言的优势，最大程度地简化操作。  
- 所有文本采用UTF-8编码，具备良好的多语言和跨平台支持。  

## 仿真
本工程使用`批处理/Makefile + Python3 + Modelsim/iverilog`完成仿真全流程，可根据个人喜好与平台使用合适的工具。如果已配置相关工具，可跳过环境搭建步骤。    
若需要编写c语言程序并仿真，请参阅[板级支持包BSP](#板级支持包bsp)  
**仿真环境框架**  
![soc架构](/pic/img/仿真环境.svg)  

### Linux环境搭建与仿真
必须使用带有图形化界面的Linux的系统，否则无法正常仿真。    
Linux下仅支持iverilog  
Debian系(Ubuntu、Debian、Deepin)执行以下命令：  
```
sudo apt install make git python3 python3-tk gtkwave gcc g++ bison flex gperf autoconf
git clone -b v11_0 --depth=1 https://gitee.com/xiaowuzxc/iverilog/
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
cd ..
rm -rf iverilog/
```
其他Linux发行版暂不提供支持，请自行探索。  

- `/tb/makefile`是Linux环境下的实现各项仿真功能的启动器  

进入`/tb/`目录，终端输入`make`即可启动人机交互界面。根据提示，输入`make`+`空格`+`单个数字或符号`，按下回车即可执行对应项目。   

目前支持的命令：  
- [0]导入inst.txt，RTL仿真并显示波形  
- [1]收集指令测试集程序，测试所有指令  
- [2]转换bin文件为inst.txt，可被testbench读取  
- [3]转换bin文件并进行RTL仿真、显示波形，主要用于仿真c语言程序  
- [4]显示上一次的仿真波形  
- [c]清理缓存文件  

### Windows环境搭建
- 进入[Python官网](https://www.python.org/)，下载并安装Python 3.x版本(建议使用稳定版)  
- (可跳过)如果想在Win系统使用make，请参阅[Makefile开发](#Makefile开发)第2步。  
#### iverilog仿真
进入[iverilog Win官网](http://bleyer.org/icarus/)，下载并安装iverilog-v12-20220611-x64_setup[18.2MB]  
Windows下iverilog安装流程及仿真可参考[视频教程](https://www.bilibili.com/video/bv1dS4y1H7zn)  
**可选择以下任意一种方式进行仿真**  
- `/tb/run_zh.bat`是Windows环境下的启动器，进入`/tb/`目录，仅需双击`run_zh.bat`即可启动人机交互界面。根据提示，输入单个数字或符号，按下回车即可执行对应项目。  
- `/tb/makefile`是Windows/Linux环境下的启动器，进入`/tb/`目录，终端输入`make`即可启动人机交互界面。根据提示，输入`make`+`空格`+`单个数字或符号`，按下回车即可执行对应项目。   

处理器运行C语言程序，见[板级支持包BSP](#板级支持包bsp)。需要将生成的`obj.bin`转换为`inst.txt`文件，才能导入程序并执行仿真。命令2仅转换，命令3可以转换并仿真。  

`/tb/tools/isa_test.py`是仿真脚本的核心，负责控制仿真流程，转换文件类型，数据收集。使用者通过启动器与此脚本交互，一般情况下不建议修改。  
iverilog是仿真工具，gtkwave用于查看波形。  

目前支持的命令：  
- [0]导入inst.txt，RTL仿真并显示波形  
- [1]执行RV32IM指令测试集，收集结果  
- [2]转换bin文件为inst.txt，可被testbench读取  
- [3]转换bin文件并进行RTL仿真、显示波形，主要用于仿真c语言程序  
- [4]显示上一次的仿真波形  
- [c]清理缓存文件  



#### Modelsim仿真
本工程提供了Modelsim仿真脚本，启动方式与iverilog类似，软件安装问题请各显神通  
- `/tb/run_zh.bat`是Windows环境下的启动器，进入`/tb/`目录，仅需双击`run_zh.bat`即可启动人机交互界面。根据提示，输入单个数字或符号，按下回车即可执行对应项目。   
- 处理器运行C语言程序，见[板级支持包BSP](#板级支持包bsp)。需要将生成的`obj.bin`转换为`inst.txt`文件(命令2转换，命令3可以直接转换并仿真)，才能导入程序并执行仿真。  
- `/tb/tools/msim.tcl`主导Modelsim的启动、配置、编译、仿真流程，由批处理脚本启动，Modelsim启动后读入。  

目前支持的命令：  
- [5]导入inst.txt，RTL仿真并显示波形  
- [6]转换bin文件并进行RTL仿真、显示波形，主要用于仿真c语言程序  
- [c]清理缓存文件  
  

### 问题说明
- inst.txt是被testbench读入指令存储器的文件，必须存在此文件处理器才可运行  
- 程序编译生成的bin文件不能直接被读取，需要先转换为inst.txt  
- iverilog版本建议大于v11，低于此版本可能会无法运行  
- Makefile环境下可能会出现gtkwave开着的情况下不显示打印信息  
- Windows下`make`建议使用Powershell，经测试Bash存在未知bug(实验性修复)   
- (已修复)~~run_zh.bat是中文的启动器，但是由于`git CRLF`相关问题无法使用~~  
- 若出现`WARNING: tb_core.sv:23: $readmemh(inst.txt):...`或`ERROR: tb_core.sv:24: $readmemh:`警告或错误信息，请忽略，它不会有任何影响  


## 板级支持包BSP
位于`/bsp/`文件夹下  
BSP支持3种开发方式   
1. Linux+Makefile  
2. Windows+Makefile  
3. MRS图形化界面开发   

`1` `2`的操作流程大致相同，Win/Linux双平台支持，适合老司机，环境配置与使用说明见[Makefile开发](#makefile开发)。  
`3`有图形化界面，仅限Win系统，适合习惯用keil的开发者，环境配置与使用说明见[图形化界面开发](#图形化界面开发)。  

### Makefile开发
**支持Linux和Windows**  
通过makefile脚本，仅需终端输入make，即可执行自动化编译。虽然写脚本有点麻烦，但是后期用得爽。    
使用流程：  
1. 下载并解压GCC工具链至`/tools/`目录，GCC请根据操作系统(Win/Linux)进行选择：  
百度网盘：https://pan.baidu.com/s/1thofSUOS5Mg0Fu-38qPeag?pwd=dj8b  
Github：https://github.com/xiaowuzxc/SparrowRV/releases/tag/v0.8   
请确保解压后文件目录为以下形式，否则无法正常make   
```
SparrowRV
  ├─bsp
  ├─doc
  ├─pic
  ├─rtl
  ├─tb
  └─tools
      └─RISC-V_Embedded_GCC
         ├─bin
         ├─distro-info
         ├─doc
         ├─include
         ├─lib
         ├─libexec
         ├─riscv-none-embed
         └─share
```
2. (Linux或已安装make的windows用户可跳过)下载上方GCC工具链中的make.exe，将make.exe所在的路径添加至环境变量`Path`，添加环境变量的步骤自行百度。  
3. 进入`/bsp/app/`，终端输入`make`，执行编译，此目录下会输出文件  
4. 进入`/bsp/app/`，终端输入`make clean`，清理编译文件  

### 图形化界面开发
**仅支持Windows**  
本工程使用MRS(MounRiver Studio)作为图形化开发环境。MRS基于Eclipse GNU版本，支持中文界面，配置了完善的GCC工具链，可以做到开箱即用。  
官网链接http://www.mounriver.com/  
使用流程：  
1. 下载并安装MRS  
2. 切换中文界面。打开MRS主界面，`Help`->`Language`->`Simplified Chinese`  
3. 打开工程。`文件`->`加载`->`选定'工程'`->`浏览..`->`选择bsp目录下的SparrowRV.wvproj`
4. 点击`构建项目`，编译并生成bin文件

## 致谢
本项目借鉴了[tinyriscv](https://gitee.com/liangkangnan/tinyriscv)的RTL设计和Python脚本。tinyriscv使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议    
感谢先驱者为我们提供的灵感  
感谢众多开源软件提供的好用的工具  
感谢MRS开发工具提供的便利   
感谢导师对我学习方向的支持和理解  
大家的支持是我前进的动力！  