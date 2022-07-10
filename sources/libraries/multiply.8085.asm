;questa libreria contiene gli algoritmi utilizzati per la moltiplicazione fra due numeri di diversa grandezza

;unsigned_multiply_byte esegue una moltiplicazione senza segno fra due numeri a 8 bit e restituisce un risultato di 16bit
;B -> primo operando
;C -> secondo operando
;BC <- risultato

unsigned_multiply_byte:             mov a,b 
                                    ora a 
                                    jnz unsigned_multiply_byte_not_zero
                                    mov c,b 
                                    ret
unsigned_multiply_byte_not_zero:    mov a,c 
                                    ora a
                                    jnz unsigned_multiply_byte_not_zero2
                                    mov b,c 
                                    ret 
unsigned_multiply_byte_not_zero2:   push d 
                                    push h 
                                    lxi h,0 
                                    mvi d,0
                                    mov e,c 
                                    mvi c,7 
unsigned_multiply_byte_loop:        mov a,b  
                                    rrc
                                    mov b,a 
                                    jnc unsigned_multiply_byte_loop_jump
                                    dad d 
unsigned_multiply_byte_loop_jump:   mov a,e 
                                    add e 
                                    mov e,a 
                                    mov a,d 
                                    ral 
                                    mov d,a
                                    dcr c 
                                    jnz unsigned_multiply_byte_loop
                                    mov c,l 
                                    mov b,h
                                    pop h 
                                    pop d 
                                    ret 

;unsigned_multiply_word esegue la moltiplicazione fra due numeri interi senza segno a 16 bit e restituisce un risultato a 32 bit
;BC -> primo operando
;DE -> secondo operando
;A <- esito dell'operazione (può generare un errore nella creazione del segmento in memoria)
;DEHL <- risultato dell'operazione

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

;unsigned_multiply_long esegue la moltiplicazione fra due numeri interi senza segno a 32 bit e restituisce come risultato un numero a 64 bit
; SP -> [primo operando (4bytes)][secondo operando(4bytes)]
; SP <- [risultato (8bytes)]
unsigned_multiply_long:         pop psw
                                push h  
                                push h 
                                push h 
                                push h 
                                push h 
                                push h 
                                push psw
                                push h 
                                push d 
                                push b  
                                mvi a,32
                                push psw ;stack: [iterazioni][BC][DE][HL][SP][accumulatore (8bytes)][primo operando(8bytes)][secondo operando(4bytes)]           
                                lxi h,0 
                                dad sp 
                                mvi a,10 
                                add l 
                                mov l,a 
                                mov a,h 
                                aci 0
                                mov h,a 
                                push h 
                                mvi a,8 
unsigned_multiply_long_clear:   mvi m,0
                                inx h 
                                dcr a 
                                jnz unsigned_multiply_long_clear
                                pop h 
                                mov e,l 
                                mov d,h 
                                mvi a,8
                                add l 
                                mov l,a 
                                mov a,h 
                                aci 0 
                                mov h,a 
                                mov c,l 
                                mov b,h 
                                mvi a,4
                                add l 
                                mov l,a 
                                mov a,h 
                                aci 0 
                                mov h,a     ;HL -> &primo operando   BC -> &secondo operando DE -> &accumulatore
                                push b 
                                mov a,m 
                                stax b 
                                inx b 
                                mvi m,0
                                inx h 
                                mov a,m 
                                stax b 
                                inx b 
                                mvi m,0
                                inx h 
                                mov a,m 
                                stax b 
                                inx b 
                                mvi m,0
                                inx h 
                                mov a,m 
                                stax b  
                                mvi m,0
                                inx h 
                                pop b 
unsigned_multiply_long_loop:    xthl 
                                mvi l,4
                                xthl
                                inx h 
                                inx h 
                                inx h 
                                push psw 
unsigned_multiply_long_shift1:  pop psw 
                                mov a,m
                                rar 
                                mov m,a
                                dcx h 
                                push psw 
                                inx sp
                                inx sp 
                                xthl 
                                dcr l 
                                xthl 
                                dcx sp 
                                dcx sp 
                                jnz unsigned_multiply_long_shift1
                                inx h 
                                pop psw 
                                jnc unsigned_multiply_long_shift2
                                xthl
                                mvi l,8
                                xthl
                                xchg 
                                stc 
                                cmc
                                push psw 
unsigned_multiply_long_add:     pop psw 
                                ldax b 
                                adc m 
                                mov m,a 
                                inx h 
                                inx b 
                                push psw 
                                inx sp 
                                inx sp 
                                xthl 
                                dcr l 
                                xthl 
                                dcx sp 
                                dcx sp 
                                jnz unsigned_multiply_long_add
                                pop psw 
                                xchg
                                mov a,c 
                                sui 8
                                mov c,a 
                                mov a,b 
                                sbi 0
                                mov b,a 
                                mov a,e
                                sui 8
                                mov e,a 
                                mov a,d 
                                sbi 0
                                mov d,a       
unsigned_multiply_long_shift2:  xthl
                                mvi l,8
                                xthl
                                stc 
                                cmc
                                push psw 
unsigned_multiply_long_shift22: pop psw 
                                ldax b  
                                ral  
                                stax b 
                                inx b 
                                push psw 
                                inx sp 
                                inx sp 
                                xthl 
                                dcr l 
                                xthl 
                                dcx sp 
                                dcx sp 
                                jnz unsigned_multiply_long_shift22
                                pop psw
                                mov a,c 
                                sui 8
                                mov c,a 
                                mov a,b 
                                sbi 0
                                mov b,a 
                                xthl 
                                dcr h 
                                xthl 
                                jnz unsigned_multiply_long_loop
                                inx h 
                                inx h 
                                inx h 
                                dcx b
                                mvi d,16 
                                push b
unsigned_multiply_long_result:  ldax b
                                mov m,a 
                                dcx b 
                                dcx h 
                                dcr d 
                                jnz unsigned_multiply_long_result
                                inx h
                                sphl
                                pop b 
                                pop d 
                                pop h 
                                ret 
                                

                                

                                
                                
