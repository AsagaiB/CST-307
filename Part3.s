.equ JTAG_UART_DATA,  0xFF201000      @ JTAG UART Data Register
.equ JTAG_UART_CTRL,  0xFF201004      @ JTAG UART Control Register
.equ SEVENSEG,        0xFF200020      @ Base address for 7-seg display

.section .text
.global _start

_start:
    ldr r4, =uart_msg            @ r4 points to the UART message string
    ldr r1, =digit_table         @ r1 points to the 7-seg conversion table

print_loop:
    ldrb r2, [r4], #1            @ Load next byte from message into r2; increment r4
    cmp r2, #0                   @ Check if null terminator reached
    beq end_program              @ If end-of-string, branch to end_program
    mov r0, r2                   @ Move character from r2 into r0 for UART printing
    bl write_char                @ Call write_char to print the character via UART
    ldr r3, [r1]                 @ Load current digit pattern from table into r3
    cmp r3, #0                   @ Check if table terminator reached
    beq reset_digit_table        @ If so, branch to reset_digit_table
    mov r0, r3                   @ Move digit pattern from r3 into r0 for 7-seg update
    bl update_7seg               @ Call update_7seg to update 7-seg display with pattern
    add r1, r1, #4               @ Increment digit table pointer by 4 bytes
    bl delay_1s                  @ Call delay_1s to wait approximately one second
    b print_loop                 @ Branch back to print_loop to process next character

reset_digit_table:
    ldr r1, =digit_table         @ Reset r1 to point to the start of digit_table
    b print_loop                 @ Branch back to print_loop

end_program:
    b end_program                @ Infinite loop to end program

@ -----------------------------------
@ Write a Character to JTAG UART
@ r0 contains the character to be printed
@ -----------------------------------
write_char:
    push {r0, r1, r2, lr}        @ Save r0, r1, r2, and lr
wait_for_tx:
    ldr r1, =JTAG_UART_CTRL     @ Load address of UART control register into r1
    ldr r2, [r1]                @ Read UART control register into r2
    lsr r2, r2, #16             @ Extract TX FIFO space from bits 31:16 in r2
    cmp r2, #0                  @ Check if TX FIFO is full (no space available)
    beq wait_for_tx             @ If FIFO is full, loop back to wait_for_tx
    ldr r1, =JTAG_UART_DATA     @ Load address of UART data register into r1
    str r0, [r1]                @ Write the character in r0 to UART data register
    pop {r0, r1, r2, pc}        @ Restore r0, r1, r2 and return via lr

@ -----------------------------------
@ Update the 7-Segment Display
@ r0 contains the 7-seg digit pattern to display
@ -----------------------------------
update_7seg:
    push {r5}                   @ Save r5 (callee-saved register)
    ldr r5, =SEVENSEG           @ Load address of 7-seg display into r5
    str r0, [r5]                @ Write digit pattern in r0 to the 7-seg display register
    pop {r5}                    @ Restore r5
    bx lr                       @ Return from update_7seg

@ -----------------------------------
@ Delay Subroutine (approx. 1 second)
@ r3 is used as the delay counter (adjust value if necessary)
@ -----------------------------------
delay_1s:
    mov r3, #0x200000           @ Load delay counter with constant value
delay_loop:
    subs r3, r3, #1             @ Decrement delay counter by 1
    bne delay_loop              @ Loop until counter reaches 0
    bx lr                       @ Return from delay_1s

.section .rodata
uart_msg:
    .asciz "HELLO ALL. I AM HERE\n"  @ Null-terminated UART message string

.align 2                         @ Align digit_table to a 4-byte boundary
digit_table:
    .word 0x06                 @ 7-seg pattern for digit 1
    .word 0x5B                 @ 7-seg pattern for digit 2
    .word 0x4F                 @ 7-seg pattern for digit 3
    .word 0x66                 @ 7-seg pattern for digit 4
    .word 0x6D                 @ 7-seg pattern for digit 5
    .word 0x7D                 @ 7-seg pattern for digit 6
    .word 0x07                 @ 7-seg pattern for digit 7
    .word 0x7F                 @ 7-seg pattern for digit 8
    .word 0x6F                 @ 7-seg pattern for digit 9
    .word 0x0                  @ Table terminator
