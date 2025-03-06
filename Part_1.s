.section .text
.global _start

_start:
    LDR R0, =0xFF200000  // Load correct GPIO Base Address for DE1-SoC (CPUlator internal LEDs)
    MOV R1, #1           // Start with the first LED

loop:
    STR R1, [R0]         // Write to GPIO (turn on one LED)
    BL delay             // Call delay function
    MOV R2, #0           // Turn off current LED
    STR R2, [R0]         // Write to GPIO (turn off LED)
    BL delay             // Call delay function
    LSL R1, R1, #1       // Shift left to move to the next LED
    CMP R1, #0x100       // Adjusted to match correct number of LEDs
    BNE loop             // Continue looping
    MOV R1, #1           // Reset to first LED
    B loop               // Repeat

// Delay function
.global delay
.type delay, %function
delay:
    LDR R2, =0xFFFFF     // Load delay count
loop_delay:
    SUBS R2, R2, #1      // Decrement counter
    BNE loop_delay       // Repeat until zero
    BX LR                // Return from function