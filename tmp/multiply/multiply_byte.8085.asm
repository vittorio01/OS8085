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