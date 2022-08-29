#include "fpioa.h"

/*********************************************************************
 * @fn      fpioa_perips_out_set
 *
 * @brief   配置FPIOA输出与外设的映射关系
 *
 * @param   FPIOAx - x是待配置的FPIOA端口编号，范围是[31:0]
 * @param   fpioa_perips_o - 选择映射哪个外设输出端口，数据见fpioa.h/fpioa_perips_o参数
 *
 * @return  无
 */
void fpioa_perips_out_set(uint8_t FPIOAx, uint8_t fpioa_perips_o)
{
    FPIOA_REG_B(FPIOA_OT_BASE, FPIOAx) = fpioa_perips_o;
}

/*********************************************************************
 * @fn      fpioa_perips_in_set
 *
 * @brief   配置外设与FPIOA输入的映射关系
 *
 * @param   fpioa_perips_i - 待配置的外设输入端口，数据见fpioa.h/fpioa_perips_i参数
 * @param   FPIOAx - x是连接当前外设输入端口的FPIOA端口编号，范围是[31:0]
 *
 * @return  无
 */
void fpioa_perips_in_set(uint8_t fpioa_perips_i, uint8_t FPIOAx)
{
    FPIOA_REG_B(FPIOA_IN_BASE, fpioa_perips_i) = FPIOAx;
}

/*********************************************************************
 * @fn      fpioa_out_read
 *
 * @brief   读取FPIOA的端口与外设输出的映射关系
 *
 * @param   FPIOAx - x是待读取的FPIOA端口编号，范围是[31:0]
 *
 * @return  连接此FPIOA端口的外设输出编号
 */
uint8_t fpioa_out_read(uint8_t FPIOAx)
{
    return FPIOA_REG_B(FPIOA_OT_BASE, FPIOAx);
}

/*********************************************************************
 * @fn      fpioa_in_read
 *
 * @brief   读取外设输入与FPIOA的端口的映射关系
 *
 * @param   fpioa_perips_i - 这是待读取的外设输入端口编号
 *
 * @return  连接此外设输入端口的FPIOA编号
 */
uint8_t fpioa_in_read(uint8_t fpioa_perips_i)
{
    return FPIOA_REG_B(FPIOA_IN_BASE, fpioa_perips_i);
}

