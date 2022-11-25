;questo file contiene tutti i codici di esecuzione che possono essere generati nel sistema
;ogni file sorgente deve importare questo file
bios_execution_code_mark                .equ %00000000
mms_execution_code_mark                 .equ %01000000
fsm_execution_code_mark                 .equ %10000000
msi_execution_code_mark                 .equ %11000000

;codici di esecuzione che possono essere generati dalle funzioni del bios
bios_operation_ok                       .equ $ff 


bios_IO_device_not_found                        .equ bios_execution_code_mark+$01 
bios_IO_device_not_selected                     .equ bios_execution_code_mark+$02 
bios_mass_memory_device_not_found               .equ bios_execution_code_mark+$03
bios_mass_memory_device_not_selected            .equ bios_execution_code_mark+$04
bios_mass_memory_values_not_setted              .equ bios_execution_code_mark+$05
bios_mass_memory_number_overflow                .equ bios_execution_code_mark+$06
bios_mass_memory_write_only                     .equ bios_execution_code_mark+$07
bios_mass_memory_transfer_error                 .equ bios_execution_code_mark+$08
bios_mass_memory_seek_error                     .equ bios_execution_code_mark+$09
bios_memory_transfer_error                      .equ bios_execution_code_mark+$0A 
bios_bad_argument                               .equ bios_execution_code_mark+$0B

bios_IO_device_connected_mask       .equ %10000000  ;per indicare se il dispositivo è collegato o scollegato (caso ad esempio di un dispositivo seriale)
bios_IO_device_input_byte_ready     .equ %01000000  ;per indicare se il dispositivo è pronto per inviare un byte al sistema 
bios_IO_device_output_byte_ready    .equ %00100000  ;per indicare se il dispositivo è pronto per ricevere un byte dal sistema 
bios_IO_device_readable_mask        .equ %10000000
bios_IO_device_writerable_mask      .equ %01000000
bios_IO_device_type_console         .equ %00000000     ;il tipo %0000000 viene assegnato per identificare una console basilare I/O  

;codici di esecuzione che possono essere sollevati durante l'esecuzione delle funzioni della mms 

mms_operation_ok                            .equ $ff

mms_not_enough_ram_error_code               .equ mms_execution_code_mark+$01
mms_segment_data_not_found_error_code       .equ mms_execution_code_mark+$02
mms_segment_segmentation_fault_error_code   .equ mms_execution_code_mark+$03
mms_segment_number_overflow_error_code      .equ mms_execution_code_mark+$04
mms_segment_bad_argument                    .equ mms_execution_code_mark+$05

mms_source_segment_not_selected             .equ mms_execution_code_mark+$06
mms_source_segment_overflow                 .equ mms_execution_code_mark+$07
mms_destination_segment_not_selected        .equ mms_execution_code_mark+$08
mms_destination_segment_not_found           .equ mms_execution_code_mark+$09 
mms_destination_segment_overflow            .equ mms_execution_code_mark+$0a 
mms_program_not_loaded                      .equ mms_execution_code_mark+$0b 
mms_mass_memory_not_selected                .equ mms_execution_code_mark+$0c 

;codici di esecuzione che possono essere generati durante l'esecuzione delle funzioni della fsm
fsm_operation_ok                    .equ $ff 

fsm_mass_memory_sector_not_found    .equ fsm_execution_code_mark+$01
fsm_disk_not_selected               .equ fsm_execution_code_mark+$02
fsm_device_not_found                .equ fsm_execution_code_mark+$04
fsm_unformatted_disk                .equ fsm_execution_code_mark+$05

fsm_not_enough_spage_left           .equ fsm_execution_code_mark+$08

fsm_bad_argument                    .equ fsm_execution_code_mark+$09
fsm_formatting_fat_generation_error .equ fsm_execution_code_mark+$0A 
fsm_list_is_empty                   .equ fsm_execution_code_mark+$0B 
fsm_header_not_found                .equ fsm_execution_code_mark+$0C 
fsm_header_not_selected             .equ fsm_execution_code_mark+$0D 
fsm_end_of_disk                     .equ fsm_execution_code_mark+$0E 
fsm_end_of_list                     .equ fsm_execution_code_mark+$0F 
fsm_end_of_file                     .equ fsm_execution_code_mark+$10
fsm_header_exist                    .equ fsm_execution_code_mark+$11 
fsm_data_pointer_not_setted         .equ fsm_execution_code_mark+$12 
fsm_destination_segment_overflow    .equ fsm_execution_code_mark+$13
fsm_file_pointer_overflow           .equ fsm_execution_code_mark+$14
fsm_source_segment_overflow         .equ fsm_execution_code_mark+$15
fsm_selected_file_not_executable    .equ fsm_execution_code_mark+$16 
fsm_program_too_big                 .equ fsm_execution_code_mark+$17 
fsm_read_only_file                  .equ fsm_execution_code_mark+$18 

fsm_not_a_system_file               .equ fsm_execution_code_mark+$1B 

;codici di esecuzione che possono essere generati durante l'esecuzione delle funzioni della MSI

msi_operation_ok                        .equ $ff 
msi_system_call_not_found               .equ msi_execution_code_mark+$01
msi_current_program_permissions_error   .equ msi_execution_code_mark+$02
msi_string_too_long                     .equ msi_execution_code_mark+$03 
msi_invalid_character_in_string         .equ msi_execution_code_mark+$04
msi_string_empty                        .equ msi_execution_code_mark+$05 
msi_name_too_long                       .equ msi_execution_code_mark+$06 
msi_extension_too_long                  .equ msi_execution_code_mark+$07

msi_not_a_program                       .equ msi_execution_code_mark+$08 

msi_load_program_error_execution_code   .equ msi_execution_code_mark+$09 
msi_program_start_error                 .equ msi_execution_code_mark+$0A
msi_program_message_share_error         .equ msi_execution_code_mark+$0B

;variabili e flags predefinite nella mms
mms_low_memory_valid_segment_mask           .equ %10000000
mms_low_memory_type_segment_mask            .equ %01000000
mms_low_memory_temporary_segment_mask       .equ %00100000

;variabili e flags predefinite nella FSM 
fsm_disk_name_max_lenght                    .equ 20
fsm_header_name_dimension                   .equ 20
fsm_header_extension_dimension              .equ 5 
fsm_header_valid_bit                        .equ %10000000
fsm_header_deleted_bit                      .equ %01000000
fsm_header_system_bit                       .equ %00100000
fsm_header_program_bit                      .equ %00010000
fsm_header_hidden_bit                       .equ %00001000
fsm_header_readonly_bit                     .equ %00000100

fsm_SFS10_format_ID                         .equ $01