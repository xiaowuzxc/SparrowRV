#include <stdint.h>
#include "xprintf.h"

extern void timer0_irq_handler() __attribute__((weak));


void trap_handler(uint32_t mcause, uint32_t mepc)
{
    xprintf("%s", "\n ext trap in \n");
}
