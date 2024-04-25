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
keyb_status                             .equ crt_hide_cursor+3
keyb_read                               .equ keyb_status+3
time_delay                              .equ keyb_read+3


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

start:                  .org 0000
                        lxi sp,$2000
                        call crt_display_reset
                        call dma_reset 
                        lxi b,$1000
                        lxi d,$8000
                        lxi h,$0100
                        call dma_memory_transfer
                        in dma_status_register
                        call print_byte 
                        mvi a,$20 
                        call crt_char_out 

                        out dma_ff_clear
                        in dma_channel0_word_count_register
                        mov l,a 
                        in dma_channel0_word_count_register
                        mov h,a 
                        call print_address
                        mvi a,$20 
                        call crt_char_out 

                        out dma_ff_clear
                        in dma_channel1_word_count_register
                        mov l,a 
                        in dma_channel1_word_count_register
                        mov h,a 
                        call print_address
                        mvi a,$20 
                        call crt_char_out 

                        out dma_ff_clear
                        in dma_channel0_address_register
                        mov l,a 
                        in dma_channel0_address_register
                        mov h,a 
                        call print_address
                        mvi a,$20 
                        call crt_char_out 

                        out dma_ff_clear
                        in dma_channel1_address_register
                        mov l,a 
                        in dma_channel1_address_register
                        mov h,a 
                        call print_address
                        mvi a,$20 
                        call crt_char_out 

                        hlt 

dma_reset:				out dma_master_clear
						mvi a,dma_command_register_mm_enable+dma_command_register_ch0_hold_disable+dma_command_register_controller_enable+dma_command_register_compressed_timing+dma_command_register_drq_active_high+dma_command_register_dack_active_low 
						out dma_command_register
						mvi a,dma_mode_all_mask_register_channel3+dma_mode_all_mask_register_channel2+dma_mode_all_mask_register_channel1+dma_mode_all_mask_register_channel0
						out dma_all_mask_register
						ret

dma_memory_transfer:        mvi a,dma_mode_register_channel0+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_read_transfer
                            out dma_mode_register
                            mvi a,dma_mode_register_channel1+dma_mode_register_increment+dma_mode_register_no_autoinitialize+dma_mode_register_block_transfer+dma_mode_register_write_transfer
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
							ret