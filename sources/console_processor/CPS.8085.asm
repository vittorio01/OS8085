cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk
                lxi d,file_name
                lxi b,extension_name
                mvi a,%10111111
                call fsm_create_file_header
                hlt

file_name:  .text "HEADER DI PROVA"
            .b 0
extension_name: .text "ABC"
                .b 0
CPS_level_end: