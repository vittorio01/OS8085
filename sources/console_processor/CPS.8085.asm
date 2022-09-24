cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                mvi a,bios_mass_memory_rom_id 
                call bios_mass_memory_select_drive
                mvi a,0 
                call bios_mass_memory_select_head
                mvi a,0 
                call bios_mass_memory_select_sector
                lxi h,0 
                call bios_mass_memory_select_track
                mvi a,%11000000
                lxi h,512
                call mms_create_low_memory_data_segment
                lxi h,0
                call mms_mass_memory_read_sector
                lxi h,1024 
                call mms_load_low_memory_program
                lxi b,256 
                lxi d,0 
                lxi h,0
                call mms_program_bytes_read
                hlt 
                ;call fsm_init
                ;mvi a,$41
                ;call fsm_select_disk 
                ;lxi b,file_name
                ;lxi d,extension_name
                ;call fsm_select_file_header
                ;lxi b,0 
                ;lxi d,1024
                ;call fsm_selected_file_set_data_pointer
                ;lxi h,512+256
                ;call fsm_selected_file_get_bytes
                ;call fsm_writeback_page
                hlt

file_name:  .text "file di prova"
            .b 0

extension_name: .text "prg"
                .b 0

CPS_level_end: