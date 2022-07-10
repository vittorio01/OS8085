;questa libreria contiene gli algoritmi necessari per la divisione di numeri di diversa dimensione

;unsigned_divide_byte esegue la divisione fra due numeri interi senza segno a 8 bit
;B -> unsigned_dividendo
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

;unsigned_divide_long esegue la divisione tra due numeri interi senza segno a 32 bit 
;SP -> [dividendo(4 bytes)][divisore(4 bytes)]
;SP <- [resto(4 bytes)][quoziente(4 bytes)]

unsigned_divide_long:           push h 
                                push d 
                                push b 
                                lxi h,0 
                                push h 
                                push h 
                                push h 
                                dad sp 
                                inx h 
                                inx h 
                                mov e,l 
                                mov d,h
                                mvi a,12 
                                add l 
                                mov l,a 
                                mov a,h 
                                aci 0 
                                mov h,a 
                                mov c,l 
                                mov b,h 
                                inx h 
                                inx h 
                                inx h 
                                inx h   ;HL: [quoziente] BC: [dividendo] DE: [divisore]
                                xchg    ;SP: [indici][quoziente(4bytes)][bc][de][hl][pc][dividendo(4 bytes)][divisore(4 bytes)]                 
unsigned_divide_long_shift:     inx b 
                                inx b 
                                inx b 
                                ldax b 
                                dcx b 
                                dcx b 
                                dcx b
                                ora a 
                                jm unsigned_divide_long_shift2
                                ldax b 
                                add a 
                                stax b 
                                inx b 
                                ldax b 
                                ral
                                stax b 
                                inx b 
                                ldax b 
                                ral
                                stax b 
                                inx b 
                                ldax b 
                                ral
                                stax b 
                                dcx b 
                                dcx b 
                                dcx b 
                                xthl 
                                inr h 
                                xthl 
                                jmp unsigned_divide_long_shift
unsigned_divide_long_shift2:    inx d 
                                inx d 
                                inx d 
                                ldax d 
                                dcx d 
                                dcx d 
                                dcx d 
                                ora a 
                                jm unsigned_divide_shift_end 
                                ldax d 
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
                                inr l 
                                xthl 
                                jmp unsigned_divide_long_shift2
unsigned_divide_shift_end:      xthl 
                                mov a,l 
                                sub h 
                                mov l,a
                                xthl 
                                jc unsigned_divide_long_end
                                xchg        ;DE: [quoziente] BC: [dividendo] HL: [divisore]
unsigned_divide_long_loop:      ldax b 
                                sub m 
                                inx b 
                                inx h 
                                ldax b 
                                sbb m
                                inx b 
                                inx h
                                ldax b 
                                sbb m
                                inx b 
                                inx h
                                ldax b 
                                sbb m
                                dcx b 
                                dcx h 
                                dcx b 
                                dcx h 
                                dcx b 
                                dcx h 
                                jc unsigned_divide_long_skip
                                ldax b 
                                sub m
                                stax b  
                                inx b 
                                inx h 
                                ldax b 
                                sbb m
                                stax b 
                                inx b 
                                inx h
                                ldax b 
                                sbb m
                                stax b 
                                inx b 
                                inx h
                                ldax b 
                                sbb m
                                stax b 
                                dcx b 
                                dcx h 
                                dcx b 
                                dcx h 
                                dcx b 
                                dcx h 
unsigned_divide_long_skip:      cmc 
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
                                inx d 
                                ldax d  
                                ral 
                                stax d
                                dcx d 
                                dcx d 
                                dcx d 
                                stc 
                                cmc 
                                inx h 
                                inx h 
                                inx h 
                                mov a,m 
                                rar 
                                mov m,a 
                                dcx h 
                                mov a,m 
                                rar 
                                mov m,a 
                                dcx h 
                                mov a,m 
                                rar 
                                mov m,a 
                                dcx h 
                                mov a,m 
                                rar 
                                mov m,a 
                                xthl 
                                dcr l 
                                xthl 
                                jm unsigned_divide_long_end
                                jmp unsigned_divide_long_loop
unsigned_divide_long_end:       xthl 
                                mov a,h 
                                ora a 
                                xthl 
                                jz unsigned_divide_long_end2
unsigned_divide_long_align3:    inx b 
                                inx b 
                                inx b 
                                stc
                                cmc 
                                ldax b 
                                rar 
                                stax b 
                                dcx b 
                                ldax b 
                                rar 
                                stax b 
                                dcx b 
                                ldax b 
                                rar 
                                stax b 
                                dcx b 
                                ldax b 
                                rar 
                                stax b 
                                xthl 
                                dcr h 
                                xthl 
                                jnz unsigned_divide_long_align3
unsigned_divide_long_end2:      xchg
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
                                lxi h,6
                                dad sp 
                                sphl 
                                pop b 
                                pop d 
                                pop h 
                                ret 