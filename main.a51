$NOMOD51
#include <REG517A.h>

NAME main
		
	EXTRN CODE(serial_init)												; from init.a51
	EXTRN CODE(timer_init)												; from init.a51
	EXTRN CODE (scheduler, process_start, process_stop)					; from scheduler.a51
	EXTRN CODE (b_interrupt)											; from process_b.a51
	
	main_data SEGMENT DATA
		
		PUBLIC next_process
		PUBLIC next_process_priority
		RSEG main_data
		
		next_process: DS 1						; current process: 0:console, 1:prozessA, 2:processB, 3:processZ
		next_process_priority: DS 1				; priority of next process: high value = low priority (low runtime)
			
		stack: DS 4								; default space for stack
	
	main_data_bit SEGMENT BIT
		PUBLIC first_run
		RSEG main_data_bit
		first_run: DBIT 1						; flag, used in scheduler to check first run
		
	_code SEGMENT CODE
		RSEG _code
		
	
	CSEG										; start
	ORG 0										; at adress 0
	JMP start									; jump to program start	

	ORG 000Bh									; timer 0 interrupt (timer 0 = scheduler)
	JMP scheduler
	
	ORG 001Bh									; timer 1 interrupt (timer 1 = counter)
	JMP b_interrupt
	
	start:										; start routine
	
		SETB EAL								; allow global interrupts
		SETB ET0								; allow timer 0 interrupt
		
		CALL serial_init						; initialize serial interface 0
		CALL timer_init							; initialize timers
		
		MOV SP, #stack							; set stack pointer to reserved space
		
		SETB first_run							; set bit "first_run" active (1)
		
		MOV next_process, #0					; set next_process to 0 (console)
		MOV next_process_priority, #0x00		; set next_process priority to 0 (highest)
		
		CALL process_start						; call process_start (to start process from next_process)
		
		SETB TR0								; start timer 0
		SETB TF0								; jump to timer 0 interrupt routine
		
	loop:										; nop loop as default behavior if some program parts crash
		NOP
		JMP loop
END