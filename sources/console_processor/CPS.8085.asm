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
                mvi a,%10100000
                lxi b,file_name
                lxi d,extension_name
                call fsm_create_file_header
                call fsm_select_file_header
                lxi b,0 
                lxi d,2048 
                call fsm_selected_file_append_data_bytes
                 
                lxi b,0 
                lxi d,0 
                call fsm_selected_file_set_data_pointer
                lxi h,2048 
                call mms_create_low_memory_data_segment
                lxi h,0 
loop:           mov a,l 
                call mms_write_selected_data_segment_byte
                inx h 
                jnc loop
                mvi a,2 
                lxi b,2048 
                lxi h,0 
                call fsm_selected_file_write_bytes
                
                lxi b,file_name 
                lxi d,extension_name
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