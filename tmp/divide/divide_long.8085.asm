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
                                push h 
                                mov l,c 
                                mov h,b 
                                mov a,m 
                                inx h 
                                ora m 
                                inx h 
                                ora m 
                                inx h 
                                ora m 
                                pop h 
                                jz unsigned_divide_long_zero
                                push h 
                                mov l,e 
                                mov h,d 
                                mov a,m 
                                inx h 
                                ora m 
                                inx h 
                                ora m 
                                inx h 
                                ora m 
                                pop h 
                                jnz unsigned_divide_long_shift
unsigned_divide_long_zero:      xchg 
                                jmp unsigned_divide_long_end2
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
                                xchg                         ;DE: [quoziente] BC: [dividendo] HL: [divisore]
                                jc unsigned_divide_long_end
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