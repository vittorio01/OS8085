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
                mvi h,64
                mvi l,$30
loop:           mov a,l
                sta file_name+6
                sta extension_name+3
                mvi a,%10110000
                call fsm_create_file_header
                inr l 
                dcr h 
                jnz loop
                
                hlt

file_name:  .text "HEADER5"
            .b 0

extension_name: .text "EXT5"
                .b 0
CPS_level_end: