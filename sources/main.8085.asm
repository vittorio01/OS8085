end_ram_address             .equ $7fff
low_memory_dimension        .equ 24588
reserved_memory_dimension   .equ $0080


reserved_memory_start    .equ $0000
reserved_memory_end      .equ reserved_memory_start + reserved_memory_dimension
low_memory_start         .equ reserved_memory_end 
low_memory_end           .equ reserved_memory_end+low_memory_dimension
high_memory_start        .equ $8000 ;low_memory_end


CPS         .equ high_memory_start
FSM         .equ CPS+1024
MMS         .equ FSM+1024
BIOS        .equ mms+2048

.include "sources/bios/PX_MINI_BIOS.8085.asm" 
.include "sources/memory_management/mms.8085.asm" 
.include "sources/file_system_manager/FSM.8085.asm" 
.include "sources/console_processor/CPS.8085.asm"
.include "sources/libraries/multiply/multiply_word.8085.asm"
.include "sources/libraries/multiply/multiply_byte.8085.asm"
.include "sources/libraries/multiply/multiply_long.8085.asm"
.include "sources/libraries/divide/divide_long.8085.asm"
.include "sources/libraries/divide/divide_word.8085.asm"
.include "sources/libraries/divide/divide_byte.8085.asm"
.include "sources/libraries/string/string_copy.8085.asm"
.include "sources/libraries/string/string_ncopy.8085.asm"