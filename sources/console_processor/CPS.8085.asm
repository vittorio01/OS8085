.include "os_constraints.8085.asm"
.include "bios_system_calls.8085.asm"
.include "mms_system_calls.8085.asm"
.include "fsm_system_calls.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "execution_codes.8085.asm"

cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                call fsm_init
                mvi a,$41
                call fsm_select_disk 
                lxi h,0 
                call fsm_format_disk 
                mvi h,128
loop:           lxi b,file_name 
                lxi d,extension_name 
                mvi a,%01101100
                call fsm_create_file_header
                mov a,h 
                sta file_name
                sta extension_name
                dcr h 
                jnz loop
                
                hlt

file_name:  .text " MAIN_PROGRAM"
            .b 0

extension_name: .text " BEF"
                .b 0

test_program:       mvi a,$AA 
                    lxi h,$AAAA 
                    lxi d,$BBBB 
                    lxi b,$CCCC 
                    hlt 
test_program_end:       
test_program_dim .equ test_program_end-test_program 
cps_layer_end:
.memory "fill", cps_layer_end, cps_dimension-cps_layer_end+CPS,$00

.print "CPS load address ->",CPS 
.print "All functions built successfully"