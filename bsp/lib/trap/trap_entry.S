    .section      .text.entry	
    .align 2
    .global trap_entry
trap_entry:

    addi sp, sp, -16*4

    sw x1 , 0*4(sp)
    sw x5 , 1*4(sp)
    sw x6 , 2*4(sp)
    sw x7 , 3*4(sp)
    sw x10, 4*4(sp)
    sw x11, 5*4(sp)
    sw x12, 6*4(sp)
    sw x13, 7*4(sp)
    sw x14, 8*4(sp)
    sw x15, 9*4(sp)
    sw x16, 10*4(sp)
    sw x17, 11*4(sp)
    sw x28, 12*4(sp)
    sw x29, 13*4(sp)
    sw x30, 14*4(sp)
    sw x31, 15*4(sp)


    csrr a0, mcause
    csrr a1, mepc
test_if_asynchronous:
	srli a2, a0, 31		                /* MSB of mcause is 1 if handing an asynchronous interrupt - shift to LSB to clear other bits. */
	beq a2, x0, handle_synchronous		/* Branch past interrupt handing if not asynchronous. */

    call trap_handler
    j asynchronous_return

handle_synchronous:
    addi a1, a1, 4
    csrw mepc, a1

asynchronous_return:
    lw x1 , 0*4(sp)
    lw x5 , 1*4(sp)
    lw x6 , 2*4(sp)
    lw x7 , 3*4(sp)
    lw x10, 4*4(sp)
    lw x11, 5*4(sp)
    lw x12, 6*4(sp)
    lw x13, 7*4(sp)
    lw x14, 8*4(sp)
    lw x15, 9*4(sp)
    lw x16, 10*4(sp)
    lw x17, 11*4(sp)
    lw x28, 12*4(sp)
    lw x29, 13*4(sp)
    lw x30, 14*4(sp)
    lw x31, 15*4(sp)


    addi sp, sp, 16*4

    mret


.weak trap_handler
trap_handler:
1:
    j 1b
