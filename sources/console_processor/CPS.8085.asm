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
                call fsm_delete_selected_file_header
                hlt

file_name:  .text "HEADERo"
            .b 0

extension_name: .text "EXTo"
                .b 0

CPS_level_end: