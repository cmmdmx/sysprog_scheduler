; disable predefined 8051 registers and include CPU definition file (for example, 8052)
$NOMOD51
#include <REG517A.h>	

NAME process_a
	
	PUBLIC run_a
	
	_code SEGMENT CODE
		RSEG _code
	
	run_a:
		MOV B, #'a'
		CALL write
		MOV B, #'b'
		CALL write
		MOV B, #'c'
		CALL write
		MOV B, #'d'
		CALL write
		MOV B, #'e'
		CALL write
		RET
		
	write:	
		CLR EAL						; deactivate global interrupts
		MOV S0BUF, B
	loop:
		SETB WDT
		SETB SWDT
		JNB TI0, loop
		CLR TI0
		SETB EAL						; activate interrupts after sending to serial
		RET
		
END