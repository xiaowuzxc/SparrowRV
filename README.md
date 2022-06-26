# 小麻雀处理器

## 简介
小麻雀处理器(SparrowRV)是一款单周期32位，支持RV32IM指令集的嵌入式处理器。它的控制逻辑简单，没有复杂的流水线控制结构，没有冗余的线网连接，代码注释完备，整体可读性强。 

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

## 设计进度
```
SoC RTL
 ├─内核
 │   ├─译码执行 (完成)
 │   ├─iram (完成)
 │   ├─CSR  (Debug 90%)
 │   ├─寄存器组 (完成)
 │   ├─总线接口 (Debug 75%)
 │   ├─中断控制 (Debug 90%)
 │   └─多周期指令控制 (OK)
 ├─外设 (10%)
 └─调试 (未进行)

软件部分
 ├─指令仿真 (完成)
 └─BSP (90%)

当前任务
- 扩展AXI总线
```

## 开发工具
- 处理器RTL设计采用Verilog-2001可综合子集。此版本代码密度更高，可读性更强，并且受到综合器的广泛支持。  
- 处理器RTL验证采用System Verilog-2005。此版本充分满足仿真需求，并且受到仿真器的广泛支持。   
- 数字逻辑仿真采用iverilog。开源免费的跨平台HDL仿真器，无法律风险。  
- 辅助脚本采用 Batchfile批处理(Win)/Makefile(Linux) + Python3。发挥各种脚本语言的优势，最大程度地简化操作。  
- 所有文本采用UTF-8编码，具备良好的多语言和跨平台支持。  

## 仿真
本工程需要使用 批处理/Makefile + Python3 + iverilog/gtkwave 进行仿真。如果已配置相关工具，可跳过环境配置步骤。    
### Linux环境搭建
Debian系(Ubuntu、Debian、Deepin)执行以下命令：  
```
sudo apt install make git python3 gtkwave gcc g++ bison flex gperf autoconf
git clone -b v11_0 --depth=1 https://gitee.com/xiaowuzxc/iverilog/
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
cd ..
rm -rf iverilog/
```
如果使用命令[2]或[3]，需要安装`python3-tk`：  
```
sudo apt install python3-tk
```
其他Linux发行版暂不提供支持，请自行探索。  

### Windows环境搭建
- 进入[Python官网](https://www.python.org/)，下载并安装Python 3.x版本(建议使用稳定版)  
- 进入[iverilog Win官网](http://bleyer.org/icarus/)，下载并安装iverilog-v12-20220611-x64_setup[18.2MB]  
- (可跳过)如果想在Win系统使用make，请参阅**Makefile开发**。  

iverilog安装及windows下仿真可参考[视频教程](https://www.bilibili.com/video/bv1dS4y1H7zn)  

### 开始仿真
`/tb/run.bat`是Windows环境下的启动器，进入`/tb/`目录，仅需双击`run.bat`即可启动人机交互界面。根据提示，输入单个数字或符号，按下回车即可执行对应项目。  
`/tb/makefile`是Windows/Linux环境下的启动器，进入`/tb/`目录，终端输入`make`即可启动人机交互界面。根据提示，输入`make`+`空格`+`单个数字或符号`，按下回车即可执行对应项目。
`/tb/tools/isa_test.py`是仿真脚本的核心，负责控制仿真流程，转换文件类型，数据收集，通过启动器与此脚本交互。  
iverilog是仿真工具，gtkwave用于查看波形。  
**仿真流程**  
![soc架构](/pic/img/仿真环境.svg)  
目前支持的命令：  
- [0]导入inst.txt，单次RTL仿真并显示波形  
- [1]收集指令测试集程序，测试所有指令  
- [2]转换bin文件为可被testbench读取的格式  
- [3]转换并导入bin文件，进行RTL仿真  
- [c]清理缓存文件  

**说明**
- inst.txt是被testbench读入指令存储器的文件  
- bin文件不能直接被读取，需要先转换为inst.txt  
- iverilog版本建议大于v11，低于此版本可能会无法运行  
- 命令[2]或[3]需要Python3-tkinter支持，Linux用户请注意  


## 板级支持包BSP
位于`/bsp/`文件夹下

### 开发方式
支持3种开发方式  
1. Linux+Makefile  
2. Windows+Makefile  
3. MRS图形化界面开发   

`1` `2`的使用流程相同，适合老司机，环境配置与使用说明见**Makefile开发**。  
`3`有图形化界面，适合习惯用keil的开发者，环境配置与使用说明见**图形化界面开发**。  

#### Makefile开发
**支持Linux和Windows**  
通过makefile脚本，仅需终端输入make，即可执行自动化编译。虽然写脚本有点麻烦，但是后期用得爽。    
使用流程：  
1. 下载并解压GCC工具链至`/tools/`目录，GCC根据操作系统(Win/Linux)进行选择：  
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
2. Linux或已安装make的windows用户可跳过。下载make.exe，将make.exe所在的路径添加至环境变量`Path`  
3. 进入`/bsp/app/`，终端输入`make`，执行编译，此目录下会输出文件  
4. 进入`/bsp/app/`，终端输入`make clean`，清理编译文件  

#### 图形化界面开发
**仅支持Windows**  
本工程使用MRS(MounRiver Studio)作为图形化开发环境。MRS基于Eclipse GNU版本开发，支持中文界面，配置了完善的GCC工具链，可以做到开箱即用。  
官网链接http://www.mounriver.com/  
使用流程：  
1. 下载并安装MRS  
2. 切换中文界面。打开MRS主界面，`Help`->`Language`->`Simplified Chinese`  
3. 打开工程。`文件`->`加载`->`选定'工程'`->`浏览..`->`选择bsp目录下的SparrowRV.wvproj`
4. 点击`构建项目`，编译并生成bin文件

## 杂谈:个人心路历程
本项目开坑，是我学习数字逻辑设计从量变到质变的又一个转折点。  
我以前搞嵌入式，全靠自己摸索，当时觉得单片机可有意思了，从STC到STM32，还有经典的ESP8266，可以自己做各种小玩意。不过，再有意思的东西，玩上好几年，新鲜感没了，也就腻了，觉得是时候跳出这个圈子了。  
我学习数字逻辑设计的起点是一个40包邮的ZYNQ7010矿板。这板子买不了吃亏买不了上当，又能玩PL/FPGA部分，也能玩PS/Cortex-A9硬核。后来随着技术力的提升，我开始参加竞赛，玩各个厂家的FPGA器件，尝试iverilog,VCS,AlpsMS等各种仿真器，学会了makefile、Python等脚本，一次次挑战自我。  
搞技术的就怕舒适圈。很多时候，调用现成的模块可以带来很大的便利，重复造轮子也确实没有意义，毕竟高复用性是开源的灵魂之一，不必将精力消耗在重复劳动上，~~IP连连看不爽吗~~。但是，会用现成的轮子，不代表不需要有造轮子的能力。要知道，轮子也是人造的，人人都想着调库，技术就难以发展。我的开源仓库里面就有很多轮子，比如说明很详细的异步FIFO、逐次逼近型ADC、CIC/FIR滤波器等。借鉴并复现成熟设计不丢人，毕竟只有吃透了成熟设计才有创新的能力；但是，只想借鉴不想创造，躺在舒适圈里，不是一个工程师该有的想法。借鉴并研究经典设计，在此基础上创造出新的知识或成果，成为后人所学习的”经典设计“，既象征着对技术的不懈追求，也是一种开源精神的传承。  
如果只是为了拿来用，tinyriscv、蜂鸟E203、PicoRV都是非常成熟且优秀的设计，做一个使用者，方便快捷。但是，我是一个不甘于一直做“使用者”的人，如果有可能，我想做开发者，能力不够也可以尝试去修改。我以前搞单片机，开发C语言程序，是“使用者”；我修改tinyriscv和蜂鸟E203的功能和外设，做出自己想要的东西，是“开发者”。同样，我在tinyriscv或蜂鸟E203的基础上进行开发，却是“使用者”；我尝试自己写一个RISC-V处理器，做出自己想要的东西，是“开发者”。  

## 致谢
本项目借鉴了[tinyriscv](https://gitee.com/liangkangnan/tinyriscv)的RTL设计和Python脚本，使用其除法器模块。tinyriscv使用[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)协议    
感谢先驱者为我们提供的灵感  
感谢众多开源软件提供的好用的工具  
感谢MRS开发工具提供的便利   
感谢导师对我学习方向的支持和理解  
大家的支持是我前进的动力！  