#ifndef SYSTEM_H_
#define SYSTEM_H_

#include <stdint.h>
//#include <stdio.h>
#include "utils.h"
#include "trap.h"
#include "xprintf.h"
#include "uart.h"
#include "spi.h"
#include "fpioa.h"
#include "gpio.h"

#include "nor25_flash.h"
//系统主频
#define SYS_FRE 24000000


#define ENABLE 1
#define DISABLE 0

//自定义CSR
#define msprint 0x346  //仿真打印
#define mends   0x347  //仿真结束
#define mtrig   0x306  //触发系统
#define mcctr   0xB88  //系统控制

#define SYS_RWMEM_W(addr) (*((volatile uint32_t *)(addr)))   //必须4字节对齐访问(低2位为0)
#define SYS_RWMEM_B(addr) (*((volatile uint8_t  *)(addr)))   //允许访问4G地址空间任意字节，但是部分外设不支持字节寻址写

#endif
