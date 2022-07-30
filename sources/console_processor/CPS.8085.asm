cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,$00bf
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init 
                mvi a,'A'
                call bios_mass_memory_select_drive
                mvi a,bios_mass_memory_rom_heads_number
                sta fsm_selected_disk_head_number
                mvi a,bios_mass_memory_rom_spt_number
                sta fsm_selected_disk_spt_number
                lxi h,bios_mass_memory_rom_tracks_number
                shld fsm_selected_disk_tph_number
                lxi h,1
                shld fsm_selected_disk_data_first_sector
                lxi h,2000
                shld fsm_selected_disk_sectors_number
                mvi a,8 
                sta fsm_selected_disk_spp_number
                mvi a,5
                sta fsm_selected_disk_fat_page_number
                lxi h,512
                shld fsm_selected_disk_data_page_number
                call fsm_clear_fat_table
                hlt 

                lxi h,0 
                lxi d,disk_name 
                call fsm_disk_format
                hlt 
                
                
                lxi h,128
                call mms_create_low_memory_user_data_segment
                lxi h,256
                call mms_create_low_memory_system_data_segment
                lxi h,0
                mvi a,$AA 
loop:           call mms_write_selected_system_segment_byte
                inx h
                jnc loop 
                call mms_read_data_segment_operation_error_code
                call mms_delete_selected_low_memory_user_data_segment
                call mms_delete_selected_low_memory_system_data_segment
                hlt

disk_name:  .text "DISCO DI PROVA"
            .b 0
CPS_level_end: