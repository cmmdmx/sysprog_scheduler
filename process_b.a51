; disable predefined 8051 registers and include CPU definition file (for example, 8052)
$NOMOD51
#include <REG517A.h>	

NAME process_b
	
	PUBLIC run_b
	PUBLIC b_interrupt
		
	_data SEGMENT DATA
		RSEG _data
		ticks: DS 1								; ticks : 31 ticks are ~ one second in 8051, 1 tick is 1 overflow of timer 1
	
	_bit SEGMENT BIT
		RSEG _bit
		active: DBIT 1
	
	_code SEGMENT CODE
		RSEG _code
	
	run_b:										; main routin of process b
		JB active, loopa						; jump directly to loopa if b is already active
		
		SETB TR1
		SETB ET1
		
		MOV R0, #31								; R0  is check variable		
		MOV ticks, #0							; Reset ticks at process start
		
		SETB active								; process b is active	
		
		MOV B, #'+'								; write 'b' to serial device 0
		CALL write
		
		loopa:
			
			MOV A, ticks
			SUBB A, R0
			CJNE A, #0, loopa					; compare, wether ticks is 31, if no, stay in loop
			CLR active
			JMP run_b							; jmp to run_b and start again
		
	write:	
		CLR EAL									; deactivate global interrupts
		MOV S0BUF, B							; move content from B into S0BUF (write to serial device 0)
	loop:
		SETB WDT								; refresh watchdog
		SETB SWDT
		JNB TI0, loop							; loop as long serial device 0 is sending
		CLR TI0
		SETB EAL								; activate interrupts after sending to serial
		RET
		
	b_interrupt:								; interrupt routine of timer 1
		
		CLR EAL									; deactivate interrupts
		CLR TR1
		
		MOV A, #32								
		INC ticks								; increment 'ticks'
		CJNE A, ticks, end_interrupt			; if 'ticks' is greater than 31, it should have 31
		MOV ticks, #31
		
		end_interrupt:							; end interrupt
				
			SETB TR1
			SETB EAL
			RETI
	
END