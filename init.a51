; disable predefined 8051 registers and include CPU definition file (for example, 8052)
$NOMOD51
#include <REG517A.h>	

NAME init
	
	PUBLIC timer_init
	PUBLIC serial_init
	
	init_code SEGMENT CODE
		RSEG init_code
			
	
	timer_init:
		MOV TMOD, #0x11			;set Timer 0/1 to 16-Bit
		SETB ET0				;set Timer 0 interrupt
		RET
		
	serial_init:
	;initialize serial interface
			
	CLR 	SM0		;Mode 1
	SETB 	SM1		; 
	
	SETB BD				; intern baud generator enabled
	MOV PCON, #0x00		; SMOD = 0
	MOV S0RELH, #0x03 	; baudrate = 14423
	MOV S0RELL,	#0xE6 	; 
	
	SETB REN0			; activate recieve
	MOV S1CON, 0x20
	RET
END