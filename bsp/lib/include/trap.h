#ifndef _TRAP_H_
#define _TRAP_H_
#include "system.h"

#define TRAP_GLBL 0 //全局中断
#define TRAP_SOFT 1 //软件中断
#define TRAP_TCMP 2 //定时器中断
#define TRAP_EXTI 3 //外部中断

uint8_t trap_en_ctrl(uint8_t sel, uint8_t en);

#endif
