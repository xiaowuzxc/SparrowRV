#include <stdint.h>
#include "printf.h"

void trap_handler(uint32_t mcause, uint32_t mepc)
{
    printf("%s", "\n EX trap in \n");
}
