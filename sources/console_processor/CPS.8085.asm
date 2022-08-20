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
                lxi b,file_name2
                lxi d,extension_name2
                call fsm_set_selected_file_header_name_and_extension
                hlt

file_name:  .text "HEADER5"
            .b 0

extension_name: .text "EXT5"
                .b 0

file_name2:  .text "HEADER6"
            .b 0

extension_name2: .text "EXT6"
                .b 0
CPS_level_end: