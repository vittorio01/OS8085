;string_ncompare esegue la comparazione fra le due stringe. Entrambe le stringe utilizzano $00 come carattere terminatore
;A -> dimensione massima delle stringe da confrontare
;DE -> puntatore alla prima stringa
;HL -> puntatore alla seconda stringa

;A <- esit dell'operazione ($ff se corrispondono, $00 altrimenti)

string_ncompare:    push d 
                    push h 
                    push b 
                    mov a,b 
string_cmp_loop:    dcr a 
                    jnz 
                    mov a,m 
                    cpi 0
                    jnz string_cmp_loop2
                    ldax d 
                    cpi 0 
                    jnz string_not_equals
                    jz string_equals
string_cmp_loop2:   ldax d
                    cmp m 
                    jnz string_not_equals
string_cmp_loop3:   inx h 
                    inx d 
                    jmp string_cmp_loop

string_not_equals:  mvi a,0 
                    pop d 
                    pop h 
                    ret

string_equals:      mvi a,$ff
                    mov e,c 
                    mov d,b 

                    pop b 
                    pop h 
                    pop d 
                    ret