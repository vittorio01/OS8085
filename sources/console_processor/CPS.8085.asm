cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk 
                lxi d,2
                lxi h,0
                call fsm_append_pages
                lxi h,0 
                lxi d,2
                call fsm_append_pages
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