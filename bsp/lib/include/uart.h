#include "system.h"

#ifndef _UART_H_
#define _UART_H_

#define SYSIO_BASE      (0x20000000)
#define UART0_BASE      (SYSIO_BASE + (0x000))
#define UART1_BASE      (SYSIO_BASE + (0x100))

#define UART0_CTRL      (UART0_BASE + (0x00))
#define UART0_STATUS    (UART0_BASE + (0x04))
#define UART0_BAUD      (UART0_BASE + (0x08))
#define UART0_TXDATA    (UART0_BASE + (0x0c))
#define UART0_RXDATA    (UART0_BASE + (0x10))

#define UART1_CTRL      (UART1_BASE + (0x00))
#define UART1_STATUS    (UART1_BASE + (0x04))
#define UART1_BAUD      (UART1_BASE + (0x08))
#define UART1_TXDATA    (UART1_BASE + (0x0c))
#define UART1_RXDATA    (UART1_BASE + (0x10))

#define UART0 0
#define UART1 1

#define UART_REG(addr) (*((volatile uint32_t *)addr))

void uart_enable_ctr(uint32_t UARTx, uint32_t uart_en);//串口使能控制
void uart_band_ctr(uint32_t UARTx, uint32_t uart_band);//串口波特率控制
void uart_send_date(uint32_t UARTx, uint32_t uart_send);//串口发送
uint8_t uart_recv_date(uint32_t UARTx);//串口接收
uint8_t uart_recv_flg(uint32_t UARTx);//串口接收状态查询

void uart_init(uint32_t band);
void uart_putc(uint8_t c);

uint8_t uart_getc();

#endif
