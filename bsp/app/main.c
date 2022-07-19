#include "system.h"

uint8_t astr[60];
uint8_t program_data[N25Q_PAGE_SIZE];
uint8_t read_data[N25Q_PAGE_SIZE];
//测试
int main()
{
    uint32_t isp_base = 0x08000000;
    fpioa_setio(0,UART0_RX);
    fpioa_setio(1,UART1_TX);
    fpioa_setio(2,SPI0_CS);
    fpioa_setio(3,SPI0_MISO);
    fpioa_setio(4,SPI0_MOSI);
    fpioa_setio(5,SPI0_SCK);
    uart_init(25000000);
    xprintf("%s", "Hello world\n");
    (*((volatile uint32_t *)isp_base))=0x33445566;
    (*((volatile uint32_t *)isp_base+1))=0x778899aa;
    (*((volatile uint32_t *)isp_base+2))=0xbbccddee;
    (*((volatile uint32_t *)isp_base+3))=0xff551122;
    (*((volatile uint32_t *)isp_base+4))=0x00000000;
    uint32_t tmp;
    tmp=(*((volatile uint32_t *)isp_base));
    xprintf("%d\n",tmp);
    tmp=(*((volatile uint32_t *)isp_base+1));
    xprintf("%d\n",tmp);
    tmp=(*((volatile uint32_t *)isp_base+2));
    xprintf("%d\n",tmp);
    tmp=(*((volatile uint32_t *)isp_base+3));
    xprintf("%d\n",tmp);
    tmp=(*((volatile uint32_t *)isp_base+4));
    xprintf("%d\n",tmp);

    /*
    fpioa_setio(0, UART0_RX);
    fpioa_setio(1,UART1_TX);
    fpioa_setio(2,SPI0_CS);
    fpioa_setio(3,SPI0_MISO);
    fpioa_setio(4,SPI0_MOSI);
    fpioa_setio(5,SPI0_SCK);
    n25q_init(SPI0,1);
    uart_init(25000000);
    xprintf("%s", "Hello world\n");
    n25q_read_id(astr, 3);
    xprintf("manu id = 0x%x\n", astr[0]);
    xprintf("device id = 0x%x, 0x%x\n", astr[1], astr[2]);

    uint16_t i;

    // 初始化要编程的数据
    for (i = 0; i < N25Q_PAGE_SIZE; i++)
        program_data[i] = 0x55;
    xprintf("start erase subsector...\n");
    // 擦除第0个子扇区
    n25q_subsector_erase(0x00);
    xprintf("start program page...\n");
    // 编程第1页
    n25q_page_program(program_data, N25Q_PAGE_SIZE, 0);
    xprintf("start read page...\n");
    // 读第1页
    n25q_read_data(read_data, N25Q_PAGE_SIZE, 0);

    xprintf("read data: \n");
    // 打印读出来的数据
    for (i = 0; i < N25Q_PAGE_SIZE; i++)
        xprintf("0x%x\n", read_data[i]);
*/
    
}
