;This file contains all implementation of hardware drivers for these PX1 Full board devices:
;-	FDC controller		
;-	DMA controller
;- 	CRT controller
;- 	PS/2 keyboard interface
;All code is written in 8085 assembly and can be used for BIOS implementation.

;--------- environment_variables ---------

fdc_interrupt_address			.equ 	$0034

;CRT controller environment variables
crt_display_characters_size				.equ 	512
crt_display_character_line_size			.equ 	32
crt_display_character_lines_number		.equ 	16
crt_display_line_size 					.equ 	64
crt_display_lines_number 				.equ 	48


crt_vram_dimension        		.equ    512
crt_background_character    	.equ    %10000000
crt_cursor_character 			.equ 	%10111111
crt_line_feed_verify        	.equ    %00000001

crt_character_mode_setting_mask	.equ	%10000000 	
crt_character_mode_on 			.equ 	%10000000
crt_character_mode_off 			.equ 	%00000000

crt_cursor_status_mask			.equ 	%01000000
crt_cursor_status_off			.equ 	%00000000
crt_cursor_status_on			.equ 	%01000000

crt_vram_mode_mask 						.equ %11000000
crt_vram_character_mode_enable_bits		.equ %00000000
crt_vram_direct_mode_enable_bits		.equ %10000000

;CRT controller port addresses
crt_vram_low_address_port		.equ 	$20			
crt_vram_high_address_port		.equ 	$21			
crt_data_port		    		.equ 	$22			
crt_status_port 	    		.equ 	$20	

;PS/2 keyboard environment variables
keyboard_input_mask				.equ 	%10000000
keyboard_data_mask				.equ 	%01111111

;PS/2 keyboard port address
keyboard_input_port		    	.equ 	$21			

;DMA controller environment variables
;dma_initial_address				.equ 	$0080

;DMA controller port addresses
;dma_status_register		    .equ $08
;dma_command_register	    .equ $08
;dma_request_register	    .equ $09
;dma_single_mask_register	.equ $0a
;dma_mode_register		    .equ $0b
;dma_ff_clear		        .equ $0c
;dma_temporary_register	    .equ $0d
;dma_master_clear		    .equ $0d
;dma_clear_mask_register	    .equ $0e
;dma_all_mask_register	    .equ $0f
;dma_address_register	    .equ $04
;dma_word_count_register     .equ $05

;FDC controller environment variables

;fdc_send_bytes					.equ	$0082
;fdc_read_bytes					.equ 	$0082

;FDC controller port addresses
;fdc_drive_control_register	.equ $12
;fdc_data_rate_register		.equ $17
;fdc_disk_changed_register	.equ $17
;fdc_main_status_register	.equ $14
;fdc_data_register			.equ $15

;--------- memory variables ---------

drivers_memory_start_address:		.equ drivers_memory_space_base_address 
crt_current_pointer_address     	.equ drivers_memory_start_address
crt_current_settings				.equ crt_current_pointer_address+2
crt_backup_cursor_character			.equ crt_current_settings+1
crt_vram_start_address				.equ vram_memory_space_address

;program_status_byte				.equ 	drivers_memory_start_address
;floppy_drive_select				.equ	$7ff5
;floppy_track_number				.equ 	$7ff6
;floppy_head_number				.equ 	$7ff7
;floppy_sector_number			.equ	$7ff8
;floppy_sector_size				.equ 	$7ff9

;------- drivers function addresses -------
bios_entries:  	jmp crt_display_reset
                jmp crt_enable_character_mode
				jmp crt_disable_character_mode
				jmp crt_set_display_pointer
				jmp crt_get_display_pointer
				jmp crt_char_out
				jmp crt_show_cursor
				jmp crt_hide_cursor

				jmp keyb_status 
				jmp keyb_read 

;------- CRT controller driver implementation ----

;crt_display_reset initializes the vram memory space with the backround predefined character
crt_display_reset:  				push h
									push d
									lxi h,0
									shld crt_current_pointer_address
									mvi a,crt_character_mode_on+crt_cursor_status_off
									sta crt_current_settings
									lxi h,crt_vram_start_address
									lxi d,crt_vram_dimension
crt_display_vram_clear_loop:		mvi m,crt_background_character
									inx h 
									dcx d 
									mov a,d 
									ora e 
									jnz crt_display_vram_clear_loop 
									lxi d,crt_vram_dimension
									lxi h,0
crt_display_external_vram_clear:	mvi a,crt_background_character
									call crt_byte_out 
									dcx d
									inx h
									mov a,d
									ora e
									jnz crt_display_external_vram_clear
crt_display_reset_end:  			pop d
									pop h
									ret

;crt_enable_character_mode turns the crt controller into a default ASCII terminal with automatic shift up
crt_enable_character_mode:		push h 
								push d 
								push b 
								lda crt_current_settings 
								ani $ff-crt_character_mode_setting_mask
								ori crt_character_mode_on
								sta crt_current_settings
								lxi b,crt_vram_start_address
								lxi h,0 
								lxi d,crt_vram_dimension
crt_enable_character_mode_loop:	ldax b 
								call crt_byte_out 
								inx b 
								inx h 
								dcx b 
								mov a,e 
								ora d 
								jnz crt_enable_character_mode_loop
crt_enable_character_mode_end:	pop b 
								pop d 
								pop h 
								ret 

;crt_disable_character_mode the CRT controller just show the vram values in pixel format
crt_disable_character_mode:			push h 
									push d  
									push b 
									lda crt_current_settings 
									ani $ff-crt_character_mode_setting_mask
									ori crt_character_mode_off
									sta crt_current_settings	
									lxi b,crt_vram_start_address
									lxi h,0 
									lxi d,crt_vram_dimension
crt_disable_character_mode_loop:	ldax b 
									call crt_byte_out 
									inx b 
									inx h 
									dcx b 
									mov a,e 
									ora d 
									jnz crt_disable_character_mode_loop
crt_disable_character_mode_end:		pop b 
									pop d 
									pop h 
									ret 

;crt_byte_out sends a byte to the external vram 
;A 	-> 	byte to send
;HL -> 	vram address

crt_byte_out:					push h 
								push d
								push b
								ani $ff-crt_vram_mode_mask
								mov b,a   
								lxi d,crt_display_characters_size
								mov a,l 
								sub e 
								mov a,h 
								sbb d 
								jnc crt_byte_out_end
								lxi d,crt_vram_start_address
								xchg 
								dad d 
								mov m,b 
								xchg 
								lda crt_current_settings 
								ani crt_character_mode_setting_mask
								cpi crt_character_mode_on
								jz crt_byte_out_character_mode
								mvi a,crt_vram_direct_mode_enable_bits
								ora b 
								mov b,a 
								jmp crt_byte_out_next
crt_byte_out_character_mode:	mvi a,crt_vram_character_mode_enable_bits
								ora b 
								mov b,a 
crt_byte_out_next:				mov a,l 
								out crt_vram_low_address_port 
								mov a,h 
								out crt_vram_high_address_port 
crt_byte_out_ready_wait:		in crt_status_port 
								ani crt_line_feed_verify
								jnz crt_byte_out_ready_wait
								mov a,b 
								out crt_data_port 
crt_byte_out_end:				pop b 
								pop d 
								pop h 
								ret 

;crt_byte_in reads a byte from the vram 
;HL -> 	vram address
;A <- character from vram 

crt_byte_in:		push h
					push d 
					lxi d,crt_display_characters_size
					mov a,l 
					sub e 
					mov a,h 
					sbb d 
					jc crt_byte_in_next
					xra a 
					jmp crt_byte_in_end
crt_byte_in_next:	lxi d,crt_vram_start_address
					dad d 
					mov a,m 
crt_byte_in_end:	pop d 
					pop h 
					ret 

;crt_set_display_pointer sets a custom value for the pointer address
;HL -> new pointer address
crt_set_display_pointer:		push d
								lxi d,crt_vram_dimension
								mov a,e  
								sub l 
								mov a,d 
								sbb h 
								jc crt_set_display_pointer_end
								shld crt_current_pointer_address
crt_set_display_pointer_end:	pop d 
								ret

;crt_get_display_pointer_gets the current pointer address
;HL <- current pointer address
crt_get_display_pointer:	lhld crt_current_pointer_address
							ret

;crt_char_out sends an ASCII character to the current pointer address. If character mode is disabled this function will return whitout printing the character
;A 	-> character to print 

crt_char_out:						push h
									push d 
									push b 
									mov b,a 
									lda crt_current_settings
									ani crt_character_mode_setting_mask
									cpi crt_character_mode_off
									jz crt_char_out_end 
									lda crt_current_settings
									ani $ff-crt_cursor_status_mask
									cpi crt_cursor_status_off 
									jz crt_char_out_start
									lhld crt_current_pointer_address
									call crt_byte_in 
									call crt_byte_out 
crt_char_out_start:					lhld crt_current_pointer_address 
									lxi d,crt_display_characters_size
									mov a,e 
									sub l 
									mov a,d 
									sbb h 
									jc crt_char_out_next
crt_char_out_line_shift_up:			push b 
									lxi h,0
									lxi b,crt_display_characters_size-crt_display_character_line_size
									lxi d,crt_display_character_line_size
crt_char_out_line_shift_up_loop:	xchg 
									call crt_byte_in
									xchg 
									call crt_byte_out 
									dcx b
									inx h
									inx d
									mov a,b
									ora c
									jnz crt_char_out_line_shift_up_loop
									shld crt_current_pointer_address
									lxi d,crt_display_character_line_size
crt_char_out_line_shift_up_loop2:	mvi a,crt_background_character
									call crt_byte_out 
									inx h
									dcx d
									mov a,d
									ora e
									jnz crt_char_out_line_shift_up_loop2
									pop b 
									lhld crt_current_pointer_address
crt_char_out_next:					mov a,b 
									ani $ff-crt_vram_mode_mask
									cpi $0a 
									jz crt_char_out_new_line
									cpi $0d
									jz crt_char_out_carriage_return
									cpi $08
									jz crt_char_out_backspace
crt_char_out_print:					cpi $61
									jc crt_char_out_print_upper_case
									cpi $7B
									jnc crt_char_out_print_upper_case
									ani %11011111
crt_char_out_print_upper_case:		call crt_byte_out 
									inx h
									shld crt_current_pointer_address
									jmp crt_char_out_end
crt_char_out_new_line:				lxi d,crt_display_character_line_size
									dad d 
									shld crt_current_pointer_address
									jmp crt_char_out_end
crt_char_out_carriage_return:		xra a
									sui crt_display_character_line_size
									ana l
									mov l,a
									shld crt_current_pointer_address
									jmp crt_char_out_end
crt_char_out_backspace:				mvi a,crt_background_character
									call crt_byte_out
									dcx h
									shld crt_current_pointer_address
crt_char_out_end:					lda crt_current_settings
									ani $ff-crt_cursor_status_mask
									cpi crt_cursor_status_off 
									jz crt_char_out_end2
									lhld crt_current_pointer_address
									mvi a,crt_cursor_character 
									call crt_byte_out 
crt_char_out_end2:					pop b 
									pop d 
									pop h 
									ret 


;crt_show_cursor replace current pointer char with the cursor. The original char is saved and can be restored with crt_hide_cursor function.

crt_show_cursor:		push h 
						lda crt_current_settings
						mov h,a 
						ani crt_cursor_status_mask
						cpi crt_cursor_status_on
						jz crt_show_cursor_end
						mov a,h 
						ani $ff-crt_cursor_status_mask
						ori crt_cursor_status_on
						sta crt_current_settings
						lhld crt_current_pointer_address
						mvi a,crt_cursor_character 
						call crt_byte_out 
crt_show_cursor_end:	pop h 
						ret 

;crt_hide_cursor replace the cursor with the original character
crt_hide_cursor:		push h 
						lda crt_current_settings
						ani $ff-crt_cursor_status_mask
						ori crt_cursor_status_off
						sta crt_current_settings
						lhld crt_current_pointer_address
						call crt_byte_in 
						call crt_byte_out 
crt_hide_cursor_end:	pop h 
						ret 


;-------- DMA controller driver implementation --------

/*
dma_reset:	push h
			lxi h,0
			shld dma_initial_address
			pop h
			out dma_master_clear
			mvi a,%00001000			;dack active low, drq active high, compressed timing, m-to-m disable
			out dma_command_register
			mvi a,%00001011			;set dma channels 0,1,3 mask bit
			out dma_all_mask_register
			ret

dma_set_write_address:	mvi a,%01000110
						jmp dma_set_next
dma_set_read_address:	mvi a,%01001010
dma_set_next:			out dma_mode_register
						out dma_ff_clear
						mov a,l
						out dma_address_register
						mov a,h
						out dma_address_register
						out dma_ff_clear
						mvi a,$0ff
						out dma_word_count_register
						out dma_word_count_register
						ret
*/

;--------- PS/2 Keyboard driver implementation ---------

;keyb_status gets the current state of the PS/2 keyboard 
;A	<- $ff if there is an available character, $00 otherwise

keyb_status:			in keyboard_input_port 
						ani keyboard_input_mask
						jz keyb_status_available
						xra a 
						ret
keyb_status_available:	mvi a,$ff
						ret

;keyb_read gets the last avaiulable character from the PS/2 keyboard
;A <- last character
keyb_read:				in keyboard_input_port
						cma
						ani keyboard_data_mask
						ret

;funzioni del BIOS secondarie

/*



fdc_reset:		push b
				push h
				lxi h,program_status_byte
				mvi b,07
				mvi a,%00000000
				out fdc_drive_control_register
				mvi a,%00001111			;device on, dma pins on, select drive 3
				out fdc_drive_control_register
				mvi a,%00000010			;250kb/s default speed
				out fdc_data_rate_register
				lxi h,specify_command
				call fdc_command_send
				lxi h,mode_command
				call fdc_command_send
				pop h
				pop b
				ret

select_drive0:		mvi a,0
					sta floppy_drive_select
					mvi a,%00011100
					out fdc_drive_control_register
					ret

select_drive1:		mvi a,1
					sta floppy_drive_select
					mvi a,%00101101
					out fdc_drive_control_register
					ret

deselect_drive:		mvi a,%00001111
					out fdc_drive_control_register
					ret

fdc_command_send:	push d
					push h
					lxi d,fdc_interrupt_request
					lxi h,interrupt_address
					mvi m,$c3
					inx h
					mov m,e
					inx h
					mov m,d
					pop h
					pop d
					push b
					mov b,l
					ei
fdc_command_loop:	in fdc_main_status_register
					cpi %10000000
					jc fdc_command_loop
					ani %01110000
					cpi %01000000
					jnc fdc_abnormal_command_read
					cpi %00100000
					jnc fdc_abnormal_ndma_status
					cpi %00010000
					jc send_command_verify
fdc_command_loop_1:	mov a,m
					inx h
					out fdc_data_register
					jmp fdc_command_loop

fdc_abnormal_command_read:	lda program_status_byte
							ori %00000010
							sta program_status_byte
							jmp fdc_command_read

fdc_abnormal_ndma_status:	lda program_status_byte
							ori %00000100
							sta program_status_byte
fdc_abnormal_ndma_loop:		in fdc_main_status_register
							ani %00100000
							jnz fdc_abnormal_ndma_loop
							jmp fdc_command_read

send_command_verify:	mov a,l
						cmp b
						jz fdc_command_loop_1
seek_command_loop:	in fdc_main_status_register
					ani $0f
					jnz seek_command_loop
fdc_command_end:	pop b
					lda program_status_byte
					ori %00000001
					sta program_status_byte
					ret

fdc_interrupt_request:	pop h
						in fdc_main_status_register
						ani %00110000
						cpi %00100000
						jnc fdc_abnormal_ndma_status
						cpi %00010000
						jnz fdc_sense_interrupt_request
fdc_command_read:		lxi h,fdc_read_bytes
fdc_command_read_1:		in fdc_main_status_register
						cpi %10000000
						jc fdc_command_read_1
						ani %00010000
						jz fdc_command_end
						in fdc_main_status_register
						ani %01000000
						jz fdc_abnormal_command_request
						in fdc_data_register
						mov m,a
						inx h
						jmp fdc_command_read_1

fdc_sense_interrupt_request:	lda program_status_byte
								ori %00001000
								sta program_status_byte
								push h
								lxi h,sense_interrupt_command
								call fdc_command_loop
								jmp fdc_command_end

fdc_abnormal_command_request:	lda program_status_byte
								ori %00010000
								sta program_status_byte
								jmp fdc_command_end

sense_interrupt_command		.b %00001000
specify_command				.b %00000011, %00001111, %11111110
mode_command				.b %00000001, %00100110, %00000000, %11001111, %00000000
*/