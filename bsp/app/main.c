#include <stdint.h>
#include "utils.h"
#include "xprintf.h"
#include "system.h"
#include "uart.h"

uint8_t a[60];
//测试
int main()
{
    a[0]='R';
    a[1]='V';
    a[2]='3';
    a[3]='2';
    a[4]='I';
    a[5]='M';
    a[6]='\n';
    a[7]=0x00;
    uart_init(9600);
    xprintf("%s", "Hello world\n");
    xprintf("%s", "SparrowRV ");
    xprintf("%s", a);
}
