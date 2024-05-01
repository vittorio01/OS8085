;unsigned_divide_byte esegue la divisione fra due numeri interi senza segno a 8 bit
;B -> dividendo
;C -> divisore
;B <- quoziente
;C <- resto

unsigned_divide_byte:               mov a,b 
                                    ora a 
                                    jz unsigned_divide_byte_zero_return
                                    mov a,c 
                                    ora a 
                                    jz unsigned_divide_byte_zero_return
                                    push h 
                                    push d 
                                    lxi d,0
                                    lxi h,0
unsigned_divide_byte_align:         ora a 
                                    jm unsigned_divide_byte_align_end
                                    rlc 
                                    inr e 
                                    jmp unsigned_divide_byte_align
unsigned_divide_byte_align_end:     mov c,a 
                                    mov a,b 
unsigned_divide_byte_align2:        ora a
                                    jm unsigned_divide_byte_align2_end
                                    rlc 
                                    inr d 
                                    jmp unsigned_divide_byte_align2
unsigned_divide_byte_align2_end:    mov b,a 
                                    mov a,e 
                                    sub d  
                                    mov e,a 
                                    jc unsigned_divide_byte_end
unsigned_divide_byte_loop:          mov a,b 
                                    cmp c 
                                    jc unsigned_divide_byte_loop2
                                    sub c 
                                    mov b,a
unsigned_divide_byte_loop2:         mov a,h 
                                    cmc
                                    ral
                                    mov h,a
                                    stc 
                                    cmc 
                                    mov a,c 
                                    rar 
                                    mov c,a 
                                    dcr e 
                                    jm unsigned_divide_byte_end
                                    jmp unsigned_divide_byte_loop
unsigned_divide_byte_end:           mov c,b 
                                    mov a,d 
                                    ora a
                                    jz unsigned_divide_byte_end2
                                    mov a,c 
unsigned_divide_byte_align3:        rar 
                                    dcr d 
                                    jnz unsigned_divide_byte_align3
                                    mov c,a
unsigned_divide_byte_end2:          mov b,h
                                    pop d 
                                    pop h 
                                    ret 
unsigned_divide_byte_zero_return:   lxi b,0
                                    ret 