#include "system.h"

//测试bootrom
int main()
{
    //init_uart0_printf(25000000);
    //init_uart0_printf(115200);
    //printf("%s", "Hello world SparrowRV\n");
    //printf("%s", "iram turn from bootrom to dpram\n");
    inst_mem_switch(APP_RAM);
}
