import os
import sys
import time
from tkinter import filedialog

def 找到所有bin文件(path):
    找到的文件列表 = []
    list_dir = os.walk(path)
    for 主目录, 子目录, 所有文件 in list_dir:
        for 文件的名称 in 所有文件:
            找到的文件 = os.path.join(主目录, 文件的名称)
            if 找到的文件.endswith('.bin'):
                找到的文件列表.append(找到的文件)

    return 找到的文件列表

def bin文件转换(输入文件, 输出文件):
    bin文件 = open(输入文件, 'rb')
    文本文件 = open(输出文件, 'w')
    字节索引 = 0
    b0 = 0
    b1 = 0
    b2 = 0
    b3 = 0
    bin文件内容 = bin文件.read(os.path.getsize(输入文件))
    for b in  bin文件内容:
        if 字节索引 == 0:
            b0 = b
            字节索引 = 字节索引 + 1
        elif 字节索引 == 1:
            b1 = b
            字节索引 = 字节索引 + 1
        elif 字节索引 == 2:
            b2 = b
            字节索引 = 字节索引 + 1
        elif 字节索引 == 3:
            b3 = b
            字节索引 = 0
            一条指令 = []
            一条指令.append(b3)
            一条指令.append(b2)
            一条指令.append(b1)
            一条指令.append(b0)
            文本文件.write(bytearray(一条指令).hex() + '\n')
    bin文件.close()
    文本文件.close()

def 编译并仿真():
    编译命令 =r'iverilog '#仿真工具
    编译命令+=r'-g2005-sv '#语法
    编译命令+=r'-o tb '#输出文件
    编译命令+=r'-Y .sv '#检索sv文件
    编译命令+=r'-y ../rtl/core/ '#文件夹路径
    编译命令+=r'-y ../rtl/soc/ '#文件夹路径
    编译命令+=r'-y ../rtl/perips/ '#文件夹路径
    编译命令+=r'-y ../rtl/perips/sysio/ '#文件夹路径
    编译命令+=r'-y ../rtl/jtag/ '#文件夹路径
    编译命令+=r'-y ../rtl/ '#文件夹路径
    编译命令+=r'-I ../rtl/ '#头文件路径
    if sys.argv[1] == 'all_isa':
        编译命令+=r'-D ISA_TEST '
    编译命令+=r'tb_core.sv '#仿真文件
    编译进程 = os.popen(str(编译命令))
    if sys.argv[1] != 'all_isa':
        print(编译进程.read())
    编译进程.close()
    仿真进程 = os.popen(r'vvp -n tb')
    仿真输出 = 仿真进程.read()
    仿真进程.close()
    if sys.argv[1] != 'all_isa':
        print(仿真输出)
        波形进程 = os.popen(r'gtkwave tb.vcd')
        波形进程.close()
    return 仿真输出

def modelsim命令行仿真():
    仿真进程 = os.popen(r'vsim -c -do vsim_regress_sim.tcl')
    仿真输出 = 仿真进程.read()
    仿真进程.close()
    return 仿真输出

def ISA测试(测试程序):
    bin文件转换(测试程序, 'inst.txt')
    return 编译并仿真()

def modelsim_ISA测试(测试程序):
    bin文件转换(测试程序, 'inst.txt')
    return modelsim命令行仿真()

def bin文件转文本():
    待转换的文件路径=filedialog.askopenfilename()
    if 待转换的文件路径:
        print(待转换的文件路径)
        bin文件转换(待转换的文件路径, 'inst.txt')

def isp文件转文本():
    待转换的文件路径=filedialog.askopenfilename()
    if 待转换的文件路径:
        print(待转换的文件路径)
        bin文件转换(待转换的文件路径, 'btrm.txt')

def 启动modelsim仿真():
    仿真进程 = os.popen(r'vsim -do vsim_gui.tcl')
    仿真进程.close()


def iverilog指令集测试():
    开始时间 = time.time()
    bin文件列表 = 找到所有bin文件(r'tools/isa/generated')
    错误标志 = False
    for file in bin文件列表:
        输出字符串 = ISA测试(file)
        if (输出字符串.find('TEST_PASS') != -1):
            print('项目 ' + file[29:] + '   通过')
        else:
            print('  ------------------------------------  ')
            print('----     项目 ' + file[29:] + '    出错     ----')
            print('  ------------------------------------  ')
            print(输出字符串)
            print('  ------------------------------------  ')
            print('----     打开 ' + file[29:] + '    波形     ----')
            print('  ------------------------------------  ')
            显示波形 = os.popen(r'gtkwave tb.vcd')
            显示波形.close()
            错误标志 = True
            break
    print('本次指令集测试用时 ', round(time.time() - 开始时间, 1),' 秒')
    if (错误标志 == False):
        print('--  RV32IM 指令全部通过！  --')

def modelsim指令集测试():
    开始时间 = time.time()
    bin文件列表 = 找到所有bin文件(r'tools/isa/generated')
    错误标志 = False
    vsim编译进程 = os.popen(r'vsim -c -do vsim_regress_cpl.tcl')
    vsim编译输出 = vsim编译进程.read()
    vsim编译进程.close()
    for file in bin文件列表:
        输出字符串 = modelsim_ISA测试(file)
        if (输出字符串.find('TEST_PASS') != -1):
            print('项目 ' + file[29:] + '   通过')
        else:
            print('  ------------------------------------  ')
            print('----     项目 ' + file[29:] + '    出错     ----')
            print('  ------------------------------------  ')
            print(输出字符串)
            print('  ------------------------------------  ')
            print('----     打开 ' + file[29:] + '    波形     ----')
            print('  ------------------------------------  ')
            显示波形 = os.popen(r'gtkwave tb.vcd')
            显示波形.close()
            错误标志 = True
            break
    print('本次指令集测试用时 ', round(time.time() - 开始时间, 1),' 秒')
    if (错误标志 == False):
        print('--  RV32IM 指令全部通过！  --')

##########################################################
if __name__ == '__main__':
    if sys.argv[1] == 'all_isa':
        sys.exit(iverilog指令集测试())
    elif sys.argv[1] == 'tsr_bin':
        sys.exit(bin文件转文本())
    elif sys.argv[1] == 'tsr_isp':
        sys.exit(isp文件转文本())
    elif sys.argv[1] == 'sim_rtl':
        sys.exit(编译并仿真())
    elif sys.argv[1] == 'sim_bin':
        bin文件转文本()
        sys.exit(编译并仿真())
    elif sys.argv[1] == 'sim_isp':
        isp文件转文本()
        sys.exit(编译并仿真())
    elif sys.argv[1] == 'vsim_rtl':
        sys.exit(启动modelsim仿真())
    elif sys.argv[1] == 'vsim_bin':
        bin文件转文本()
        sys.exit(启动modelsim仿真())
    elif sys.argv[1] == 'vsim_isa':
        sys.exit(modelsim指令集测试())
    else:
        print(r'isa_test.py找不到指令')
        print(sys.argv[1])
        sys.exit()