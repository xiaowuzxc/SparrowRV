#include "system.h"

uint8_t a[60];
//测试
int main()
{
    trap_en_ctrl(TRAP_GLBL,ENABLE);
    trap_en_ctrl(TRAP_EXTI,ENABLE);
    trap_trig_ctrl(TRAP_EXTI,TRAP_TRIG_NE);
    trap_trig_ctrl(TRAP_EXTI,TRAP_TRIG_PE);
    a[0]='R';
    a[1]='V';
    a[2]='3';
    a[3]='2';
    a[4]='I';
    a[5]='M';
    a[6]='\n';
    a[7]=0x00;
    uart_init(25000000);
    xprintf("%s", "Hello world\n");
    xprintf("%s", "SparrowRV ");
    xprintf("%s", a);
}
