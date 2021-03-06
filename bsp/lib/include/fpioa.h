#ifndef _FPIOA_H_
#define _FPIOA_H_

#include "system.h"
#define SYSIO_BASE           (0x20000000)
#define FPIOA_BASE           (SYSIO_BASE + (0xF00))
#define FPIOA_REG_B(addr,offset) (*((volatile uint8_t *)(addr + offset)))
void fpioa_setio(uint32_t FPIOAx, uint8_t fpioa_function);
uint8_t fpioa_read(uint32_t FPIOAx);
/*------------------------------
 * 外设端口布局
 * 最大支持256个外设端口，外设端口0恒为空端口
 * 端口布局由 [Number/编号] [Function/功能] [描述] 构成，布局列表如下：
 * | Number   | Function        | 描述                      
 * |----------|-----------------|------------------------------------
 * | 0        | DEF_Null        | FPIOA端口默认状态，高阻，输入输出无效
 * | 1        | SPI0_SCK        | SPI0 SCK 时钟输出
 * | 2        | SPI0_MOSI       | SPI0 MOSI 数据输出
 * | 3        | SPI0_MISO       | SPI0 MISO 数据输入
 * | 4        | SPI0_CS         | SPI0 CS 片选输出，低有效
 * | 5        | SPI1_SCK        | SPI1 SCK 时钟输出
 * | 6        | SPI1_MOSI       | SPI1 MOSI 数据输出
 * | 7        | SPI1_MISO       | SPI1 MISO 数据输入
 * | 8        | SPI1_CS         | SPI1 CS 片选输出，低有效
 * | 9        | UART0_TX        | UART0 Tx 串口数据输出
 * | 10       | UART0_RX        | UART0 Rx 串口数据输入
 * | 11       | UART1_TX        | UART1 Tx 串口数据输出
 * | 12       | UART1_RX        | UART1 Rx 串口数据输入
 * | 13       | GPIO0           | 
 * | 14       | GPIO1           | 
 * | 15       | GPIO2           | 
 * | 16       | GPIO3           | 
 * | 17       | GPIO4           | 
 * | 18       | GPIO5           | 
 * | 19       | GPIO6           | 
 * | 20       | GPIO7           | 
 * | 21       | GPIO8           | 
 * | 22       | GPIO9           | 
 * | 23       | GPIO10          | 
 * | 24       | GPIO11          | 
 * | 25       | GPIO12          | 
 * | 26       | GPIO13          | 
 * | 27       | GPIO14          | 
 * | 28       | GPIO15          | 
 * | 29       | GPIO16          | 
 * | 30       | GPIO17          | 
 * | 31       | GPIO18          | 
 * | 32       | GPIO19          | 
 * | 33       | GPIO20          | 
 * | 34       | GPIO21          | 
 * | 35       | GPIO22          | 
 * | 36       | GPIO23          | 
 * | 37       | GPIO24          | 
 * | 38       | GPIO25          | 
 * | 39       | GPIO26          | 
 * | 40       | GPIO27          | 
 * | 41       | GPIO28          | 
 * | 42       | GPIO29          | 
 * | 43       | GPIO30          | 
 * | 44       | GPIO31          | 
 * | 45       |                 | 
 * | 46       |                 | 
 * | 47       |                 | 
 * | 48       |                 | 
 * | 49       |                 | 
 * | 50       |                 | 
 * | 51       |                 | 
 * | 52       |                 | 
 * | 53       |                 | 
 * | 54       |                 | 
 * | 55       |                 | 
 * | 56       |                 | 
 * | 57       |                 | 
 * | 58       |                 | 
 * | 59       |                 | 
 * | 60       |                 | 
 * | 61       |                 | 
 * | 62       |                 | 
 * | 63       |                 | 
 * | 64       |                 | 
 * | 65       |                 | 
 * | 66       |                 | 
 * | 67       |                 | 
 * | 68       |                 | 
 * | 69       |                 | 
 * | 70       |                 | 
 * | 71       |                 | 
 * | 72       |                 | 
 * | 73       |                 | 
 * | 74       |                 | 
 * | 75       |                 | 
 * | 76       |                 | 
 * | 77       |                 | 
 * | 78       |                 | 
 * | 79       |                 | 
 * | 80       |                 | 
 * | 81       |                 | 
 * | 82       |                 | 
 * | 83       |                 | 
 * | 84       |                 | 
 * | 85       |                 | 
 * | 86       |                 | 
 * | 87       |                 | 
 * | 88       |                 | 
 * | 89       |                 | 
 * | 90       |                 | 
 * | 91       |                 | 
 * | 92       |                 | 
 * | 93       |                 | 
 * | 94       |                 | 
 * | 95       |                 | 
 * | 96       |                 | 
 * | 97       |                 | 
 * | 98       |                 | 
 * | 99       |                 | 
 * | 100      |                 | 
 * | 101      |                 | 
 * | 102      |                 | 
 * | 103      |                 | 
 * | 104      |                 | 
 * | 105      |                 | 
 * | 106      |                 | 
 * | 107      |                 | 
 * | 108      |                 | 
 * | 109      |                 | 
 * | 110      |                 | 
 * | 111      |                 | 
 * | 112      |                 | 
 * | 113      |                 | 
 * | 114      |                 | 
 * | 115      |                 | 
 * | 116      |                 | 
 * | 117      |                 | 
 * | 118      |                 | 
 * | 119      |                 | 
 * | 120      |                 | 
 * | 121      |                 | 
 * | 122      |                 | 
 * | 123      |                 | 
 * | 124      |                 | 
 * | 125      |                 | 
 * | 126      |                 | 
 * | 127      |                 | 
 * | 128      |                 | 
 * | 129      |                 | 
 * | 130      |                 | 
 * | 131      |                 | 
 * | 132      |                 | 
 * | 133      |                 | 
 * | 134      |                 | 
 * | 135      |                 | 
 * | 136      |                 | 
 * | 137      |                 | 
 * | 138      |                 | 
 * | 139      |                 | 
 * | 140      |                 | 
 * | 141      |                 | 
 * | 142      |                 | 
 * | 143      |                 | 
 * | 144      |                 | 
 * | 145      |                 | 
 * | 146      |                 | 
 * | 147      |                 | 
 * | 148      |                 | 
 * | 149      |                 | 
 * | 150      |                 | 
 * | 151      |                 | 
 * | 152      |                 | 
 * | 153      |                 | 
 * | 154      |                 | 
 * | 155      |                 | 
 * | 156      |                 | 
 * | 157      |                 | 
 * | 158      |                 | 
 * | 159      |                 | 
 * | 160      |                 | 
 * | 161      |                 | 
 * | 162      |                 | 
 * | 163      |                 | 
 * | 164      |                 | 
 * | 165      |                 | 
 * | 166      |                 | 
 * | 167      |                 | 
 * | 168      |                 | 
 * | 169      |                 | 
 * | 170      |                 | 
 * | 171      |                 | 
 * | 172      |                 | 
 * | 173      |                 | 
 * | 174      |                 | 
 * | 175      |                 | 
 * | 176      |                 | 
 * | 177      |                 | 
 * | 178      |                 | 
 * | 179      |                 | 
 * | 180      |                 | 
 * | 181      |                 | 
 * | 182      |                 | 
 * | 183      |                 | 
 * | 184      |                 | 
 * | 185      |                 | 
 * | 186      |                 | 
 * | 187      |                 | 
 * | 188      |                 | 
 * | 189      |                 | 
 * | 190      |                 | 
 * | 191      |                 | 
 * | 192      |                 | 
 * | 193      |                 | 
 * | 194      |                 | 
 * | 195      |                 | 
 * | 196      |                 | 
 * | 197      |                 | 
 * | 198      |                 | 
 * | 199      |                 | 
 * | 200      |                 | 
 * | 201      |                 | 
 * | 202      |                 | 
 * | 203      |                 | 
 * | 204      |                 | 
 * | 205      |                 | 
 * | 206      |                 | 
 * | 207      |                 | 
 * | 208      |                 | 
 * | 209      |                 | 
 * | 210      |                 | 
 * | 211      |                 | 
 * | 212      |                 | 
 * | 213      |                 | 
 * | 214      |                 | 
 * | 215      |                 | 
 * | 216      |                 | 
 * | 217      |                 | 
 * | 218      |                 | 
 * | 219      |                 | 
 * | 220      |                 | 
 * | 221      |                 | 
 * | 222      |                 | 
 * | 223      |                 | 
 * | 224      |                 | 
 * | 225      |                 | 
 * | 226      |                 | 
 * | 227      |                 | 
 * | 228      |                 | 
 * | 229      |                 | 
 * | 230      |                 | 
 * | 231      |                 | 
 * | 232      |                 | 
 * | 233      |                 | 
 * | 234      |                 | 
 * | 235      |                 | 
 * | 236      |                 | 
 * | 237      |                 | 
 * | 238      |                 | 
 * | 239      |                 | 
 * | 240      |                 | 
 * | 241      |                 | 
 * | 242      |                 | 
 * | 243      |                 | 
 * | 244      |                 | 
 * | 245      |                 | 
 * | 246      |                 | 
 * | 247      |                 | 
 * | 248      |                 | 
 * | 249      |                 | 
 * | 250      |                 | 
 * | 251      |                 | 
 * | 252      |                 | 
 * | 253      |                 | 
 * | 254      |                 | 
 * | 255      |                 | 
 * |----------|-----------------|------------------------------------
 */
#define  DEF_Null      0 
#define  SPI0_SCK      1 
#define  SPI0_MOSI     2 
#define  SPI0_MISO     3 
#define  SPI0_CS       4 
#define  SPI1_SCK      5 
#define  SPI1_MOSI     6 
#define  SPI1_MISO     7 
#define  SPI1_CS       8 
#define  UART0_TX      9 
#define  UART0_RX      10
#define  UART1_TX      11
#define  UART1_RX      12
#define  GPIO0         13
#define  GPIO1         14
#define  GPIO2         15
#define  GPIO3         16
#define  GPIO4         17
#define  GPIO5         18
#define  GPIO6         19
#define  GPIO7         20
#define  GPIO8         21
#define  GPIO9         22
#define  GPIO10        23
#define  GPIO11        24
#define  GPIO12        25
#define  GPIO13        26
#define  GPIO14        27
#define  GPIO15        28
#define  GPIO16        29
#define  GPIO17        30
#define  GPIO18        31
#define  GPIO19        32
#define  GPIO20        33
#define  GPIO21        34
#define  GPIO22        35
#define  GPIO23        36
#define  GPIO24        37
#define  GPIO25        38
#define  GPIO26        39
#define  GPIO27        40
#define  GPIO28        41
#define  GPIO29        42
#define  GPIO30        43
#define  GPIO31        44

#endif