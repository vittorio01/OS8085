cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk
                mvi a,%10111111
                lxi b,file_name2
                lxi d,extension_name2
                call fsm_create_file_header
                lxi b,file_name2
                lxi d,extension_name2
                call fsm_select_file_header
                call fsm_delete_selected_file_header
                hlt

file_name:  .text "file di prova"
            .b 0

extension_name: .text "prg"
                .b 0

file_name2: .text "file molto bello" 
            .b 0 
extension_name2:    .text "culo"
                    .b 0

CPS_level_end: