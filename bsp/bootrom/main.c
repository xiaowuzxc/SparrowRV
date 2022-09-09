#include "system.h"

//测试bootrom
int main()
{
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    uart_init(25000000);
    xprintf("%s", "Hello world SparrowRV\n");

    xprintf("%s", "iram turn from bootrom to dpram\n");
    set_csr(mcctr, 0b10000);
    
}
