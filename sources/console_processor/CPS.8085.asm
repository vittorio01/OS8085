cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,$00bf
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk
                lxi h,0 
                call fsm_disk_format
                hlt 
                lxi h,0
                call fsm_move_data_page
                call fsm_reselect_mms_segment
                mvi m,$AA
                lxi h,1
                call fsm_move_data_page
                lhld fsm_selected_disk_loaded_page
                hlt 

disk_name:  .text "DISCO DI PROVA"
            .b 0

CPS_level_end: