# 上电启动与ISP系统
**注意：此文档仅适用于上电复位！**   
若处理器正在执行用户程序，即`mcctr[4]`=1，那么外部、内部、JTAG复位均不能有效控制启动方式。  

## 双指令存储器设计
小麻雀处理器有两个指令存储器：`bootrom`  `appram`  
它们共享同一块地址空间，起始地址0x0000_0000  
CSR(0xB88)`mcctr[4]`决定了此地址映射哪一个存储器  
|mcctr[4]|取指来源|
|-|-|
|0|bootrom|
|1|appram|

`mcctr[4]`仅接受上电复位，不接受其他复位方式(外部、软件、JTAG)  
需要注意，`bootrom`无法写入；通过AXI4-Lite Slave接口，若进行写操作，无论`mcctr[4]`为多少，数据均写入`appram`  

## 上电启动方式选择
小麻雀处理器上电后访问固化了ISP程序的`bootrom`存储器，通过BOOT0、BOOT1引脚选择小麻雀处理器上电的启动方式。  

|启动方式|BOOT1|BOOT0|
|-|-|-|
|直接从appram启动|0|0|
|读取Flash后启动|0|1|
|串口烧写appram|1|0|
|串口烧写Flash|1|1|

### 直接从appram启动
`bootrom`不进行任何操作  
跳转进入`appram`并启动  

### 读取Flash后启动
`bootrom`阶段，读取Flash存储器，并对比SM3杂凑值  
如果SM3杂凑值正确，数据写入`appram`后跳转进入`appram`并启动  
如果SM3杂凑值错误，数据写入`appram`后死循环   

### 串口烧写appram
`bootrom`阶段，通过串口向`appram`写入数据  
写入结束后，跳转进入`appram`  
`appram`阶段，若BOOT配置为`2'b10`，跳转进入`bootrom`  
**烧写完成后需尽快将BOOT配置为`2'b00`**  

### 串口烧写Flash
`bootrom`阶段，通过串口向`appram`写入数据  
写入结束后，跳转进入`appram`  
`appram`阶段，若BOOT配置为`2'b11`，将指令和SM3杂凑值写入Flash，然后死循环    

## 推荐的Flash固化方法
设备关机，启动方式配置为`串口烧写Flash`，然后FPGA上电，通过串口烧写  







