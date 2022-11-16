#include "system.h"
volatile uint32_t cnt;
uint32_t tmp;
uint32_t adc_data;
uint32_t cpu_csr_freq;//处理器频率Hz
uint32_t cpu_iram_size;//指令存储器大小kb
uint32_t cpu_sram_size;//数据存储器大小kb
uint32_t vendorid;//Vendor ID

//测试
int main()
{
    init_uart0_printf(115200);
    printf("SparrowRV Core: RV32 IM\n");
    printf("Support Interrupt and CSRs\n");

    tmp=read_csr(mimpid);
    cpu_csr_freq = (tmp & 0x00007FFF) * 10000;
    cpu_iram_size = ((tmp & 0x00FF0000) >> 16)*1024;
    cpu_sram_size = (tmp >> 24)*1024;
    vendorid = read_csr(mvendorid);

    printf("sys freq = %lu Hz\n",cpu_csr_freq);
    printf("cpu_iram_size = %lu byte\n",cpu_iram_size);
    printf("cpu_sram_size = %lu byte\n",cpu_sram_size);
    printf("Vendor ID = %lx \n",vendorid);
    while(1)
    {
        printf("%s", "Hello world SparrowRV\n");
    }
}
