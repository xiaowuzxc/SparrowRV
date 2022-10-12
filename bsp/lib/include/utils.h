
#ifndef _UTILS_H_
#define _UTILS_H_
#include "system.h"

#define cpu_nop ({asm volatile( "nop");})

#define __read_csr(reg) ({ unsigned long __tmp; \
  asm volatile ("csrr %0, " #reg : "=r"(__tmp)); \
  __tmp; })

#define __write_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrw " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrw " #reg ", %0" :: "r"(val)); })

#define __set_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrs " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrs " #reg ", %0" :: "r"(val)); })

#define __clear_csr(reg, val) ({ \
  if (__builtin_constant_p(val) && (unsigned long)(val) < 32) \
    asm volatile ("csrc " #reg ", %0" :: "i"(val)); \
  else \
    asm volatile ("csrc " #reg ", %0" :: "r"(val)); })

#define read_csr(reg)        __read_csr(reg)       //读取CSR
#define write_csr(reg, val)  __write_csr(reg, val) //写入CSR
#define set_csr(reg, val)    __set_csr(reg, val)   //CSR置1
#define clear_csr(reg, val)  __clear_csr(reg, val) //CSR清0

uint64_t mtime_value_get();
void mtime_value_set(uint64_t value64b);
void mtime_en_ctr(uint8_t mtime_en);
uint64_t minstret_value_get();
void minstret_value_set(uint64_t value64b);
void minstret_en_ctr(uint8_t minstret_en);
void delay_sys_wait(uint32_t us);
void core_reset_enable();
void core_sim_end();
uint32_t sm3_accl_in_busy();
uint32_t sm3_accl_res_wait();
uint32_t sm3_accl_res_data(uint32_t sm3_res_sel);
void sm3_accl_in_lst(uint32_t sm3_lst_ctr);
void sm3_accl_in_data(uint32_t sm3_data);




#endif
