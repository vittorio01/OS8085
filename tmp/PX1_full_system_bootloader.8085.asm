start_address               .equ $0020
disk_information_address    .equ $0000

firmware_functions                      .equ $8000
firmware_boot                           .equ firmware_functions+3
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

disk_sector_dimension     .equ 512
disk_sector_per_track     .equ 18
disk_track_per_head       .equ 80
disk_heads_number         .equ 2

disk_system_sector_first  .equ 1
disk_system_track_first   .equ 0
disk_system_head_first    .equ 0

disk_system_sector_last   .equ 8
disk_system_track_last    .equ 2
disk_system_head_last     .equ 0       

system_dimension          .equ 22016

disk_boot_address           .equ $0000
end_address                 .equ $0100

disk_informations:          .org disk_information_address
                            .text "SFS1.0"
                            .b %11000000
                            .w disk_boot_address
                            .w 2880
                            .w 0
                            
                            .b 2
                            .b 3
                            .w 1415
                            .w 44

boot:                       .org start_address
start:                      call firmware_serial_send_terminal_char 
                            lxi h,boot_message
                            call text_out
                            lxi d,disk_system_track_first
                            mvi b,disk_system_head_first
                            mvi c,disk_system_sector_first
                            lxi h,end_address
boot_disk_load_increment:   push b
                            mvi c,"."
                            call firmware_serial_send_terminal_char
                            pop b 
                            call firmware_serial_disk_read_sector
                            inr c 
                            mov a,c 
                            cpi disk_sector_per_track 
                            jc boot_disk_verify
                            mvi c,0 
                            inx d
                            push h 
                            lxi h,disk_track_per_head
                            mov a,e  
                            sub l 
                            mov a,d 
                            sbb h 
                            pop h  
                            jc boot_disk_verify
                            inr b
                            lxi h,0
boot_disk_verify:           push h
                            lxi h,disk_system_track_last 
                            mov a,e 
                            sub l 
                            mov l,a 
                            mov a,h 
                            sbb h 
                            ora l 
                            mov l,a 
                            mov a,c 
                            sui disk_system_sector_last
                            ora l 
                            mov l,a 
                            mov a,b 
                            sui disk_system_head_last
                            ora l 
                            pop h 
                            jnz boot_disk_load_increment
boot_disk_load_end:         lxi h,boot_message2
                            call text_out
                            lxi b,system_dimension 
                            lxi d,end_address
                            lxi h,disk_boot_address
                            jmp system_transfer_and_boot

text_out:			push psw		
text_out_1:			mov a,m			
					cpi 0
					jz text_out_2
					call firmware_serial_send_terminal_char
					inx h
					jmp text_out_1
text_out_2:			pop psw
					ret

boot_message:       .b $0a,$0d
                    .text "Loading OS "
                    .b $0d,$0a,$00

boot_message2:      .b $0a, $0d
                    .text "Done"
                    .b $0a, $0d ,$0a,$0d,$00

bootloader_end:

.print "Space left in bootloader sector ->",disk_sector_dimension-(bootloader_end-disk_information_address) 
.memory "fill", bootloader_end, disk_sector_dimension-(bootloader_end-disk_information_address) ,$00
.print "Bootloader load address -> ",disk_information_address
.print "Bootloader start address -> ", start_address
.print "All functions built successfully"