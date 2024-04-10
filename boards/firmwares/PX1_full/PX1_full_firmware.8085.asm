firmware_start_address              .equ $8000
firmware_dimension                  .equ 32768
bootloader_load_address     .equ $0020

firmware_functions:     .org firmware_start_address 
                        jmp firmware_boot 
                        jmp firmware_send_char 
                        jmp firmware_request_char 
                        jmp firmware_disk_information
                        jmp firmware_disk_read_sector 
                        jmp firmware_disk_write_sector 
                        jmp system_transfer_and_boot 

vram_memory_space_address           .equ firmware_start_address-512
drivers_memory_space_base_address   .equ vram_memory_space_address-16
serial_memory_space_base_address    .equ drivers_memory_space_base_address-42
stack_pointer                       .equ serial_memory_space_base_address-1

.include "PX1_full_serial_drivers.8085.asm"
.include "PX1_full_drivers.8085.asm"
;.include "PX1_full_firmware_program.8085.asm"

;tvalue=(fvalue-31)/14
time_delay_value    .equ 140


firmware_boot:          lxi sp,stack_pointer 
                        ;call dma_reset 
                        call crt_display_reset 
                        call crt_show_cursor 
firmware_loop:          call keyb_status 
                        ora a 
                        jz firmware_loop
                        call keyb_read
                        call crt_char_out 
                        lxi h,100
                        call time_delay 
                        jmp firmware_loop

;time_delay generates a custom delay
;HL -> delay millis
time_delay:         push h                  ;12
time_delay_millis:  mvi a,time_delay_value  ;7
time_delay_loop:    dcr a                   ;4
                    jnz time_delay_loop     ;10
                    dcx h                   ;6
                    mov a,l                 ;4
                    ora h                   ;4
                    jnz time_delay_millis   ;10
time_delay_end:     pop h                   ;10
                    ret                     ;10



firmware_send_char:     ret 
firmware_request_char:  ret 
firmware_disk_information:  ret 
firmware_disk_read_sector:  ret 
firmware_disk_write_sector: ret 
system_transfer_and_boot:   ret 

firmware_end:
.print "Space left in firmware memory ->",firmware_dimension-(firmware_end-firmware_functions) 
.memory "fill", firmware_end, firmware_dimension-(firmware_end-firmware_functions),$00
.print "Firmware load address ->",firmware_functions
.print "VRAM start address ->", vram_memory_space_address
.print "All functions built successfully"