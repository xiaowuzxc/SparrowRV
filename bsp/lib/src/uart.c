#include <stdint.h>

#include "uart.h"


// send one char to uart
void uart_putc(uint8_t c)
{
    while (UART0_REG(UART0_STATUS) & 0x1);
    UART0_REG(UART0_TXDATA) = c;
    write_csr(0x346, c);//0x346 msprint
}

// Block, get one char from uart.
uint8_t uart_getc()
{
    UART0_REG(UART0_STATUS) &= ~0x2;
    while (!(UART0_REG(UART0_STATUS) & 0x2));
    return (UART0_REG(UART0_RXDATA) & 0xff);
}

// band = 25M/band
void uart_init(uint32_t band)
{
    //配置波特率
    UART0_REG(UART0_BAUD) = SYS_FRE / band ;
    // enable tx and rx
    UART0_REG(UART0_CTRL) = 0x3;
    //xprint
    xdev_out(uart_putc);
}
