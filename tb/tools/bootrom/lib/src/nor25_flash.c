#include "nor25_flash.h"



/* N25Q064特点:
 * 1.总共64Mb大小，即8MB
 * 2.总共128个扇区，每个扇区大小为64KB
 * 3.总共2048个子扇区，每个子扇区大小为4KB
 * 4.总共37768页，每页大小为256B
 * 5.擦除的最小单位是子扇区，编程(写)的最小单位是页，读的最小单位是字节
 */


// 写使能
// 擦除或者编程操作之前必须先发送写使能命令
void n25q_write_enable(uint8_t en)
{
    spi_set_cs(N25_SPI_SEL,ENABLE);
//N25_SPI_SEL
    if (en)
        spi_send_byte(N25_SPI_SEL,WRITE_ENABLE_CMD);
    else
        spi_send_byte(N25_SPI_SEL,WRITE_DISABLE_CMD);
    while (spi_busy_chk(N25_SPI_SEL)); //等待一次收发结束
    spi_set_cs(N25_SPI_SEL,DISABLE);
}

// 读状态寄存器
uint8_t n25q_read_status_reg()
{
    uint8_t data;

    spi_set_cs(N25_SPI_SEL,ENABLE);

    spi_send_byte(N25_SPI_SEL,READ_STATUS_REG_CMD);
    data = spi_sdrv_byte(N25_SPI_SEL,0x00);
    while (spi_busy_chk(N25_SPI_SEL)); //等待一次收发结束
    spi_set_cs(N25_SPI_SEL,DISABLE);

    return data;
}

// 是否正在擦除或者编程
uint8_t n25q_is_busy()
{
    return (n25q_read_status_reg() & 0x1);
}

//初始化
void n25q_init()
{
    spi_sclk_div(N25_SPI_SEL,1);//SPI分频器
    spi_cp_model(N25_SPI_SEL, SPI_CP_MODEL_0);//SPI相位控制
}

// 读ID号
void n25q_read_id(uint8_t data[], uint8_t len)
{
    spi_set_cs(N25_SPI_SEL,ENABLE);

    spi_send_byte(N25_SPI_SEL, READ_ID_CMD);
    spi_read_bytes(N25_SPI_SEL, data, len);

    spi_set_cs(N25_SPI_SEL,DISABLE);
}

// 读数据
// addr: 0, 1, 2, ...
void n25q_read_data(uint8_t data[], uint32_t len, uint32_t addr)
{
    spi_set_cs(N25_SPI_SEL,ENABLE);

    spi_send_byte(N25_SPI_SEL, READ_CMD);
    spi_send_byte(N25_SPI_SEL, (addr >> 16) & 0xff);
    spi_send_byte(N25_SPI_SEL, (addr >> 8) & 0xff);
    spi_send_byte(N25_SPI_SEL, addr & 0xff);
    spi_read_bytes(N25_SPI_SEL, data, len);

    spi_set_cs(N25_SPI_SEL,DISABLE);
}

// 子扇区擦除
// subsector，第几个子扇区: 0 ~ N
void n25q_subsector_erase(uint32_t subsector)
{
    n25q_write_enable(1);

    spi_set_cs(N25_SPI_SEL,ENABLE);

    uint32_t addr = N25Q_SUBSECTOR_TO_ADDR(subsector);

    spi_send_byte(N25_SPI_SEL, SUBSECTOR_ERASE_CMD);
    spi_send_byte(N25_SPI_SEL, (addr >> 16) & 0xff);
    spi_send_byte(N25_SPI_SEL, (addr >> 8) & 0xff);
    spi_send_byte(N25_SPI_SEL, addr & 0xff);
    while (spi_busy_chk(N25_SPI_SEL)); //等待一次收发结束
    spi_set_cs(N25_SPI_SEL,DISABLE);

    while (n25q_is_busy());

    n25q_write_enable(0);
}

// 扇区擦除
// sector，第几个扇区: 0 ~ N
void n25q_sector_erase(uint32_t sector)
{
    n25q_write_enable(1);

    spi_set_cs(N25_SPI_SEL,ENABLE);

    uint32_t addr = N25Q_SECTOR_TO_ADDR(sector);

    spi_send_byte(N25_SPI_SEL, SECTOR_ERASE_CMD);
    spi_send_byte(N25_SPI_SEL, (addr >> 16) & 0xff);
    spi_send_byte(N25_SPI_SEL, (addr >> 8) & 0xff);
    spi_send_byte(N25_SPI_SEL, addr & 0xff);
    while (spi_busy_chk(N25_SPI_SEL)); //等待一次收发结束
    spi_set_cs(N25_SPI_SEL,DISABLE);

    while (n25q_is_busy());

    n25q_write_enable(0);
}

// 页编程
// page，第几页: 0 ~ N
void n25q_page_program(uint8_t data[], uint32_t len, uint32_t page)
{
    n25q_write_enable(1);
    spi_set_cs(N25_SPI_SEL,ENABLE);

    uint32_t addr = N25Q_PAGE_TO_ADDR(page);

    spi_send_byte(N25_SPI_SEL, PAGE_PROGRAM_CMD);
    spi_send_byte(N25_SPI_SEL, (addr >> 16) & 0xff);
    spi_send_byte(N25_SPI_SEL, (addr >> 8) & 0xff);
    spi_send_byte(N25_SPI_SEL, addr & 0xff);
    spi_send_bytes(N25_SPI_SEL, data, len);
    while (spi_busy_chk(N25_SPI_SEL)); //等待一次收发结束
    spi_set_cs(N25_SPI_SEL,DISABLE);

    while (n25q_is_busy());

    n25q_write_enable(0);
}
