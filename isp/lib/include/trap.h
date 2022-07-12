#ifndef _TRAP_H_
#define _TRAP_H_
#include "system.h"
#include "utils.h"

#define TRAP_GLBL 0 //全局中断
#define TRAP_SOFT 1 //软件中断
#define TRAP_TCMP 2 //定时器中断
#define TRAP_EXTI 3 //外部中断

#define TRAP_TRIG_HV 0b00 //高电平触发
#define TRAP_TRIG_LV 0b01 //低电平触发
#define TRAP_TRIG_PE 0b10 //上升沿触发
#define TRAP_TRIG_NE 0b11 //下降沿触发

uint8_t trap_en_ctrl(uint8_t sel, uint8_t en);
uint8_t trap_trig_ctrl(uint8_t sel, uint8_t trig_sel);
#endif
