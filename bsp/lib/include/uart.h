#include "system.h"
#include "xprintf.h"
#include "utils.h"
#ifndef _UART_H_
#define _UART_H_
#define SYSIO_BASE      (0x20000000)
#define UART0_BASE      (SYSIO_BASE + (0x000))
#define UART0_CTRL      (UART0_BASE + (0x00))
#define UART0_STATUS    (UART0_BASE + (0x04))
#define UART0_BAUD      (UART0_BASE + (0x08))
#define UART0_TXDATA    (UART0_BASE + (0x0c))
#define UART0_RXDATA    (UART0_BASE + (0x10))

#define UART0_REG(addr) (*((volatile uint32_t *)addr))

void uart_init(uint32_t band);
void csr_putc(uint8_t c);
void uart_putc(uint8_t c);

uint8_t uart_getc();

#endif
