;questa libreria contiene le funzioni utilizzate per la conversione di numeri da esadecimale a BCD 


;unsigned_convert_hex_bcd_long converte un numero esadecimale a 32 bit in bcd 
;SP -> [numero da convertire (4 bytes)]
;SP -> [numero in BCD (6 bytes)]
unsigned_convert_hex_bcd_long:          push h 
                                        pop psw 
                                        lxi h,0 
                                        dad sp 
                                        dcx sp 
                                        dcx sp 
                                        push psw 
                                        inx sp 
                                        inx sp 
                                        mov a,m 
                                        xthl 
                                        mov l,a 
                                        xthl 
                                        inx h 
                                        mov a,m  
                                        xthl 
                                        mov h,a 
                                        xthl 
                                        inx h 
                                        dcx sp 
                                        dcx sp 
                                        push b 
                                        push d 
                                        xchg 
                                        lxi h,$ffff-8+1 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        mov a,l 
                                        sui 14
                                        mov e,a 
                                        mov a,h 
                                        sbi 0 
                                        mov d,a 
                                        mov a,e
                                        sui 4 
                                        mov c,a 
                                        mov a,d     ;BC -> [dividendo/resto]
                                        sbi 0       ;DE -> [divisore/quoziente] 
                                        mov b,a     ;HL -> [risultato]
                                        mov a,m 
                                        stax d
                                        inx h 
                                        inx d   
                                        mov a,m 
                                        stax d
                                        inx h 
                                        inx d   
                                        mov a,m 
                                        stax d
                                        inx h 
                                        inx d   
                                        mov a,m 
                                        stax d 
                                        dcx d
                                        dcx d 
                                        dcx d 
                                        mvi a,6
unsigned_convert_hex_bcd_long_clear:    mvi m,0 
                                        dcx h 
                                        dcr a 
                                        jnz unsigned_convert_hex_bcd_long_clear
                                        xra a 
                                        stax b 
                                        inx b 
                                        stax b 
                                        inx b 
                                        stax b 
                                        inx b 
                                        stax b 
                                        dcx b 
                                        dcx b 
                                        dcx b 
                                        inx h 
unsigned_convert_hex_bcd_long_loop:     xchg 
                                        inx h 
                                        mov a,m 
                                        inx h 
                                        ora m 
                                        inx h 
                                        ora m 
                                        dcx h 
                                        dcx h 
                                        dcx h 
                                        jnz unsigned_convert_hex_bcd_long_loop2
                                        mov a,m 
                                        cpi 10 
                                        jnc unsigned_convert_hex_bcd_long_loop2
                                        xchg 
                                        mov m,a 
                                        jmp unsigned_convert_hex_bcd_long_loop_end 
unsigned_convert_hex_bcd_long_loop2:    mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        dcx b 
                                        dcx b 
                                        dcx b 
                                        dcx h 
                                        dcx h 
                                        dcx h 
                                        xchg 
                                        mvi a,10 
                                        stax d
                                        inx d 
                                        mvi a,0 
                                        stax d 
                                        inx d 
                                        mvi a,0 
                                        stax d 
                                        inx d 
                                        mvi a,0 
                                        stax d
                                        dcx d 
                                        dcx d 
                                        dcx d 
                                        call unsigned_divide_long 
                                        ldax b 
                                        mov m,a 
                                        xchg 
                                        inx h 
                                        mov a,m 
                                        inx h 
                                        ora m 
                                        inx h 
                                        ora m 
                                        dcx h 
                                        dcx h 
                                        dcx h 
                                        jnz unsigned_convert_hex_bcd_long_loop3
                                        mov a,m 
                                        cpi 10 
                                        jnc unsigned_convert_hex_bcd_long_loop3
                                        xchg 
                                        rlc 
                                        rlc 
                                        rlc 
                                        rlc 
                                        ora m 
                                        mov m,a 
                                        jmp unsigned_convert_hex_bcd_long_loop_end 
unsigned_convert_hex_bcd_long_loop3:    mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        inx h 
                                        inx b 
                                        mov a,m 
                                        stax b 
                                        dcx b 
                                        dcx b 
                                        dcx b 
                                        dcx h 
                                        dcx h 
                                        dcx h 
                                        xchg 
                                        mvi a,10 
                                        stax d 
                                        inx d  
                                        mvi a,0 
                                        stax d  
                                        inx d 
                                        mvi a,0 
                                        stax d 
                                        inx d  
                                        mvi a,0 
                                        stax d 
                                        dcx d  
                                        dcx d 
                                        dcx d  
                                        call unsigned_divide_long 
                                        ldax b 
                                        rlc 
                                        rlc 
                                        rlc 
                                        rlc 
                                        ora m 
                                        mov m,a
                                        inx h  
                                        jmp unsigned_convert_hex_bcd_long_loop
unsigned_convert_hex_bcd_long_loop_end: lxi h,8 
                                        dad sp 
                                        sphl 
                                        pop d
                                        pop d 
                                        pop b 
                                        ret 