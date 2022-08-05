cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,$00bf
                mvi a,$41
                call fsm_select_disk
                hlt

disk_name:  .text "DISCO DI PROVA"
            .b 0

CPS_level_end: