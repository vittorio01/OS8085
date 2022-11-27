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
bios_disk_device_device_not_found               .equ bios_execution_code_mark+$03
bios_disk_device_device_not_selected            .equ bios_execution_code_mark+$04
bios_disk_device_values_not_setted              .equ bios_execution_code_mark+$05
bios_disk_device_number_overflow                .equ bios_execution_code_mark+$06
bios_bad_argument                               .equ bios_execution_code_mark+$0B

bios_IO_console_connected_mask       .equ %10000000  ;per indicare se il dispositivo è collegato o scollegato (caso ad esempio di un dispositivo seriale)
bios_IO_console_input_byte_ready     .equ %01000000  ;per indicare se il dispositivo è pronto per inviare un byte al sistema 
bios_IO_console_output_byte_ready    .equ %00100000  ;per indicare se il dispositivo è pronto per ricevere un byte dal sistema 

;flags del byte inviato dalla funzione bios_disk_device_set_state 
bios_disk_device_motor_control_bit_mask                 .equ %10000000      ;se il bit è settato a 1 il motore del disco selezionato deve essere avviato
bios_disk_device_head_align_control_bit_mask            .equ %01000000      ;se il bit è settato a 1 il disk device deve riallineare la testina nel disco 

;flags del byte di stato ricevuto dalla funzione bios_disk_device_get_state 
bios_disk_device_disk_inserted_status_bit_mask          .equ %10000000      ;questo bit deve essere settato a 1 se il disco è stato inserito nel drive 
bios_disk_device_controller_ready_status_bit_mask       .equ %01000000      ;questo bit deve essere settato a 1 quando il disk device è pronto per il trasferimento dei dati 
bios_disk_device_disk_write_protected_status_bit_mask   .equ %00100000      ;questo bit deve essere settato a 1 se il disco inserito è protetto da scrittura 
bios_disk_device_data_transfer_error_status_bit_mask    .equ %00001000      ;questo bit deve essere settato a 1 se si è verificato un errore durante il trasferimento dei dati 
bios_disk_device_seek_error_status_bit_mask             .equ %00000100      ;questo bit deve essere settato a 1 se si è verificato un errore durante lo spostamento della testina 
bios_disk_device_bad_sector_status_bit_mask             .equ %00000010      ;questo bit deve essere settato a 1 se il settore che si desidera leggere/scrivere non è valido

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
mms_disk_device_not_selected                .equ mms_execution_code_mark+$0c 

;codici di esecuzione che possono essere generati durante l'esecuzione delle funzioni della fsm
fsm_operation_ok                    .equ $ff 

fsm_disk_device_sector_not_found    .equ fsm_execution_code_mark+$01
fsm_disk_not_selected               .equ fsm_execution_code_mark+$02
fsm_disk_not_inserted               .equ fsm_execution_code_mark+$03
fsm_disk_seek_error                 .equ fsm_execution_code_mark+$04 
fsm_disk_write_protected            .equ fsm_execution_code_mark+$05 
fsm_disk_data_transfer_error        .equ fsm_execution_code_mark+$06 
fsm_disk_bad_sector                 .equ fsm_execution_code_mark+$07
fsm_device_not_found                .equ fsm_execution_code_mark+$08
fsm_unformatted_disk                .equ fsm_execution_code_mark+$09
fsm_unknown_format_type             .equ fsm_execution_code_mark+$0A

fsm_not_enough_spage_left           .equ fsm_execution_code_mark+$0B 

fsm_bad_argument                    .equ fsm_execution_code_mark+$0C 
fsm_formatting_fat_generation_error .equ fsm_execution_code_mark+$0D 
fsm_list_is_empty                   .equ fsm_execution_code_mark+$0E 
fsm_header_not_found                .equ fsm_execution_code_mark+$0F 
fsm_header_not_selected             .equ fsm_execution_code_mark+$10
fsm_end_of_disk                     .equ fsm_execution_code_mark+$11 
fsm_end_of_list                     .equ fsm_execution_code_mark+$12
fsm_end_of_file                     .equ fsm_execution_code_mark+$13
fsm_header_exist                    .equ fsm_execution_code_mark+$14 
fsm_data_pointer_not_setted         .equ fsm_execution_code_mark+$15 
fsm_destination_segment_overflow    .equ fsm_execution_code_mark+$16
fsm_file_pointer_overflow           .equ fsm_execution_code_mark+$17
fsm_source_segment_overflow         .equ fsm_execution_code_mark+$18
fsm_selected_file_not_executable    .equ fsm_execution_code_mark+$19 
fsm_program_too_big                 .equ fsm_execution_code_mark+$1A  
fsm_read_only_file                  .equ fsm_execution_code_mark+$1B 

fsm_not_a_system_file               .equ fsm_execution_code_mark+$1C 

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

fsm_SFS10_format_ID                         .equ $01