; disable predefined 8051 registers and include CPU definition file (for example, 8052)
$NOMOD51
#include <REG517A.h>	

NAME process_b
	
	PUBLIC run_b
	PUBLIC b_interrupt
		
	_data SEGMENT DATA
		RSEG _data
		ticks: DS 1
	
	_code SEGMENT CODE
		RSEG _code
	
	run_b:
		MOV ticks, #0
		SETB TR1
		
		MOV B, #'+'
		CALL write
		
		MOV R0, #31
		
		loopa:
			
		
		
		
		RET
		
		
	write:	
		CLR EAL							; deactivate global interrupts
		MOV S0BUF, B
	loop:
		SETB WDT
		SETB SWDT
		JNB TI0, loop
		CLR TI0
		SETB EAL						; activate interrupts after sending to serial
		RET
		
	b_interrupt:
		
		CLR EAL
		CLR TR1
		
		INC ticks
		
		SETB TR1
		SETB EAL
	
END