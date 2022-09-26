#include "system.h"

//测试bootrom
int main()
{
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    //uart_init(115200);
    uart_init(25000000);
    xprintf("%s", "Hello world SparrowRV\n");

    xprintf("%s", "iram turn from bootrom to dpram\n");
    /*
    while(1)
    {
        if(uart_recv_flg(UART0))//串口接收状态查询
            uart_send_date(UART0, uart_recv_date(UART0));
    }
        */
    set_csr(mcctr, 0b10000);//切换
    
}
