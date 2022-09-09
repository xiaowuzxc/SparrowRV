#include <stdint.h>
#include "xprintf.h"

void trap_handler(uint32_t mcause, uint32_t mepc)
{
    xprintf("%s", "\n EX trap in \n");
}
