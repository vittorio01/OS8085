;unsigned_multiply_word esegue la moltiplicazione fra due numeri interi senza segno a 16 bit e restituisce un risultato a 32 bit
;BC -> primo operando
;DE -> secondo operando
;BCDE <- risultato dell'operazione

unsigned_multiply_word:                 mov a,c 
                                        ora b
                                        jnz unsigned_multiply_word_not_zero_value
                                        lxi d,0
                                        ret  
unsigned_multiply_word_not_zero_value:  mov a,e 
                                        ora d 
                                        jnz unsigned_multiply_word_not_zero_value2
                                        lxi b,0 
                                        ret
unsigned_multiply_word_not_zero_value2: push h 
                                        lxi h,0 
                                        push h 
                                        push h        ;stack -> [accumulatore]
                                        push h  
                                        push d  
                                        mvi a,16 
                                        push psw      ;stack -> [iterazioni] [secondo operando] [accumulatore]
                                        dad sp 
                                        inx h 
                                        inx h 
                                        mov e,l 
                                        mov d,h 
                                        inx h 
                                        inx h 
                                        inx h 
                                        inx h         ;stack -> [iterazioni] [secondo operando] [accumulatore]  HL -> &accumulatore  DE -> &secondo operando
unsigned_multiply_word_loop:            mov a,b 
                                        rar 
                                        mov b,a 
                                        mov a,c 
                                        rar 
                                        mov c,a 
                                        jnc unsigned_multiply_word_shift_loop
                                        ldax d 
                                        add m 
                                        mov m,a
                                        inx h 
                                        inx d 
                                        ldax d 
                                        adc m 
                                        mov m,a 
                                        inx h 
                                        inx d 
                                        ldax d 
                                        adc m 
                                        mov m,a 
                                        inx h 
                                        inx d 
                                        ldax d 
                                        adc m 
                                        mov m,a 
                                        dcx h 
                                        dcx h 
                                        dcx h 
                                        dcx d 
                                        dcx d 
                                        dcx d 
unsigned_multiply_word_shift_loop:      ldax d 
                                        add a
                                        stax d 
                                        inx d 
                                        ldax d 
                                        ral 
                                        stax d 
                                        inx d 
                                        ldax d 
                                        ral
                                        stax d 
                                        inx d 
                                        ldax d 
                                        ral 
                                        stax d 
                                        dcx d 
                                        dcx d 
                                        dcx d
                                        xthl 
                                        dcr h 
                                        xthl 
                                        jnz unsigned_multiply_word_loop
                                        pop d 
                                        pop d 
                                        pop d
                                        pop d 
                                        pop b 
                                        pop h 
                                        ret 