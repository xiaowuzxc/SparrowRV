#include "gpio.h"

/*********************************************************************
 * @fn      gpio_gpi_data_in
 *
 * @brief   读取GPI输入数据
 *
 * @return  GPI[31,0]的输入数据
 */
uint32_t gpio_gpi_data_in()
{
    return SYS_RWMEM_W(GPIO_DIN);
}

/*********************************************************************
 * @fn      gpio_gpo_set_data
 *
 * @brief   写入GPIO_OPT输出寄存器
 *
 * @param   gpio_opt_data - 写入GPIO_OPT输出寄存器的数据
 *
 * @return  无
 */
void gpio_gpo_set_data(uint32_t gpio_opt_data)
{
    SYS_RWMEM_W(GPIO_OPT) = gpio_opt_data;
}

/*********************************************************************
 * @fn      gpio_gpo_get_data
 *
 * @brief   读取GPIO_OPT输出寄存器的数据
 *
 * @return  GPIO_OPT输出寄存器的值
 */
uint32_t gpio_gpo_get_data()
{
    return SYS_RWMEM_W(GPIO_OPT);
}

/*********************************************************************
 * @fn      gpio_gpo_mode_ctr
 *
 * @brief   设置GPO端口工作模式
 *
 * @param   GPO_Px - x为[0,31]，选择需要配置的IO口，多个GPIO可以表示为 GPIO_P0 | GPIO_P1 [| GPIO_Px]...
 * @param   gpo_mode - 配置GPIO端口工作模式
 *            GPO_MODE_HIGHZ - 高阻
 *            GPO_MODE_OE_PP - 推挽输出
 *            GPO_MODE_OE_OD - 开漏输出
 *
 * @return  无
 */
void gpio_gpo_mode_ctr(uint32_t GPO_Px, uint8_t gpo_mode)
{
    switch (gpo_mode)
    {
    case GPO_MODE_HIGHZ:
        SYS_RWMEM_W(GPIO_OEC) = ~GPO_Px & SYS_RWMEM_W(GPIO_OEC);
        //temp_omd = SYS_RWMEM_W(GPIO_ODC);
        break;
    case GPO_MODE_OE_PP:
        SYS_RWMEM_W(GPIO_OEC) =  GPO_Px | SYS_RWMEM_W(GPIO_OEC);
        SYS_RWMEM_W(GPIO_ODC) = ~GPO_Px & SYS_RWMEM_W(GPIO_ODC);
        break;
    case GPO_MODE_OE_OD:
        SYS_RWMEM_W(GPIO_OEC) =  GPO_Px | SYS_RWMEM_W(GPIO_OEC);
        SYS_RWMEM_W(GPIO_ODC) =  GPO_Px | SYS_RWMEM_W(GPIO_ODC);
        break;
    default: break;
    }

}


/*********************************************************************
 * @fn      gpio_gpo_mode_read
 *
 * @brief   读取GPIO端口工作模式
 *
 * @return  GPIO端口工作模式，[63:32]GPIO_OEC, [31:0]GPIO_ODC
 */
uint64_t gpio_gpo_mode_read()
{
    uint64_t temp;
    temp = (uint64_t)SYS_RWMEM_W(GPIO_OEC) << 32;
    temp |= (uint64_t)SYS_RWMEM_W(GPIO_ODC);
    return temp;
}


