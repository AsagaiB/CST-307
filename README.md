# CST-307
CST-307 CLC - I/O System Design Part 1
****************************************************************
Presentation in Word Doc.
****************************************************************
Part 1: This assembly program controls the internal LEDs in CPUlator, blinking them one at a time with a delay.

Requirements
CPUlator (ARMv7 DE1-SoC emulator)
ARMv7 assembly
Basic GPIO knowledge
Setup & Execution
Open CPUlator and select ARMv7 DE1-SoC.
Copy and paste the assembly code.
Click Assemble and Load, then Run.
Expected Output
LEDs blink sequentially with a delay.
Cycle restarts after the last LED.
Troubleshooting
No LED output? Ensure CPUlator is in DE1-SoC mode.
Error: Not mapped to any device? Set GPIO base to 0xFF200000.
Some LEDs not blinking? Check loop reset logic.


Part 2: Fernando Godinez
Asagai Barbee

CST-307 CLC - I/O System Design Part 2
****************************************************************
Presentation in Word Doc.
****************************************************************
Execution:

Requirements:
	*Cpulator Arm Emulator: https://cpulator.01xz.net/?sys=arm-de1soc
	*Part2.s File

Compilation Instructions:
1. Load Part2.s File from menu in Cpulator Arm Emulator
2. Click on Compile and Load
3. Press Continue
4. Select the JTAG_UART Terminal
5. Enter the two numbers to be compared (No separation or spaces required, just two two digit numbers back to back, 
   For single digit numbers enter a 0 before the number)
6. Once the fourth digit is entered The JTAG_UART Terminal should display the answer of whether the second number 
   is greater than, less than, or equal to the first number.
7. Repeat Steps 5-6 for further use, otherwise select the Stop button to end the code.
	
Part 3:
Fernando Godinez
Asagai Barbee

CST-307 CLC = I/O System Design Part 3
****************************************************************
Presentation in Word Doc.
****************************************************************
Execution:

Requirements:
	*Cpulator Arm Emulator: https://cpulator.01xz.net/?sys=arm-de1soc
	*Part3.s File

Compilation Instructions:
1. Load Part3.s File from menu in Cpulator Arm Emulator
2. Click on Compile and Load
3. Press Continue
4. Observe the JTAG UART and 7 Segment display output boxes to see the code display the string and update the digit as it runs
Part 3:
