
debug_mode          .var false

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
.include "PX1_full_firmware_program.8085.asm"


firmware_boot:          lxi sp,stack_pointer 
                        jmp hex_editor_start


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