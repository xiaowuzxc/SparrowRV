#include "trap.h"

/*********************************************************************
 * @fn      trap_en_ctrl
 *
 * @brief   中断响应设置
 *
 * @param   sel - 选择设置对象
 *            TRAP_GLBL - 全局中断
 *            TRAP_SOFT - 软件中断
 *            TRAP_TCMP - 定时器中断
 *            TRAP_EXTI - 外部中断
 * @param   en - 状态选择位
 *            ENABLE - 中断可以被响应
 *            DISABLE - 中断被屏蔽
 *
 * @return  0 - 设置失败
 *          1 - 设置成功
 */
uint8_t trap_en_ctrl(uint8_t sel, uint8_t en)
{
    uint8_t tmp=1;
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
            
            break;
        }
        default:{tmp=0;break;}
    }
    return tmp;
}
