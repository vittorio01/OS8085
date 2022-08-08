cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk
                lxi h,0 
                call fsm_truncate_page
                hlt

disk_name:  .text "DISCO DI PROVA"
            .b 0

CPS_level_end: