#include "system.h"

//测试
int main()
{
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    uart_init(25000000);
    xprintf("%s", "Hello world SparrowRV\n");
    mtime_en_ctr(DISABLE);
    mtime_value_set((uint64_t)0x10000000000);
    mtime_en_ctr(ENABLE);
    fpioa_perips_in_set(GPIO0,20);
    fpioa_perips_in_set(GPIO1,21);
    fpioa_perips_in_set(GPIO2,31);
    fpioa_perips_in_set(GPIO3,20);
    fpioa_perips_in_set(GPIO4,21);
    fpioa_perips_in_set(GPIO5,31);
    fpioa_perips_out_set(30, GPIO16);
    gpio_gpo_mode_ctr(GPIO_P0 | GPIO_P1 |GPIO_P2 |GPIO_P3 |GPIO_P4 |GPIO_P5, GPO_MODE_HIGHZ);
    gpio_gpo_mode_ctr(GPIO_P16, GPO_MODE_OE_PP);
    gpio_gpo_set_data(0xffffffff);
    uint64_t mtime_temp;
    uint32_t mtime32tmp;
    mtime_temp = mtime_value_get();
    mtime32tmp = mtime_temp;
    xprintf("mtimel=%lu\n", mtime32tmp);
    mtime32tmp = mtime_temp>>32;
    xprintf("mtimeh=%lu\n", mtime32tmp);
    

    
}
