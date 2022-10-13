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
                call fsm_load_selected_program
                hlt

file_name:  .text "MAIN_PROGRAM"
            .b 0

extension_name: .text "BEF"
                .b 0

test_program:       mvi a,$AA 
                    lxi h,$AAAA 
                    lxi d,$BBBB 
                    lxi b,$CCCC 
                    hlt 
test_program_end:       
test_program_dim .equ test_program_end-test_program 
CPS_level_end: