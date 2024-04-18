;PX1 firmware program is a simple hex editor that can be used to read, manage data and execute code using the crt controller and the PS/2 keyboard

;debug_mode		.var true 

;--------- environment variables ---------

pointer_blinking_delay			.equ 	25

hex_editor_table_start_position				.equ crt_display_character_line_size
hex_editor_table_bytes_per_line				.equ 8
hex_editor_table_byte_per_line_address_mask	.equ %00000111
hex_editor_table_lines_number				.equ 14
hex_editor_table_bytes_represented			.equ hex_editor_table_bytes_per_line*hex_editor_table_lines_number


hex_editor_left_border_character 				.equ %10101010
hex_editor_right_border_character 				.equ %10010101
hex_editor_table_address_divisor_character		.equ %10010101
hex_editor_table_byte_divisor_character			.equ $20 
hex_editor_lower_border_left_corner_character	.equ %10101011
hex_editor_lower_border_right_corner_character	.equ %10010111
hex_editor_lower_border_character				.equ %10000011
hex_editor_lower_border_divisor_character		.equ %10010111
hex_editor_top_bar_position						.equ 0 
hex_editor_lower_border_position				.equ crt_display_characters_size-crt_display_character_line_size
hex_editor_line_address_divisor_character	.equ $20 
hex_editor_table_end_border_character		.equ $20


hex_editor_start_memory_address 			.equ 0

hex_editor_move_down_char					.equ $53
hex_editor_move_up_char						.equ $57
hex_editor_move_left_char					.equ $41
hex_editor_move_right_char					.equ $44

hex_editor_search_char						.equ $53
hex_editor_run_char							.equ $52
hex_editor_edit_char 						.equ $45

hex_editor_top_bar_search_position			.equ 1
hex_editor_top_bar_run_position				.equ 9
hex_editor_top_bar_edit_position			.equ 14

hex_editor_top_bar_address_position			.equ 10

;--------- main application ---------

hex_editor_start:						call crt_display_reset
										call hex_editor_print_frame 
										lxi h,hex_editor_start_memory_address
										call hex_editor_print_table  
										xra a 
										mov d,a 
hex_editor_wait_input_restart:			mov a,d 
										call hex_editor_select_byte
hex_editor_wait_input:					call keyb_wait_char
										cpi $09
										jz hex_editor_wait_title_input
										cpi $0d
										jz hex_editor_edit
										cpi hex_editor_move_down_char
										jz hex_editor_move_down
										cpi hex_editor_move_up_char
										jz hex_editor_move_up
										cpi hex_editor_move_left_char
										jz hex_editor_move_left
										cpi hex_editor_move_right_char
										jz hex_editor_move_right
										jmp hex_editor_wait_input
hex_editor_move_up:						mov a,l 
										sui hex_editor_table_bytes_per_line
										mov l,a 
										mov a,h 
										sbi 0 
										mov h,a 
										mov a,d 
										sui hex_editor_table_bytes_per_line
										jc hex_editor_move_up_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_up_shift:				call hex_editor_shift_table_down 
										xra a 
										call hex_editor_print_line
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_down:					mov a,l 
										adi hex_editor_table_bytes_per_line 
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										mov a,d 
										adi hex_editor_table_bytes_per_line 
										cpi hex_editor_table_bytes_represented
										jnc hex_editor_move_down_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_down_shift:				call hex_editor_shift_table_up 
										push d 
										push h
										lxi d,hex_editor_table_bytes_represented-hex_editor_table_bytes_per_line
										dad d 
										mvi a,hex_editor_table_lines_number-1
										call hex_editor_print_line 
										pop h 
										pop d 
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_left:					mov a,d 
										sui 1
										jc hex_editor_move_left_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_left_shift:				mov a,l 
										sui hex_editor_table_bytes_per_line
										mov l,a 
										mov a,h 
										sbi 0 
										mov h,a 
										mov a,d 
										adi hex_editor_table_bytes_per_line-1
										mov d,a
										call hex_editor_shift_table_down 
										xra a 
										call hex_editor_print_line
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_right:					mov a,d 
										adi 1
										cpi hex_editor_table_bytes_represented
										jnc hex_editor_move_right_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_wait_input
hex_editor_move_right_shift:			mov a,l 
										adi hex_editor_table_bytes_per_line
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										mov a,d 
										sui hex_editor_table_bytes_per_line-1
										mov d,a
										call hex_editor_shift_table_up
										push d 
										push h
										lxi d,hex_editor_table_bytes_represented-hex_editor_table_bytes_per_line
										dad d 
										mvi a,hex_editor_table_lines_number-1
										call hex_editor_print_line 
										pop h 
										pop d 
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_wait_input

hex_editor_wait_title_input:			mvi c,0
										push h
										lxi h,hex_editor_top_bar_search_position
										call crt_set_display_pointer 
										pop h 
hex_editor_wait_title_input_loop:		call keyb_wait_char
										cpi $08 
										jz hex_editor_wait_input_restart
										cpi $09
										jz hex_editor_wait_input_restart 
										cpi $0d 
										jz hex_editor_title_select_option 
										cpi hex_editor_search_char
										jz hex_editor_search_address					
										cpi hex_editor_run_char				
										jz hex_editor_run_address_input			
										cpi hex_editor_edit_char 
										jz hex_editor_edit					
										cpi hex_editor_move_left_char
										jz hex_editor_title_move_left 
										cpi hex_editor_move_right_char 
										jz hex_editor_title_move_right 
										jmp hex_editor_wait_title_input_loop
hex_editor_title_select_option:			mov a,c 
										ora a 
										jz hex_editor_search_address
										cpi 1
										jz hex_editor_run_address_input	
										jmp hex_editor_edit 
heX_editor_title_move_right:			mov a,c 
										cpi 2
										jnc hex_editor_wait_title_input_loop
										inr c 
										jmp hex_editor_title_set_pointer_position
hex_editor_title_move_left:				mov a,c 
										ora a 
										jz hex_editor_wait_title_input_loop
										dcr c 
hex_editor_title_set_pointer_position:	mov a,c 
										ora a 
										jz hex_editor_wait_title_input
										cpi 1 
										jz hex_editor_title_set_pointer_run
hex_editor_title_set_pointer_edit:		push h 
										lxi h,hex_editor_top_bar_edit_position
										call crt_set_display_pointer
										pop h 
										jmp hex_editor_wait_title_input_loop
hex_editor_title_set_pointer_run:		push h 
										lxi h,hex_editor_top_bar_run_position
										call crt_set_display_pointer
										pop h 
										jmp hex_editor_wait_title_input_loop


							
hex_editor_search_address:				call hex_editor_request_address
										ora a 
										jz hex_editor_wait_input_restart
										mov a,l 
										ani hex_editor_table_byte_per_line_address_mask
										mov d,a 
										mov a,l 
										ani $ff-hex_editor_table_byte_per_line_address_mask
										mov l,a 
										call hex_editor_print_table
										jmp hex_editor_wait_input_restart

hex_editor_run_address_input:			call hex_editor_request_address
										ora a 
										jz hex_editor_wait_input_restart
										pchl 

hex_editor_edit: 						push h
										lxi h,hex_editor_top_bar_edit_position
										call crt_set_display_pointer
										lxi h,hex_editor_top_bar_edit_text_selected
										stc 
										cmc 
										call hex_editor_string_out
										pop h 
										mov a,d 
										call hex_editor_select_byte
hex_editor_edit_wait_ms:				call keyb_wait_char
										cpi $20 
										jz hex_editor_edit_move_right
										cpi $08 
										jz hex_editor_edit_move_left 
										cpi $7f 
										jz hex_editor_edit_deselect_text
										mov b,a 
										call ascii_is_hex
										ora a 
										jz hex_editor_edit_wait_ms
										mov a,b 
										stc 
										cmc 
										call hex_editor_char_out
										mov a,b
										call ascii_to_hex 
										ral 
										ral 
										ral 
										ral 
										ani $f0 
										mov e,a 
										mov a,l 
										add d
										mov c,a 
										mov a,h 
										aci 0 
										mov b,a  
										ldax b 
										ani $0f 
										ora e 
										stax b
hex_editor_edit_wait_ls:				call keyb_wait_char
										cpi $20 
										jz hex_editor_edit_move_right
										cpi $08 
										jz hex_editor_edit
										cpi $7f 
										jz hex_editor_edit_deselect_text
										mov b,a 
										call ascii_is_hex 
										ora a 
										jz hex_editor_edit_wait_ls
										mov a,b 
										stc 
										cmc 
										call hex_editor_char_out 
										mov a,b 
										call ascii_to_hex 
										ani $0f 
										ora e
										mov e,a  
hex_editor_edit_write_byte:				mov a,l 
										add d
										mov c,a 
										mov a,h 
										aci 0 
										mov b,a 
										mov a,e 
										stax b 
hex_editor_edit_move_right:				mov a,d 
										adi 1
										cpi hex_editor_table_bytes_represented
										jnc hex_editor_edit_move_right_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_edit_wait_ms
hex_editor_edit_move_right_shift:		mov a,l 
										adi hex_editor_table_bytes_per_line
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										mov a,d 
										sui hex_editor_table_bytes_per_line-1
										mov d,a
										call hex_editor_shift_table_up
										push d 
										push h
										lxi d,hex_editor_table_bytes_represented-hex_editor_table_bytes_per_line
										dad d 
										mvi a,hex_editor_table_lines_number-1
										call hex_editor_print_line 
										pop h 
										pop d 
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_edit_wait_ms
hex_editor_edit_move_left:				mov a,d 
										sui 1
										jc hex_editor_edit_move_left_shift
										mov d,a 
										call hex_editor_select_byte 
										jmp hex_editor_edit_wait_ms
hex_editor_edit_move_left_shift:		mov a,l 
										sui hex_editor_table_bytes_per_line
										mov l,a 
										mov a,h 
										sbi 0 
										mov h,a 
										mov a,d 
										adi hex_editor_table_bytes_per_line-1
										mov d,a
										call hex_editor_shift_table_down 
										xra a 
										call hex_editor_print_line
										mov a,d
										call hex_editor_select_byte 
										jmp hex_editor_edit_wait_ms
hex_editor_edit_deselect_text:			push h 
										lxi h,hex_editor_top_bar_edit_position
										call crt_set_display_pointer
										lxi h,hex_editor_top_bar_edit_text_selected
										stc 
										call hex_editor_string_out
										pop h 
										jmp hex_editor_wait_input_restart


hex_editor_top_bar_edit_text_selected:	.text "EDIT"
										.b 0

hex_editor_top_bar_string:	 		.b $bf 
									.text "SEARCH"
									.b $bf,$bf
									.text "RUN"
									.b $bf,$bf
									.text "EDIT"
									.b $bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf
									.b 0

hex_editor_top_bar_address_string:	.b $bf 
									.text "ADDRESS: "
									.b $bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,
									.b 0

;hex_editor_request_address prompts an address request on the title bar 
;A <- $ff if the address is valid, %00 if not 
;HL -> address received
hex_editor_request_address:				push h 
										push d 
										push b 
										lxi h,hex_editor_top_bar_position
										call crt_set_display_pointer
										lxi h,hex_editor_top_bar_address_string
										stc 
										call hex_editor_string_out 
										lxi h,hex_editor_top_bar_address_position
										call crt_set_display_pointer
										lxi h,0 
										mvi c,0 
hex_editor_request_address_input_msb1:	call keyb_wait_char
										cpi $7f  
										jz hex_editor_request_address_end
										mov b,a 
										call ascii_is_hex
										ora a 
										jz hex_editor_request_address_input_msb1
										mov a,b 
										stc 
										call hex_editor_char_out
										mov a,b 
										call ascii_to_hex
										ral 
										ral 
										ral 
										ral 
										ani $f0 
										mov h,a 
										mvi c,1
hex_editor_request_address_input_msb2:	call keyb_wait_char
										cpi $08 
										jz hex_editor_request_address_backspace
										cpi $7f  
										jz hex_editor_request_address_end
										mov b,a 
										call ascii_is_hex
										ora a 
										jz hex_editor_request_address_input_msb2
										mov a,b 
										stc 
										call hex_editor_char_out
										mov a,b 
										call ascii_to_hex
										ani $0f
										ora h 
										mov h,a 
										mvi c,2
hex_editor_request_address_input_lsb1:	call keyb_wait_char
										cpi $08 
										jz hex_editor_request_address_backspace
										cpi $7f  
										jz hex_editor_request_address_end
										mov b,a 
										call ascii_is_hex
										ora a 
										jz hex_editor_request_address_input_lsb1
										mov a,b 
										stc 
										call hex_editor_char_out
										mov a,b 
										call ascii_to_hex
										ral 
										ral 
										ral 
										ral 
										ani $f0 
										mov l,a 
										mvi c,3
hex_editor_request_address_input_lsb2:	call keyb_wait_char
										cpi $08 
										jz hex_editor_request_address_backspace
										cpi $7f  
										jz hex_editor_request_address_end
										mov b,a 
										call ascii_is_hex
										ora a 
										jz hex_editor_request_address_input_lsb2
										mov a,b 
										stc 
										call hex_editor_char_out
										mov a,b 
										call ascii_to_hex
										ani $0f
										ora l 
										mov l,a 
										mvi c,4
hex_editor_request_address_input_enter:	call keyb_wait_char
										cpi $08 
										jz hex_editor_request_address_backspace
										cpi $0d 
										jnz hex_editor_request_address_input_enter
										xchg 
										lxi h,hex_editor_top_bar_position
										call crt_set_display_pointer
										lxi h,hex_editor_top_bar_string
										stc 
										call hex_editor_string_out
										xchg 
hex_editor_request_address_end:			inx sp 
										inx sp 
										pop d 
										pop b 
										mvi a,$ff 
										ret 
hex_editor_request_address_backspace:	mov a,c 
										ora a 
										jz hex_editor_request_address_input_msb1
										xchg 
										call crt_get_display_pointer
										mvi a,$bf 
										dcr c 
										call crt_byte_out
										dcx h 
										call crt_set_display_pointer
										xchg 
										mov a,c 
										cpi 1 
										jz hex_editor_request_address_input_msb2
										cpi 2
										jz hex_editor_request_address_input_lsb1 
										jmp hex_editor_request_address_input_lsb2 
hex_editor_request_address_cancel:		pop h
										pop d 
										pop b 
										xra a 
										ret 


;hex_editor_shift_table_up shifts the hex table in order to free the last line
hex_editor_shift_table_up:				push h 
										push d
										push b  
										lxi h,hex_editor_table_start_position+crt_display_character_line_size
										lxi d,hex_editor_table_start_position
										lxi b,hex_editor_lower_border_position-hex_editor_table_start_position-crt_display_character_line_size
hex_editor_shift_table_up_loop:			call crt_byte_in
										xchg 
										call crt_byte_out 
										xchg 
										inx h 
										inx d 
										dcx b 
										mov a,c
										ora b
										jnz hex_editor_shift_table_up_loop
hex_editor_shift_table_up_end:			pop b 
										pop d 
										pop h
										ret 

;hex_editor_shift_table_up shifts the hex table in order to free the last line
hex_editor_shift_table_down:			push h 
										push d
										push b  
										lxi h,hex_editor_lower_border_position-crt_display_character_line_size-1
										lxi d,hex_editor_lower_border_position-1
										lxi b,hex_editor_lower_border_position-hex_editor_table_start_position-crt_display_character_line_size
hex_editor_shift_table_down_loop:		call crt_byte_in
										xchg 
										call crt_byte_out 
										xchg 
										dcx h 
										dcx d 
										dcx b 
										mov a,c
										ora b
										jnz hex_editor_shift_table_down_loop
hex_editor_shift_table_down_end:		pop b 
										pop d 
										pop h
										ret 


;hex_editor_select_byte sets the display pointer to the specific byte into the hex table
;A -> position of the byte
hex_editor_select_byte:					push h 
										push b
										cpi hex_editor_table_bytes_represented
										jnc hex_editor_select_byte_end
										mov h,a 
										lxi b,0 
hex_editor_select_byte_row:				mov a,h 
										sui hex_editor_table_bytes_per_line
										jc hex_editor_select_byte_pointer
										mov h,a 
										inr b 
										jmp hex_editor_select_byte_row
hex_editor_select_byte_pointer:			mov c,h
										lxi h,hex_editor_table_start_position+7
hex_editor_select_byte_pointer_row:		mov a,b
										ora a 
										jz hex_editor_select_byte_pointer_col
										mov a,l 
										adi crt_display_character_line_size
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										dcr b
										jmp hex_editor_select_byte_pointer_row
hex_editor_select_byte_pointer_col:		mov a,c 
										ora a 
										jz hex_editor_select_byte_pointer_end
										mov a,l 
										adi 3 
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										dcr c 
										jmp hex_editor_select_byte_pointer_col
hex_editor_select_byte_pointer_end:		call crt_set_display_pointer
hex_editor_select_byte_end:				pop b 
										pop h 
										ret 

;hex_editor_print_frame prints the display frame with title bar 
hex_editor_print_frame:					push h 
										push d 
										push b 
										lxi h,0 
										call crt_set_display_pointer
										lxi h,hex_editor_top_bar_string
										stc 
										call hex_editor_string_out
										lxi h,hex_editor_table_start_position
										call crt_set_display_pointer
										mvi b,hex_editor_table_lines_number
hex_editor_print_frame_lines:			mvi a,hex_editor_left_border_character
										stc 
										cmc 
										call hex_editor_char_out 
										mov a,l 
										adi 5 
										mov l,a 
										mov a,h 
										aci 0 
										call crt_set_display_pointer
										mvi a,hex_editor_table_address_divisor_character
										stc 
										cmc 
										call hex_editor_char_out
										mov a,l 
										adi (hex_editor_table_bytes_per_line*3)+2
										mov l,a 
										mov a,h 
										aci 0 
										mov h,a 
										call crt_set_display_pointer
										mvi a,hex_editor_right_border_character
										stc 
										cmc 
										call hex_editor_char_out
										inx h 
										dcr b 
										jnz hex_editor_print_frame_lines
										lxi h,hex_editor_lower_border_position
										call crt_set_display_pointer
hex_editor_print_frame_bottom:			mvi a,hex_editor_lower_border_left_corner_character
										call hex_editor_char_out 
										mvi b,crt_display_character_line_size-2 
hex_editor_print_frame_bottom_loop:		mvi a,hex_editor_lower_border_character
										call hex_editor_char_out
										dcr b 
										jnz hex_editor_print_frame_bottom_loop
										mvi a,hex_editor_lower_border_right_corner_character
										call hex_editor_char_out 
										lxi h,hex_editor_lower_border_position+5
										call crt_set_display_pointer
										mvi a,hex_editor_lower_border_divisor_character
										stc 
										cmc 
										call hex_editor_char_out
hex_editor_print_frame_end:				pop b 
										pop d 
										pop h 
										ret 

;hex_editor_print_table prints all the table starting from the specified address 
;HL -> start address
hex_editor_print_table:				push h
									push d
									push b 
									mvi b,0
									mvi c,hex_editor_table_lines_number 
									lxi d,hex_editor_table_bytes_per_line
hex_editor_print_table_loop:		mov a,b 
									call hex_editor_print_line 
									dad d 
									inr b 
									dcr c 
									jnz hex_editor_print_table_loop
hex_editor_print_table_end:			pop b 
									pop d 
									pop h 
									ret 

;hex_editor_print_line prints the memory values line that contains the requested address on the specified table line 
;A -> table line 
;HL -> address memory 

hex_editor_print_line:				push h 
									push b 
									push d 
									cpi hex_editor_table_lines_number
									jnc hex_editor_print_line_end
									xchg 
									lxi h,hex_editor_table_start_position
									lxi b,crt_display_character_line_size
hex_editor_print_line_coordinate:	ora a 
									jz hex_editor_print_line_address
									dad b
									dcr a 
									jmp hex_editor_print_line_coordinate
hex_editor_print_line_address:		inx h 
									call crt_set_display_pointer
									xchg 
									call hex_editor_print_address
									xchg 
									lxi b,5 
									dad b
									call crt_set_display_pointer 
									mvi c,hex_editor_table_bytes_per_line
hex_editor_print_line_loop:			mvi a,hex_editor_table_byte_divisor_character
									stc 
									cmc 
									call hex_editor_char_out
									ldax d 
									call hex_editor_print_byte 
									inx d
									dcr c
									jz hex_editor_print_line_loop_end 
									jmp hex_editor_print_line_loop
hex_editor_print_line_loop_end:		mvi a,hex_editor_table_byte_divisor_character
									stc 
									cmc 
									call hex_editor_char_out
hex_editor_print_line_end:			pop d 
									pop b
									pop h 
									ret 

;hex_editor_string_out sends a string to the crt controller. The string is terminated with char $00
;Cy -> 1 if the string has to be printed with a white background, 0 otherwise
;HL -> string address

hex_editor_string_out:					push h
										push psw 
hex_editor_string_out_loop:				mov a,m 
										ora a 
										jz hex_editor_string_out_end
										pop psw 
										push psw 
										mov a,m
										call hex_editor_char_out
										inx h 
										jmp hex_editor_string_out_loop
hex_editor_string_out_end:				pop psw 
										pop h 
										ret 				

;hex_editor_char_out prints the character and increments the display pointer
;Cy -> 1 for white background, 0 for black background 
;A -> character to print
hex_editor_char_out:			push h 
								push d 
								push psw
								pop d
								call crt_get_display_pointer
								mov a,d 
								ani crt_output_byte_type_mode_mask
								cpi crt_output_byte_mode_special
								mov a,d
								jz hex_editor_char_out_loop_out
								mov a,e 
								ani %00000001
								jnz hex_editor_char_out_inverted
								mov a,d
								ani $ff-crt_output_byte_type_mode_mask
								ori crt_output_byte_mode_character
								jmp hex_editor_char_out_loop_out
hex_editor_char_out_inverted:	mov a,d
								ani $ff-(crt_output_byte_type_mode_mask+crt_output_byte_special_mode)
								ori crt_output_byte_inverted_mode+crt_output_byte_mode_special
hex_editor_char_out_loop_out:	call crt_byte_out
								inx h 
								call crt_set_display_pointer 
hex_editor_char_out_end:		pop d 
								pop h 
								ret 

;hex_editor_print_address prints the given address 
;HL -> address to print 
hex_editor_print_address:	mov a,h 
							call hex_editor_print_byte 
							mov a,l 
							call hex_editor_print_byte 
							ret 

;hex_editor_print_byte prints the hex value of the given byte 
;A -> value to print 
hex_editor_print_byte:					push b 
										mov b,a 
										rar 
										rar 
										rar 
										rar 
										ani $0f
										call hex_to_ascii 
										stc 
										cmc 
										call hex_editor_char_out
										mov a,b 
										ani $0f 
										call hex_to_ascii 
										stc 
										cmc 
										call hex_editor_char_out
										pop b 
										ret 	

;hex_to_ascii converts the first four number of given value into his ascii char 
;A	-> hex value
;A 	<- ASCII char 

hex_to_ascii:				ani $0f 
							cpi $0a 
							jnc hex_to_ascii_letter
							adi $30 
							ret 
hex_to_ascii_letter:		adi $37
							ret 

;ascii_to_hex converts the ascii character into his hex value 
;A	-> ASCII character
;A 	<- hex value

ascii_to_hex:				cpi $30 
							jc ascii_to_hex_not_valid
							cpi $3A 
							jnc ascii_to_hex_letter 
							sui $30 
							ret 
ascii_to_hex_letter:		cpi $41 
							jc ascii_to_hex_not_valid
							cpi $47
							jnc ascii_to_hex_not_valid
							sui $37 
							ret 
ascii_to_hex_not_valid:		xra a 
							ret 

;ascii_is_hex indicates if the ascii character can be converted as hex value
;A -> ASCII character
;A -> $ff if true, $00 if false
ascii_is_hex:				cpi $47 
							jnc ascii_is_hex_false
							cpi $41 
							jnc ascii_is_hex_true
							cpi $3A
							jnc ascii_is_hex_false
							cpi $30 
							jc ascii_is_hex_false
ascii_is_hex_true:			mvi a,$ff 
							ret 
ascii_is_hex_false:			xra a 
							ret 

;ascii_upper_case converts all small letters in big letters 
;A -> ASCII letter
;A <- ASCII letter in upper case 
ascii_upper_case:			cpi $7B
							rnc 
							cpi $61
							rc 
							sui $20
							ret 


;keyb_wait_char wait a new character from the PS/2 interface and provide the blinking cursor effect 
;A	<- character received

keyb_wait_char:				push h
							push b 
keyb_wait_char_loop:		call crt_show_cursor
							lxi b,pointer_blinking_delay
keyb_wait_char_on_loop:		call keyb_status
							ora a
							jnz keyb_wait_char_cursor_off
							dcx b 
							mov a,c 
							ora b
							jnz keyb_wait_char_on_loop
							call crt_hide_cursor
							lxi b,pointer_blinking_delay
keyb_wait_char_off_loop:	call keyb_status
							ora a
							jnz keyb_wait_char_read
							dcx b 
							mov a,c 
							ora b
							jnz keyb_wait_char_off_loop
							jmp keyb_wait_char_loop
keyb_wait_char_cursor_off:	call crt_hide_cursor
keyb_wait_char_read:		call keyb_read
							call ascii_upper_case
keyb_wait_char_end:			pop b 
							pop h
							ret
