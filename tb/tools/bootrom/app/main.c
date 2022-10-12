#include "system.h"

uint8_t boot_key_flag[2];//boot[1:0]状态
uint8_t sm3_accl_flag;//SM3加速器使能
uint32_t cpu_csr_freq;//处理器频率Hz
uint32_t cpu_iram_size;//指令存储器大小kb
uint32_t cpu_sram_size;//数据存储器大小kb
uint32_t vendorid;//Vendor ID

uint8_t flash_data[256];//Flash读写缓冲区
uint32_t inst_addr = 8192;//指令指针
uint32_t sm3_hash[8];//SM3杂凑值256bit

/*
 * SM3校验规则
 * 输入app bin所有数据作为消息
 * 添加最后一个消息Vendor ID
 * 256bit杂凑值存储于0起始地址，小端存储
 * 从Flash启动会比对存储值与计算值
 */
//测试
int main()
{
    fpioa_perips_in_set(UART0_RX, 0);//配置必要引脚
    fpioa_perips_out_set(UART0_TX, 1);
    fpioa_perips_in_set(GPI0, 2);
    fpioa_perips_in_set(GPI1, 3);
    {//读取BOOT[1:0]，系统频率，SM3状态
        uint32_t tmp;//读取启动模式
        tmp = gpio_gpi_data_in();
        tmp = tmp & 0x00000003;
        boot_key_flag[0] = tmp & 0x00000001;
        boot_key_flag[1] = tmp >> 1;
        tmp=read_csr(mimpid);
        cpu_csr_freq = (tmp & 0x00007FFF) * 10000;
        sm3_accl_flag = (tmp & 0x00008000) >> 15;
        cpu_iram_size = ((tmp & 0x00FF0000) >> 16)*1024;
        cpu_sram_size = (tmp >> 24)*1024;
        vendorid = read_csr(mvendorid);
    }
    //配置波特率
    uart_band_ctr(UART0,25000000);//----115200
    uart_enable_ctr(UART0, ENABLE);
    uart_recv_date(UART0);
    //打印基本信息
    printf("%s", "Hello world SparrowRV\n");
    printf("boot key = %u %u \n",boot_key_flag[1],boot_key_flag[0]);
    printf("sys freq = %lu \n",cpu_csr_freq);
    printf("sm3 en = %d \n",sm3_accl_flag);
    printf("cpu_iram_size = %lu \n",cpu_iram_size);
    printf("cpu_sram_size = %lu \n",cpu_sram_size);
    printf("Vendor ID = %lx \n",vendorid);
    if(boot_key_flag[0] == 1)//初始化25Flash
    {
        uint8_t nor25_id_data[3];
        fpioa_perips_in_set(SPI0_MISO, 4);//配置Flash必要引脚
        fpioa_perips_out_set(SPI0_MOSI, 5);
        fpioa_perips_out_set(SPI0_SCK, 6);
        fpioa_perips_out_set(SPI0_CS, 7);
        n25q_init();//初始化
        n25q_read_id(nor25_id_data, 3);//读取JEDEC ID
        printf("Flash JEDEC ID = %x %x %x\n", nor25_id_data[0], nor25_id_data[1], nor25_id_data[2]);
    }
    //
    if(boot_key_flag[1] == 0)//启动
    {
        //
        if(boot_key_flag[0] == 1)//读flash
        {
            uint8_t i,j;//缓冲数据
            uint32_t tmp;//缓冲数据
            printf("%s", "SparrowRV BOOT_RF_STAR\n");
            //读出所有数据
            spi_set_cs(SPI0,ENABLE);
            spi_send_byte(SPI0, READ_CMD);
            spi_send_byte(SPI0, (inst_addr >> 16) & 0xff);
            spi_send_byte(SPI0, (inst_addr >> 8) & 0xff);
            spi_send_byte(SPI0, inst_addr & 0xff);
            while(inst_addr<cpu_iram_size)
            {
                tmp = 0;
                for(i=0; i<4; i++)
                {
                    tmp = tmp | spi_sdrv_byte(SPI0, 0x00) << (i*8);
                }
                SYS_RWMEM_W(inst_addr) = tmp;
                inst_addr = inst_addr+4;
                if(sm3_accl_flag)//SM3
                {
                    sm3_accl_in_data(tmp);
                }
            }
            spi_set_cs(SPI0,DISABLE);
            //SM3校验内容
            if(sm3_accl_flag)//SM3
            {
                uint32_t flash_sm3_hash[8];//flash存储的sm3
                sm3_accl_in_lst(ENABLE);
                sm3_accl_in_data(vendorid);
                sm3_accl_in_lst(DISABLE);
                while(sm3_accl_res_wait());
                for(i=0; i<8; i++)
                    sm3_hash[i] = sm3_accl_res_data(i);
                printf("SM3 current =");
                for(i=7; i<8; i--)
                {
                    printf("%lx",sm3_hash[i]);
                }
                printf("\n");

                spi_set_cs(SPI0,ENABLE);
                spi_send_byte(SPI0, READ_CMD);
                spi_send_byte(SPI0, 0x00);
                spi_send_byte(SPI0, 0x00);
                spi_send_byte(SPI0, 0x00);
                for(i=0 ; i<8 ; i++)
                {
                    tmp = 0;
                    for(j=0 ; j<4 ; j++)
                    {
                        tmp = tmp | spi_sdrv_byte(SPI0, 0x00) << (j*8);
                    }
                    flash_sm3_hash[i] = tmp;
                }
                spi_set_cs(SPI0,DISABLE);
                for(i=0; i<8; i++)
                {
                    if(sm3_hash[i] != flash_sm3_hash[i])//SM3不一致
                        tmp = 1;
                }
                if (tmp == 1)
                {
                    printf("SM3 Err!\n");
                    printf("SM3 in flash =");
                    for(i=7; i<8; i--)
                    {
                        printf("%lx",flash_sm3_hash[i]);
                    }
                    printf("\n");
                }
                else
                {
                    printf("SM3 Pass!\n");
                }
            }
        }
        else //直接启动
        {
            printf("%s", "SparrowRV BOOT_JP_STAR\n");
        }
        
    }
    //烧写
    else
    {
        //读串口到appram区域
        if(boot_key_flag[0] == 1)//写flash
        {
            printf("%s", "SparrowRV BOOT_UART_WF\n");
            //写flash
            //sm3
            //while(1);
        }
        else//串口烧写appram
        {
            printf("%s", "SparrowRV BOOT_UART_WI\n");
        }
    }
    //从appram启动
    printf("%s", "SparrowRV Startup\n");

    /*
    cnt =0;
    sm3_tmp =0;
    while (cnt<63)
    {
        sm3_accl_in_data(sm3_tmp);
        sm3_tmp +=5;
        cnt++;
    }
    sm3_accl_in_lst(ENABLE);
    sm3_accl_in_data(sm3_tmp);
    sm3_accl_in_lst(DISABLE);
    while(sm3_accl_res_wait());
    for(cnt=0; cnt<8; cnt++)
    {
        printf("sm3 res[%d] = %lx \n", cnt, sm3_accl_res_data(cnt));
    }
    */
}
