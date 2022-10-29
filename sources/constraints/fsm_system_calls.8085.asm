;questo file contiene i riferimenti di tutte le system calls della fsm 
;ogni codice sorgente che utilizza la fsm deve importare questo file 

fsm_init                                            .equ FSM
fsm_close                                           .equ fsm_init +3
fsm_select_disk                                     .equ fsm_close +3
fsm_format_disk                                     .equ fsm_select_disk+3
fsm_wipe_disk                                       .equ fsm_format_disk+3
fsm_disk_set_name                                   .equ fsm_wipe_disk+3
fsm_disk_get_name                                   .equ fsm_disk_set_name+3
fsm_disk_get_free_space                             .equ fsm_disk_get_name+3

fsm_search_file_header                              .equ fsm_disk_get_free_space+3
fsm_select_file_header                              .equ fsm_search_file_header+3
fsm_create_file_header                              .equ fsm_select_file_header+3
fsm_get_selected_file_header_name                   .equ fsm_create_file_header+3
fsm_get_selected_file_header_extension              .equ fsm_get_selected_file_header_name+3
fsm_get_selected_file_header_flags                  .equ fsm_get_selected_file_header_extension+3
fsm_get_selected_file_header_dimension              .equ fsm_get_selected_file_header_flags+3
fsm_set_selected_file_header_name_and_extension     .equ fsm_get_selected_file_header_dimension+3
fsm_set_selected_file_header_flags                  .equ fsm_set_selected_file_header_name_and_extension+3
fsm_delete_selected_file_header                     .equ fsm_set_selected_file_header_flags+3
fsm_reset_file_header_scan_pointer                  .equ fsm_delete_selected_file_header+3
fsm_increment_file_header_scan_pointer              .equ fsm_reset_file_header_scan_pointer+3
               
fsm_selected_file_append_data_bytes                 .equ fsm_increment_file_header_scan_pointer+3
fsm_selected_file_remove_data_bytes                 .equ fsm_selected_file_append_data_bytes+3
fsm_selected_file_write_bytes                       .equ fsm_selected_file_remove_data_bytes+3
fsm_selected_file_read_bytes                        .equ fsm_selected_file_write_bytes+3
fsm_selected_file_wipe                              .equ fsm_selected_file_read_bytes+3
fsm_selected_file_set_data_pointer                  .equ fsm_selected_file_wipe+3
fsm_load_selected_program                           .equ fsm_selected_file_set_data_pointer+3

fsm_selected_disk_get_system                        .equ fsm_load_selected_program +3
fsm_selected_disk_set_system                        .equ fsm_selected_disk_get_system+3
;fsm_selected_disk_get_boot_sector                  .equ fsm_selected_disk_put_system+3
;fsm_selected_disk_set_boot_sector                  .equ fsm_selected_disk_get_boot_sector+3
;fsm_selected_disk_set_bootable                     .equ fsm_selected_disk_put_boot_sector+3
;fsm_selected_disk_set_not_bootable                 .equ fsm_selected_disk_set_bootable+3