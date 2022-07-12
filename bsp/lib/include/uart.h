#include "system.h"

#ifndef _UART_H_
#define _UART_H_

#define SYSIO_BASE            (0x20000000)
#define UART_BASE             (SYSIO_BASE + (0x000))
#define UART0_BASE            (UART_BASE  + (0x000))
#define UART1_BASE            (UART_BASE  + (0x100))

#define UART_CTRL(UARTx)      (UARTx + (0x00))
#define UART_STATUS(UARTx)    (UARTx + (0x04))
#define UART_BAUD(UARTx)      (UARTx + (0x08))
#define UART_TXDATA(UARTx)    (UARTx + (0x0c))
#define UART_RXDATA(UARTx)    (UARTx + (0x10))

#define UART0 UART0_BASE
#define UART1 UART1_BASE

#define UART_REG(addr) (*((volatile uint32_t *)addr))

void uart_enable_ctr(uint32_t UARTx, uint32_t uart_en);//串口使能控制
void uart_band_ctr(uint32_t UARTx, uint32_t uart_band);//串口波特率控制
void uart_send_date(uint32_t UARTx, uint32_t uart_send);//串口发送
uint8_t uart_recv_date(uint32_t UARTx);//串口接收
uint8_t uart_recv_flg(uint32_t UARTx);//串口接收状态查询


#endif
