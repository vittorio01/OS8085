;questo file contiene tutti i riferimenti alle system calls della mms 
;deve essere importato in tutti i codici sorgenti che utilizzano la mms 

mms_low_memory_initialize                       .equ MMS 
mms_free_low_ram_bytes                          .equ mms_low_memory_initialize+3
mms_load_low_memory_program                     .equ mms_free_low_ram_bytes+3
mms_get_low_memory_program_dimension            .equ mms_load_low_memory_program+3
mms_unload_low_memory_program                   .equ mms_get_low_memory_program_dimension+3
mms_start_low_memory_loaded_program             .equ mms_unload_low_memory_program+3
mms_create_low_memory_data_segment              .equ mms_start_low_memory_loaded_program+3
mms_select_low_memory_data_segment              .equ mms_create_low_memory_data_segment+3
mms_delete_selected_low_memory_data_segment     .equ mms_select_low_memory_data_segment+3
mms_read_selected_data_segment_byte             .equ mms_delete_selected_low_memory_data_segment+3
mms_write_selected_data_segment_byte            .equ mms_read_selected_data_segment_byte+3
mms_segment_data_transfer                       .equ mms_write_selected_data_segment_byte+3
mms_set_selected_data_segment_flags             .equ mms_segment_data_transfer+3
mms_get_selected_data_segment_dimension         .equ mms_set_selected_data_segment_flags+3
mms_get_selected_data_segment_flags             .equ mms_get_selected_data_segment_dimension+3 
mms_delete_all_temporary_segments               .equ mms_get_selected_data_segment_flags+3
mms_program_bytes_write                         .equ mms_delete_all_temporary_segments+3
mms_program_bytes_read                          .equ mms_program_bytes_write+3
mms_mass_memory_read_sector                     .equ mms_program_bytes_read+3
mms_mass_memory_write_sector                    .equ mms_mass_memory_read_sector+3
mms_get_selected_segment_ID                     .equ mms_mass_memory_write_sector+3 
mms_dselect_low_memory_data_segment             .equ mms_get_selected_segment_ID+3
