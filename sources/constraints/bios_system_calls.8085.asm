;questo file contiene tutte le system calls del BIOS 
;ogni codice sorgente che utilizza le system calls del bios deve importare questo file

bios_system_start                       .equ    BIOS  
bios_select_IO_device                   .equ    bios_system_start+3
bios_get_IO_device_informations         .equ    bios_select_IO_device+3
bios_initialize_selected_device         .equ    bios_get_IO_device_informations+3 
bios_get_selected_device_state          .equ    bios_initialize_selected_device+3
bios_set_selected_device_state          .equ    bios_get_selected_device_state+3 
bios_read_selected_device_byte          .equ    bios_set_selected_device_state+3
bios_write_selected_device_byte         .equ    bios_read_selected_device_byte+3
bios_disk_device_select_drive           .equ    bios_write_selected_device_byte+3
bios_disk_device_select_sector          .equ    bios_disk_device_select_drive+3
bios_disk_device_select_track           .equ    bios_disk_device_select_sector+3
bios_disk_device_select_head            .equ    bios_disk_device_select_track+3
bios_disk_device_status                 .equ    bios_disk_device_select_head+3
bios_disk_device_set_motor              .equ    bios_disk_device_status+3 
bios_disk_device_get_bps                .equ    bios_disk_device_set_motor+3
bios_disk_device_get_spt                .equ    bios_disk_device_get_bps+3
bios_disk_device_get_tph                .equ    bios_disk_device_get_spt+3
bios_disk_device_get_head_number        .equ    bios_disk_device_get_tph+3
bios_disk_device_write_sector           .equ    bios_disk_device_get_head_number+3
bios_disk_device_read_sector            .equ    bios_disk_device_write_sector+3
bios_disk_device_format_drive           .equ    bios_disk_device_read_sector+3
bios_memory_transfer                    .equ    bios_disk_device_format_drive+3
bios_memory_transfer_reverse            .equ    bios_memory_transfer +3 