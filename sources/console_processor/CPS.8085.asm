cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk
                lxi b,file_name
                lxi d,extension_name
                call fsm_select_file_header
                lxi h,4096 
                call fsm_selected_file_append_data_bytes
                lxi b,0 
                lxi d,1024
                call fsm_selected_file_set_data_pointer
                hlt 
                lxi h,512
                call fsm_selected_file_get_bytes
                hlt

file_name:  .text "HEADER5"
            .b 0

extension_name: .text "EXT5"
                .b 0

CPS_level_end: