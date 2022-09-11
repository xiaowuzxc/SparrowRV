#include <stdint.h>
#include <stdio.h>

uint32_t aaa; //全局变量-无初始值-bss段 <-全局指针GP
uint32_t bbb=32; //全局变量-有初始值-data段 <-全局指针GP

void main()
{
    uint32_t ccc; //局部变量-动态分配 <-堆栈指针SP
    ccc=10;
    printf("%c\n", ccc);
}


