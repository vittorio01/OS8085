;questo file contiene i riferimenti per il linking di tutte le system calls della fsm 
;ogni codice sorgente che utilizza la FSM deve importare questo file 


fsm_init                                            .equ FSM
fsm_select_disk                                     .equ fsm_init +3
fsm_deselect_disk                                   .equ fsm_select_disk+3 
fsm_wipe_disk                                       .equ fsm_deselect_disk +3
fsm_disk_set_name                                   .equ fsm_wipe_disk+3
fsm_disk_get_name                                   .equ fsm_disk_set_name+3
fsm_disk_get_free_space                             .equ fsm_disk_get_name+3

fsm_search_file_header                              .equ fsm_disk_get_free_space+3
fsm_select_file_header                              .equ fsm_search_file_header+3
fsm_create_file_header                              .equ fsm_select_file_header+3
fsm_get_selected_file_header_name                   .equ fsm_create_file_header+3
fsm_get_selected_file_header_system_flag_status     .equ fsm_get_selected_file_header_name+3
fsm_get_selected_file_header_hidden_flag_status     .equ fsm_get_selected_file_header_system_flag_status+3 
fsm_get_selected_file_header_readonly_flag_status   .equ fsm_get_selected_file_header_hidden_flag_status+3 
fsm_get_selected_file_header_dimension              .equ fsm_get_selected_file_header_readonly_flag_status+3
fsm_set_selected_file_header_name                   .equ fsm_get_selected_file_header_dimension+3
fsm_set_selected_file_header_system_flag            .equ fsm_set_selected_file_header_name+3 
fsm_set_selected_file_header_hidden_flag            .equ fsm_set_selected_file_header_system_flag+3
fsm_set_selected_file_header_readonly_flag          .equ fsm_set_selected_file_header_hidden_flag+3 
fsm_delete_selected_file_header                     .equ fsm_set_selected_file_header_readonly_flag+3
fsm_reset_file_header_scan_pointer                  .equ fsm_delete_selected_file_header+3
fsm_increment_file_header_scan_pointer              .equ fsm_reset_file_header_scan_pointer+3
               
fsm_selected_file_append_data_bytes                 .equ fsm_increment_file_header_scan_pointer+3
fsm_selected_file_remove_data_bytes                 .equ fsm_selected_file_append_data_bytes+3
fsm_selected_file_write_bytes                       .equ fsm_selected_file_remove_data_bytes+3
fsm_selected_file_read_bytes                        .equ fsm_selected_file_write_bytes+3
fsm_selected_file_wipe                              .equ fsm_selected_file_read_bytes+3
fsm_selected_file_set_data_pointer                  .equ fsm_selected_file_wipe+3
fsm_load_selected_program                           .equ fsm_selected_file_set_data_pointer+3

fsm_get_disk_format_type                            .equ fsm_load_selected_program+3
fsm_file_name_max_dimension                         .equ fsm_get_disk_format_type +3
fsm_disk_name_max_dimension                         .equ fsm_file_name_max_dimension+3
