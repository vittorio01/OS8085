;questo file contiene le coorsinate per le system calls delle librerie 
;deve essere importato in tutti i codici sorgenti che utilizzano queste librerie 

unsigned_multiply_byte      .equ LIBRARIES 
unsigned_multiply_word      .equ unsigned_multiply_byte+3
unsigned_multiply_long      .equ unsigned_multiply_word+3 
unsigned_divide_byte        .equ unsigned_multiply_long+3 
unsigned_divide_word        .equ unsigned_divide_byte+3 
unsigned_divide_long        .equ unsigned_divide_word+3 
string_compare              .equ unsigned_divide_long+3 
string_ncompare             .equ string_compare+3 
string_copy                 .equ string_ncompare+3
string_ncopy                .equ string_copy+3 