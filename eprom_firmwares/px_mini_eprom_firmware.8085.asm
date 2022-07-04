;firmware di base
firmware_start:                     di
                                    lxi h,startup_message 
                                    call string_out
system_first_sector_load:           mvi a,00
                                    call select_mass_memory_drive
                                    ora a 
                                    jz system_first_sector_load_error
                                    mvi a,01
                                    call select_mass_memory_track
                                    ora a 
                                    jz system_first_sector_load_error
                                    mvi a,02
                                    call select_mass_memory_sector
                                    ora a 
                                    jz system_first_sector_load_error
                                    lxi h,$0050
                                    call mass_memory_read_sector
                                    ora a 
                                    jnz $0050

system_first_sector_load_error:     lxi h,system_start_error
                                    hlt

string_out:	push psw		
		push b
string_out_1:	mov a,m			
		cpi 0
		jz string_out_2
		mov c,m
		call char_out
		inx h
		jmp string_out_1
string_out_2:	pop b
		pop psw
		ret

startup_message     .text "PX-BIOS v1.0 MINI BY V.P."
                    .b $0a,$0d
                    .text "CPU -> INTEL 8085 2MHZ"
                    .b $0a,$0d
                    .text "RAM -> 32KB"
                    .b $0a,$0d
                    .text "AVVIO DEL SISTEMA IN CORSO..."
                    .b $0a,$0d,$00

system_start_error  .text "ERRORE NELL'AVVIO DEL SISTEMA: SETTORE DI AVVIO NON TROVATO"
                    .b $0a,$0d,$00