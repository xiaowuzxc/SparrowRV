#include "uart.h"

/*********************************************************************
 * @fn      uart_enable_ctr
 *
 * @brief   串口使能控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *          uart_en - 串口使能选择位
 *            ENABLE - 使能.
 *            DISABLE - 关闭.
 *
 * @return  none
 */
void uart_enable_ctr(uint32_t UARTx, uint32_t uart_en)
{}
/*********************************************************************
 * @fn      uart_band_ctr
 *
 * @brief   串口波特率控制
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *          uart_band - 写入所需的波特率值
 *
 * @return  none
 */
void uart_band_ctr(uint32_t UARTx, uint32_t uart_band)
{}
/*********************************************************************
 * @fn      uart_send_date
 *
 * @brief   串口发送数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *          uart_send - 需要发送的数据
 *
 * @return  none
 */
void uart_send_date(uint32_t UARTx, uint32_t uart_send)
{}
/*********************************************************************
 * @fn      uart_recv_date
 *
 * @brief   串口接收数据
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  返回接收到的数据
 */
uint8_t uart_recv_date(uint32_t UARTx)
{}
/*********************************************************************
 * @fn      uart_recv_flg
 *
 * @brief   串口接收状态查询
 *
 * @param   UARTx - x可以为0,1 ，去选择操作的串口，如UART0
 *
 * @return  如果接收缓冲区有数据，返回1；没有为0
 */
uint8_t uart_recv_flg(uint32_t UARTx)
{}


//发送一个字节
void uart_putc(uint8_t c)
{
    while (UART_REG(UART0_STATUS) & 0x1);
    UART_REG(UART0_TXDATA) = c;
    write_csr(0x346, c);//0x346 msprint
}
// Block, get one char from uart.
uint8_t uart_getc()
{
    UART_REG(UART0_STATUS) &= ~0x2;
    while (!(UART_REG(UART0_STATUS) & 0x2));
    return (UART_REG(UART0_RXDATA) & 0xff);
}

// band = 25M/band
void uart_init(uint32_t band)
{
    //配置波特率
    UART_REG(UART0_BAUD) = SYS_FRE / band ;
    // enable tx and rx
    UART_REG(UART0_CTRL) = 0x3;
    //xprint
    xdev_out(uart_putc);
}

