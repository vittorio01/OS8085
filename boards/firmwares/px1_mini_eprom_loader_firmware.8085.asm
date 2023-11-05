start_offset                    .equ    $8000
system_load_address             .equ    $0000       
system_start                    .equ    $8900
system_rom_disk_address         .equ    $8800
system_dimension                .equ    $5200

stack_pointer					.equ 	$7fdf

bios_start:     		    .org start_offset 
                            jmp bios_graphic_print

bios_graphic_print:         lxi sp,stack_pointer
load_system:                lxi h,system_load_address 
                            lxi b,system_dimension 
                            lxi d,system_start 
							call cpu_memory_transfer  
                            jmp system_load_address

cpu_memory_transfer:		mov a,c 
							ora b 
							rz
							ldax d 
							mov m,a 
							inx d 
							inx h 
							dcx b
							jmp cpu_memory_transfer

