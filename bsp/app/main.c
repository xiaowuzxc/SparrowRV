#include "system.h"

//测试
int main()
{
    init_uart0_printf(25000000);
    printf("%s", "Hello world SparrowRV\n");
    mtime_en_ctr(DISABLE);
    mtime_value_set((uint64_t)0x10000000000);
    mtime_en_ctr(ENABLE);
    printf("float=%f\n", 114.514F);
    uint64_t mtime_temp=12345678912345;
    uint32_t mtime32tmp;
    /*
    mtime_temp = mtime_value_get();
    mtime32tmp = mtime_temp;
    printf("mtimel=%lu\n", mtime32tmp);
    mtime32tmp = mtime_temp>>32;
    printf("mtimeh=%lu\n", mtime32tmp);
    printf("mtime_temp=%llu\n", mtime_temp);
    printf("mtime_temp=%llu\n", 11451419198100LLU);
    printf("mtime_temp=%llu\n", 10000000000000LLU);
*/
    volatile uint64_t value=12345678912345;
    volatile uint64_t base;
    char temp;
    for(base=10;value>0;value=value/base)
    {
        temp=value%base;
        printf("%d",temp);
    }


    
}
