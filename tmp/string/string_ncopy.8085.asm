;string_ncopy esegue la copia la stringa sorgente a partire dell'indirizzo specificato come destinazione imponendo un massimo di caratteri da copiare. 
;La stringa sorgente viene considerata come terminata quando viene rilevato il carattere terminatore.
;A  -> numero massimo di caratteri
;DE -> puntatore alla stringa di sorgente
;HL -> puntatore alla stringa di destinazione

string_ncopy:       push b 
                    push d 
                    push h 
                    ora a 
                    jz string_ncopy_end1
                    mov b,a 
string_ncopy_loop:  ldax d 
                    ora a 
                    jz string_ncopy_end
                    mov m,a 
                    inx h 
                    inx d 
                    dcr b 
                    jnz string_ncopy_loop
string_ncopy_end:   mvi m,0 
string_ncopy_end1:  pop h 
                    pop d 
                    pop b 
                    ret 