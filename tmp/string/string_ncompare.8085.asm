;string_ncompare esegue la comparazione fra le due stringe. Entrambe le stringe utilizzano $00 come carattere terminatore
;A -> dimensione massima delle stringe da confrontare
;DE -> puntatore alla prima stringa
;HL -> puntatore alla seconda stringa

;A <- esit dell'operazione ($ff se corrispondono, $00 altrimenti)

string_ncompare:        push b 
                        push d 
                        push h 
                        ora a 
                        jz string_ncmp_loop_end2
                        mov b,a 
string_ncmp_loop:       dcr b 
                        jnz string_ncmp_loop3
                        ldax d
                        cmp m 
                        jz string_ncmp_loop_end1
                        jmp string_ncmp_loop_end2
string_ncmp_loop3:      mov a,m 
                        ora a 
                        ldax d 
                        jz string_ncmp_loop2
                        cmp m 
                        jnz string_ncmp_loop_end2
                        inx h 
                        inx d 
                        jmp string_ncmp_loop
string_ncmp_loop2:      ora a 
                        jnz string_ncmp_loop_end2
string_ncmp_loop_end1:  mvi a,$ff
                        jmp string_ncompare_end
string_ncmp_loop_end2:  xra a 
string_ncompare_end:    pop h 
                        pop d 
                        pop b
                        ret