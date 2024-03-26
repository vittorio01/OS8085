;This file contains all functions that implements Retro Commander protocol. All code is written in 8085 assembly but can be used also for INTEL 8080 and Z80 platforms.
;The source code is based on retro-assembler compiler. To compile this file download and use this program (https://enginedesigns.net/retroassembler/)

; -------- Packet structure ---------

;- 0xAA - header - command - checksum - data (may be obmitted) - 0xf0 - 

; command ->    a byte which identifies the action that the slave must execute 
; header  ->    bit 7 -> ACK
;               bit 6 -> COUNT 
;               bit 5 -> type (fast or slow)
;               from bit 4 to bit 0 -> data dimension (max 32 bytes)
; checksum ->   used for checking errors. It's a simple 8bit truncated sum of all bytes of the packet (also header,command,start and stop bytes) 

; -------- Variables --------
;All variables al related of main packet/protocol structure. Most of all variables don't need to be changed.

serial_packet_start_packet_byte         .equ $AA 
serial_packet_stop_packet_byte          .equ $f0 

serial_packet_acknowledge_bit_mask      .equ %10000000
serial_packet_count_bit_mask            .equ %01000000
serial_packet_type_mask                 .equ %00100000
serial_packet_dimension_mask            .equ %00011111

serial_packet_resend_attempts           .equ 5

serial_wait_timeout_value_short:       .equ 750         
serial_wait_timeout_value_long:        .equ 2500


serial_command_reset_connection_byte    .equ $21
serial_command_send_identifier_byte     .equ $22

serial_command_send_terminal_char_byte          .equ $01
serial_command_request_terminal_char_byte       .equ $02

serial_command_request_disk_information         .equ $11
serial_command_read_sector_request              .equ $12
serial_command_write_sector_request             .equ $13

serial_packet_max_dimension             .equ 31
serial_disk_packet_dimension            .equ 16

debug_mode      .var  false

terminal_input_char_queue_dimension             .equ 32

serial_packet_line_state          .equ %10000000
serial_packet_connection_reset    .equ %01000000

;serial delai value is a costant used for generating delays in wait functions. In base of the CPU clock this value should be modified with this formula:
;delay_value = (clk-31)/74      where clk is specified in KHz

serial_delay_value                      .equ 16

;device_boardId is the string that will be sent to the slave device to identify the master. This string can be replaced with a custom board ID
device_boardId          .text   "GENERAL DEVICE"                        
device_boardId_dimension .equ 14    ;dimension of the string

; ------ memory addresses ------
;This implementation uses also a portion of memory to save important informations. 
;To manage terminal chars received from the slave, a small array queue is used  

;To change the posizion of this memory space the variable memory_space_base_address can be modified.
memory_space_base_address                       .equ $0000
;this variable indicates the first address that can be used to save data. 
;The final memory region used will be from memory_space_base_address to memory_space_base_address+42

serial_packet_state                             .equ    memory_space_base_address
serial_packet_disk_bps                          .equ    serial_packet_state+1
serial_packet_disk_spt                          .equ    serial_packet_disk_bps+1
serial_packet_disk_tph                          .equ    serial_packet_disk_spt+1
serial_packet_disk_heads_number                 .equ    serial_packet_disk_tph+2
serial_packet_timeout_current_value             .equ    serial_packet_disk_heads_number+1

terminal_input_char_queue_start_address         .equ serial_packet_timeout_current_value+2
terminal_input_char_queue_end_address           .equ terminal_input_char_queue_start_address+2
terminal_input_char_queue_number                .equ terminal_input_char_queue_end_address+2

terminal_input_char_queue_fixed_space_address   .equ terminal_input_char_queue_number+1

; -------- Function addresses --------

function_addresses:             jmp serial_reset_connection         ;this function creates a new connection with the slave
                                jmp serial_send_terminal_char       ;this function sends a single char to the slave's terminal
                                jmp serial_request_terminal_char    ;this function requests a char from the slave's terminal
                                jmp serial_request_disk_information ;this function requests all disk informations
                                jmp serial_request_disk_sector      ;this function requests a single disk sector from the slave
                                jmp serial_write_disk_sector        ;this function sensd a single disk sector to the slave


; -------- primary functions implementation --------

;serial_reset_connection sends an open request to the slave and send the board ID

serial_reset_connection:        push b
                                push d 
                                push h 
                                call serial_line_initialize
serial_reset_connection_retry:  mvi b,serial_command_reset_connection_byte  
                                mvi c,0
                                xra a 
                                stc 
                                call serial_send_packet
                                jnc serial_reset_connection_retry
                                lda serial_packet_state 
                                ori serial_packet_connection_reset 
                                sta serial_packet_state
serial_send_boardId:            mvi b,serial_command_send_identifier_byte
                                lxi h,device_boardId
                                mvi c,device_boardId_dimension 
                                xra a 
                                stc
                                call serial_send_packet
                                jnc serial_send_boardId
serial_reset_connection_end:    pop h 
                                pop d 
                                pop b
                                ret 

;serial_send_terminal_char sends a terminal char to the slave 
;A -> char to send 

serial_send_terminal_char:              push h 
                                        push b 
                                        lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp 
                                        mov m,a 
                                        mvi b,serial_command_send_terminal_char_byte
                                        mvi c,1
serial_send_terminal_char_retry:        xra a 
                                        stc 
                                        
                                        call serial_send_packet
serial_send_terminal_char_end:          pop b 
                                        pop h 
                                        ret 

;serial_request_terminal_char requests a char from the slave terminal
;A <- char received 

serial_request_terminal_char:               push h 
                                            push b 
                                            push d
                                            call serial_buffer_remove_byte
                                            jc serial_request_terminal_char_end
serial_request_terminal_char_retry:         mvi c,0 
                                            mvi b,serial_command_request_terminal_char_byte
                                            stc 
                                            cmc 
                                            call serial_send_packet
                                            jnc serial_request_terminal_char_retry 
                                            mvi a,$ff
                                            call serial_set_new_timeout
                                            lxi h,$ffff-serial_packet_max_dimension+1
                                            dad sp 
                                            stc
                                            call serial_get_packet
                                            jnc serial_request_terminal_char_retry
                                            mov a,b 
                                            cpi serial_command_request_terminal_char_byte
                                            jnz serial_request_terminal_char_retry
                                            mov a,c 
                                            ora a 
                                            jz serial_request_terminal_char_retry
                                            mov a,m 
                                            dcr c 
                                            jz serial_request_terminal_char_end
                                            mov b,a 
                                            inx h 
serial_request_terminal_char_store_chars:   mov a,m 
                                            call serial_buffer_add_byte
                                            ora a 
                                            jz serial_request_terminal_char_received
                                            inx h 
                                            dcr c 
                                            jnz serial_request_terminal_char_store_chars
serial_request_terminal_char_received:      mov a,b
serial_request_terminal_char_end:           pop d 
                                            pop b 
                                            pop h 
                                            ret 

;serial_request_disk_information returns the current status of disk emulator
; B <- Disk state 
; C <- bytes per sector
; D <- sectors per track
; E <- heads number
; HL <- tracks per head

;Cy <- 1 if data have been received successfully, 0 otherwise

serial_request_disk_information:        mvi c,0 
                                        mvi b,serial_command_request_disk_information
                                        xra a 
                                        stc 
                                        call serial_send_packet
                                        jnc serial_request_disk_information
serial_request_disk_information_wait:   lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp
                                        mvi a,$ff 
                                        call serial_set_new_timeout
                                        stc 
                                        call serial_get_packet
                                        rnc
                                        mov a,b 
                                        cpi serial_command_request_disk_information
                                        jz serial_request_disk_information_update
                                        stc 
                                        cmc 
                                        ret 
serial_request_disk_information_update: mov b,m 
                                        inx h 
                                        mov c,m 
                                        inx h 
                                        mov d,m 
                                        push h 
                                        mov h,m 
                                        xthl 
                                        inx h 
                                        mov a,m 
                                        xthl 
                                        mov l,a 
                                        xthl 
                                        inx h 
                                        mov a,m 
                                        xthl 
                                        mov e,m 
                                        inx sp 
                                        inx sp 
                                        mov a,c 
                                        sta serial_packet_disk_bps
                                        mov a,d 
                                        sta serial_packet_disk_spt
                                        mov a,e 
                                        sta serial_packet_disk_heads_number
                                        shld serial_packet_disk_tph 
                                        stc 
                                        ret 

;serial_request_disk_sector sends a packet to the slave to request a sector read. Next, the function will verify that all packet will be received correctly
;B -> head number
;C -> sector number
;DE -> track number
;HL -> address for data location

;Cy <- 1 if the sector has been receiving correctly, 0 otherwise
;HL <- address incremented

serial_request_disk_sector:             push d 
                                        push b 
                                        push h 
serial_request_disk_sector_retry:       lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp 
                                        mov m,c 
                                        inx h 
                                        mov m,e 
                                        inx h 
                                        mov m,d 
                                        inx h 
                                        mov m,b
                                        lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp  
                                        mvi c,4 
                                        mvi b,serial_command_read_sector_request
                                        xra a 
                                        stc 
                                        call serial_send_packet
                                        jnc serial_request_disk_sector_failure
                                        lda serial_packet_disk_bps
                                        mvi e,0 
                                        stc 
                                        cmc 
                                        rar
                                        mov d,a 
                                        jnc serial_request_disk_sector_byte_skip
                                        mvi e,%10000000
serial_request_disk_sector_byte_skip:   pop h 
serial_request_disk_sector_loop:        mvi a,$ff 
                                        call serial_set_new_timeout
                                        stc 
                                        call serial_get_packet
                                        jnc serial_request_disk_sector_loop_fail
                                        mov a,b
                                        cpi serial_command_read_sector_request
                                        jnz serial_request_disk_sector_loop_fail
                                        mov a,c
                                        ora a 
                                        jz serial_request_disk_sector_loop_fail
                                        mov a,l 
                                        add c 
                                        mov l,a 
                                        mov a,h 
                                        aci 0 
                                        mov h,a 
                                        mov a,e 
                                        sub c 
                                        mov e,a 
                                        mov a,d 
                                        sbi 0
                                        mov d,a 
                                        jc serial_request_disk_sector_loop_end 
                                        ora e 
                                        jz serial_request_disk_sector_loop_end 
                                        jmp serial_request_disk_sector_loop
serial_request_disk_sector_loop_fail:   stc 
                                        cmc 
                                        jmp serial_request_disk_sector_end
serial_request_disk_sector_loop_end:    stc 
                                        jmp serial_request_disk_sector_end
serial_request_disk_sector_failure:     stc 
                                        cmc 
                                        pop h 
serial_request_disk_sector_end:         pop b 
                                        pop d 
                                        ret 

;serial_write_disk_sector sends a packet to the slave to write a sector read. Next, the function will verify that all packet will be received correctly
;B -> head number
;C -> sector number
;DE -> track number
;HL -> address for data location

;Cy <- 1 if the sector has been writing correctly, 0 otherwise
;HL <- address incremented

serial_write_disk_sector:               push d 
                                        push b 
                                        push h 
serial_write_disk_sector_retry:         lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp 
                                        mov m,c 
                                        inx h 
                                        mov m,e 
                                        inx h 
                                        mov m,d 
                                        inx h 
                                        mov m,b 
                                        lxi h,$ffff-serial_packet_max_dimension+1
                                        dad sp 
                                        mvi c,4 
                                        mvi b,serial_command_write_sector_request
                                        xra a 
                                        stc 
                                        call serial_send_packet
                                        jnc serial_write_disk_sector_failure
                                        lda serial_packet_disk_bps
                                        mvi e,0 
                                        stc 
                                        cmc 
                                        rar
                                        mov d,a 
                                        jnc serial_write_disk_sector_byte_skip
                                        mvi e,%10000000
serial_write_disk_sector_byte_skip:     pop h 
serial_write_disk_sector_loop:          mov a,d 
                                        ora e 
                                        jz serial_write_disk_sector_loop_end 
                                        mvi c,serial_disk_packet_dimension
                                        mov a,d 
                                        ora a 
                                        jnz serial_write_disk_sector_loop2
                                        mov a,e
                                        cpi serial_disk_packet_dimension
                                        jnc serial_write_disk_sector_loop2
                                        mov c,e
serial_write_disk_sector_loop2:         mov a,e
                                        sub c 
                                        mov e,a 
                                        mov a,d 
                                        sbi 0
                                        mov d,a 
                                        mvi b,serial_command_write_sector_request
                                        xra a 
                                        stc 
                                        call serial_send_packet
                                        jnc serial_write_disk_sector_end
                                        mov a,l 
                                        add c 
                                        mov l,a 
                                        mov a,h 
                                        aci 0 
                                        mov h,a 
                                        jmp serial_write_disk_sector_loop 
serial_write_disk_sector_loop_end:      stc 
                                        jmp serial_write_disk_sector_end
serial_write_disk_sector_failure:       stc 
                                        cmc 
                                        pop h 
serial_write_disk_sector_end:           pop b 
                                        pop d 
                                        ret

;-------- secondary functions implementation --------

;serial_line_initialize resets all serial packet support system 

serial_line_initialize:     push h
                            call serial_buffer_initialize
                            call serial_configure
                            xra a  
                            sta serial_packet_state 
                            call serial_set_new_timeout
                            pop h 
                            ret 

;serial_buffer_initialize creates variables and space necessary for initialize a circular array.

serial_buffer_initialize:       push h 
                                lxi h,terminal_input_char_queue_fixed_space_address
                                shld terminal_input_char_queue_start_address
                                shld terminal_input_char_queue_end_address 
                                xra a 
                                sta terminal_input_char_queue_number
                                pop h 
                                ret 

;serial_buffer_add_byte adds the specified value in the circular array
;A -> data to insert
;A <- $ff if data is stored correctly, $00 if the array is full

serial_buffer_add_byte:         push b 
                                push d 
                                push h 
                                mov b,a 
                                lda terminal_input_char_queue_number
                                cpi terminal_input_char_queue_dimension
                                jnz serial_buffer_add_byte_next
                                xra a 
                                jz serial_buffer_add_byte_end
serial_buffer_add_byte_next:    inr a 
                                sta terminal_input_char_queue_number
                                lhld terminal_input_char_queue_end_address
                                mov m,b 
                                lxi d,terminal_input_char_queue_fixed_space_address+terminal_input_char_queue_dimension
                                inx h 
                                mov a,l  
                                sub e 
                                mov a,h 
                                sbb d 
                                jc serial_buffer_add_byte_store
                                lxi h,terminal_input_char_queue_fixed_space_address
serial_buffer_add_byte_store:   shld terminal_input_char_queue_end_address
                                mvi a,$ff
serial_buffer_add_byte_end:     pop h 
                                pop d 
                                pop b 
                                ret 

;serial_buffer_remove_byte removes a single byte from the array
;A <- byte to remove
;Cy <= 0 if the array is empty, 1 otherwise

serial_buffer_remove_byte:          push h 
                                    push d 
                                    push b 
                                    lda terminal_input_char_queue_number
                                    ora a 
                                    jnz serial_buffer_remove_byte_next
                                    xra a 
                                    stc 
                                    cmc 
                                    jmp serial_buffer_remove_byte_end
serial_buffer_remove_byte_next:     dcr a 
                                    sta terminal_input_char_queue_number
                                    lhld terminal_input_char_queue_start_address
                                    mov b,m 
                                    lxi d,terminal_input_char_queue_fixed_space_address+terminal_input_char_queue_dimension
                                    inx h 
                                    mov a,l  
                                    sub e 
                                    mov a,h 
                                    sbb d 
                                    jc serial_buffer_remove_byte_store
                                    lxi h,terminal_input_char_queue_fixed_space_address
serial_buffer_remove_byte_store:    shld terminal_input_char_queue_start_address
                                    mov a,b 
                                    stc 
serial_buffer_remove_byte_end:      pop b 
                                    pop d 
                                    pop h 
                                    ret 

;serial_get_packet read a packet from the serial line, do the checksum and send an ACK to the serial port if it's valid.

;CY -> 0 if the packet has to be waited, 1 if a preliminar timeout is needed
;HL -> buffer address

;A <- $ff if the packet is an ACK, $00 otherwise
;C <- data dimension
;B <- command

serial_get_packet:              push d 
                                push psw 
                                push h 
                                call serial_set_rts_on
serial_get_packet_retry:        pop h 
                                pop psw 
                                push psw 
                                push h 
                                jnc serial_get_packet_wait
serial_get_packet_wait_timeout: call serial_wait_timeout_new_byte
                                jc serial_get_packet_begin
                                lxi b,0 
                                xra a 
                                stc 
                                cmc 
                                jmp serial_get_packet_end
serial_get_packet_wait:         call serial_wait_new_byte
serial_get_packet_begin:        cpi serial_packet_start_packet_byte
                                jnz serial_get_packet_retry
                                xra a 
                                call serial_set_new_timeout
                                call serial_wait_timeout_new_byte
                                jnc serial_get_packet_retry
                                mov e,a                                 ;E <- header 
                                call serial_wait_timeout_new_byte       
                                jnc serial_get_packet_retry     
                                mov b,a                                 ;B <- command
                                call serial_wait_timeout_new_byte 
                                jnc serial_get_packet_retry
                                mov d,a                                 ;D <- checksum

                                mov a,e 
                                ani serial_packet_dimension_mask   
                                jz serial_get_packet_stop_byte           
                                mov c,a                                       
serial_get_packet_bytes_loop:   call serial_wait_timeout_new_byte
                                jnc serial_get_packet_retry
                                mov m,a 
                                inx h 
                                dcr c 
                                jnz serial_get_packet_bytes_loop
serial_get_packet_stop_byte:    call serial_wait_timeout_new_byte
                                jnc serial_get_packet_retry
                                cpi serial_packet_stop_packet_byte
                                jnz serial_get_packet_retry
                                mov a,e 
                                ani serial_packet_dimension_mask 
                                mov c,a 
                                pop h 
                                push h 
                                push b 
                                mvi b,0
                                mov a,c 
                                ora a 
                                jz serial_get_packet_check_end 
serial_get_packet_check_loop:   mov a,m 
                                add b 
                                mov b,a 
                                inx h 
                                dcr c 
                                jnz serial_get_packet_check_loop
serial_get_packet_check_end:    pop psw 
                                mov c,a 
                                add b 
                                add e 
                                adi serial_packet_start_packet_byte
                                adi serial_packet_stop_packet_byte
                                cmp d 
                                jnz serial_get_packet_retry
serial_get_packet_received:     mov b,c
                                mov a,e 
                                ani serial_packet_acknowledge_bit_mask
                                jnz serial_get_packet_count_check
                                mov a,e 
                                ani serial_packet_type_mask
                                jz serial_get_packet_count_check
                                push b 
                                mvi b,0 
                                mvi c,0 
                                mvi a,$ff 
                                call serial_send_packet
                                pop b  
serial_get_packet_count_check:  lda serial_packet_state
                                ani serial_packet_line_state  
                                jz serial_get_packet_count_check2
                                mov a,e 
                                ani serial_packet_count_bit_mask
                                jz serial_get_packet_retry
                                mov a,e 
                                ani serial_packet_acknowledge_bit_mask
                                jnz serial_get_packet_acknowledge
                                jmp serial_get_packet_count_switch
serial_get_packet_count_check2: mov a,e 
                                ani serial_packet_count_bit_mask
                                jnz serial_get_packet_retry
                                mov a,e 
                                ani serial_packet_acknowledge_bit_mask
                                jnz serial_get_packet_acknowledge
serial_get_packet_count_switch: lda serial_packet_state
                                xri $ff 
                                ani serial_packet_line_state
                                mov d,a 
                                lda serial_packet_state 
                                ani $ff - serial_packet_line_state
                                ora d 
                                sta serial_packet_state 
serial_get_packet_acknowledge:  mov a,e 
                                ani serial_packet_dimension_mask
                                mov c,a 
								mov a,e
                                ani serial_packet_acknowledge_bit_mask
                                stc 
                                jz serial_get_packet_end
                                mvi a,$ff 
serial_get_packet_end:          pop h 
                                inx sp 
                                inx sp 
                                pop d 
                                call serial_set_rts_off
                                ret 



;serial_send_packet sends a packet to the serial line
;A -> $FF if the packet is ACK, $00 otherwise
;C -> packet dimension
;B -> command
;HL -> address to data 
;Cy -> slow packet

;Cy <- 1 packet transmitted successfully, 0 otherwise


serial_send_packet:             push d 
                                push b 
                                push h 
                                push psw
                                mov a,c 
                                ani serial_packet_dimension_mask
                                mov c,a  
                                pop psw 
                                push psw 
                                jnc serial_send_packet_init_skip
                                mov a,c 
                                ori serial_packet_type_mask
                                mov c,a 
serial_send_packet_init_skip:   pop psw 
                                ora a 
                                jz serial_send_packet_init
                                mov a,c 
                                ori serial_packet_acknowledge_bit_mask+serial_packet_type_mask
                                mov c,a 
serial_send_packet_init:        lda serial_packet_state 
                                ani serial_packet_line_state 
                                jz serial_send_packet2
                                mov a,c 
                                ori serial_packet_count_bit_mask
                                mov c,a 
serial_send_packet2:            mvi e,0
                                mvi b,serial_packet_resend_attempts     ;d -> dimension 
                                mov a,c 
                                ani serial_packet_dimension_mask        ;c -> header
                                mov d,a                                 ;b -> attempts
                                jz serial_send_packet_checksum2         ;e -> checksum
serial_send_packet_checksum:    mov a,m 
                                add e 
                                mov e,a 
                                inx h 
                                dcr d 
                                jnz serial_send_packet_checksum
serial_send_packet_checksum2:   mov a,e 
                                add c 
                                inx sp 
                                inx sp 
                                xthl 
                                add h 
                                xthl 
                                dcx sp 
                                dcx sp 
                                adi serial_packet_start_packet_byte
                                adi serial_packet_stop_packet_byte
                                mov e,a 
serial_send_packet_start_send:  mov a,c 
                                ani serial_packet_dimension_mask        
                                mov d,a 
                                pop h 
                                push h 
                                mvi a,serial_packet_start_packet_byte
                                call serial_send_new_byte
                                mov a,c 
                                call serial_send_new_byte 
                                inx sp 
                                inx sp 
                                xthl 
                                mov a,h 
                                xthl 
                                dcx sp 
                                dcx sp 
                                call serial_send_new_byte
                                mov a,e 
                                call serial_send_new_byte
                                mov a,d 
                                ora a 
                                jz serial_send_packet_send_stop
serial_send_packet_data:        mov a,m 
                                call serial_send_new_byte
                                inx h 
                                dcr d
                                jnz serial_send_packet_data
serial_send_packet_send_stop:   mvi a,serial_packet_stop_packet_byte
                                call serial_send_new_byte
                                mov a,c 
                                ani serial_packet_acknowledge_bit_mask
                                jnz serial_send_packet_end2
                                mov a,c 
                                ani serial_packet_type_mask
                                jz serial_send_packet_ok
                                push b 
                                lxi h,$ffff-serial_packet_max_dimension+1
                                dad sp 
                                stc 
                                call serial_get_packet 
                                pop b 
                                jnc serial_send_packet_send_retry
                                ora a 
                                jnz serial_send_packet_ok
serial_send_packet_send_retry:  dcr b
                                jnz serial_send_packet_start_send
                                stc 
                                cmc 
                                jmp serial_send_packet_end
serial_send_packet_ok:          lda serial_packet_state 
                                ani serial_packet_line_state 
                                jz serial_send_packet_ok2
                                lda serial_packet_state 
                                ani $ff-serial_packet_line_state 
                                sta serial_packet_state 
                                stc 
                                jmp serial_send_packet_end 
serial_send_packet_ok2:         lda serial_packet_state 
                                ori serial_packet_line_state 
                                sta serial_packet_state 
serial_send_packet_end2:        stc 
serial_send_packet_end:         pop h 
                                pop b 
                                pop d 
                                ret 

;serial_set_new_timeout sets a new value of timeout of input bytes
;A -> timeout type ($ff long, $00 short)

serial_set_new_timeout:         push h 
                                ora a 
                                jz serial_set_new_timeout_short
                                lxi h,serial_wait_timeout_value_long
                                shld serial_packet_timeout_current_value
                                pop h 
                                ret 
serial_set_new_timeout_short:   lxi h,serial_wait_timeout_value_short
                                shld serial_packet_timeout_current_value
                                pop h 
                                ret 


;serial_wait_timeout_new_byte does the same function of serial_wait_new_byte can't be read in the timeout 
; Cy <- setted if the function returns a valid value
; A <- byte received if Cy = 1, $00 otherwise

serial_wait_timeout_new_byte:                   push b 
                                                push h
                                                lhld serial_packet_timeout_current_value
serial_wait_Timeout_new_byte_value_reset:       mvi b,serial_delay_value                        ;7      
serial_wait_timeout_new_byte_value_check:       call serial_get_input_state                     ;17     ---
                                                ora a                                           ;4
                                                jnz serial_wait_timeout_new_byte_received       ;10
                                                dcr b                                           ;5
                                                jnz serial_wait_timeout_new_byte_value_check    ;10     --> 74
                                                dcx h                                           ;5
                                                mov a,l                                         ;5
                                                ora h                                           ;4
                                                jnz serial_wait_Timeout_new_byte_value_reset    ;10
                                                xra a
                                                stc 
                                                cmc 
                                                jmp serial_wait_timeout_new_byte_end
serial_wait_timeout_new_byte_received:          call serial_get_byte
                                                stc 
serial_wait_timeout_new_byte_end:               pop h
                                                pop b 
                                                ret 
 
;serial_wait_new_byte wait until the serial device reads a new byte and returns it's value
; A <- received byte

serial_wait_new_byte:   call serial_get_input_state
                        ora a 
                        jz serial_wait_new_byte
                        call serial_get_byte
                        ret 

;serial_send_new_byte wait until the serial device can transmit a new byte and then sends it
;A -> byte so transmit 

serial_send_new_byte:       push psw 
serial_send_new_byte_wait:  call serial_get_output_state
                            ora a 
                            jz serial_send_new_byte_wait
                            pop psw 
                            call serial_send_byte
                            ret 

;------ UART device function implementation ------
;these elementar functions are used to control the I/O UART device. In base of the device used for all communications, all functions should be modified.

;------ Variables used in this sections ------

serial_data_port        .equ %00100110
serial_command_port     .equ %00100111
serial_port_settings    .equ %01001101

serial_error_reset_bit          .equ %00010000
serial_rts_bit                  .equ %00100000
serial_receive_enable_bit       .equ %00000100
serial_transmit_enable_bit      .equ %00000001
serial_dtr_enable_bit           .equ %00000010

serial_state_input_line_mask    .equ %00000010
serial_state_output_line_mask   .equ %00000001

;------ Function implementation ------
;All comments followed by a specific function should be modified (do not touch debug_mode==false copies or .if structure)

.if (debug_mode==false)

;serial_set_rts_on enables the RTS line
serial_set_rts_on:      push psw 
                        mvi a,serial_rts_bit+serial_error_reset_bit+serial_transmit_enable_bit+serial_receive_enable_bit+serial_dtr_enable_bit
                        out serial_command_port	
                        pop psw 
                        ret 
.endif 

.if (debug_mode==true) 
serial_set_rts_on:      ret 
.endif 


.if (debug_mode==false)
;serial_set_rts_off disables the RTS line
serial_set_rts_off:     push psw
                        mvi a,serial_error_reset_bit+serial_transmit_enable_bit+serial_receive_enable_bit+serial_dtr_enable_bit
                        out serial_command_port	
                        pop psw 
                        ret 
.endif 

.if (debug_mode==true)
serial_set_rts_off:     ret
.endif 


;serial_get_input_state returns the state of the serial device input line
;A <- $ff if there is an incoming byte, $00 otherwise 
.if (debug_mode==false)
serial_get_input_state:     in serial_command_port                      ;10
                            ani serial_state_input_line_mask            ;7
                            rz                                          ;11
                            mvi a,$ff 
                            ret 
.endif 
.if (debug_mode==true)
serial_get_input_state:     mvi a,$ff
                            ret 
.endif 
;serial_get_output_state returns the state of the serial device output line 
;A <- $ff if the serial device can transmit a byte, $00 otherwise
.if (debug_mode==false)
serial_get_output_state:    in serial_command_port
                            ani serial_state_output_line_mask
                            rz 
                            mvi a,$ff 
                            ret 
.endif 
.if (debug_mode==true)
serial_get_output_state:        mvi a,$ff 
                                ret 
.endif 

;serial_configure resets the serial device and reconfigure all settings
.if (debug_mode==false)
serial_configure:   xra a 	
                    out serial_command_port		
                    out serial_command_port	
                    out serial_command_port	
                    mvi a,%01000000
                    out serial_command_port	
                    mvi a,serial_port_settings
                    out serial_command_port	
                    mvi a,serial_error_reset_bit+serial_transmit_enable_bit+serial_receive_enable_bit+serial_dtr_enable_bit
                    out serial_command_port	
                    in serial_data_port	
                    ret 
.endif 

.if (debug_mode==true) 
serial_configure:   ret 
.endif 

;serial_send_byte sends a new byte to the serial port 
;A -> byte to send
serial_send_byte:   out serial_data_port
                    ret 

;serial_get_byte get the received byte from the serial device 
;A <- byte received
serial_get_byte:    in serial_data_port
                    ret 