;questo file contiene tutti i riferimenti alle system calls della mms 
;deve essere importato in tutti i codici sorgenti che utilizzano la mms 

mms_high_memory_initialize                           .equ MMS 
mms_free_high_ram_bytes                              .equ mms_high_memory_initialize+3
mms_load_high_memory_program                         .equ mms_free_high_ram_bytes+3
mms_get_high_memory_program_dimension                .equ mms_load_high_memory_program+3
mms_unload_high_memory_program                       .equ mms_get_high_memory_program_dimension+3
mms_start_high_memory_loaded_program                 .equ mms_unload_high_memory_program+3
mms_create_high_memory_data_segment                  .equ mms_start_high_memory_loaded_program+3
mms_select_high_memory_data_segment                  .equ mms_create_high_memory_data_segment+3
mms_delete_selected_high_memory_data_segment         .equ mms_select_high_memory_data_segment+3
mms_read_selected_data_segment_byte                 .equ mms_delete_selected_high_memory_data_segment+3
mms_write_selected_data_segment_byte                .equ mms_read_selected_data_segment_byte+3
mms_segment_data_transfer                           .equ mms_write_selected_data_segment_byte+3
mms_set_selected_data_segment_type_flag             .equ mms_segment_data_transfer+3 
mms_set_selected_data_segment_temporary_flag        .equ mms_set_selected_data_segment_type_flag+3 
mms_get_selected_data_segment_dimension             .equ mms_set_selected_data_segment_temporary_flag+3
mms_get_selected_data_segment_type_flag_status      .equ mms_get_selected_data_segment_dimension+3 
mms_get_selected_data_segment_temporary_flag_status .equ mms_get_selected_data_segment_type_flag_status+3 
mms_delete_all_temporary_segments                   .equ mms_get_selected_data_segment_temporary_flag_status+3
mms_program_bytes_write                             .equ mms_delete_all_temporary_segments+3
mms_program_bytes_read                              .equ mms_program_bytes_write+3
mms_disk_device_read_sector                         .equ mms_program_bytes_read+3
mms_disk_device_write_sector                        .equ mms_disk_device_read_sector+3
mms_get_selected_segment_ID                         .equ mms_disk_device_write_sector+3 
mms_dselect_high_memory_data_segment                 .equ mms_get_selected_segment_ID+3
