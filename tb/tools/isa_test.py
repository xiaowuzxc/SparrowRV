import os
import sys
import subprocess
import time
def 找到所有bin文件(path):
	找到的文件列表 = []
	list_dir = os.walk(path)
	for maindir, subdir, all_file in list_dir:
		for filename in all_file:
			找到的文件 = os.path.join(maindir, filename)
			if 找到的文件.endswith('.bin'):
				找到的文件列表.append(找到的文件)

	return 找到的文件列表

def bin文件转换(输入文件, 输出文件):
	bin文件 = open(输入文件, 'rb')
	文本文件 = open(输出文件, 'w')#自动覆盖
	#一行4字节
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
	编译命令+=r'-y ../rtl/core/ '#文件路径
	编译命令+=r'-I ../rtl/core/ '#头文件路径
	编译命令+=r'tb_core.sv '#仿真文件
	编译进程 = os.popen(str(编译命令))
	编译进程.close()
	仿真进程 = os.popen(r'vvp -n tb -lxt2')
	仿真输出 = 仿真进程.read()
	仿真进程.close()
	return 仿真输出


def ISA测试(测试程序):
	bin文件转换(测试程序, 'inst.txt')
	return 编译并仿真()
	
# 主函数
def main():
	bin文件列表 = 找到所有bin文件(r'tools/isa/generated')
	#print(bin文件列表)
	错误标志 = False

	# 对每一个bin文件进行测试

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
			显示波形 = os.popen(r'gtkwave tb.lxt')
			显示波形.close()
			错误标志 = True
			break

	if (错误标志 == False):
		print('RV32IM all pass')

if __name__ == '__main__':
	sys.exit(main())
