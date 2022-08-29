#include "system.h"

uint8_t astr[60];
uint8_t program_data[N25Q_PAGE_SIZE];
uint8_t read_data[N25Q_PAGE_SIZE];
//测试
int main()
{
    trap_en_ctrl(TRAP_GLBL,ENABLE);
    trap_en_ctrl(TRAP_EXTI,ENABLE);
    fpioa_perips_in_set(UART0_RX,0);
    fpioa_perips_out_set(1,UART0_TX);
    uart_init(25000000);
    xprintf("%s", "Hello world\n");
    fpioa_perips_in_set(GPIO0,20);
    fpioa_perips_in_set(GPIO1,21);
    fpioa_perips_in_set(GPIO2,31);
    fpioa_perips_in_set(GPIO3,20);
    fpioa_perips_in_set(GPIO4,21);
    fpioa_perips_in_set(GPIO5,31);
    fpioa_perips_out_set(30, GPIO16);

    
}
