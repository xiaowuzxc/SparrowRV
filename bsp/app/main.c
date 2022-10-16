#include "system.h"
uint8_t cnt;
uint32_t sm3_tmp;
//测试
int main()
{
    init_uart0_printf(115200);
    printf("%s", "Hello world SparrowRV\n");
    sm3_tmp=read_csr(mimpid);
    printf("mimpid l=%lu\n",sm3_tmp&0x0000FFFF);
    printf("mimpid h=%lu\n",sm3_tmp>>16);
    while(1)
    {
        printf("%s", "Hello world SparrowRV\n");
    }
    /*
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
    */
    
}
