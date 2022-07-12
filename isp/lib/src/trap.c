#include "trap.h"
//#include <stdint.h>
uint8_t trap_en_ctrl(uint8_t sel, uint8_t en)
{
    uint8_t tmp;
    switch (sel) {
        case TRAP_GLBL:
        {
            if(en==ENABLE)
            {
                __asm__ __volatile__ (
                "csrrsi x0, mstatus, 0b01000");
            }
            else
            {
                __asm__ __volatile__ (
                "csrrci x0, mstatus, 0b01000");
            }
            tmp=1;
            break;
        }
        case TRAP_SOFT://MSIE
        {
            if(en==ENABLE)
            {
                set_csr(mie, 0b1000);
            }
            else
            {
                clear_csr(mie, 0b1000);
            }
            tmp=1;
            break;
        }
        case TRAP_TCMP://MTIE
        {
            if(en==ENABLE)
            {
                set_csr(mie, 0b10000000);
            }
            else
            {
                clear_csr(mie, 0b10000000);
            }
            tmp=1;
            break;
        }
        case TRAP_EXTI://MEIE
        {
            if(en==ENABLE)
            {
                set_csr(mie, 0b100000000000);
            }
            else
            {
                clear_csr(mie, 0b100000000000);
            }
            tmp=1;
            break;
        }
        default:{tmp=0;break;}
    }
    return tmp;
}

uint8_t trap_trig_ctrl(uint8_t sel, uint8_t trig_sel)
{
    uint8_t tmp;
    switch (sel) {
        case TRAP_SOFT://MSIE
        {
            trig_sel = trig_sel<<4;
            set_csr(0x306, trig_sel);
            trig_sel = (~trig_sel) & 0b110000;
            clear_csr(0x306, trig_sel);
            tmp=1;
            break;
        }
        case TRAP_TCMP://MTIE
        {
            trig_sel = trig_sel<<2;
            set_csr(0x306, trig_sel);
            trig_sel = (~trig_sel) & 0b001100;
            clear_csr(0x306, trig_sel);
            tmp=1;
            break;
        }
        case TRAP_EXTI://MEIE
        {
            set_csr(0x306, trig_sel);
            trig_sel = (~trig_sel) & 0b000011;
            clear_csr(0x306, trig_sel);
            tmp=1;
            break;
        }
        default:{tmp=0;break;}
    }
    return tmp;
}
