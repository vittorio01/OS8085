;string_copy esegue la copia la stringa sorgente a partire dell'indirizzo specificato come destinazione. La stringa sorgente deve avere $00 come carattere terminatore
;DE -> puntatore alla stringa di sorgente
;HL -> puntatore alla stringa di destinazione

string_copy:        push d 
                    push h 
string_copy_loop:   ldax d 
                    ora a 
                    jz string_copy_end
                    mov m,a 
                    inx h 
                    inx d 
                    jmp string_copy_loop
string_copy_end:    mvi m,0 
                    pop h 
                    pop d 
                    ret 