#include "system.h"

//串口环回
int main()
{
    init_uart0_printf(115200);
    printf("SparrowRV uart loopback\n");

    while(1)
    {
        if(uart_recv_flg(UART0))
            uart_send_date(UART0, uart_recv_date(UART0));
    }
}
