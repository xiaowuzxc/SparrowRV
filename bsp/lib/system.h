#ifndef SYSTEM_H_
#define SYSTEM_H_

#include <stdint.h>
#include <stdio.h>
#include "utils.h"
#include "trap.h"
#include "xprintf.h"
#include "uart.h"
#include "spi.h"
//系统主频
#define SYS_FRE 25000000



#define ENABLE 1
#define DISABLE 0

//自定义CSR
#define msprint 0x346  //仿真打印
#define mends   0x347  //仿真结束
#define mtrig   0x306  //
#define mcctr   0xB88  //

#endif
