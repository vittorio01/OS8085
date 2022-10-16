;questo file contiene tutte le system calls del BIOS 
;ogni codice sorgente che utilizza le system calls del bios deve importare questo file

bios_cold_boot                          .equ    BIOS 
bios_warm_boot                          .equ    bios_cold_boot+3 
bios_console_output_write_character     .equ    bios_warm_boot+3
bios_console_output_ready               .equ    bios_console_output_write_character+3 
bios_console_input_read_character       .equ    bios_console_output_ready +3
bios_console_input_ready                .equ    bios_console_input_read_character+3
bios_mass_memory_select_drive           .equ    bios_console_input_ready+3
bios_mass_memory_select_sector          .equ    bios_mass_memory_select_drive+3
bios_mass_memory_select_track           .equ    bios_mass_memory_select_sector+3
bios_mass_memory_select_head            .equ    bios_mass_memory_select_track+3
bios_mass_memory_status                 .equ    bios_mass_memory_select_head+3
bios_mass_memory_get_bps                .equ    bios_mass_memory_status+3
bios_mass_memory_get_spt                .equ    bios_mass_memory_get_bps+3
bios_mass_memory_get_tph                .equ    bios_mass_memory_get_spt+3
bios_mass_memory_get_head_number        .equ    bios_mass_memory_get_tph+3
bios_mass_memory_write_sector           .equ    bios_mass_memory_get_head_number+3
bios_mass_memory_read_sector            .equ    bios_mass_memory_write_sector+3
bios_mass_memory_format_drive           .equ    bios_mass_memory_read_sector+3
bios_memory_transfer                    .equ    bios_mass_memory_format_drive+3
bios_memory_transfer_reverse            .equ    bios_memory_transfer +3 