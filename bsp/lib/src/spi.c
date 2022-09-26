#include "spi.h"

/*********************************************************************
 * @fn      spi_cp_model
 *
 * @brief   SPI极性CPOL\相位CPHA控制
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 * @param   spi_cpmodel - SPI极性相位选择
 *            SPI_CP_MODEL_0 - MODEL0, CPOL = 0, CPHA = 0
 *            SPI_CP_MODEL_1 - MODEL1, CPOL = 0, CPHA = 1
 *            SPI_CP_MODEL_2 - MODEL2, CPOL = 1, CPHA = 0
 *            SPI_CP_MODEL_3 - MODEL3, CPOL = 1, CPHA = 1
 *
 * @return  无
 */
void spi_cp_model(uint32_t SPIx, uint32_t spi_cpmodel)
{
    SYS_RWMEM_B(SPI_CTRL(SPIx)+0) = spi_cpmodel;
}

/*********************************************************************
 * @fn      spi_sclk_div
 *
 * @brief   SPI SCLK分频器配置
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 * @param   spi_div - SCLK分频系数 = 2^(spi_div+1), 例如 0:2分频, 1:4分频
 *
 * @return  无
 */
void spi_sclk_div(uint32_t SPIx, uint32_t spi_div)
{
    SYS_RWMEM_B(SPI_CTRL(SPIx)+1) = spi_div;
}
/*********************************************************************
 * @fn      spi_set_cs
 *
 * @brief   SPI CS片选信号控制
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 * @param   spi_cs - SPI从机使能控制
 *            ENABLE - 使能，CS线拉低
 *            DISABLE - 关闭，CS线拉高
 *
 * @return  无
 */
void spi_set_cs(uint32_t SPIx, uint32_t spi_cs)
{
    if (spi_cs == ENABLE)
        SYS_RWMEM_W(SPI_CTRL(SPIx)) |= 1 << 3;
    else
        SYS_RWMEM_W(SPI_CTRL(SPIx)) &= ~(1 << 3);
}

/*********************************************************************
 * @fn      spi_send_byte
 *
 * @brief   SPI发送一个字节，开始发送后立即返回
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 * @param   data - 待发送的数据
 *
 * @return  无
 */
void spi_send_byte(uint32_t SPIx, uint32_t data)
{
    while (spi_busy_chk(SPIx)); //等待上一个操作结束
    SYS_RWMEM_W(SPI_DATA(SPIx)) = data;
    SYS_RWMEM_W(SPI_CTRL(SPIx)) |= 1 << 0; // spi en
}

/*********************************************************************
 * @fn      spi_sdrv_byte
 *
 * @brief   SPI发送1字节接收1字节，等待收发完成后返回数据
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 * @param   data - 待发送的数据
 *
 * @return  接收到的数据
 */
uint8_t spi_sdrv_byte(uint32_t SPIx, uint32_t data)//SPI发送1字节接收1字节
{
    while (spi_busy_chk(SPIx)); //等待上一个操作结束
    SYS_RWMEM_W(SPI_DATA(SPIx)) = data;
    SYS_RWMEM_W(SPI_CTRL(SPIx)) |= 1 << 0; // spi en
    while (spi_busy_chk(SPIx)); //等待一次收发结束
    return (uint8_t)(SYS_RWMEM_W(SPI_DATA(SPIx)) & 0xff);//返回收到的数据
}

/*********************************************************************
 * @fn      spi_busy_chk
 *
 * @brief   SPI工作状态检查
 *
 * @param   SPIx - x可以为0,1 ，去选择操作的SPI，如SPI0
 *
 * @return  1:SPI工作中; 0:SPI空闲
 */
uint32_t spi_busy_chk(uint32_t SPIx)//SPI状态检查
{
    return (SYS_RWMEM_W(SPI_STATUS(SPIx)) & 0x1);
}

void spi_send_bytes(uint32_t SPIx, uint8_t data[], uint32_t len)
{
    uint32_t i;
    for (i = 0; i < len; i++)
        spi_send_byte(SPIx, data[i]);
}


void spi_read_bytes(uint32_t SPIx, uint8_t data[], uint32_t len)
{
    uint32_t i;
    for (i = 0; i < len; i++)
        data[i] = spi_sdrv_byte(SPIx, 0x00);
}

