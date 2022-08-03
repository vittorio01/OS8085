cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,$00bf
                lxi b,0 
                push b 
                lxi b,$A 
                push b 
                lxi b,0 
                push b 
                lxi b,$800
                push b 
                call unsigned_divide_long
                hlt 


                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init 
                mvi a,'A'
                lxi h,0 
                call fsm_disk_format
                hlt

disk_name:  .text "DISCO DI PROVA"
            .b 0
CPS_level_end: