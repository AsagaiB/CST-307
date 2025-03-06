.equ JTAG_UART_DATA,  0xFF201000  @ JTAG UART Data Register
.equ JTAG_UART_CTRL,  0xFF201004  @ JTAG UART Control Register

.section .text
.global _start

_start:
    @ Initialize registers
    mov r5, #0                @ First number
    mov r6, #0                @ Second number
    mov r7, #0                @ State: 0=first tens, 1=first ones, 2=second tens, 3=second ones
    mov r8, #0                @ Buffer to accumulate all 4 digits
    
    @ Main program loop
main_loop:
    @ Check if there's data in the JTAG UART
    bl check_uart_input
    cmp r0, #0                @ Check if no valid input
    beq main_loop             @ If no valid input, keep checking
    
    @ Validate digit
    cmp r0, #'0'              @ Check if character is < '0'
    blt main_loop             @ If not a digit, ignore
    cmp r0, #'9'              @ Check if character is > '9'
    bgt main_loop             @ If not a digit, ignore
    
    @ Store digit in the buffer
    mov r1, r8, lsl #4        @ Shift buffer left by 4 bits (multiply by 16)
    sub r2, r0, #'0'          @ Convert ASCII to number
    add r8, r1, r2            @ Add new digit to buffer
    
    @ Increment state
    add r7, r7, #1            @ Move to next state
    cmp r7, #4                @ Check if all 4 digits received
    bne main_loop             @ If not done, continue reading
    
    @ Extract first and second numbers from buffer
    mov r1, r8, lsr #8        @ Get first number (first 2 digits)
    and r5, r1, #0xFF         @ Mask to get only 2 digits
    and r6, r8, #0xFF         @ Get second number (last 2 digits)
    
    @ Display the numbers with space between them
    mov r0, r5, lsr #4        @ Get tens digit of first number
    add r0, r0, #'0'          @ Convert to ASCII
    bl write_char             @ Print tens digit
    
    mov r0, r5                @ Get ones digit of first number
    and r0, r0, #0xF
    add r0, r0, #'0'          @ Convert to ASCII
    bl write_char             @ Print ones digit
    
    mov r0, #' '              @ Print space
    bl write_char
    
    mov r0, r6, lsr #4        @ Get tens digit of second number
    add r0, r0, #'0'          @ Convert to ASCII
    bl write_char             @ Print tens digit
    
    mov r0, r6                @ Get ones digit of second number
    and r0, r0, #0xF
    add r0, r0, #'0'          @ Convert to ASCII
    bl write_char             @ Print ones digit
    
    mov r0, #' '              @ Print space
    bl write_char
    
    @ Compare the two numbers using flags
    cmp r6, r5                @ Compare second to first
    beq print_equal           @ If equal (ZF=1), print "equal"
    bhi print_bigger          @ If higher (CF=0 and ZF=0), print "bigger"
    blo print_less            @ If lower (CF=1), print "less"
    
print_bigger:
    @ Print "bigger"
    ldr r4, =bigger_msg
    bl print_string
    b reset_state

print_equal:
    @ Print "equal"
    ldr r4, =equal_msg
    bl print_string
    b reset_state

print_less:
    @ Print "less"
    ldr r4, =less_msg
    bl print_string
    b reset_state

reset_state:
    @ Reset to initial state to read two new numbers
    mov r7, #0                @ Reset state
    mov r5, #0                @ Reset first number
    mov r6, #0                @ Reset second number
    mov r8, #0                @ Reset digit buffer
    b main_loop

@ -----------------------------------
@ Check for UART Input
@ Returns character in r0, or 0 if no valid input
@ -----------------------------------
check_uart_input:
    push {r1, r2, lr}
    
    @ Check if there's data in the JTAG UART
    ldr r1, =JTAG_UART_CTRL
    ldr r2, [r1]              @ Read control register
    lsr r2, r2, #16           @ Extract Read FIFO count
    cmp r2, #0                @ Check if FIFO has data
    moveq r0, #0              @ If no data, return 0
    beq check_uart_exit
    
    @ Read the character
    ldr r1, =JTAG_UART_DATA
    ldr r0, [r1]              @ Read the character and remove from FIFO
    
    @ Check if valid character
    tst r0, #0x8000           @ Test bit 15 (RVALID)
    moveq r0, #0              @ If not valid, set to 0
    bne extract_char          @ If valid, extract character
    b check_uart_exit
    
extract_char:
    and r0, r0, #0xFF         @ Extract just the character (bits 0-7)
    
check_uart_exit:
    pop {r1, r2, pc}

@ -----------------------------------
@ Write a Character to JTAG UART
@ -----------------------------------
write_char:
    push {r1, r2, r3, lr}
    mov r3, r0                @ Save character
    
write_wait:
    ldr r1, =JTAG_UART_CTRL
    ldr r2, [r1]              @ Read control register
    lsr r2, r2, #16           @ Extract Write FIFO space available
    cmp r2, #0                @ Check if FIFO has space
    beq write_wait            @ If FIFO is full, keep waiting
    
    ldr r1, =JTAG_UART_DATA
    str r3, [r1]              @ Write character
    
    pop {r1, r2, r3, pc}

@ -----------------------------------
@ Print a null-terminated string
@ String address should be in r4
@ -----------------------------------
print_string:
    push {r0, r4, lr}
    
print_loop:
    ldrb r0, [r4], #1         @ Load byte and increment pointer
    cmp r0, #0                @ Check for null terminator
    beq print_string_exit     @ If null, exit
    bl write_char             @ Print the character
    b print_loop              @ Continue with next character
    
print_string_exit:
    pop {r0, r4, pc}

@ -----------------------------------
@ Data section
@ -----------------------------------
.section .data
bigger_msg:
    .asciz "bigger\n"
equal_msg:
    .asciz "equal\n"
less_msg:
    .asciz "less\n"