cps_functions:      .org CPS
                    jmp system_boot

system_boot:    lxi sp,stack_memory_start
                call bios_warm_boot
                call mms_low_memory_initialize
                lxi h,1024
                call mms_create_low_memory_data_segment
                lxi h,0
loop:           mov a,l 
                inx h
                call mms_write_selected_data_segment_byte
                jnc loop 
loop_end:       call fsm_init
                mvi a,$41
                call fsm_select_disk 
                lxi b,file_name2 
                lxi d,extension_name2
                mvi a,%10110000
                call fsm_create_file_header
                call fsm_select_file_header
                lxi b,0 
                lxi d,4096 
                call fsm_selected_file_append_data_bytes
                lxi d,0
                call fsm_selected_file_set_data_pointer
                lxi b,1024
                lxi h,0
                mvi a,1
                call fsm_selected_file_write_bytes

                hlt

file_name:  .text "file di prova"
            .b 0

extension_name: .text "prg"
                .b 0

file_name2: .text "file molto bello" 
            .b 0 
extension_name2:    .text "culo"
                    .b 0

CPS_level_end: