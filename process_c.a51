; disable predefined 8051 registers and include CPU definition file (for example, 8052)
$NOMOD51
#include <REG517A.h>	

NAME process_c
	
	PUBLIC run_c
	
	EXTRN DATA (next_process)
	EXTRN DATA (next_process_priority)
	
	EXTRN CODE (process_start)
	EXTRN CODE (process_stop)

	_code SEGMENT CODE
		RSEG _code
	
	run_c:
		JBC RI0, input_switch						; Jump to input switch, if entry exists
		
		SETB WDT										; Refresh Watchdog
		SETB SWDT									; Refresh Watchdog
		
		JMP run_c
		
	input_switch:
		MOV A, S0BUF
		
	check_a:											; character a
		CJNE A, #'a', check_b						; Jump to next label if input is not character a
		MOV next_process, #1
		MOV next_process_priority, #0xff
		CALL process_start
		JMP run_c
		
	check_b:											; character b
		CJNE A, #'b', check_c						; jump to next label if input is not character b
		MOV next_process, #2
		MOV next_process_priority, #0xbb
		CALL process_start
		JMP run_c

	check_c:											; character c
		CJNE A, #'c', check_z						; jump no next label if input is not c
		MOV next_process, #2
		CALL process_stop
		JMP run_c
		
	check_z:											; character z
		CJNE A,#'z', run_c							; jump back to main loop of console process if input is not z
		MOV next_process, #3
		MOV next_process_priority, #0x01
		CALL process_start
		JMP run_c
		
END	