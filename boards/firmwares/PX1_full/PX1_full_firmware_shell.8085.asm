ascii_hex_conv: 	.org rom_memory_offset+$30					
					.b $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $41, $42, $43, $44, $45, $46


delay_millis_value				.equ 	78

keyboard_pointer_delay			.equ 	500
keyboard_insert_delay			.equ 	200
;firmware di base
bios_start:     		lxi sp,stack_pointer
						call display_reset
						
						lxi h,start_graphic
						call graphic_out
						lxi h,start_string
						call string_out

						lxi h,5000
bios_wait_loop:			call delay_millis
						dcx h
						mov a,l
						ora h
						jnz bios_wait_loop

						;call fdc_reset
						;call dma_reset


						lxi h,0080
hex_editor_return: 		call display_reset
						push h
						mov a,l
						ani %11111000
						mov l,a
						mvi b,15
						call hex_editor_println
hex_editor_fprint:		mvi a,$0a
						call display_char_out
						mvi a,$0d
						call display_char_out
						call hex_editor_println
						dcr b
						jnz hex_editor_fprint
						pop h
						mov a,l
						ani %00000111
						mov b,a
						call hex_memory_address_fix
hex_editor_action:		call keyboard_char_in
						ani %11011111
						cpi 'S'
						jz hex_editor_selectdw
						cpi 'A'
						jz hex_editor_selectlf
						cpi 'D' 
						jz hex_editor_selectrt
						cpi 'W'
						jz hex_editor_selectup
						cpi 'E'
						jz hex_editor_write
						cpi 'J'
						jz hex_editor_search
						cpi 'L'
						jz program_launch
						
						jmp hex_editor_action
hex_editor_selectrt:	mvi e,1
						mvi d,0
						jmp hex_editor_select
hex_editor_selectdw:	mvi e,$08
						mvi d,0
						jmp hex_editor_select
hex_editor_selectup:	mvi e,0
						mvi d,$08
						jmp hex_editor_select
hex_editor_selectlf:	mvi e,0
						mvi d,1
hex_editor_select:		call hex_editor_fprocess
						jmp hex_editor_action

hex_editor_fprocess:	mov a,d
						ora a
						jnz hex_editor_dcr_byte
						ora e
						jz hex_editor_pointerset
hex_editor_inrbyte:		mov a,b
						cpi 127
						jz hex_editor_addline
						inr b
						inx h
						dcr e
						jnz hex_editor_inrbyte
						jmp hex_editor_pointerset
hex_editor_dcr_byte:	mov a,b
						ora a
						jz hex_editor_subline
						dcr b
						dcx h
						dcr d
						jnz hex_editor_dcr_byte
hex_editor_pointerset:	call hex_memory_address_fix
						ret
			
hex_editor_addline:		sui $08
						mov b,a
						push h
						lxi h,$200
						shld display_pointer_address
						pop h
						push h
						inx h
						call hex_editor_println
						pop h
						jmp hex_editor_fprocess
hex_editor_subline:		mvi b,$08
						call display_shift_down
						push h
						dcx h
						mov a,l
						ani %11111000
						mov l,a
						call hex_editor_println
						pop h
						jmp hex_editor_fprocess
			
				
hex_editor_write:		call keyboard_char_in
						cpi 'Q'
						jz hex_editor_action
						cpi 'q'
						jz hex_editor_action
						cpi ' '
						jz hex_editor_write_jump
						cpi $08
						jz hex_editor_dcr
						mov c,a
						call hex_test
						ora a
						jz hex_editor_write
						mov a,c
						call ascii_to_hex
						add a
						add a
						add a
						add a
						mov m,a
						cmp m
						jnz hex_editor_readonly
						mov a,c
						call display_char_out
hex_editor_req2:		call keyboard_char_in
						cpi 'Q'
						jz hex_editor_action
						cpi 'q'
						jz hex_editor_action
						cpi ' '
						jz hex_editor_write_jump
						cpi $08
						jz hex_editor_write_back
						mov c,a
						call hex_test
						ora a
						jz hex_editor_req2
						mov a,c
						call ascii_to_hex
						ora m
						mov m,a
						cmp m
						jnz hex_editor_write_jump
						mov a,c
						call display_char_out
hex_editor_write_jump:	mvi e,$01
						mvi d,0
						call hex_editor_fprocess
						jmp hex_editor_write
hex_editor_dcr:			mvi e,0
						mvi d,$01
						call hex_editor_fprocess
						jmp hex_editor_write
hex_editor_write_back:	push h
						lhld display_pointer_address
						dcx h
						shld display_pointer_address
						pop h
						jmp hex_editor_write
hex_editor_readonly:	push h
						lhld display_pointer_address
						inx h
						shld display_pointer_address
						pop h
						jmp hex_editor_req2

hex_editor_search:		push d
						lxi h,display_character_number-display_character_x_number
						lxi d,display_character_x_number
hex_editor_search_loop:	mvi a,display_background_character
						call display_out
						dcx d
						inx h
						mov a,d
						ora e
						jnz hex_editor_search_loop

						lxi h,display_character_number-display_character_x_number
						call set_display_pointer

hex_editor_search_1:	call keyboard_char_in
						mov d,a
						call is_hex
						jz hex_editor_search_1
						mov a,d
						call display_char_out
						call ascii_to_hex
						add a 
						add a 
						add a
						add a
						mov h,a
hex_editor_search_2:	call keyboard_char_in
						mov d,a
						call is_hex
						jz hex_editor_search_2
						mov a,d
						call display_char_out
						call ascii_to_hex
						ora h
						mov h,a
hex_editor_search_3:	call keyboard_char_in
						mov d,a
						call is_hex
						jz hex_editor_search_3
						mov a,d
						call display_char_out
						call ascii_to_hex
						add a 
						add a 
						add a
						add a
						mov l,a
hex_editor_search_4:	call keyboard_char_in
						mov d,a
						call is_hex
						jz hex_editor_search_4
						mov a,d
						call display_char_out
						call ascii_to_hex
						ora l
						mov l,a
						pop d
						jmp hex_editor_return

hex_editor_println:		push b
						mov a,h
						rar
						rar
						rar
						rar
						ani $0f
						call hex_to_ascii
						call display_char_out
						mov a,h
						ani $0f
						call hex_to_ascii
						call display_char_out
						mov a,l
						rar
						rar
						rar
						rar
						ani $0f
						call hex_to_ascii
						call display_char_out
						mov a,l
						ani $0f
						call hex_to_ascii
						call display_char_out
						mvi a,$20
						call display_char_out
						mvi a,%10101010
						call display_out_addr
						mvi b,$08
hex_editor_printloop:	mov a,m
						rar
						rar 
						rar 
						rar
						ani $0f
						call hex_to_ascii
						call display_char_out
		
						mov a,m
						ani $0f
						call hex_to_ascii
						call display_char_out
						mvi a,$20
						call display_char_out
						inx h
						dcr b
						jnz hex_editor_printloop
						mvi a,$08
						call display_char_out
						mvi a,%10010101 
						call display_out_addr
						pop b
						ret 
			
hex_memory_address_fix:	push h
						push b
						lxi h,0
						
						mov a,b
						ani %11111000
						rar
						rar 
						rar
						mov c,a
						jz hex_memory_addfx_jump
hex_memory_addfx_loop:	mov a,l
						adi %00100000
						mov l,a
						mov a,h
						aci 0
						mov h,a
						dcr c
						jnz hex_memory_addfx_loop
hex_memory_addfx_jump:	mov a,b
						ani %00000111
						mov c,a
						mov a,l
						adi $06
						mov l,a
						mov a,c
						ora a
						jz hex_editor_addfx_end
hex_memory_addfx_loop2:	inx h
						inx h
						inx h
						dcr c
						jnz hex_memory_addfx_loop2
hex_editor_addfx_end:	shld display_pointer_address
						pop b
						pop h
						ret

display_shift_down:			push h
							push d
							lxi d,display_character_number-1
							lxi h,display_character_number-display_character_x_number-1
display_shift_down_loop:	call display_in
							xchg
							call display_out
							xchg
							dcx d
							dcx h
							mov a,h
							ora a
							jnz display_shift_down_loop
							mov a,l
							ora a
							jnz display_shift_down_loop
							shld display_pointer_address
							lxi d,display_character_x_number
display_reset_line:			mvi a,display_background_character
							call display_out
							inx h
							dcx d
							mov a,d
							ora e
							jnz display_reset_line
							pop d
							pop h
							ret

hex_test:	cpi $30			
			jc not_hex	
			cpi $3A
			jnc hex_test_1
			jmp is_hex
hex_test_1:	cpi $41
			jc not_hex
			cpi $47
			jnc hex_test_2
			jmp is_hex
hex_test_2:	cpi $61
			jc not_hex
			cpi $67
			jnc not_hex
is_hex:		mvi a,$ff
			ret
not_hex:	mvi a,0
			ret

ascii_to_hex:	cpi $61			
				jc ascii_to_hex_1	
				ani $4f	
ascii_to_hex_1:	push h
				lxi h,ascii_hex_conv
ascii_to_hex_2:	cmp m
				jz ascii_to_hex_e
				inx h
				jmp ascii_to_hex_2
ascii_to_hex_e:	mov a,l
				ani $0f
				pop h
				ret
		

hex_to_ascii:		push h
					push b			
					mov b,a
					lxi h,ascii_hex_conv
hex_to_ascii_loop:	mov a,l
					ani $0f
					cmp b
					jz hex_to_ascii_end
					inx h
					jmp hex_to_ascii_loop
hex_to_ascii_end:	mov a,m
					pop b
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

keyboard_char_in:	push h
keyboard_loop1:		lxi h,keyboard_pointer_delay 
					call pointer_enable
keyboard_loop1_1:	call keyboard_in_ver
					ora a
					call delay_millis
					jnz keyboard_loop1_end 
					dcx h
					mov a,h
					ora l
					jnz keyboard_loop1_1
		
					call pointer_disable
					lxi h,keyboard_pointer_delay
keyboard_loop2_1:	call keyboard_in_ver
					ora a
					call delay_millis
					jnz keyboard_loop2_end 
					dcx h
					mov a,h
					ora l
					jnz keyboard_loop2_1

					jmp keyboard_loop1

keyboard_loop1_end:	call pointer_disable	 
keyboard_loop2_end:	call keyboard_in_data

					push psw
					lxi h,keyboard_insert_delay
keyboard_end_delay:	call delay_millis
					dcx h
					mov a,h
					ora l
					jnz keyboard_end_delay
					pop psw
					pop h
					ret

pointer_enable:	push h
				push psw
				lhld display_pointer_address
				call display_in
				sta display_character_backup
				mvi a,display_white_character
				call display_out
				pop psw
				pop h
				ret

pointer_disable:	push h
					push psw
					lhld display_pointer_address
					lda display_character_backup
					call display_out
					pop psw
					pop h
					ret

program_launch:	call display_reset
				pchl

hex_editor_help_text2:	.text 	"--    FUNZIONI DISPONIBILI    --"
						.b $0a, $0d
						.text 	"DURANTE LA FASE DI SELEZIONE:"
						.b $0a, $0d
						.text 	"4 PER SCORRERE A SINISTRA"
						.b $0a, $0d
						.text 	"6 PER SCORRERE A DESTRA"
						.b $0a, $0d
						.text 	"2 PER SCORRERE IN BASSO"
						.b $0a, $0d
						.text 	"8 PER SCORRERE IN ALTO"
						.b $0a, $0d
						.text  	"INVIO PER MODIFICARE"
						.b $0a, $0d
						.text 	"H PER MOSTRARE LA GUIDA"
						.b $0a, $0d
						.text 	"L PER AVVIARE IL PROGRAMMA"
						.b $0a, $0d
						.text 	"NELLA FASE DI MODIFICA"
						.b $0a, $0d
						.text 	"BCK PER TORNARE INDIETRO"
						.b $0a, $0d
						.text  	"INVIO PER SALTARE IL BYTE"
						.b $0a, $0d
						.text  	"ESC PER TORNARE ALLA SELEZIONE"
						.b $0a, $0d
						.b 0

								
hex_editor_help_text:	.text	"--    GUIDA PER L'UTILIZZO    --"
						.b $0a, $0d
						.text 	"L'EDITOR ESADECIMALE RENDE POSSI"
						.text 	"BILE LA LETTURA DEI BYTES PRESEN"
						.text 	"TI IN MEMORIA."
						.b $0a, $0d
						.TEXT 	"PRIMA SI SELEZIONA IL BYTE CON I"
						.text 	" TASTI DI SCORRIMENTO, POI SI MO"
						.text 	"DIFICA IL BYTE DESIDERATO"
						.b $0a, $0d
						.b 0

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
					.text "AVVIO DELLE RISORSE"
					.b 0