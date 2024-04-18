;PX1 FULL internal EPROM firmware. 

;This firmware contains:
;-  A program that verifies if there is a serial service available 
;-  the bootloader for serial virtual disks
;-  All drivers for onboard hardware and serial connection

;-------- environment variables --------
debug_mode          .var false

firmware_start_address                      .equ $8000
firmware_dimension                          .equ 32768
bootloader_load_address                     .equ $0020

serial_disk_inserted_mask                   .equ %10000000
serial_disk_ready_mask                      .equ %01000000
serial_disk_read_only_mask                  .equ %00100000
serial_disk_transfer_error_mask             .equ %00010000
serial_disk_seek_error_mask                 .equ %00001000
serial_disk_bad_sector_error_mask           .equ %00000100

disk_bootable_flag_mask        .equ %10000000
disk_bootable_flag             .equ %10000000
boot_disk_format_dimension     .equ 6

;-------- ram resources allocation --------
vram_memory_space_address           .equ firmware_start_address-512
drivers_memory_space_base_address   .equ vram_memory_space_address-16
serial_memory_space_base_address    .equ drivers_memory_space_base_address-42
stack_pointer                       .equ serial_memory_space_base_address-1

;-------- firmware functions ---------
firmware_functions:     .org firmware_start_address 
                        jmp firmware_boot 
                        jmp firmware_serial_send_terminal_char
                        jmp firmware_serial_request_terminal_char
                        jmp firmware_serial_disk_status
                        jmp firmware_serial_disk_read_sector
                        jmp firmware_serial_disk_write_sector
                        jmp system_transfer_and_boot 

                        jmp crt_display_reset 
                        jmp crt_char_out
                        jmp crt_set_display_pointer
                        jmp crt_get_display_pointer
                        jmp crt_show_cursor
                        jmp crt_hide_cursor
                        jmp crt_byte_in 
                        jmp crt_byte_out 

                        jmp keyb_status 
                        jmp keyb_read 
                        jmp time_delay

.include "string/string_ncompare.8085.asm"
.include "PX1_full_serial_drivers.8085.asm"
.include "PX1_full_drivers.8085.asm"
.include "PX1_full_firmware_program.8085.asm"


firmware_boot:                  lxi sp,stack_pointer 
                                call crt_display_reset

                                lxi h,firmware_boot_string
                                call firmware_crt_string_out
                                call serial_reset_connection 
                                ora a 
                                jz firmware_internal_boot
                                call serial_request_disk_information
                                ani serial_disk_inserted_mask+serial_disk_ready_mask
                                cpi serial_disk_inserted_mask+serial_disk_ready_mask
                                jnz firmware_serial_disk_not_found
firmware_serial_disk_load:      lxi h,bootloader_load_address
                                lxi b,0
                                lxi d,0 
                                call serial_request_disk_sector
                                jnc firmware_serial_disk_error 
firmware_serial_disk_verify:    lxi h,bootloader_load_address
                                lxi d,boot_disk_format_string 
                                call string_ncompare 
                                ora a 
                                jz firmware_serial_disk_not_bootable
                                lda bootloader_load_address+boot_disk_format_dimension
                                ani disk_bootable_flag_mask
                                cpi disk_bootable_flag
                                jnz firmware_serial_disk_not_bootable
firmware_serial_boot:           lxi h,firmware_boot_external_string
                                call firmware_crt_string_out 
                                jmp bootloader_load_address

firmware_serial_disk_error:         lxi h,firmware_serial_error_string
                                    call firmware_crt_string_out
                                    jmp firmware_internal_boot
firmware_serial_disk_not_bootable:  lxi h,firmware_serial_disk_not_bootable_string
                                    call firmware_crt_string_out 
                                    jmp firmware_internal_boot
firmware_serial_disk_not_found:     lxi h,firmware_serial_disk_not_valid_string 
                                    call firmware_crt_string_out
firmware_internal_boot:             lxi h,firmware_starting_internal_string
                                    call firmware_crt_string_out 
                                    lxi h,2000
                                    call time_delay
                                    jmp hex_editor_start


;system_transfer_and_boot moves data loaded by the bootloader form a specific location to a specific destination and loads the OS from the destination address
;BC -> bytes number
;DE -> source address
;HL -> destination address

system_transfer_and_boot:           push h 
system_transfer_and_boot_loop:      mov a,c 
                                    ora b 
                                    jz system_transfer_and_boot_start
                                    ldax d 
                                    mov m,a 
                                    inx d 
                                    inx h 
                                    dcx b 
                                    jmp system_transfer_and_boot_loop
system_transfer_and_boot_start:     pop h 
                                    pchl 

;-------- interface functions for serial drivers --------

firmware_serial_disk_status:        call serial_request_disk_information
                                    jc firmware_serial_disk_status_end
                                    call serial_reset_connection
                                    jmp firmware_serial_disk_status
firmware_serial_disk_status_end:    mov a,b 
                                    pop b 
                                    pop d 
                                    pop h 
                                    ret 

firmware_serial_disk_read_sector:       push b 
                                        push d 
                                        push h 
                                        call serial_request_disk_sector
                                        jc firmware_serial_disk_read_sector_end
                                        call serial_reset_connection
                                        pop h 
                                        pop d 
                                        pop b 
                                        jmp firmware_serial_disk_read_sector
firmware_serial_disk_read_sector_end:   inx sp 
                                        inx sp 
                                        pop d 
                                        pop b 
                                        ret 

firmware_serial_disk_write_sector:      push b 
                                        push d 
                                        push h 
                                        call serial_write_disk_sector
                                        jc firmware_serial_disk_write_sector_end
                                        call serial_reset_connection
                                        pop h 
                                        pop d 
                                        pop b 
                                        jmp firmware_serial_disk_write_sector
firmware_serial_disk_write_sector_end:  inx sp 
                                        inx sp 
                                        pop d 
                                        pop b 
                                        ret 

firmware_serial_request_terminal_char:      call serial_request_terminal_char
                                            rc 
                                            call serial_reset_connection
                                            jmp firmware_serial_request_terminal_char

firmware_serial_send_terminal_char:         call serial_send_terminal_char
                                            rc 
                                            call serial_reset_connection 
                                            jmp firmware_serial_send_terminal_char

;firmware_crt_string_out prints a string on the onboard crt controller
;HL -> address of the string

firmware_crt_string_out:            push h 
                                    push d 
firmware_crt_string_out_loop:       mov a,m 
                                    ora a 
                                    jz firmware_crt_string_out_end
                                    ani crt_output_byte_type_mode_mask
                                    cpi crt_output_byte_mode_special
                                    jnz firmware_crt_string_out_loop_char
                                    xchg 
                                    call crt_get_display_pointer
                                    mov a,m 
                                    call crt_byte_out
                                    inx h 
                                    call crt_set_display_pointer
                                    xchg 
                                    inx h 
                                    jmp firmware_crt_string_out_loop
firmware_crt_string_out_loop_char:  mov a,m 
                                    call crt_char_out 
                                    inx h 
                                    jmp firmware_crt_string_out_loop
firmware_crt_string_out_end:        pop d 
                                    pop h 
                                    ret 

firmware_boot_string:           .b %10000001, %10000011, %10000001, %10000001, %10000000, %10000000, %10000011, %10000000, %10000010, %10000001, %10000010, %10000000, %10000011, $80, $80, $80 
                                .b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
                                .b %10010101, %10001100, %10010001, %10011001, %10000100, %10001000, %10101110, %10100010, %10101010, %10101010, %10010101, %10010000, %10001101, $80, $80, $80 
                                .b $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80, $80
                                .b %10010000, %10000000, %10010000, %10010000, %10000000, %10000000, %10110000, %10000000, %10100000, %10010000, %10100000, %10010000, %10100000, $80, $80, $80
                                .b $0a, $0d, 0

                                .text "Starting serial port service...."
                                .b $0a, $0d, 0

firmware_boot_external_string:  .text "Done :-)"
                                .b 0


firmware_serial_error_string:               .text "Error reading first sector"
                                            .b $0a, $0d, 0
firmware_serial_disk_not_valid_string:      .text "Boot disk not found"
                                            .b $0a, $0d, 0
firmware_serial_disk_not_bootable_string:   .text "Disk not bootable"
                                            .b $0a, $0d, 0


firmware_boot_internal_string:      .text "Serial service not available."
                                    .b $0a, $0d
firmware_starting_internal_string:  .b $0a, $0d 
                                    .text "Starting firmware...."
                                    .b 0

boot_disk_format_string:        .text "SFS1.0"

firmware_end:

.print "Space left in firmware memory ->",firmware_dimension-(firmware_end-firmware_functions) 
.memory "fill", firmware_end, firmware_dimension-(firmware_end-firmware_functions),$00
.print "Firmware load address ->",firmware_functions
.print "VRAM start address ->", vram_memory_space_address
.print "Used RAM start address ->", stack_pointer
.print "All functions built successfully"