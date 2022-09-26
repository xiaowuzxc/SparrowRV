#include "system.h"

//测试
int main()
{
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    uart_init(25000000);
    xprintf("%s", "Hello world SparrowRV\n");
    fpioa_perips_in_set(GPIO0,20);
    fpioa_perips_in_set(GPIO1,21);
    fpioa_perips_in_set(GPIO2,31);
    fpioa_perips_in_set(GPIO3,20);
    fpioa_perips_in_set(GPIO4,21);
    fpioa_perips_in_set(GPIO5,31);
    fpioa_perips_out_set(30, GPIO16);
    gpio_mode_ctr(GPIO_P0 | GPIO_P1 |GPIO_P2 |GPIO_P3 |GPIO_P4 |GPIO_P5, GPIO_MODE_IN_HIZ);
    gpio_mode_ctr(GPIO_P16, GPIO_MODE_OUT_PP);
    gpio_send_data_out(0xffffffff);
    xprintf("GPIO_IN=%h\n", gpio_get_data_in());
    xprintf("GPIO_IN=%h\n", gpio_get_data_in());
    
}
