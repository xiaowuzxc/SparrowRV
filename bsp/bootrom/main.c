#include "system.h"

//测试bootrom
int main()
{
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    //uart_init(115200);
    //uart_init(25000000);
    xprintf("%s", "Hello world SparrowRV\n");

    xprintf("%s", "iram turn from bootrom to dpram\n");

    while(1)
    {
        xprintf("%s", "Hello world SparrowRV\n");
    }

    inst_mem_switch(APP_RAM);
    
}
