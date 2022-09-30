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
    mtime_temp = mtime_value_get();

    printf("mtime_temp=%llu\n", mtime_temp);
    printf("mtime_temp=%llu\n", 11451419198100LLU);
    printf("mtime_temp=%llu\n", 10000000000000LLU);



    
}
