$NOMOD51
#include <REG517A.h>

NAME scheduler
	
	PUBLIC scheduler 
	PUBLIC process_start
	PUBLIC process_stop
		
	EXTRN CODE(run_a)
	EXTRN CODE(run_b)
	EXTRN CODE(run_c)
	EXTRN CODE(fkt_text)
		
	EXTRN DATA (next_process)
	EXTRN DATA (next_process_priority)
	EXTRN BIT (first_run)
		
	; data of scheduler
	schedule_data SEGMENT DATA
		
		RSEG schedule_data
		
		puffer_a: DS 1
		puffer_b: DS 1
		puffer_r0: DS 1
		
		process_table: DS 4							; active processes are stored here
		process_time: DS 4							; process times to affect priorities
		process_current: DS 1						; current process
		process_stack: DS 16						; 4 byte as stack for 4 processes
		process_state: DS 56						; 4 * 14 byte to save register etc. for the processes
		
			
	_code SEGMENT CODE
		RSEG _code
		
	process_locations: DW run_c, run_a, run_b, fkt_text
	
	
	
	
	process_start:
	
		MOV A, next_process
		
		; Set process time
		ADD A, #process_time
		MOV R0, A
		MOV @R0, next_process_priority
				
		; get Stack position
		MOV A, next_process
		MOV B, #4
		MUL AB
		ADD A, #process_stack
		MOV R1, A								; stack start adress of process in r1
		
		MOV A, next_process						; get process start adress
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
		
		MOV A, next_process
		
		MOV B, #14
		MUL AB
		ADD A, #process_state
		MOV R0, A								; R0 start adress for saving state
		
		MOV A, R1
		MOV @R0, A								; set stack to beginning
		
		MOV A, R0
		INC R0
		MOV R1, #1								; R1 is Iteration variable
		
		process_reset:
			
			MOV @R0, #0
			INC R0
			INC R1
			CJNE R1, #14, process_reset
		
		MOV A, next_process
		ADD A, #process_table
		MOV R0, A
		MOV @R0, #0xFF
		RET
		
	process_stop:
		
		MOV A, next_process
		ADD A, #process_table
		MOV R0, A
		MOV @R0, #0
		
		SETB TF0
		RET
		
	scheduler:
		
		CLR EAL
		CLR TR0
		
		SETB WDT								; Watchdog reset
		SETB SWDT
		
		MOV puffer_a, A							; temp save A
		MOV puffer_b, B							; temp save B
		MOV puffer_r0, R0						; temp save R0
		
		JBC first_run, find_process				; saving everything is not necessary on first run
		
		MOV A, process_current
		
		MOV B, #14								; save state of current running process
		MUL AB
		ADD A, #process_state
		MOV R0, A
		
		MOV @R0, SP
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
		
		find_process:
			
			INC process_current
			MOV A, process_current
			CJNE A, #4, check_process
			MOV process_current, #0
			
		check_process:
		
			MOV A, #process_table
			ADD A, process_current
			MOV R0, A
			CJNE @R0, #0xff, find_process
		
		
		MOV A, #process_time
		ADD A, process_current
		MOV R0, A
		MOV A, @R0
		MOV TH0, A
		
		MOV A, process_current
		MOV B, #14
		MUL AB
		ADD A, #process_state
		MOV R0, A
		
		MOV A, @R0
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
		
		MOV A, puffer_a
		MOV B, puffer_b
		MOV R0, puffer_r0
			
		SETB TR0
		SETB EAL
		RETI

END