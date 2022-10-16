;questo file contiene tutte le informazioni generali sul sistema operativo (dimensione della ram, dimensione del sistema operativo ecc...).
;è possibile modificare alcune informazioni per adattare il sistema ad un computer specifico

;queste informazioni riguardano la gestione dello spazio nelle varie componenti del sistema (da non modificare se non in fase di sviluppo del sistema)
CPS_dimension           .equ    1024
FSM_dimension           .equ    4096+2048
MMS_dimension           .equ    2048
BIOS_dimension          .equ    2048 
LIBRARIES_dimension     .equ    1024  
SYSTEM_dimension        .equ    CPS_dimension+FSM_dimension+MMS_dimension+BIOS_dimension+LIBRARIES_dimension        ;insica la dimensione finale del sistema

;queste informazioni riguardano la divisione degli spazi all'interno della ram
end_ram_address             .equ $8000                                        ;indica la dimensione totale della ram installata nel sistema (può essere adattata secondo la macchina fisica)  
high_memory_start           .equ end_ram_address-SYSTEM_dimension 

reserved_memory_dimension   .equ $0050
reserved_memory_start       .equ high_memory_start-reserved_memory_dimension
reserved_memory_end         .equ high_memory_start

max_system_stack_dimension  .equ 128
stack_memory_start          .equ reserved_memory_start


low_memory_start         .equ $0050
low_memory_end           .equ reserved_memory_start-max_system_stack_dimension

CPS         .equ high_memory_start
FSM         .equ CPS+CPS_dimension
MMS         .equ FSM+FSM_dimension
BIOS        .equ MMS+MMS_dimension
LIBRARIES   .equ BIOS+BIOS_dimension


