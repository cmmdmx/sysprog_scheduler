$NOMOD51
#include <REG517A.h>

NAME main
		
	EXTRN CODE(serial_init)
	EXTRN CODE(timer_init)
	EXTRN CODE (scheduler, process_start, process_stop)
	EXTRN CODE (b_interrupt)
	
	; main data of scheduler
	main_data SEGMENT DATA
		
		PUBLIC next_process
		PUBLIC next_process_priority
		RSEG main_data
		
		next_process: DS 1						; current process: 0:console, 1:prozessA, 2:processB, 3:processZ
		next_process_priority: DS 1
			
		stack: DS 4
	
	main_data_bit SEGMENT BIT
		PUBLIC first_run
		RSEG main_data_bit
		first_run: DBIT 1
		
	_code SEGMENT CODE
		RSEG _code
		
	
	CSEG											; Festes Segment 
	ORG 0											; Bei Adresse 0
	JMP start
	
	ORG 4
	JMP process_stop
	
	; Interrupt Routinen
	; Timer 0 (Scheduler)
	ORG 000Bh
	JMP scheduler
	
	; Timer 1
	ORG 001Bh
	JMP b_interrupt
	
	start:
	
		SETB EAL								; Allow interrupts
		SETB ET0								; Timer 0 interrupt erlauben
		
		CALL serial_init
		CALL timer_init
		
		MOV SP, #stack							; Stack Pointer auf reservierten Bereich setzen
		
		SETB first_run
		
		MOV next_process_priority, #0x00			; Priorität 2 für aktuellen Prozess
		MOV next_process, #0					; process_current auf Konsole setzen
		
		CALL process_start
		
		SETB TR0								; Timer 0 starten
		SETB TF0
		
	loop:
		NOP
		JMP loop
END