;questo file contiene tutte le informazioni generali sul sistema operativo (dimensione della ram, dimensione del sistema operativo ecc...).

current_system_version      .equ    $10     ;indica la versione corrente del sistema operativo

;le seguenti informazioni si riveriscono alle proprietà hardware del processore (non toccare) 
rst0_address                .equ    $0000
rst1_address                .equ    $0008
rst2_address                .equ    $0010 
rst3_address                .equ    $0018
rst4_address                .equ    $0020
rst5_address                .equ    $0028 
rst6_address                .equ    $0030

I8085_trap_address          .equ    $0024
I8085_rst55_address         .equ    $002C 
I8085_rst65_address         .equ    $0034
I8085_rst75_address         .equ    $003C
Z80_int_address             .equ    $0038

system_interrupt_space_end  .equ    $0040

;queste informazioni riguardano la gestione dello spazio nelle varie componenti del sistema (da non modificare se non in fase di sviluppo del sistema)
MSI_dimension           .equ    5120-system_interrupt_space_end
FSM_dimension           .equ    8192
MMS_dimension           .equ    2048
BIOS_dimension          .equ    4096
LIBRARIES_dimension     .equ    1536
SYSTEM_dimension        .equ    MSI_dimension+FSM_dimension+MMS_dimension+BIOS_dimension+LIBRARIES_dimension        ;insica la dimensione finale del sistema

;queste informazioni riguardano la divisione degli spazi all'interno della ram

;----- LOW RAM -----
;zona dedicata alla gestione dello spazio nel sistema operativo (da non modificare se non in fase di sviluppo del sistema)
MSI                 .equ system_interrupt_space_end
FSM                 .equ MSI+MSI_dimension
MMS                 .equ FSM+FSM_dimension
BIOS                .equ MMS+MMS_dimension
LIBRARIES           .equ BIOS+BIOS_dimension
SYSTEM_memory_end   .equ LIBRARIES+LIBRARIES_dimension                              

;memoria dedicata alla gestione delle informazioni basilari nei layer del sistema (non toccare)
reserved_memory_dimension   .equ $0070                                              
reserved_memory_start       .equ SYSTEM_memory_end
reserved_memory_end         .equ reserved_memory_start+reserved_memory_dimension

;memoria dedicata alla gestione dello stack (si può ottimizare per rispariare RAM ma non è consigliato)
max_system_stack_dimension  .equ 256                                                
stack_memory_start          .equ reserved_memory_end+max_system_stack_dimension

;----- HIGH RAM -----
high_memory_start         .equ stack_memory_start        
;tutte le applicazioni devono essere compilate a partire da questo indirizzo


