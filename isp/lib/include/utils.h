#include "system.h"
#ifndef _UTILS_H_
#define _UTILS_H_

#define CPU_FREQ_HZ   (SYS_FRE)  // 25MHz
#define CPU_FREQ_MHZ  (SYS_FRE/1000000)        // 25MHz


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

#define read_csr(reg)        __read_csr(reg) 
#define write_csr(reg, val)  __write_csr(reg, val)
#define set_csr(reg, val)    __set_csr(reg, val)
#define clear_csr(reg, val)  __clear_csr(reg, val)

uint64_t get_cycle_value();
void busy_wait(uint32_t us);

#endif
