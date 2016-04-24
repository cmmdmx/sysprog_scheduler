$NOMOD51
#include <REG517A.h>

NAME scheduler
	
	PUBLIC scheduler 								
	PUBLIC process_start
	PUBLIC process_stop
		
	EXTRN CODE(run_a)								; from process_a
	EXTRN CODE(run_b)								; from process_b
	EXTRN CODE(run_c)								; from process_c
	EXTRN CODE(fkt_text)							; from fkt_text
		
	EXTRN DATA (next_process)						; from main
	EXTRN DATA (next_process_priority)				; from main
	EXTRN BIT (first_run)							; from main
	
	schedule_data SEGMENT DATA						; scheduler data space
		
		RSEG schedule_data
		
		puffer_a: DS 1								; backup space for A
		puffer_b: DS 1								; backup space for B
		puffer_r0: DS 1								; backup space for register R0
		
		process_table: DS 4							; active processes are stored here
		process_time: DS 4							; process times to affect priorities
		process_current: DS 1						; current process
		process_stack: DS 16						; 4 byte as stack for 4 processes
		process_state: DS 56						; 4 * 14 byte to save register etc. for the processes
		
			
	_code SEGMENT CODE
		RSEG _code
		
	process_locations: DW run_c, run_a, run_b, fkt_text
	
	
	
	
	process_start:									; "starts" a process. scheduler will handle this process now
	
		MOV A, next_process
		
		ADD A, #process_time						; set process running time (priority)
		MOV R0, A
		MOV @R0, next_process_priority
				
		MOV A, next_process							; get process stack adress
		MOV B, #4
		MUL AB
		ADD A, #process_stack
		MOV R1, A									; stack start adress of process in r1
		
		MOV A, next_process							; calculate, if yes, jmp to run_b and start again process start adress
		MOV B, #2
		MUL AB
		MOV R6, A
		MOV DPTR, #process_locations
		MOVC A, @A+DPTR
		MOV R5, A
		MOV A, R6
		INC A
		MOVC A, @A+DPTR
		
		MOV DPL, A
		MOV DPH, R5
		
		MOV @R1, DPL
		INC R1
		MOV @R1, DPH
		
		MOV A, next_process							; load A with next_process
		
		MOV B, #14
		MUL AB
		ADD A, #process_state
		MOV R0, A									; R0 start adress for saving state
		
		MOV A, R1
		MOV @R0, A									; set stack to beginning
		
		
		MOV A, next_process
		ADD A, #process_table
		MOV R0, A
		MOV @R0, #0xFF
		RET
		
	process_stop:									; stop a process from running
		
		MOV A, next_process
		ADD A, #process_table
		MOV R0, A
		MOV @R0, #0
		
		SETB TF0									; return to scheduler routine with timer 0 interrupt
		RET
		
	scheduler:
		
		CLR EAL
		CLR TR0
		
		SETB WDT									; Watchdog reset
		SETB SWDT
		
		MOV puffer_a, A								; temp save A
		MOV puffer_b, B								; temp save B
		MOV puffer_r0, R0							; temp save R0
		
		JBC first_run, find_process					; saving everything is not necessary on first run
		
		MOV A, process_current
		
		MOV B, #14									; calculate data storage adress
		MUL AB
		ADD A, #process_state
		MOV R0, A
		
		MOV @R0, SP									; save state data of current process
		INC R0
		MOV @R0, puffer_a
		INC R0
		MOV @R0, puffer_b
		INC R0
		MOV A, PSW
		MOV @R0, A
		INC R0
		MOV A, DPH
		MOV @R0, A
		INC R0
		MOV A, DPL
		MOV @R0, A
		INC R0
		MOV @R0, puffer_r0
		INC R0
		MOV A, R1
		MOV @R0, A
		INC R0
		MOV A, R2
		MOV @R0, A
		INC R0
		MOV A, R3
		MOV @R0, A
		INC R0
		MOV A, R4
		MOV @R0, A
		INC R0
		MOV A, R5
		MOV @R0, A
		INC R0
		MOV A, R6
		MOV @R0, A
		INC R0
		MOV A, R7
		MOV @R0, A
		
		find_process:									; find next process (next active process of process table)
			
			INC process_current
			MOV A, process_current
			CJNE A, #4, check_process
			MOV process_current, #0
			
		check_process:
		
			MOV A, #process_table
			ADD A, process_current
			MOV R0, A
			CJNE @R0, #0xff, find_process
		
		
		MOV A, #process_time							; calculate priority (process running time)
		ADD A, process_current
		MOV R0, A
		MOV A, @R0
		MOV TH0, A
		
		MOV A, process_current							; calculate adress of upcoming process
		MOV B, #14
		MUL AB
		ADD A, #process_state
		MOV R0, A
		
		MOV A, @R0										; restore state of upcoming process
		MOV SP, A
		INC R0
		MOV puffer_a, @R0
		INC R0
		MOV puffer_b, @R0
		INC R0
		MOV A, @R0
		MOV PSW, A
		INC R0
		MOV A, @R0
		MOV DPH, A
		INC R0
		MOV A, @R0
		MOV DPL, A
		INC R0
		MOV puffer_r0, @R0
		INC R0
		MOV A, @R0
		MOV R1, A
		INC R0
		MOV A, @R0
		MOV R2, A
		INC R0
		MOV A, @R0
		MOV R3, A
		INC R0
		MOV A, @R0
		MOV R4, A
		INC R0
		MOV A, @R0
		MOV R5, A
		INC R0
		MOV A, @R0
		MOV R6, A
		INC R0
		MOV A, @R0
		MOV R7, A
		
		MOV A, puffer_a									; restore A
		MOV B, puffer_b									; restore B
		MOV R0, puffer_r0								; restore R0
			
		SETB TR0										; re-activate timer 0
		SETB EAL										; allow global interrupts
		RETI											; return from interrupt

END