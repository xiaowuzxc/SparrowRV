#ifndef _FPIOA_H_
#define _FPIOA_H_

#include "system.h"
#define SYSIO_BASE                  (0x20000000)
#define FPIOA_BASE                  (SYSIO_BASE + (0xF00))
#define FPIOA_OT_BASE               (FPIOA_BASE)
#define FPIOA_IN_BASE               (FPIOA_BASE + (0x80))
#define FPIOA_REG_B(addr,offset)    (*((volatile uint8_t *)(addr + offset)))

void fpioa_perips_out_set(uint8_t FPIOAx, uint8_t fpioa_perips_o);
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

//定义fpioa_perips_i参数
#define  SPI0_MISO     0
#define  SPI1_MISO     1
#define  UART0_RX      2
#define  UART1_RX      3

//定义fpioa_perips_o,fpioa_perips_i共享参数
#define  GPIO0         32
#define  GPIO1         33
#define  GPIO2         34
#define  GPIO3         35
#define  GPIO4         36
#define  GPIO5         37
#define  GPIO6         38
#define  GPIO7         39
#define  GPIO8         40
#define  GPIO9         41
#define  GPIO10        42
#define  GPIO11        43
#define  GPIO12        44
#define  GPIO13        45
#define  GPIO14        46
#define  GPIO15        47
#define  GPIO16        48
#define  GPIO17        49
#define  GPIO18        50
#define  GPIO19        51
#define  GPIO20        52
#define  GPIO21        53
#define  GPIO22        54
#define  GPIO23        55
#define  GPIO24        56
#define  GPIO25        57
#define  GPIO26        58
#define  GPIO27        59
#define  GPIO28        60
#define  GPIO29        61
#define  GPIO30        62
#define  GPIO31        63

#endif