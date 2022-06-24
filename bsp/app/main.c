#include <stdint.h>
#include "utils.h"
#include "xprintf.h"
#include "system.h"
#include "uart.h"

uint32_t adc_v;
uint8_t a[13];
uint8_t abc=0;


int main()
{
    uart_init(9600);
    a[4]=0xcc;
    a[5]=0x00;
    xprintf("%s", "Hello world!!!\n");
    xprintf("%s", "SparrowRV!!!\n");
}
