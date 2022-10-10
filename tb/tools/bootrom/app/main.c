#include "system.h"
uint8_t cnt;
uint32_t sm3_tmp;
//测试
int main()
{
    fpioa_perips_in_set(GPI0, 2);
    fpioa_perips_in_set(GPI1, 3);
    {
        uint32_t boot_key;//启动模式设置
        boot_key = gpio_gpi_data_in();
        boot_key = boot_key & 0x00000003;
    }
    sm3_tmp=read_csr(mimpid);
    fpioa_perips_in_set(UART0_RX, 0);
    fpioa_perips_out_set(UART0_TX, 1);

    //配置波特率
    uart_band_ctr(UART0,115200);
    // enable tx and rx
    uart_enable_ctr(UART0, ENABLE);
    printf("%s", "Hello world SparrowRV\n");
    cnt =0;
    sm3_tmp =0;
    while (cnt<63)
    {
        sm3_accl_in_data(sm3_tmp);
        sm3_tmp +=5;
        cnt++;
    }
    sm3_accl_in_lst(ENABLE);
    sm3_accl_in_data(sm3_tmp);
    sm3_accl_in_lst(DISABLE);
    while(sm3_accl_res_wait());
    for(cnt=0; cnt<8; cnt++)
    {
        printf("sm3 res[%d] = %lx \n", cnt, sm3_accl_res_data(cnt));
    }
    
}
