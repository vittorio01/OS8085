;questa libreria contiene le funzioni utilizzate per la conversione di numeri da esadecimale a BCD 

;unsigned_convert_hex_bcd_byte converte un byte esadecimale in BCD
;A -> numero da convertire 
;BC -> numero convertito 
unsigned_convert_hex_bcd_byte:          push d 
                                        lxi d,0 
                                        mvi c,10 
                                        mov b,a 
                                        call unsigned_divide_byte 
                                        mov e,c 
                                        mvi c,10 
                                        call unsigned_divide_byte 
                                        mov a,c 
                                        rlc 
                                        rlc 
                                        rlc 
                                        rlc 
                                        ora e 
                                        mov c,a 
                                        pop d 
                                        ret 

