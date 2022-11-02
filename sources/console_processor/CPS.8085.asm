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
                lxi h,$2000 
                call fsm_selected_disk_set_bootable
                call fsm_selected_disk_is_bootable
                call fsm_selected_disk_get_boot_section_dimension
                xchg 
                call fsm_selected_disk_get_system_section_dimension

                hlt

file_name:  .text "SYSTEM"
            .b 0

extension_name: .text "BIN"
                .b 0



cps_layer_end:
.memory "fill", cps_layer_end, cps_dimension-cps_layer_end+CPS,$00

.print "CPS load address ->",CPS 
.print "All functions built successfully"