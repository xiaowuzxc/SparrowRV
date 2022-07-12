/*------------------------------------------------------------------------*/
/* Universal string handler for user console interface  (C)ChaN, 2011     */
/*------------------------------------------------------------------------*/

#ifndef _XPRINTF_H_
#define _XPRINTF_H_
#include "system.h"
#define	_CR_CRLF		0	/* 1: Convert \n ==> \r\n in the output char */

#define xdev_out(func) xfunc_out = (void(*)(unsigned char))(func)
extern void (*xfunc_out)(unsigned char);
void xputc (char c);
void xputs (const char* str);
void xprintf (const char* fmt, ...);

void uart_init(uint32_t band);
void uart_putc(uint32_t uart_send);

#define DW_CHAR		sizeof(char)
#define DW_SHORT	sizeof(short)
#define DW_LONG		sizeof(long)

#endif
