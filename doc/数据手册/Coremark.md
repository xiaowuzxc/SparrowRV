## Coremark跑分
**系统配置**  
- SGCY_MUL
- DIV_MODE "HF_DIV"
- RV32IM
- GCC8.2.0 -o3

```
Start Coremark
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 718395227
Total time (secs): 29.933131
Iterations/Sec   : 66.815597
Iterations       : 2000
Compiler version : GCC8.2.0
Compiler flags   : -O3 -fno-common -funroll-loops -finline-functions --param max-inline-insns-auto=20 -falign-functions=4 -falign-jumps=4 -falign-loops=4
Memory location  : STATIC
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x4983
Correct operation validated. See readme.txt for run and reporting rules.
CoreMark 1.0 : 66.815597 / GCC8.2.0 -O2 -fno-common -funroll-loops -finline-functions --param max-inline-insns-auto=20 -falign-functions=4 -falign-jumps=4 -falign-loops=4 / STATIC
SparrowRV Coremark = 2.783983 CoreMark/MHz
```
