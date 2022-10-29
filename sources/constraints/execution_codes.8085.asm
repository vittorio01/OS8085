;questo file contiene tutti i codici di esecuzione che possono essere generati nel sistema
;ogni file sorgente deve importare questo file

;codici di esecuzione che possono essere generati dalle funzioni del bios
bios_operation_ok                       .equ $ff 

bios_mass_memory_write_only             .equ $01
bios_mass_memory_device_not_found       .equ $02
bios_mass_memory_device_not_selected    .equ $03
bios_mass_memory_bad_argument           .equ $04
bios_mass_memory_transfer_error         .equ $05
bios_mass_memory_seek_error             .equ $06
bios_memory_transfer_error              .equ $07 

bios_console_ready                      .equ $08
bios_console_not_ready                  .equ $09

;codici di esecuzione che possono essere sollevati durante l'esecuzione delle funzioni della mms 
mms_not_enough_ram_error_code               .equ $11
mms_segment_data_not_found_error_code       .equ $12
mms_segment_segmentation_fault_error_code   .equ $13
mms_segment_number_overflow_error_code      .equ $14
mms_segment_bad_argument                    .equ $15

mms_source_segment_not_selected             .equ $16 
mms_destination_segment_not_selected        .equ $17
mms_destination_segment_not_found           .equ $18 
mms_source_segment_overflow                 .equ $19 
mms_destination_segment_overflow            .equ $1A 
mms_program_not_loaded                      .equ $1B
mms_mass_memory_not_selected                .equ $1C

mms_operation_ok                            .equ $ff

;codici di esecuzione che possono essere generati durante l'esecuzione delle funzioni della fsm
fsm_mass_memory_sector_not_found    .equ $20
fsm_bad_argument                    .equ $21
fsm_disk_not_selected               .equ $22
fsm_formatting_fat_generation_error .equ $23
fsm_unformatted_disk                .equ $24
fsm_device_not_found                .equ $25
fsm_not_enough_spage_left           .equ $26
fsm_list_is_empty                   .equ $27
fsm_header_not_found                .equ $28
fsm_header_not_selected             .equ $2a
fsm_end_of_disk                     .equ $29
fsm_header_exist                    .equ $2A 
fsm_end_of_list                     .equ $2B 
fsm_data_pointer_not_setted         .equ $2C 
fsm_end_of_file                     .equ $2D
fsm_destination_segment_overflow    .equ $2E
fsm_file_pointer_overflow           .equ $2F
fsm_source_segment_overflow         .equ $30
fsm_selected_file_not_executable    .equ $31 
fsm_program_too_big                 .equ $32 
fsm_read_only_file                  .equ $33 
fsm_selected_disk_not_bootable      .equ $34
fsm_disk_operating_system_not_found .equ $36
fsm_not_a_system_file               .equ $37 
fsm_system_space_too_small          .equ $38
fsm_operation_ok                    .equ $ff 