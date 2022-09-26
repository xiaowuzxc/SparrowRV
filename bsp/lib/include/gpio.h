#ifndef _GPIO_H_
#define _GPIO_H_
#include "system.h"
#define SYSIO_BASE            (0x20000000)
#define GPIO_BASE             (SYSIO_BASE + (0x400))

#define GPIO_DIN              (GPIO_BASE + (0x00))
#define GPIO_OPT              (GPIO_BASE + (0x04))
#define GPIO_OEC              (GPIO_BASE + (0x08))
#define GPIO_OMD              (GPIO_BASE + (0x0c))

//定义GPIO模式
#define GPIO_MODE_IN_HIZ      0x00  //高阻输入
#define GPIO_MODE_IN_LAH      0x01  //高阻输入锁存
#define GPIO_MODE_OUT_PP      0x02  //推挽输出
#define GPIO_MODE_OUT_OD      0x03  //开漏输出

//定义GPIO端口
#define GPIO_P0    0b1
#define GPIO_P1    0b10
#define GPIO_P2    0b100
#define GPIO_P3    0b1000
#define GPIO_P4    0b10000
#define GPIO_P5    0b100000
#define GPIO_P6    0b1000000
#define GPIO_P7    0b10000000
#define GPIO_P8    0b100000000
#define GPIO_P9    0b1000000000
#define GPIO_P10   0b10000000000
#define GPIO_P11   0b100000000000
#define GPIO_P12   0b1000000000000
#define GPIO_P13   0b10000000000000
#define GPIO_P14   0b100000000000000
#define GPIO_P15   0b1000000000000000
#define GPIO_P16   0b10000000000000000
#define GPIO_P17   0b100000000000000000
#define GPIO_P18   0b1000000000000000000
#define GPIO_P19   0b10000000000000000000
#define GPIO_P20   0b100000000000000000000
#define GPIO_P21   0b1000000000000000000000
#define GPIO_P22   0b10000000000000000000000
#define GPIO_P23   0b100000000000000000000000
#define GPIO_P24   0b1000000000000000000000000
#define GPIO_P25   0b10000000000000000000000000
#define GPIO_P26   0b100000000000000000000000000
#define GPIO_P27   0b1000000000000000000000000000
#define GPIO_P28   0b10000000000000000000000000000
#define GPIO_P29   0b100000000000000000000000000000
#define GPIO_P30   0b1000000000000000000000000000000
#define GPIO_P31   0b10000000000000000000000000000000

uint32_t gpio_get_data_in();//读取GPIO输入数据
void gpio_send_data_out(uint32_t gpio_data_output);//写入GPIO输出数据
uint32_t gpio_get_data_out();//读取GPIO输出数据
void gpio_mode_ctr(uint32_t GPIO_Px, uint8_t gpio_mode);//配置GPIO模式
uint64_t gpio_mode_read();//读取GPIO模式


#endif
