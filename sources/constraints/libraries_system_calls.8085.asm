;questo file contiene le coorsinate per le system calls delle librerie 
;deve essere importato in tutti i codici sorgenti che utilizzano queste librerie 

unsigned_multiply_byte          .equ LIBRARIES 
unsigned_multiply_word          .equ unsigned_multiply_byte+3
unsigned_multiply_long          .equ unsigned_multiply_word+3 
unsigned_divide_byte            .equ unsigned_multiply_long+3 
unsigned_divide_word            .equ unsigned_divide_byte+3 
unsigned_divide_long            .equ unsigned_divide_word+3 

unsigned_convert_hex_bcd_byte   .equ unsigned_divide_long+3 
unsigned_convert_hex_bcd_word   .equ unsigned_convert_hex_bcd_byte+3 
unsigned_convert_hex_bcd_long   .equ unsigned_convert_hex_bcd_word+3 