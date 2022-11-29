# 小麻雀处理器-扩展版
[![rvlogo](/doc/图库/Readme/rvlogo.bmp)RISC-V官网收录](https://riscv.org/exchange/?_sf_s=sparrowrv)  
[![teelogo](/doc/图库/Readme/giteetj.bmp)Gitee推荐项目](https://gitee.com/explore/risc-v)  
## 简介
小麻雀处理器-扩展版(SparrowRV-EX)是一款RISC-V架构的32位标量乱序变长流水线处理器。  

**设计指标：**  
- 兼容RV32IMABC Zicsr Zifencei指令集  
- 乱序(主副槽)单发射-乱序写回  
- 哈佛结构，指令存储器映射至存储器空间  
- 支持C语言，有配套BSP  
- 支持AXI4-Lite总线  

**流水线功能框图**  
![流水线](/doc/图库/Readme/乱序变长流水.svg)  



