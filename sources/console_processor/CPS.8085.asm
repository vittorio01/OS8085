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
                lxi h,2048
                call fsm_format_disk
                call fsm_selected_disk_set_bootable
                lxi h,2048
                call mms_create_low_memory_data_segment
                lxi h,0 
loop:           mov a,l 
                inx h 
                call mms_write_selected_data_segment_byte
                jnc loop
                
                lxi h,0 
                mvi a,2 
                lxi b,2048 
                lxi d,0 
                lxi h,0 
                call fsm_selected_disk_set_system
                hlt

file_name:  .text "SYSTEM"
            .b 0

extension_name: .text "BIN"
                .b 0



cps_layer_end:
.memory "fill", cps_layer_end, cps_dimension-cps_layer_end+CPS,$00

.print "CPS load address ->",CPS 
.print "All functions built successfully"