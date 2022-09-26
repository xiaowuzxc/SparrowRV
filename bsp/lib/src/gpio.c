#include "gpio.h"

/*********************************************************************
 * @fn      gpio_get_data_in
 *
 * @brief   读取GPIO输入数据
 *
 * @return  GPIO 0-31 的输入数据
 */
uint32_t gpio_get_data_in()
{
    return SYS_RWMEM_W(GPIO_DIN);
}

/*********************************************************************
 * @fn      gpio_send_data_out
 *
 * @brief   写入GPIO输出寄存器
 *
 * @param   gpio_data_output - 写入GPIO输出寄存器的数据
 *
 * @return  无
 */
void gpio_send_data_out(uint32_t gpio_data_output)
{
    SYS_RWMEM_W(GPIO_OPT) = gpio_data_output;
}

/*********************************************************************
 * @fn      gpio_get_data_out
 *
 * @brief   读取GPIO输出寄存器的数据
 *
 * @return  输出寄存器的值
 */
uint32_t gpio_get_data_out()
{
    return SYS_RWMEM_W(GPIO_OPT);
}

/*********************************************************************
 * @fn      gpio_mode_ctr
 *
 * @brief   设置GPIO端口工作模式
 *
 * @param   GPIO_Px - x为[0,31]，选择需要配置的IO口，多个GPIO可以表示为 GPIO_P0 | GPIO_P1 [| GPIO_Px]...
 * @param   gpio_mode - 配置GPIO端口工作模式
 *            GPIO_MODE_IN_HIZ - 高阻
 *            GPIO_MODE_IN_LAH - 高阻输入锁存
 *            GPIO_MODE_OUT_PP - 推挽输出
 *            GPIO_MODE_OUT_OD - 开漏输出
 *
 * @return  无
 */
void gpio_mode_ctr(uint32_t GPIO_Px, uint8_t gpio_mode)
{
    uint32_t temp_oec,temp_omd;
    switch (gpio_mode)
    {
    case GPIO_MODE_IN_HIZ:
        temp_oec = ~GPIO_Px & SYS_RWMEM_W(GPIO_OEC);
        temp_omd = ~GPIO_Px & SYS_RWMEM_W(GPIO_OMD);
        break;
    case GPIO_MODE_IN_LAH:
        temp_oec = ~GPIO_Px & SYS_RWMEM_W(GPIO_OEC);
        temp_omd =  GPIO_Px | SYS_RWMEM_W(GPIO_OMD);
        break;
    case GPIO_MODE_OUT_PP:
        temp_oec =  GPIO_Px | SYS_RWMEM_W(GPIO_OEC);
        temp_omd = ~GPIO_Px & SYS_RWMEM_W(GPIO_OMD);
        break;
    case GPIO_MODE_OUT_OD:
        temp_oec =  GPIO_Px | SYS_RWMEM_W(GPIO_OEC);
        temp_omd =  GPIO_Px | SYS_RWMEM_W(GPIO_OMD);
        break;
    default: break;
    }
    SYS_RWMEM_W(GPIO_OEC) = temp_oec;
    SYS_RWMEM_W(GPIO_OMD) = temp_omd;
}


/*********************************************************************
 * @fn      gpio_mode_read
 *
 * @brief   读取GPIO端口工作模式
 *
 * @return  GPIO端口工作模式，[63:32]GPIO_OEC, [31:0]GPIO_OMD
 */
uint64_t gpio_mode_read()
{
    uint64_t temp;
    temp = (uint64_t)SYS_RWMEM_W(GPIO_OEC) << 32;
    temp |= (uint64_t)SYS_RWMEM_W(GPIO_OMD);
    return temp;
}


