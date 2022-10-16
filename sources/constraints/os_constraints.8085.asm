;questo file contiene tutte le informazioni generali sul sistema operativo (dimensione della ram, dimensione del sistema operativo ecc...).
;è possibile modificare alcune informazioni per adattare il sistema ad un computer specifico

end_ram_address             .equ $7000          
max_system_stack_dimension  .equ 128
reserved_memory_dimension   .equ $0090


reserved_memory_start    .equ $0000
reserved_memory_end      .equ reserved_memory_start + reserved_memory_dimension
low_memory_start         .equ reserved_memory_end 
low_memory_end           .equ end_ram_address-max_system_stack_dimension
stack_memory_start       .equ end_ram_address
high_memory_start        .equ $7000

CPS_dimension           .equ    1024
FSM_dimension           .equ    4096+2048
MMS_dimension           .equ    2048
BIOS_dimension          .equ    2048 
LIBRARIES_dimension     .equ    1024  

CPS         .equ high_memory_start
FSM         .equ CPS+CPS_dimension
MMS         .equ FSM+FSM_dimension
BIOS        .equ MMS+MMS_dimension
LIBRARIES   .equ BIOS+BIOS_dimension


