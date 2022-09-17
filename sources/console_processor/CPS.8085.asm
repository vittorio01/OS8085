cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                ;call bios_warm_boot
                call mms_low_memory_initialize
                mvi a,%1100000
                lxi h,1024 
                call mms_create_low_memory_data_segment
                mvi a,%1100000
                lxi h,512
                call mms_create_low_memory_data_segment
                mvi a,1
                call mms_select_low_memory_data_segment
                call mms_delete_selected_low_memory_data_segment
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