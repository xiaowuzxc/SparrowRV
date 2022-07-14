#include <stdint.h>

#include "utils.h"


/*********************************************************************
 * @fn      get_cycle_value
 *
 * @brief   XXX
 *
 * @return  cycle
 */
uint64_t get_cycle_value()
{
    uint64_t cycle;

    cycle = read_csr(cycle);
    cycle += (uint64_t)(read_csr(cycleh)) << 32;

    return cycle;
}

/*********************************************************************
 * @fn      busy_wait
 *
 * @brief   XXX
 *
 * @param   us - YYY
 *
 * @return  无
 */
void busy_wait(uint32_t us)
{
    uint64_t tmp;
    uint32_t count;

    count = us * CPU_FREQ_MHZ;
    tmp = get_cycle_value();

    while (get_cycle_value() < (tmp + count));
}
