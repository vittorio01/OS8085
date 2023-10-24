;questa libreria contiene le funzioni utilizzate per la conversione di numeri da esadecimale a BCD 


;unsigned_convert_hex_bcd_word converte un numero esadecimale a 16 bit in bcd 
;BC -> numero da convertire 
;SP -> [numero in BCD (3 bytes)]
unsigned_convert_hex_bcd_word:          pop psw 
                                        dcx sp 
                                        dcx sp 
                                        dcx sp 
                                        push psw 
                                        push h 
                                        push d 
                                        push b 
                                        lxi h,8
                                        dad sp 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        dcx h 
                                        dcx h
unsigned_convert_hex_bcd_word_loop:     mov a,b 
                                        ora a 
                                        jnz unsigned_convert_hex_bcd_word_loop2
                                        mov a,c 
                                        cpi 10 
                                        jnc unsigned_convert_hex_bcd_word_loop2
                                        mov m,c 
                                        jmp unsigned_convert_hex_bcd_word_loop_end 
unsigned_convert_hex_bcd_word_loop2:    lxi d,10 
                                        call unsigned_divide_word 
                                        mov m,e 
                                        mov a,b 
                                        ora a 
                                        jnz unsigned_convert_hex_bcd_word_loop3
                                        mov a,c 
                                        cpi 10 
                                        jnc unsigned_convert_hex_bcd_word_loop3
                                        rlc 
                                        rlc 
                                        rlc 
                                        rlc 
                                        ora m 
                                        mov m,a 
                                        jmp unsigned_convert_hex_bcd_word_loop_end 
unsigned_convert_hex_bcd_word_loop3:    lxi d,10 
                                        call unsigned_divide_word 
                                        mov a,e 
                                        rlc 
                                        rlc 
                                        rlc 
                                        rlc 
                                        ora m 
                                        mov m,a
                                        inx h  
                                        jmp unsigned_convert_hex_bcd_word_loop
unsigned_convert_hex_bcd_word_loop_end: pop b 
                                        pop d 
                                        pop h 
                                        ret 