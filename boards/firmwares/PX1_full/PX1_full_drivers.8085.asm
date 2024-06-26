;This file contains all implementation of hardware drivers for these PX1 Full board devices:
;-	FDC controller		
;-	DMA controller
;- 	CRT controller
;- 	PS/2 keyboard interface
;All code is written in 8085 assembly and can be used for BIOS implementation.

;debug_mode 				.var 	true

;--------- environment_variables ---------

fdc_interrupt_address			.equ 	$0034

;Time delay environment variables

time_delay_value    .equ 85		;time_delay_value=(CPU_freq-31)/14

;CRT controller environment variables
crt_display_characters_size				.equ 	512
crt_display_character_line_size			.equ 	32
crt_display_character_lines_number		.equ 	16
crt_display_line_size 					.equ 	64
crt_display_lines_number 				.equ 	48

crt_output_byte_type_mode_mask 			.equ  	%10000000
crt_output_byte_mode_character 			.equ  	%00000000
crt_output_byte_mode_special 			.equ 	%10000000

crt_output_byte_special_mode 			.equ 	%01000000
crt_output_byte_semigraphic_mode 		.equ	%00000000
crt_output_byte_inverted_mode 			.equ 	%01000000


crt_vram_dimension        		.equ    512
crt_background_character    	.equ    %10000000
crt_cursor_character 			.equ 	%10111111
crt_line_feed_verify        	.equ    %00000001

crt_cursor_status_mask			.equ 	%10000000
crt_cursor_status_off			.equ 	%00000000
crt_cursor_status_on			.equ 	%10000000

;CRT controller port addresses
crt_vram_low_address_port		.equ 	$20			
crt_vram_high_address_port		.equ 	$21			
crt_data_port		    		.equ 	$22			
crt_status_port 	    		.equ 	$20	

;PS/2 keyboard environment variables
keyboard_input_mask				.equ 	%10000000
keyboard_data_mask				.equ 	%01111111
keyb_status_time_delay_value 	.equ 10
keyb_repeat_key_threshold 		.equ 200
keyb_repeat_filter_value 		.equ 3 

;PS/2 keyboard port address
keyboard_input_port		    	.equ 	$21			

;DMA controller environment variables
dma_mode_register_transfer_mode_mask        .equ %11000000
dma_mode_register_address_increment_mask    .equ %00100000
dma_mode_register_autoinitialize_mask       .equ %00010000
dma_mode_register_transfer_direction_mask   .equ %00001100
dma_mode_register_channel_mask              .equ %00000011

dma_mode_register_cascade_transfer          .equ %11000000
dma_mode_register_block_transfer            .equ %10000000
dma_mode_register_single_transfer           .equ %01000000
dma_mode_register_demand_transfer           .equ %00000000

dma_mode_register_autoinitialize            .equ %00010000
dma_mode_register_no_autoinitialize         .equ %00000000

dma_mode_register_increment                 .equ %00000000
dma_mode_register_decrement                 .equ %00100000

dma_mode_register_write_transfer            .equ %00000100
dma_mode_register_read_transfer             .equ %00001000
dma_mode_register_verify_transfer           .equ %00000000

dma_mode_register_channel0                  .equ 0
dma_mode_register_channel1                  .equ 1
dma_mode_register_channel2                  .equ 2
dma_mode_register_channel3                  .equ 3

dma_mode_all_mask_register_channel0         .equ %00000001
dma_mode_all_mask_register_channel1         .equ %00000010
dma_mode_all_mask_register_channel2         .equ %00000100
dma_mode_all_mask_register_channel3         .equ %00001000

dma_command_register_mm_enable              .equ %00000001
dma_command_register_mm_disable             .equ %00000000

dma_command_register_ch0_hold_disable       .equ %00000000
dma_command_register_ch0_hold_enable        .equ %00000010

dma_command_register_controller_enable      .equ %00000000
dma_command_register_controller_disable     .equ %00000100

dma_command_register_normal_timing          .equ %00000000
dma_command_register_compressed_timing      .equ %00001000

dma_command_register_fixed_priority         .equ %00000000
dma_command_register_rotating_priority      .equ %00010000

dma_command_register_late_write             .equ %00000000
dma_command_register_extended_write         .equ %00100000

dma_command_register_drq_active_high        .equ %00000000
dma_command_register_drq_active_low         .equ %01000000

dma_command_register_dack_active_high       .equ %10000000
dma_command_register_dack_active_low        .equ %00000000

dma_request_register_channel0_request       .equ %00000000
dma_request_register_channel1_request       .equ %00000001
dma_request_register_channel2_request       .equ %00000010
dma_request_register_channel3_request       .equ %00000011

dma_request_register_set_request                .equ %00000100
dma_request_register_reset_request              .equ %00000000

;DMA controller port addresses
dma_status_register		    .equ $08
dma_command_register	    .equ $08
dma_request_register	    .equ $09
dma_single_mask_register	.equ $0a
dma_mode_register		    .equ $0b
dma_ff_clear		        .equ $0c
dma_temporary_register	    .equ $0d
dma_master_clear		    .equ $0d
dma_clear_mask_register	    .equ $0e
dma_all_mask_register	    .equ $0f

dma_channel0_address_register       .equ $00
dma_channel0_word_count_register    .equ $01
dma_channel1_address_register       .equ $02
dma_channel1_word_count_register    .equ $03
dma_channel2_address_register       .equ $04
dma_channel2_word_count_register    .equ $05
dma_channel3_address_register       .equ $06
dma_channel3_word_count_register    .equ $07

;FDC controller environment variables

;fdc_send_bytes					.equ	$0082
;fdc_read_bytes					.equ 	$0082

;FDC controller port addresses

fdc_drive_control_register	.equ $12
fdc_data_rate_register		.equ $17
fdc_disk_changed_register	.equ $17
fdc_main_status_register	.equ $14
fdc_data_register			.equ $15

fdc_drive_control_register_motor0 
fdc_drive_control_register_motor1
fdc_drive_control_register_motor2 
fdc_drive_control_register_motor3

;--------- memory variables ---------

drivers_memory_start_address:		.equ drivers_memory_space_base_address 
crt_current_pointer_address     	.equ drivers_memory_start_address
crt_current_settings				.equ crt_current_pointer_address+2
crt_backup_cursor_character			.equ crt_current_settings+1
keyb_key_pressed_status				.equ crt_backup_cursor_character+1
crt_vram_start_address				.equ vram_memory_space_address

;program_status_byte				.equ 	drivers_memory_start_address
;floppy_drive_select				.equ	$7ff5
;floppy_track_number				.equ 	$7ff6
;floppy_head_number				.equ 	$7ff7
;floppy_sector_number			.equ	$7ff8
;floppy_sector_size				.equ 	$7ff9

extended_ascii_characters_table_start_offset 	.equ 219
extended_ascii_characters_table_end_offset		.equ 224

extended_ascii_characters_table:		.byte %10111111
										.byte %10001111
										.byte %10101010
										.byte %10010101
										.byte %10111100
extended_ascii_characters_table_end:


;------- CRT controller driver implementation ----

;crt_display_reset initializes the vram memory space with the backround predefined character
crt_display_reset:  				push h
									push d
									lxi h,0
									shld crt_current_pointer_address
									mvi a,crt_cursor_status_off
									sta crt_current_settings
									lxi h,crt_vram_start_address
									lxi d,crt_vram_dimension
crt_display_vram_clear_loop:		mvi m,crt_background_character
									inx h 
									dcx d 
									mov a,d 
									ora e 
									jnz crt_display_vram_clear_loop 
.if(debug_mode==false)
									lxi d,crt_vram_dimension
									lxi h,0
crt_display_external_vram_clear:	mvi a,crt_background_character
									call crt_byte_out 
									dcx d
									inx h
									mov a,d
									ora e
									jnz crt_display_external_vram_clear
.endif 
crt_display_reset_end:  			mvi a,crt_background_character
									sta crt_backup_cursor_character	
									pop d
									pop h
									ret

;crt_byte_out sends a byte to the external vram 
;A 	-> 	byte to send
;HL -> 	vram address

crt_byte_out:					push h 
								push d
								push b
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
crt_byte_out_next:				mov a,l 
								out crt_vram_low_address_port 
								mov a,h 
								out crt_vram_high_address_port 
.if(debug_mode==false)
crt_byte_out_ready_wait:		in crt_status_port 
								ani crt_line_feed_verify
								jnz crt_byte_out_ready_wait
								mov a,b 
								out crt_data_port 
.endif
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
									ani crt_cursor_status_mask
									cpi crt_cursor_status_off 
									jz crt_char_out_start
									lhld crt_current_pointer_address
									lda crt_backup_cursor_character	
									call crt_byte_out 
crt_char_out_start:					lhld crt_current_pointer_address 
									lxi d,crt_display_characters_size
									mov a,l
									sub e 
									mov a,h
									sbb d 
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
									cpi $7F
									jnc crt_char_out_custom_char
									cpi $0a 
									jz crt_char_out_new_line
									cpi $0d
									jz crt_char_out_carriage_return
									cpi $08
									jz crt_char_out_backspace
									cpi $20 
									jc crt_char_out_unknown_char
crt_char_out_ascii:					cpi $61
									jc crt_char_out_print
									cpi $7B
									jnc crt_char_out_print
									ani %11011111
crt_char_out_print:					call crt_byte_out 
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
crt_char_out_backspace:				dcx h
									mvi a,crt_background_character
									call crt_byte_out
									shld crt_current_pointer_address
									jmp crt_char_out_end 
crt_char_out_custom_char:			mov a,b
									call crt_byte_out 
									inx h
									shld crt_current_pointer_address
									jmp crt_char_out_end
crt_char_out_unknown_char:			mvi a,crt_background_character
									call crt_byte_out 
									shld crt_current_pointer_address
crt_char_out_end:					lda crt_current_settings
									ani crt_cursor_status_mask
									cpi crt_cursor_status_off 
									jz crt_char_out_end2
									lhld crt_current_pointer_address
									call crt_byte_in
									sta crt_backup_cursor_character	
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
						call crt_byte_in 
						sta crt_backup_cursor_character	
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
						lda crt_backup_cursor_character	
						call crt_byte_out 
crt_hide_cursor_end:	pop h 
						ret 


;-------- DMA controller driver implementation --------

dma_reset:				out dma_master_clear
						mvi a,dma_command_register_mm_enable+dma_command_register_ch0_hold_disable+dma_command_register_controller_enable+dma_command_register_compressed_timing+dma_command_register_drq_active_high+dma_command_register_dack_active_low 
						out dma_command_register
						mvi a,dma_mode_all_mask_register_channel3+dma_mode_all_mask_register_channel2+dma_mode_all_mask_register_channel1+dma_mode_all_mask_register_channel0
						out dma_all_mask_register
						ret

dma_memory_transfer:        mvi a,dma_mode_register_channel0+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_write_transfer
                            out dma_mode_register
                            mvi a,dma_mode_register_channel1+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_read_transfer
                             out dma_mode_register
                            out dma_ff_clear
                            mov a,c 
                            out dma_channel0_word_count_register
                            mov a,b 
                            out dma_channel0_word_count_register
                            out dma_ff_clear
                            mov a,c 
                            out dma_channel1_word_count_register
                            mov a,b 
                            out dma_channel1_word_count_register
                            out dma_ff_clear
                            mov a,e 
                            out dma_channel0_address_register
                            mov a,d 
                            out dma_channel0_address_register
                            out dma_ff_clear
                            mov a,l 
                            out dma_channel1_address_register
                            mov a,h 
                            out dma_channel1_address_register
                            mvi a,dma_request_register_set_request+dma_request_register_channel0_request
                            out dma_request_register
                            ret


;--------- PS/2 Keyboard driver implementation ---------

;keyb_status gets the current state of the PS/2 keyboard 
;A	<- $ff if there is an available character, $00 otherwise

.if(debug_mode==false)
keyb_status:				push h 
							lxi h,keyb_status_time_delay_value
							call time_delay
							in keyboard_input_port 
							ani keyboard_input_mask
							jz keyb_status_available
							lda keyb_key_pressed_status
							sui keyb_repeat_key_threshold
							jc keyb_status_released
							cpi keyb_repeat_filter_value
							jnc keyb_status_released
							inr a 
							sta keyb_key_pressed_status
							mvi a,$ff 
							jmp keyb_status_end
keyb_status_released:		xra a 
							sta keyb_key_pressed_status
							jmp keyb_status_end
keyb_status_available:		lda keyb_key_pressed_status
							ora a 
							jz keyb_status_first_press 
							cpi keyb_repeat_key_threshold
							jnc keyb_status_repeat
							inr a 
							sta keyb_key_pressed_status 
							xra a 
							jmp keyb_status_end
keyb_status_repeat:			mvi a,$ff 
							jmp keyb_status_end
keyb_status_first_press:	inr a 
							sta keyb_key_pressed_status
							mvi a,$ff
keyb_status_end:			pop h 
							ret

.endif 
.if(debug_mode==true) 
keyb_status:				mvi a,$ff 
							ret 
.endif 

;keyb_read gets the last avaiulable character from the PS/2 keyboard
;A <- last character
keyb_read:				in keyboard_input_port
.if(debug_mode==false)
						cma
						ani keyboard_data_mask
						cpi $0a 
						rnz 
						mvi a,$09
.endif
						ret

;time_delay generates a custom delay
;HL -> delay millis

.if (debug_mode==false)
time_delay:         push h                  ;12
time_delay_millis:  mvi a,time_delay_value  ;7
time_delay_loop:    dcr a                   ;4
                    jnz time_delay_loop     ;10
                    dcx h                   ;6
                    mov a,l                 ;4
                    ora h                   ;4
                    jnz time_delay_millis   ;10
time_delay_end:     pop h                   ;10
                    ret                     ;10
.endif 
.if(debug_mode==true)
time_delay: 		ret 
.endif 
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