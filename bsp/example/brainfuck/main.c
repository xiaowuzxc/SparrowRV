#include "system.h"

#define code_length 100

char code[256]="...put BF code here...";

int i=0,j,k,x=0;
char f[32];
char* p=f;

int stack[100];
int stack_len=0;

void BFCI();


int main()
{
    init_uart0_printf(115200);
    printf("Brainfuck C Interpreter\n");
    BFCI();
    printf("\nBrainfuck C Interpreter END\n");
}


//Brainfuck interpreter
void BFCI() {
    while(i<code_length) {
        switch(code[i]) {
            case '+':
                (*p)++;
                break;
            case '-':
                (*p)--;
                break;
            case '>':
                p++;
                break;
            case '<':
                p--;
                break;
            case '.':
                printf("%c",*p);
                break;
            case ',':
                *p=uart_recv_date(UART0);
                break;
            case '[':
                if(*p) {
                    stack[stack_len++]=i;
                } else {
                    for(k=i,j=0;k<code_length;k++) {
                        code[k]=='['&&j++;
                        code[k]==']'&&j--;
                        if(j==0)break;
                    }
                    if(j==0)
                        i=k;
                    else {
                        printf("Err 3\n");
                    }
                }
                break;
            case ']':
                i=stack[stack_len-- - 1]-1;
                break;
            default:
                printf("Err 0\n");
                break;
        }
        i++;
    }
}
