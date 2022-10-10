#ifndef _FPIOA_H_
#define _FPIOA_H_

#include "system.h"
#define SYSIO_BASE                  (0x20000000)
#define FPIOA_BASE                  (SYSIO_BASE + (0xF00))
#define FPIOA_OT_BASE               (FPIOA_BASE)
#define FPIOA_IN_BASE               (FPIOA_BASE + (0x80))
#define FPIOA_REG_B(addr,offset)    (*((volatile uint8_t *)(addr + offset)))

void fpioa_perips_out_set(uint8_t fpioa_perips_o, uint8_t FPIOAx);
void fpioa_perips_in_set(uint8_t fpioa_perips_i, uint8_t FPIOAx);
uint8_t fpioa_out_read(uint8_t FPIOAx);
uint8_t fpioa_in_read(uint8_t fpioa_perips_i);


//定义fpioa_perips_o参数
#define  DEF_Null      0 
#define  SPI0_SCK      1 
#define  SPI0_MOSI     2 
#define  SPI0_CS       3 
#define  SPI1_SCK      4 
#define  SPI1_MOSI     5 
#define  SPI1_CS       6 
#define  UART0_TX      7 
#define  UART1_TX      8 

#define  GPO0         32
#define  GPO1         33
#define  GPO2         34
#define  GPO3         35
#define  GPO4         36
#define  GPO5         37
#define  GPO6         38
#define  GPO7         39
#define  GPO8         40
#define  GPO9         41
#define  GPO10        42
#define  GPO11        43
#define  GPO12        44
#define  GPO13        45
#define  GPO14        46
#define  GPO15        47
#define  GPO16        48
#define  GPO17        49
#define  GPO18        50
#define  GPO19        51
#define  GPO20        52
#define  GPO21        53
#define  GPO22        54
#define  GPO23        55
#define  GPO24        56
#define  GPO25        57
#define  GPO26        58
#define  GPO27        59
#define  GPO28        60
#define  GPO29        61
#define  GPO30        62
#define  GPO31        63

//定义fpioa_perips_i参数
#define  SPI0_MISO     0
#define  SPI1_MISO     1
#define  UART0_RX      2
#define  UART1_RX      3
#define  GPI0         32
#define  GPI1         33
#define  GPI2         34
#define  GPI3         35
#define  GPI4         36
#define  GPI5         37
#define  GPI6         38
#define  GPI7         39
#define  GPI8         40
#define  GPI9         41
#define  GPI10        42
#define  GPI11        43
#define  GPI12        44
#define  GPI13        45
#define  GPI14        46
#define  GPI15        47
#define  GPI16        48
#define  GPI17        49
#define  GPI18        50
#define  GPI19        51
#define  GPI20        52
#define  GPI21        53
#define  GPI22        54
#define  GPI23        55
#define  GPI24        56
#define  GPI25        57
#define  GPI26        58
#define  GPI27        59
#define  GPI28        60
#define  GPI29        61
#define  GPI30        62
#define  GPI31        63


#endif