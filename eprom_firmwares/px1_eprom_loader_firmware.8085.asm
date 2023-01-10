start_offset                    .equ    $8000
system_load_address             .equ    $0000       
system_start                    .equ    $8900
system_rom_disk_address         .equ    $8800
system_dimension                .equ    $5200

display_pointer_address     	.equ    $7ffc
display_pointer_addition		.equ 	$7ffe
display_character_backup		.equ 	$7fff
stack_pointer					.equ 	$7fdf

display_character_number		.equ 	512
display_character_x_number 		.equ 	32
display_character_y_number		.equ 	16
display_character_x_dimension	.equ 	2
display_character_y_dimension	.equ 	3

display_memory_dimension        .equ    512
display_background_character    .equ    %10000000
display_white_character			.equ 	%10111111
display_line_feed_verify        .equ    %00000001


delay_millis_value				.equ 	78
bios_graphic_delay              .equ    2000

display_low_port		    .equ $20			
display_high_port		    .equ $21			
display_data_port		    .equ $22			
display_status_port 	    .equ $20			

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

dma_channel0_address_register 			.equ $00
dma_channel0_word_count_register 		.equ $01
dma_channel1_address_register 			.equ $02
dma_channel1_word_count_register 		.equ $03
dma_channel2_address_register	    	.equ $04
dma_channel2_word_count_register     	.equ $05

bios_start:     		    .org start_offset 
                            jmp bios_graphic_print

bios_graphic_print:         lxi sp,stack_pointer
						    call display_reset
						
						    lxi h,start_graphic
						    call graphic_out
						    lxi h,start_string
						    call string_out
							call dma_reset 
load_system:                lxi h,system_load_address 
                            lxi b,system_dimension 
                            lxi d,system_start 
							call dma_memory_transfer  
							lxi h,bios_graphic_delay		    
delay_millis:		        mvi a,delay_millis_value	
delay_millis_loop:	        dcr a						
					        jnz delay_millis_loop							
						    dcx h
						    mov a,l
						    ora h
						    jnz delay_millis
							mvi a,$20 
							call display_char_out
							call print_address 
							mvi a,$20 
							call display_char_out
							mov c,e 
							mov b,d 
							call print_address 
							mvi a,$20 
							call display_char_out
							mov c,l 
							mov b,h 
							call print_address 
							mvi a,$20 
							call display_char_out
							in dma_status_register
							call print_byte 
                            jmp system_load_address

print_byte:					push psw 
							rar 
							rar 
							rar 
							rar 
							ani $0f 
							call hex_to_ascii
							call display_char_out
							pop psw 
							ani $0f 
							call hex_to_ascii
							call display_char_out 
							ret 

print_address:				mov a,b 
							rar 
							rar 
							rar 
							rar 
							ani $0f 
							call hex_to_ascii
							call display_char_out
							mov a,b 
							ani $0f 
							call hex_to_ascii
							call display_char_out 
							mov a,c 
							rar 
							rar 
							rar 
							rar 
							ani $0f 
							call hex_to_ascii
							call display_char_out
							mov a,c 
							ani $0f 
							call hex_to_ascii
							call display_char_out 
							ret 

dma_reset:	out dma_master_clear
			mvi a,%00001001			;dack active low, drq active high, compressed timing, m-to-m enable
			out dma_command_register
			mvi a,%00001111			;set dma channels 0,1,3 mask bit
			out dma_all_mask_register
			mvi a,%00000000
			out dma_mode_register 
			mvi a,%00000001
			out dma_mode_register 
			ret

;dma_memory_transfer 
;BC -> numero di bytes 
;DE -> indirizzo sorgente 
;HL -> indirizzo destinazione 

dma_memory_transfer:	dcx b 
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
						mvi a,%00000100
						out dma_request_register
						out dma_ff_clear
						in dma_channel1_word_count_register 
						mov c,a 
						in dma_channel1_word_count_register
						out dma_ff_clear
						mov b,a 
						in dma_channel0_address_register
						mov e,a 
						in dma_channel0_address_register
						out dma_ff_clear
						mov d,a 
						in dma_channel1_address_register
						mov l,a 
						in dma_channel1_address_register
						mov h,a 
						inx b 
						ret 

display_reset:      push psw
                    push h
                    push d
                    lxi h,0
					shld display_pointer_address
					xra a
					sta display_pointer_addition

                    lxi d,display_memory_dimension
                    shld display_pointer_address
display_reset_loop: mvi a,display_background_character
                    call display_out_nv
                    dcx d
                    inx h
                    mov a,d
                    ora e
                    jnz display_reset_loop
display_reset_end:  pop d
                    pop h
                    pop psw
                    ret

display_char_out:			push h
							lhld display_pointer_address
							push psw
							push d
							lxi d,display_character_number
							mov a,h
							cmp d
							jc display_char_out_next
							mov a,l
							cmp e
							jc display_char_out_next
display_lines_shift_up:		push b
							lxi h,0
							lxi b,display_character_number-display_character_x_number
							lxi d,display_character_x_number
display_line_shift_up_loop:	xchg 
							call display_in
							xchg 
							call display_out		
							dcx b
							inx h
							inx d
							mov a,b
							ora c
							jnz display_line_shift_up_loop
							pop b
							shld display_pointer_address
							lxi d,display_character_x_number
display_line_shift_up_lp2:	mvi a,display_background_character
							call display_out
							inx h
							dcx d
							mov a,d
							ora e
							jnz display_line_shift_up_lp2
							lhld display_pointer_address
display_char_out_next:		pop d
							pop psw
							push psw
							ani %01111111
							cpi $20
							jnc display_character_print
							cpi $0a 
							jz display_new_line
							cpi $0d
							jz display_carriage_return
							cpi $08
							jz display_backspace
							jmp display_character_send_end

display_new_line:			mvi a,display_character_x_number
							add l
							mov l,a
							mov a,h
							aci 0
							mov h,a
							jmp display_character_send_end

display_carriage_return:	xra a
							sui display_character_x_number
							ana l
							mov l,a
							jmp display_character_send_end

display_backspace:			mvi a, display_background_character
							call display_out
							dcx h
							jmp display_character_send_end

display_character_print:	cpi $61
							jc display_character_out
							cpi $7B
							jnc display_character_out
							ani %11011111
display_character_out:		call display_out
							inx h
display_character_send_end:	shld display_pointer_address
							pop psw
							pop h
							ret
                            
display_out_nv:     push psw
                    jmp display_out_send
display_out:	   	push psw
display_out_ver:    in  display_status_port
		            ani display_line_feed_verify
		            jnz display_out_ver
display_out_send:	mov a,l
		            out display_low_port
                    mov a,h
                    out display_high_port
                    pop psw
                    out display_data_port
                    ret		

display_in:		    in display_status_port
 		            ani display_line_feed_verify
 		            jnz display_in
display_in_nv:	    mov a,l
		            out display_low_port
  		            mov a,h
		            out display_high_port
		            in display_data_port
 		            ret


						
display_out_ad_nv:		push h
						push psw
						jmp display_out_addr_send
display_out_addr:		push h
						push psw
display_out_addr_vr:	in display_status_port			
		            	ani display_line_feed_verify	
		            	jnz display_out_addr_vr		
display_out_addr_send:	lhld display_pointer_address
						mov a,l
						out display_low_port
						mov a,h
						out display_high_port
						pop psw
						out display_data_port
						inx h
						shld display_pointer_address
						pop h
						ret

ascii_hex_conv: 	.b $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46


ascii_to_hex:	ani $4f	
				push h
				push d 
				lxi h,ascii_hex_conv
ascii_to_hex_2:	cmp m
				jz ascii_to_hex_e
				inx h
				jmp ascii_to_hex_2
ascii_to_hex_e:	lxi d,ascii_hex_conv 
				mov a,l
				sub e 
				pop d 
				pop h
				ret
		

hex_to_ascii:		push h
					ani $0f 
					lxi h,ascii_hex_conv 	
					add l 
					mov l,a 
					mov a,h 
					aci 0 
					mov h,a 
					mov a,m 
					pop h
					ret

string_out:		push psw		
string_out_1:	mov a,m			
    			ora a
				jz string_out_2
				mov c,m
				call display_char_out
				inx h
				jmp string_out_1
string_out_2:	pop psw
        		ret

graphic_out:		push psw		
graphic_out_1:		mov a,m			
					ora a
					jz graphic_out_2
					mov c,m
					call display_out_addr
					inx h
					jmp graphic_out_1
graphic_out_2:		pop psw
        			ret

start_graphic: 		.b %10000001, %10000011, %10000001, %10000001, %10000000, %10000000, %10000011, %10000000, %10000010, %10000001, %10000010, %10000000, %10000011, $80, $80, $80 
					.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
					.b %10010101, %10001100, %10010001, %10011001, %10000100, %10001000, %10101110, %10100010, %10101010, %10101010, %10010101, %10010000, %10001101, $80, $80, $80 
					.b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
					.b %10010000, %10000000, %10010000, %10010000, %10000000, %10000000, %10110000, %10000000, %10100000, %10010000, %10100000, %10010000, %10100000, $80, $80, $80
					.b 0

start_string:		.b $0a, $0d
					.text "32K BYTES RAM"
					.b $0a, $0d
					.text "512 BYTES VIDEO RAM"
					.b $0a, $0d
					.text "STARTING SYSTEM"
					.b $0a, $0d, 0

dma_debug_string:   .text "DMA TRANSFER VALUES:"
					.b $0a, $0d, 0 