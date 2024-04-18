
stack_pointer               .equ $7fb7
start_address               .equ $0020
disk_information_address    .equ $0000

firmware_functions          .equ $8000
firmware_boot               .equ firmware_functions
firmware_serial_connect     .equ firmware_boot+3
firmware_send_char          .equ firmware_serial_connect+3
firmware_request_char       .equ firmware_send_char+3
firmware_disk_information   .equ firmware_request_char+3
firmware_disk_read_sector   .equ firmware_disk_information+3
firmware_disk_write_sector  .equ firmware_disk_read_sector+3
system_transfer_and_boot    .equ firmware_disk_write_sector+3

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
start:                      lxi sp,stack_pointer
                            mvi c,$0d 
                            call char_out 
                            lxi h,boot_message
                            call text_out
                            lxi d,disk_system_track_first
                            mvi b,disk_system_head_first
                            mvi c,disk_system_sector_first
                            lxi h,end_address
boot_disk_load_increment:   push b
                            mvi c,"."
                            call char_out
                            pop b 
                            call firmware_disk_read_sector
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
					call firmware_send_char
					inx h
					jmp text_out_1
text_out_2:			pop psw
					ret

boot_message:       .text "Starting OS "
                    .b $0d,$0a,$00

boot_message2:      .b $0a, $0d
                    .text "Done"
                    .b $0a, $0d ,$0a,$0d,$00