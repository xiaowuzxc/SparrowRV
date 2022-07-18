#include "fpioa.h"

/*********************************************************************
 * @fn      fpioa_setio
 *
 * @brief   配置FPIOA的端口与外设的映射关系
 *
 * @param   FPIOAx - x是待配置的FPIOA端口编号，范围是[31:0]
 * @param   fpioa_function - 选择映射哪个外设端口，外设端口编号见fpioa.h
 *
 * @return  无
 */
void fpioa_setio(uint32_t FPIOAx, uint8_t fpioa_function)
{
    FPIOA_REG_B(FPIOA_BASE,FPIOAx) = fpioa_function;
}

/*********************************************************************
 * @fn      fpioa_read
 *
 * @brief   读取FPIOA的端口与外设的映射关系
 *
 * @param   FPIOAx - x是待读取的FPIOA端口编号，范围是[31:0]
 *
 * @return  此FPIOA端口与外设的映射关系，外设端口编号见fpioa.h
 */
uint8_t fpioa_read(uint32_t FPIOAx)
{
    return FPIOA_REG_B(FPIOA_BASE,FPIOAx);
}