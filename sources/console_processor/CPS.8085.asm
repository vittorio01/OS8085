
;funzione che confronta due stringe verifica se sono uguali
;HL -> prima stringa
;DE -> seconda stringa

;A  <- $ff se le due stringhe sono uguali, $00 altrimenti
cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,$00bf
                ;call mms_low_memory_initialize
                lxi b,$000F
                lxi d,$000F
                push d 
                push b
                lxi b,$000B
                lxi d,$000B
                push d 
                push b 
                lxi b,$AAAA
                lxi d,$AAAA
                call unsigned_divide_long
                hlt

                call mms_bistream_reset
                call mms_bitstream_number_request
                call mms_bitstream_reset_requested_bit
                hlt 
                ;call cold_start
                
                lxi h,128
                call mms_create_low_memory_user_data_segment
                lxi h,256
                call mms_create_low_memory_system_data_segment
                lxi h,0
                mvi a,$AA 
loop:           call mms_write_selected_system_segment_byte
                inx h
                jnc loop 
                call mms_read_data_segment_operation_error_code
                call mms_delete_selected_low_memory_user_data_segment
                call mms_delete_selected_low_memory_system_data_segment
                hlt

string_compare:     push d 
                    push h 
string_cmp_loop:    mov a,m 
                    cpi 0
                    jnz string_cmp_loop2
                    ldax d 
                    cpi 0 
                    jnz string_not_equals
                    jz string_equals
string_cmp_loop2:   ldax d
                    cmp m 
                    jnz string_not_equals
string_cmp_loop3:   inx h 
                    inx d 
                    jmp string_cmp_loop

string_not_equals:  mvi a,$0 
                    pop d 
                    pop h 
                    ret

string_equals:      mvi a,$ff
                    mov e,c 
                    mov d,b 
                    pop b 
                    pop h 
                    ret

CPS_level_end: