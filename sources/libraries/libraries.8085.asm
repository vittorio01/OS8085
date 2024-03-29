.include "os_constraints.8085.asm"

LIBRARIES_calls:    .org LIBRARIES
                    jmp unsigned_multiply_byte 
                    jmp unsigned_multiply_word 
                    jmp unsigned_multiply_long 
                    jmp unsigned_divide_byte 
                    jmp unsigned_divide_word 
                    jmp unsigned_divide_long 
                    ;jmp string_compare
                    ;jmp string_ncompare
                    ;jmp string_copy
                    ;jmp string_ncopy 
                    jmp unsigned_convert_hex_bcd_byte
                    jmp unsigned_convert_hex_bcd_word
                    jmp unsigned_convert_hex_bcd_long

.include "multiply/multiply_word.8085.asm"
.include "multiply/multiply_byte.8085.asm"
.include "multiply/multiply_long.8085.asm"
.include "divide/divide_long.8085.asm"
.include "divide/divide_word.8085.asm"
.include "divide/divide_byte.8085.asm"
;.include "string/string_copy.8085.asm"
;.include "string/string_ncopy.8085.asm"
;.include "string/string_compare.8085.asm"
;.include "string/string_ncompare.8085.asm"
.include "convert/hex_to_bcd_byte.8085.asm"
.include "convert/hex_to_bcd_word.8085.asm"
.include "convert/hex_to_bcd_long.8085.asm"

libraries_layer_end:    
.memory "fill", libraries_layer_end, libraries_dimension-libraries_layer_end+LIBRARIES,$00
.print "Space left for libraries ->",libraries_dimension-libraries_layer_end+LIBRARIES
.print "LIBRARIES load address ->",LIBRARIES
.print "All libraries compiled succeffully"