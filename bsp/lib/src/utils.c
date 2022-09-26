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





uint64_t mtime_value_get()
{
    uint64_t temp;
    mtime_en_ctr(DISABLE);
    temp = read_csr(mtime);
    temp += (uint64_t)(read_csr(mtimeh)) << 32;
    mtime_en_ctr(ENABLE);
    return temp;
}

void mtime_value_set(uint64_t value64b)
{
    uint32_t temp;
    temp = value64b;
    write_csr(mtime, temp);
    temp = value64b>>32;
    write_csr(mtimeh, temp);
}

void mtime_en_ctr(uint8_t mtime_en)
{
    if(mtime_en == ENABLE)
        set_csr(mcctr, 0b00100);
    else
        clear_csr(mcctr, 0b00100);

}

uint64_t minstret_value_get()
{
    uint64_t temp;
    mtime_en_ctr(DISABLE);
    temp = read_csr(minstret);
    temp += (uint64_t)(read_csr(minstreth)) << 32;
    mtime_en_ctr(ENABLE);
    return temp;
}

void minstret_value_set(uint64_t value64b)
{
    uint32_t temp;
    temp = value64b;
    write_csr(minstret, temp);
    temp = value64b>>32;
    write_csr(minstreth, temp);
}

void minstret_en_ctr(uint8_t minstret_en)
{
    if(minstret_en == ENABLE)
        set_csr(mcctr, 0b00010);
    else
        clear_csr(mcctr, 0b00010);

}

void delay_sys_wait(uint32_t us)
{
    uint64_t tmp;
    uint32_t count;

    count = us * CPU_FREQ_MHZ;
    tmp = mtime_value_get();
    mtime_en_ctr(ENABLE);
    while (mtime_value_get() < (tmp + count));
}

void core_reset_enable()
{
    set_csr(mcctr, 0b01000);
}

void core_sim_end()
{
    write_csr(mends,1);
}


void inst_mem_switch(uint8_t mem_sel)
{
    if(mem_sel == BOOT_ROM)
        clear_csr(mcctr, 0b10000);
    else //APP_RAM
        set_csr(mcctr, 0b10000);
}