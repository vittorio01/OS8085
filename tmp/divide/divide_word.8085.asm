;unsigned_divide_word esegue una divisione fra numeri due interi senza segno di 16bit

;BC -> dividendo
;DE -> divisore
;BC <- quoziente
;DE <- resto

unsigned_divide_word:           mov a,b 
                                ora c 
                                jz unsigned_divide_word_zero_return
                                mov a,d 
                                ora e 
                                jz unsigned_divide_word_zero_return
                                push h 
                                lxi h,0 
                                push h      ;HL: [indici] SP: [quoziente]
unsigned_divide_word_align:     mov a,b 
                                ora a 
                                jm unsigned_divide_word_align2
                                mov a,c 
                                add a 
                                mov c,a 
                                mov a,b 
                                ral 
                                mov b,a 
                                inr h 
                                jmp unsigned_divide_word_align
unsigned_divide_word_align2:    mov a,d 
                                ora a 
                                jm unsigned_divide_word_align_end
                                mov a,e 
                                add a
                                mov e,a 
                                mov a,d 
                                ral 
                                mov d,a 
                                inr l 
                                jmp unsigned_divide_word_align2
unsigned_divide_word_align_end: mov a,l 
                                sub h 
                                jc unsigned_divide_world_end
                                mov l,a 
unsigned_divide_word_loop:      mov a,c 
                                sub e  
                                mov a,b 
                                sbb d
                                jc unsigned_divide_word_skip
                                mov b,a 
                                mov a,c 
                                sub e 
                                mov c,a 
                                stc 
                                cmc 
unsigned_divide_word_skip:      xthl
                                cmc 
                                mov a,l 
                                ral 
                                mov l,a 
                                mov a,h 
                                ral 
                                mov h,a 
                                xthl 
                                mov a,d 
                                rar 
                                mov d,a 
                                mov a,e 
                                rar
                                mov e,a 
                                dcr l 
                                jm unsigned_divide_world_end
                                jmp unsigned_divide_word_loop
unsigned_divide_world_end:      mov a,h 
                                ora a 
                                jz unsigned_divide_world_end2
                                stc 
                                cmc 
unsigned_divide_world_align3:   mov a,b 
                                rar 
                                mov b,a 
                                mov a,c
                                rar 
                                mov c,a                       
                                dcr h 
                                jnz unsigned_divide_world_align3
unsigned_divide_world_end2:     mov e,c 
                                mov d,b      
                                pop b 
                                pop h 
                                ret 

unsigned_divide_word_zero_return:   lxi b,0 
                                    lxi d,0 
                                    ret 
