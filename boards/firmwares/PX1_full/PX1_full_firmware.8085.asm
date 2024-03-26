firmware_start_address      .equ $8000
stack_pointer               .equ $7fb7
bootloader_load_address     .equ $0020

firmware_functions:     .org firmware_start_address 
                        jmp firmware_boot 
                        jmp firmware_serial_connect 
                        jmp firmware_send_char 
                        jmp firmware_request_char 
                        jmp firmware_disk_information
                        jmp firmware_disk_read_sector 
                        jmp firmware_disk_write_sector 
                        jmp system_transfer_and_boot 


firmware_boot:          lxi sp,stack_pointer 


.include "PX1_full_serial_drivers.8085.asm"
.include "PX1_full_drivers.8085.asm"
.include "PX1_full_firmware_shell.8085.asm"