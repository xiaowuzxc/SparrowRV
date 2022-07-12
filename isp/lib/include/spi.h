#ifndef _SPI_H_
#define _SPI_H_

#include "system.h"
#define SYSIO_BASE           (0x20000000)
#define SPI_BASE             (SYSIO_BASE + (0x200))
#define SPI0_BASE            (SPI_BASE  + (0x000))
#define SPI1_BASE            (SPI_BASE  + (0x100))

#define SPI_CTRL(SPIx)       (SPIx + (0x00))
#define SPI_DATA(SPIx)       (SPIx + (0x04))
#define SPI_STATUS(SPIx)     (SPIx + (0x08))

#define SPI_CP_MODEL_0 0b000 //CPOL = 0, CPHA = 0
#define SPI_CP_MODEL_1 0b100 //CPOL = 0, CPHA = 1
#define SPI_CP_MODEL_2 0b010 //CPOL = 1, CPHA = 0
#define SPI_CP_MODEL_3 0b110 //CPOL = 1, CPHA = 1

#define SPI0 SPI0_BASE
#define SPI1 SPI1_BASE

#define SPI_REG(addr) (*((volatile uint32_t *)addr))

void spi_cp_model(uint32_t SPIx, uint32_t spi_cpmodel);//SPI相位控制
void spi_sclk_div(uint32_t SPIx, uint32_t spi_div);//SPI SCLK分频器配置
void spi_set_cs(uint32_t SPIx, uint32_t spi_cs);//SPI CS片选信号控制
void spi_send_byte(uint32_t SPIx, uint32_t data);//SPI发送字节，发完不管
uint8_t spi_sdrv_byte(uint32_t SPIx, uint32_t data);//SPI发送1字节接收1字节
//void spi_write_bytes(uint8_t data[], uint32_t len);
//void spi_read_bytes(uint8_t data[], uint32_t len);

#endif
