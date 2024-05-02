firmware_functions                      .equ $8000
firmware_boot                           .equ firmware_functions
firmware_serial_send_terminal_char      .equ firmware_boot+3
firmware_serial_request_terminal_char   .equ firmware_serial_send_terminal_char+3
firmware_serial_disk_status             .equ firmware_serial_request_terminal_char+3
firmware_serial_disk_read_sector        .equ firmware_serial_disk_status+3
firmware_serial_disk_write_sector       .equ firmware_serial_disk_read_sector+3
system_transfer_and_boot                .equ firmware_serial_disk_write_sector+3
crt_display_reset                       .equ system_transfer_and_boot+3
crt_char_out                            .equ crt_display_reset+3
crt_set_display_pointer                 .equ crt_char_out+3
crt_get_display_pointer                 .equ crt_set_display_pointer+3
crt_show_cursor                         .equ crt_get_display_pointer+3
crt_hide_cursor                         .equ crt_show_cursor+3
crt_byte_in                             .equ crt_hide_cursor+3
crt_byte_out                            .equ crt_byte_in+3
keyb_status                             .equ crt_byte_out+3
keyb_read                               .equ keyb_status+3
time_delay                              .equ keyb_read+3

pointer_blinking_delay      .equ 200

dma_status_register		    .equ $08
dma_command_register	    .equ $08
dma_request_register	    .equ $09
dma_single_mask_register	.equ $0a
dma_mode_register		    .equ $0b
dma_ff_clear		        .equ $0c
dma_temporary_register	    .equ $0d
dma_master_clear		    .equ $0d
dma_clear_mask_register	    .equ $0e
dma_all_mask_register	    .equ $0f

dma_channel0_address_register       .equ $00
dma_channel0_word_count_register    .equ $01
dma_channel1_address_register       .equ $02
dma_channel1_word_count_register    .equ $03
dma_channel2_address_register       .equ $04
dma_channel2_word_count_register    .equ $05
dma_channel3_address_register       .equ $06
dma_channel3_word_count_register    .equ $07

dma_mode_register_transfer_mode_mask        .equ %11000000
dma_mode_register_address_increment_mask    .equ %00100000
dma_mode_register_autoinitialize_mask       .equ %00010000
dma_mode_register_transfer_direction_mask   .equ %00001100
dma_mode_register_channel_mask              .equ %00000011

dma_mode_register_cascade_transfer          .equ %11000000
dma_mode_register_block_transfer            .equ %10000000
dma_mode_register_single_transfer           .equ %01000000
dma_mode_register_demand_transfer           .equ %00000000

dma_mode_register_autoinitialize            .equ %00010000
dma_mode_register_no_autoinitialize         .equ %00000000

dma_mode_register_increment                 .equ %00000000
dma_mode_register_decrement                 .equ %00100000

dma_mode_register_write_transfer            .equ %00000100
dma_mode_register_read_transfer             .equ %00001000
dma_mode_register_verify_transfer           .equ %00000000

dma_mode_register_channel0                  .equ 0
dma_mode_register_channel1                  .equ 1
dma_mode_register_channel2                  .equ 2
dma_mode_register_channel3                  .equ 3

dma_mode_all_mask_register_channel0         .equ %00000001
dma_mode_all_mask_register_channel1         .equ %00000010
dma_mode_all_mask_register_channel2         .equ %00000100
dma_mode_all_mask_register_channel3         .equ %00001000

dma_command_register_mm_enable              .equ %00000001
dma_command_register_mm_disable             .equ %00000000

dma_command_register_ch0_hold_disable       .equ %00000000
dma_command_register_ch0_hold_enable        .equ %00000010

dma_command_register_controller_enable      .equ %00000000
dma_command_register_controller_disable     .equ %00000100

dma_command_register_normal_timing          .equ %00000000
dma_command_register_compressed_timing      .equ %00001000

dma_command_register_fixed_priority         .equ %00000000
dma_command_register_rotating_priority      .equ %00010000

dma_command_register_late_write             .equ %00000000
dma_command_register_extended_write         .equ %00100000

dma_command_register_drq_active_high        .equ %00000000
dma_command_register_drq_active_low         .equ %01000000

dma_command_register_dack_active_high       .equ %10000000
dma_command_register_dack_active_low        .equ %00000000

dma_request_register_channel0_request        .equ %00000000
dma_request_register_channel1_request        .equ %00000001
dma_request_register_channel2_request        .equ %00000010
dma_request_register_channel3_request        .equ %00000011

dma_request_register_set_request                .equ %00000100
dma_request_register_reset_request              .equ %00000000

;FDC controller environment variables

fdc_runtime_settings                            .equ $0500
fdc_runtime_settings_drive_selected_mask        .equ %00000011   
fdc_runtime_settings_interrupt_wait_mask        .equ %00000100
fdc_runtime_settings_motor_on_mask              .equ %00001000


fdc_runtime_settings_interrupt_seek             .equ %00000000
fdc_runtime_settings_interrupt_execution        .equ %00000100
fdc_runtime_settings_motor_on                   .equ %00001000

fdc_command_wait_timeout_value           .equ 5000
;fdc_send_bytes					.equ	$0082
;fdc_read_bytes					.equ 	$0082

;FDC controller port addresses

fdc_drive_control_register	.equ $12
fdc_data_rate_register		.equ $17
fdc_disk_changed_register	.equ $17
fdc_main_status_register	.equ $14
fdc_data_register			.equ $15

fdc_drive_control_register_motor0_enable    .equ %00010000
fdc_drive_control_register_motor1_enable    .equ %00100000
fdc_drive_control_register_motor2_enable    .equ %01000000
fdc_drive_control_register_motor3_enable    .equ %10000000

fdc_drive_control_register_drive0_select    .equ %00000000
fdc_drive_control_register_drive1_select    .equ %00000001
fdc_drive_control_register_drive2_select    .equ %00000010
fdc_drive_control_register_drive3_select    .equ %00000011

fdc_drive_control_register_dma_enable       .equ %00001000
fdc_drive_control_register_dma_disable      .equ %00000000

fdc_drive_control_register_reset            .equ %00000000
fdc_drive_control_register_normal_operation .equ %00000100


fdc_data_rate_register_500kbs               .equ %00000000
fdc_data_rate_register_250_300kbs           .equ %00000001
fdc_data_rate_register_250kbs               .equ %00000010
fdc_data_rate_register_1000kbs              .equ %00000011

fdc_disk_changed_register_mask              .equ %10000000
fdc_disk_changed_register_inserted          .equ %00000000
fdc_disk_changed_register_changed           .equ %10000000

fdc_main_status_register_request_from_master_mask   .equ %10000000
fdc_main_status_register_data_direction_mask        .equ %01000000
fdc_main_status_register_non_dma_execution_mask     .equ %00100000
fdc_main_status_register_command_in_progress_mask   .equ %00010000
fdc_main_status_register_drive_seeking_mask         .equ %00001111

fdc_main_status_register_request_from_master        .equ %10000000
fdc_main_status_register_data_direction_write       .equ %00000000
fdc_main_status_register_data_direction_read        .equ %01000000
fdc_main_status_register_non_dma_execution          .equ %00100000
fdc_main_status_register_command_in_progress        .equ %00010000
fdc_main_status_register_drive0_seeking             .equ %00000001
fdc_main_status_register_drive1_seeking             .equ %00000010
fdc_main_status_register_drive2_seeking             .equ %00000100
fdc_main_status_register_drive3_seeking             .equ %00001000
fdc_main_status_register_no_seeking                 .equ %00000000

fdc_status_register0_interrupt_mask                 .equ %11000000
fdc_status_register0_seek_end_mask                  .equ %00100000
fdc_status_register0_equipment_check_mask           .equ %00010000
fdc_status_register0_head_address_mask              .equ %00000100
fdc_status_register0_drive_select_mask              .equ %00000011

fdc_status_register0_interrupt_normal               .equ %00000000
fdc_status_register0_interrupt_abnormal             .equ %01000000
fdc_status_register0_interrupt_invalid_command      .equ %10000000
fdc_status_register0_interrupt_ready                .equ %11000000
fdc_status_register0_seek_end                       .equ %00100000
fdc_status_register0_equipment_check                .equ %00010000
fdc_status_register0_head_address0                  .equ %00000000
fdc_status_register0_head_address1                  .equ %00000100
fdc_status_register0_drive_select0                  .equ %00000000
fdc_status_register0_drive_select1                  .equ %00000001
fdc_status_register0_drive_select2                  .equ %00000010
fdc_status_register0_drive_select3                  .equ %00000011

fdc_status_register1_eot_mask                       .equ %10000000
fdc_status_register1_crc_error_mask                 .equ %00100000
fdc_status_register1_overrun_mask                   .equ %00010000
fdc_status_register1_no_data_mask                   .equ %00000100
fdc_status_register1_not_writable_mask              .equ %00000010
fdc_status_register1_missing_address_mask           .equ %00000001

fdc_status_register1_eot                            .equ %10000000
fdc_status_register1_crc_error                      .equ %00100000
fdc_status_register1_overrun                        .equ %00010000
fdc_status_register1_no_data                        .equ %00000100
fdc_status_register1_not_writable                   .equ %00000010
fdc_status_register1_missing_address                .equ %00000001

fdc_status_register2_control_mark_mask              .equ %01000000
fdc_status_register2_crc_in_data_field_mask         .equ %00100000
fdc_status_register2_wrong_track_mask               .equ %00010000
fdc_status_register2_scan_equal_hit_mask            .equ %00001000
fdc_status_register2_scan_not_satisfied_mask        .equ %00000100
fdc_status_register2_bad_track_mask                 .equ %00000010
fdc_status_Register2_missing_address_mask           .equ %00000001

fdc_status_register2_control_mark                   .equ %01000000
fdc_status_register2_crc_in_data_field              .equ %00100000
fdc_status_register2_wrong_track                    .equ %00010000
fdc_status_register2_scan_equal_hit                 .equ %00001000
fdc_status_register2_scan_not_satisfied             .equ %00000100
fdc_status_register2_bad_track                      .equ %00000010
fdc_status_Register2_missing_address                .equ %00000001

fdc_status_register3_write_protect_status_mask      .equ %01000000
fdc_status_register3_track0_status_mask             .equ %00100000
fdc_status_register3_head_select_status_mask        .equ %00001000
fdc_status_register3_drive_select_mask              .equ %00000011

fdc_status_register3_write_protect                  .equ %01000000
fdc_status_register3_track0                         .equ %00100000
fdc_status_register3_head_select                    .equ %00001000
fdc_status_register3_drive_select0                  .equ %00000000
fdc_status_register3_drive_select1                  .equ %00000001
fdc_status_register3_drive_select2                  .equ %00000010
fdc_status_register3_drive_select3                  .equ %00000011

fdc_operation_ok                .equ $ff 
fdc_wrong_direction_error       .equ $01
fdc_timeout_error               .equ $02
fdc_no_response_error           .equ $03 
fdc_response_not_expected       .equ $04
fdc_sense_interrupt_required    .equ $05

sim_interrupt_mask          .equ %00001000
sim_rst65_enable            .equ %00000010

fdc_command_space           .equ $0200

begin:                  .org 0000
                        jmp start 

rst65:                 .org $0034 
                        jmp fdc_interrupt_routine

start:                  .org $0050
                        lxi sp,$2000
                        call crt_display_reset
                        call dma_reset 
                        call fdc_reset
                        xra a 
                        call fdc_select_drive 
command_phase_restart:  lxi h,command_wait_message 
                        call text_out  
                        lxi h,$0f00
command_in_msb:         call keyb_wait_char
                        call ascii_upper_case
                        cpi $52 
                        jz command_reload 
                        cpi $0d 
                        jz command_send 
                        mov b,a 
                        call crt_char_out
                        mov a,b 
                        call ascii_is_hex
                        ora a 
                        jnz command_in_msb 
                        call ascii_to_hex
                        ral 
                        ral 
                        ral 
                        ral 
                        ani $f0 
                        mov m,a 
command_in_lsb:         call keyb_wait_char
                        call ascii_upper_case
                        cpi $52 
                        jz command_reload 
                        cpi $0d 
                        jz command_send 
                        mov b,a 
                        call crt_char_out
                        mov a,b 
                        call ascii_is_hex
                        ora a 
                        jz command_in_lsb
                        call ascii_to_hex
                        ani $0f 
                        ora m 
                        mov m,a
                        inx h 
                        mvi a,$20 
                        call crt_char_out
                        jmp command_in_msb
command_reload:         call crt_display_reset
                        jmp command_phase_restart
comamnd_send:           mvi a,$0d
                        call crt_char_out
                        mvi a,$0a 
                        call crt_char_out 
                        lxi h,command_send_message 
                        call text_out 

                        call fdc_motor_on 
                        lxi h,$1000 
                        call dma_set_channel2_read_transfer
                        lxi h,$0f00
                        mov a,m 
                        inx h 
                        cpi $ff 
                        jnz command_no_int
                        stc 
                        jmp command_send 
command_no_int:         stc 
                        cmc 
command_send:           call fdc_send_command
                        mov b,a 
                        lxi h,command_done_message
                        call text_out 
                        mov a,b 
                        call print_byte 
                        lxi h,$0f01
                        mvi a,$20 
                        call crt_char_out 
                        mvi b,7
print_loop:             call print_byte
                        inx h 
                        mvi a,$20 
                        call crt_char_out
                        dcr b 
                        jnz print_loop 
                        call fdc_motor_off 
                        call keyb_wait_char
                        jmp command_phase_restart

dma_reset:				out dma_master_clear
						mvi a,dma_command_register_mm_enable+dma_command_register_ch0_hold_disable+dma_command_register_controller_enable+dma_command_register_compressed_timing+dma_command_register_drq_active_high+dma_command_register_dack_active_low 
						out dma_command_register
						mvi a,dma_mode_all_mask_register_channel3+dma_mode_all_mask_register_channel2+dma_mode_all_mask_register_channel1+dma_mode_all_mask_register_channel0
						out dma_all_mask_register
						ret

dma_set_channel2_write_transfer:    mvi a,dma_mode_register_channel2+dma_mode_register_write_transfer+dma_mode_register_address_increment_mask+dma_mode_register_no_autoinitialize
                                    out dma_mode_register 
                                    out dma_ff_clear
                                    mov a,c 
                                    out dma_channel2_word_count_register
                                    mov a,b 
                                    out dma_channel2_word_count_register
                                    out dma_ff_clear
                                    mov a,l 
                                    out dma_channel2_address_register
                                    mov a,h 
                                    out dma_channel2_address_register
                                    ret 
                                    

dma_set_channel2_read_transfer:     mvi a,dma_mode_register_channel2+dma_mode_register_read_transfer+dma_mode_register_address_increment_mask+dma_mode_register_no_autoinitialize
                                    out dma_mode_register 
                                    out dma_ff_clear
                                    mov a,c 
                                    out dma_channel2_word_count_register
                                    mov a,b 
                                    out dma_channel2_word_count_register
                                    out dma_ff_clear
                                    mov a,l 
                                    out dma_channel2_address_register
                                    mov a,h 
                                    out dma_channel2_address_register
                                    ret 

dma_memory_transfer:        mvi a,dma_mode_register_channel0+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_write_transfer
                            out dma_mode_register
                            mvi a,dma_mode_register_channel1+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_read_transfer
                             out dma_mode_register
                            out dma_ff_clear
                            mov a,c 
                            out dma_channel0_word_count_register
                            mov a,b 
                            out dma_channel0_word_count_register
                            out dma_ff_clear
                            mov a,c 
                            out dma_channel1_word_count_register
                            mov a,b 
                            out dma_channel1_word_count_register
                            out dma_ff_clear
                            mov a,e 
                            out dma_channel0_address_register
                            mov a,d 
                            out dma_channel0_address_register
                            out dma_ff_clear
                            mov a,l 
                            out dma_channel1_address_register
                            mov a,h 
                            out dma_channel1_address_register
                            mvi a,dma_request_register_set_request+dma_request_register_channel0_request
                            out dma_request_register
                            ret

fdc_reset:      mvi a,fdc_drive_control_register_reset
                out fdc_drive_control_register
                mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_normal_operation
                out fdc_drive_control_register
                mvi a,fdc_data_rate_register_250kbs
                out fdc_data_rate_register
                xra a 
                sta fdc_runtime_settings
                ret 

fdc_motor_on:           lda fdc_runtime_settings
                        ori fdc_runtime_settings_motor_on 
                        sta fdc_runtime_settings 
                        ani fdc_runtime_settings_drive_selected_mask
                        mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive0_select+fdc_drive_control_register_motor0_enable
                        out fdc_drive_control_register
                        ret 
fdc_motor_on_drive1:    mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive1_select+fdc_drive_control_register_motor1_enable
                        out fdc_drive_control_register
                        ret 
fdc_motor_on_drive2:    mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive2_select+fdc_drive_control_register_motor2_enable
                        out fdc_drive_control_register
                        ret 
fdc_motor_on_drive3:    mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive3_select+fdc_drive_control_register_motor3_enable
                        out fdc_drive_control_register
                        ret 

fdc_motor_off:          lda fdc_runtime_settings 
                        ani $ff-fdc_runtime_settings_motor_on_mask 
                        sta fdc_runtime_settings 
                        mvi a,fdc_drive_control_register_dma_enable
                        out fdc_drive_control_register
                        ret           

;fdc_select_drive selects the ddesired floppy drive 
;A -> drive number (0 to 3)

fdc_select_drive:       ani %00000011
                        cpi 1 
                        jz fdc_select_drive1 
                        cpi 2 
                        jz fdc_select_drive2 
                        cpi 3 
                        jz fdc_select_drive3 
                        lda fdc_runtime_settings
                        ani $ff-fdc_runtime_settings_drive_selected_mask
                        ret 
fdc_select_drive1:      mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive1_select+fdc_drive_control_register_motor1_enable
                        out fdc_drive_control_register
                        lda fdc_runtime_settings
                        ani $ff-fdc_runtime_settings_drive_selected_mask
                        ori 1
                        ret 
fdc_select_drive2:      mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive2_select+fdc_drive_control_register_motor2_enable
                        out fdc_drive_control_register
                        lda fdc_runtime_settings
                        ani $ff-fdc_runtime_settings_drive_selected_mask
                        ori 2
                        ret 
fdc_select_drive3:      mvi a,fdc_drive_control_register_dma_enable+fdc_drive_control_register_drive3_select+fdc_drive_control_register_motor3_enable
                        out fdc_drive_control_register
                        lda fdc_runtime_settings
                        ani $ff-fdc_runtime_settings_drive_selected_mask
                        ori 3 
                        ret 



;fdc_send_command sends a specific command to the fdc controller 
;Cy -> 1 if the command has to wait an interrupt, 0 otherwise 
;HL -> command address

;Cy -> 1 if the command has not been sended correctly, 0 otherwise
;A -> execution error
;HL -> command 

fdc_interrupt_routine:                              inx sp 
                                                    inx sp 
                                                    lda fdc_runtime_settings 
                                                    ani fdc_runtime_settings_interrupt_wait_mask
                                                    cpi fdc_runtime_settings_interrupt_seek
                                                    jz fdc_send_command_wait_seek_end
                                                    jmp fdc_send_command_get_response

fdc_send_command:                                   push b
                                                    push d 
                                                    push h  
                                                    jnc fdc_send_command_no_wait
                                                    mvi c,$ff
                                                    jmp fdc_send_command_start
fdc_send_command_no_wait:                           mvi c,0
fdc_send_command_start:                             lxi d,fdc_command_wait_timeout_value
fdc_send_command_wait_controller:                   in fdc_main_status_register
                                                    ani fdc_main_status_register_request_from_master_mask
                                                    cpi fdc_main_status_register_request_from_master
                                                    jz fdc_send_command_loop
                                                    mov a,e 
                                                    ora d 
                                                    jz fdc_send_command_timeout_error_return
                                                    push h
                                                    lxi h,1 
                                                    call time_delay
                                                    dcx d 
                                                    pop h 
                                                    jmp fdc_send_command_loop
fdc_send_command_loop:                              in fdc_main_status_register
                                                    ani fdc_main_status_register_data_direction_mask
                                                    cpi fdc_main_status_register_data_direction_write
                                                    jz fdc_send_command_wrong_direction_error_return 
                                                    mov a,m 
                                                    out fdc_data_register
                                                    inx h 
                                                    in fdc_main_status_register
                                                    ani fdc_main_status_register_request_from_master_mask 
                                                    cpi fdc_main_status_register_request_from_master
                                                    jnz fdc_send_command_loop
                                                    mov a,c 
                                                    cpi $ff
                                                    jz fdc_send_command_wait_response
                                                    in fdc_main_status_register
                                                    ani fdc_main_status_register_command_in_progress_mask 
                                                    cpi fdc_main_status_register_command_in_progress
                                                    jnz fdc_send_command_verify_seek
fdc_send_command_response_not_expected:             mvi c,fdc_response_not_expected
                                                    jmp fdc_send_command_get_unexpected_response
fdc_send_command_wait_response:                     mvi a,sim_interrupt_mask+sim_rst65_enable
                                                    sim 
                                                    lxi d,fdc_command_wait_timeout_value
fdc_send_command_wait_response_loop:                jmp fdc_send_command_wait_response_loop
fdc_send_command_no_response_error:                 mvi a,sim_interrupt_mask
                                                    sim 
                                                    mvi a,fdc_no_response_error
                                                    stc 
                                                    jmp fdc_send_command_end  
fdc_send_command_get_response:                      mvi a,sim_interrupt_mask
                                                    sim 
fdc_send_command_get_unexpected_response:           pop h 
                                                    push h 
fdc_send_command_get_response_loop:                 in fdc_main_status_register
                                                    mov b,a 
                                                    ani fdc_main_status_register_request_from_master_mask
                                                    cpi fdc_main_status_register_request_from_master
                                                    jnz fdc_send_command_get_response_end
                                                    mov a,b 
                                                    ani fdc_main_status_register_data_direction_mask
                                                    cpi fdc_main_status_register_data_direction_read
                                                    jz fdc_send_command_wrong_direction_error_return 
                                                    in fdc_data_register
                                                    mov m,a 
                                                    inx h 
                                                    jmp fdc_send_command_get_response_loop
fdc_send_command_get_response_end:                  mov a,c 
                                                    cpi fdc_response_not_expected
                                                    jnz fdc_send_command_normal_end
                                                    stc 
                                                    jmp fdc_send_command_end
fdc_send_command_timeout_error_return:              mvi a,sim_interrupt_mask
                                                    sim 
                                                    mvi a,fdc_timeout_error
                                                    stc 
                                                    jmp fdc_send_command_end
fdc_send_command_wrong_direction_error_return:      mvi a,fdc_wrong_direction_error
                                                    stc 
                                                    jmp fdc_send_command_end 
fdc_send_command_verify_seek:                       in fdc_main_status_register
                                                    ani fdc_main_status_register_drive_seeking_mask
                                                    cpi fdc_main_status_register_no_seeking
                                                    jz fdc_send_command_normal_end
                                                    mvi a,sim_interrupt_mask+sim_rst65_enable
                                                    sim 
fdc_send_command_wait_seek:                         jmp fdc_send_command_wait_seek
fdc_send_command_wait_seek_end:                     mvi a,sim_interrupt_mask
                                                    sim 
                                                    mvi a,fdc_sense_interrupt_required 
                                                    stc 
                                                    jmp fdc_send_command_end
fdc_send_command_normal_end:                        stc 
                                                    cmc 
                                                    mvi a,fdc_operation_ok 
fdc_send_command_end:                               pop h
                                                    pop d
                                                    pop b
                                                    ret 


 
print_address:	mov a,h 
                call print_byte 
                mov a,l 
                call print_byte 
                ret 

print_byte:					push b 
                            mov b,a 
                            rar 
                            rar 
                            rar 
                            rar 
                            ani $0f
                            call hex_to_ascii 
                            stc 
                            cmc 
                            call crt_char_out
                            mov a,b 
                            ani $0f 
                            call hex_to_ascii 
                            stc 
                            cmc 
                            call crt_char_out
                            pop b 
                            ret 

hex_to_ascii:				ani $0f 
							cpi $0a 
							jnc hex_to_ascii_letter
							adi $30 
							ret 
hex_to_ascii_letter:		adi $37

;ascii_to_hex converts the ascii character into his hex value 
;A	-> ASCII character
;A 	<- hex value

ascii_to_hex:				cpi $30 
							jc ascii_to_hex_not_valid
							cpi $3A 
							jnc ascii_to_hex_letter 
							sui $30 
							ret 
ascii_to_hex_letter:		cpi $41 
							jc ascii_to_hex_not_valid
							cpi $47
							jnc ascii_to_hex_not_valid
							sui $37 
							ret 
ascii_to_hex_not_valid:		xra a 
							ret 

;ascii_is_hex indicates if the ascii character can be converted as hex value
;A -> ASCII character
;A -> $ff if true, $00 if false
ascii_is_hex:				cpi $47 
							jnc ascii_is_hex_false
							cpi $41 
							jnc ascii_is_hex_true
							cpi $3A
							jnc ascii_is_hex_false
							cpi $30 
							jc ascii_is_hex_false
ascii_is_hex_true:			mvi a,$ff 
							ret 
ascii_is_hex_false:			xra a 
							ret 

;ascii_upper_case converts all small letters in big letters 
;A -> ASCII letter
;A <- ASCII letter in upper case 
ascii_upper_case:			cpi $7B
							rnc 
							cpi $61
							rc 
							sui $20
							ret 


;keyb_wait_char wait a new character from the PS/2 interface and provide the blinking cursor effect 
;A	<- character received

keyb_wait_char:				push h
							push b 
keyb_wait_char_loop:		call crt_show_cursor
							lxi b,pointer_blinking_delay
keyb_wait_char_on_loop:		call keyb_status
							ora a
							jnz keyb_wait_char_cursor_off
							dcx b 
							mov a,c 
							ora b
							jnz keyb_wait_char_on_loop
							call crt_hide_cursor
							lxi b,pointer_blinking_delay
keyb_wait_char_off_loop:	call keyb_status
							ora a
							jnz keyb_wait_char_read
							dcx b 
							mov a,c 
							ora b
							jnz keyb_wait_char_off_loop
							jmp keyb_wait_char_loop
keyb_wait_char_cursor_off:	call crt_hide_cursor
keyb_wait_char_read:		call keyb_read
							call ascii_upper_case
keyb_wait_char_end:			pop b 
							pop h
							ret

text_out:			push h		
text_out_1:			mov a,m			
					cpi 0
					jz text_out_2
					call crt_char_out
					inx h
					jmp text_out_1
text_out_2:			pop h
					ret

command_wait_message:   .text "Insert hex command:"
                        .b $0a, $0d, 0
command_send_message:   .text "Sending command..."
                        .b 0 
command_done_message:   .text "done"
                        .b $0a,$0d,0