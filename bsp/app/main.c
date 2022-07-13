#include "system.h"

uint8_t a[60];
//测试
int main()
{
    trap_en_ctrl(TRAP_GLBL,ENABLE);
    trap_en_ctrl(TRAP_EXTI,ENABLE);
    trap_trig_ctrl(TRAP_EXTI,TRAP_TRIG_HV);
    trap_trig_ctrl(TRAP_EXTI,TRAP_TRIG_PE);
    trap_trig_ctrl(TRAP_SOFT,TRAP_TRIG_PE);
    trap_trig_ctrl(TRAP_TCMP,TRAP_TRIG_PE);
    a[0]='R';
    a[1]='V';
    a[2]='3';
    a[3]='2';
    a[4]='I';
    a[5]='M';
    a[6]='\n';
    a[7]=0x00;

    spi_cp_model(SPI0,SPI_CP_MODEL_3);
    spi_sclk_div(SPI0,2);

    uart_init(25000000);
    xprintf("%s", "Hello world\n");
    xprintf("%s", "SparrowRV ");
    xprintf("%s", a);

    spi_set_cs(SPI0,ENABLE);
    spi_sdrv_byte(SPI0,0xF7);
    spi_set_cs(SPI0,DISABLE);
}
