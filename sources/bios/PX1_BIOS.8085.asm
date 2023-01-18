;Il BIOS prevede l'implementazione di una serie di funzioni a basso livello che devono adattarsi alle varie specifiche della macchina fisica. 
;Tra le funzioni disponibili troviamo:
;-  funzione di avvio del sistema
;-  funzioni per la gestione dei dispositivi I/O tra cui la console, che serve per la gestione dei dispositivi base per l'interazione con l'utente (lettura di caratteri e stampa su schermo)
;-  funzioni per la gestione delle memorie di massa, tra cui sono presenti alcune dedicate alla selezione di tracce, settori e testine e altre alla gestione del flusso dei dati, tra cui lettura
;   scrittura di una traccia e formattazione del disco
;-  funzioni per la gestione dei trasferimenti DMA memory-to-memory.
;-  handler per gli interrupt hardware 
;-  una funzione per la richiesta delle informazioni

;la prima parte del bios viene sedicara all'implementazione del sistema di mantenimento dei dispositivi. I dispositivi possono essere modificati nella sezione successiva. 

.include "os_constraints.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "environment_variables.8085.asm"

bios_selected_IO_device_initialize_address  .equ reserved_memory_start+$0000
bios_selected_IO_device_get_state_address   .equ reserved_memory_start+$0003
bios_selected_IO_device_set_state_address   .equ reserved_memory_start+$0006 
bios_selected_IO_device_write_byte_address  .equ reserved_memory_start+$0009 
bios_selected_IO_device_read_byte_address   .equ reserved_memory_start+$000C 
bios_selected_devices_flags                 .equ reserved_memory_start+$000F

bios_disk_device_selected_sector            .equ reserved_memory_start+$0010  
bios_disk_device_selected_track             .equ reserved_memory_start+$0011 
bios_disk_device_selected_head              .equ reserved_memory_start+$0013 
bios_disk_device_vector_address             .equ reserved_memory_start+$0014

bios_selected_devices_flags_IO_selected     .equ %00001000

bios_selected_devices_flags_head           .equ %10000000
bios_selected_devices_flags_track          .equ %01000000
bios_selected_devices_flags_sector         .equ %00100000

bios_functions: .org BIOS 
                jmp bios_system_start  
                jmp bios_avabile_ram_memory
                jmp bios_hardware_interrupt_handler 
                jmp bios_select_IO_device
                jmp bios_get_IO_device_informations 
                jmp bios_selected_IO_device_initialize_address
                jmp bios_selected_IO_device_get_state_address
                jmp bios_selected_IO_device_set_state_address 
                jmp bios_selected_IO_device_read_byte_address
                jmp bios_selected_IO_device_write_byte_address 
                jmp bios_disk_device_select_drive 
                jmp bios_disk_device_select_sector 
                jmp bios_disk_device_select_track 
                jmp bios_disk_device_select_head 
                jmp bios_disk_device_status
                jmp bios_disk_device_set_motor
                jmp bios_disk_device_get_bps
                jmp bios_disk_device_get_spt
                jmp bios_disk_device_get_tph 
                jmp bios_disk_device_get_head_number 
                jmp bios_disk_device_write_sector 
                jmp bios_disk_device_read_sector  
                jmp bios_disk_device_format_drive 
                jmp bios_memory_transfer
                jmp bios_memory_transfer_reverse 

 
;bios_system_start esegue un test e un reset della memoria ram e inizializza i dispositivi per la gestione della memoria di massa.

bios_system_start:      call bios_IO_device_system_initialize
                        call bios_disk_device_system_initialize
                        call dma_reset
                        ret 

;funzioni relative alla gestione della bios_device_IO_table 

bios_IO_device_system_initialize:   lxi h,bios_IO_default_handler
                                    mvi a,$c3 
                                    sta bios_selected_IO_device_initialize_address
                                    sta bios_selected_IO_device_get_state_address
                                    sta bios_selected_IO_device_set_state_address
                                    sta bios_selected_IO_device_write_byte_address
                                    sta bios_selected_IO_device_read_byte_address
                                    shld bios_selected_IO_device_initialize_address+1
                                    shld bios_selected_IO_device_get_state_address+1 
                                    shld bios_selected_IO_device_set_state_address+1
                                    shld bios_selected_IO_device_write_byte_address+1 
                                    shld bios_selected_IO_device_read_byte_address+1 
                                    lda bios_selected_devices_flags
                                    ani $ff-bios_selected_devices_flags_IO_selected 
                                    sta bios_selected_devices_flags
                                    ret 


bios_IO_default_handler:            mvi a,bios_IO_device_not_selected
                                    stc 
                                    ret 

bios_device_ID_record_dimension                 .equ 14
bios_device_IO_device_record_name_dimension     .equ 4 

bios_search_IO_device:              lxi d,bios_device_IO_table_end
                                    lxi h,bios_device_IO_table
                                    mov b,a 
                                    mvi c,bios_device_ID_record_dimension
                                    call unsigned_multiply_byte 
                                    dad b 
                                    mov a,l 
                                    sub e 
                                    mov a,h 
                                    sbb d 
                                    cmc 
                                    ret

;bios_select_IO_device viene utilizzata per selezionare il dispositivo desiderato ($00 seleziona la console)
;A -> Id del dispositivo 
;A <- esito dell'operazione 

bios_select_IO_device:              push b 
                                    push d  
                                    push h 
                                    call bios_search_IO_device
                                    jc bios_select_IO_device_error
                                    mvi a,bios_device_IO_device_record_name_dimension
                                    add l 
                                    mov l,a 
                                    mov a,h 
                                    aci 0 
                                    mov h,a 
                                    mov a,m 
                                    sta bios_selected_IO_device_initialize_address+1 
                                    inx h 
                                    mov a,m 
                                    sta bios_selected_IO_device_initialize_address+2
                                    inx h 
                                    mov a,m 
                                    sta bios_selected_IO_device_get_state_address+1
                                    inx h  
                                    mov a,m 
                                    sta bios_selected_IO_device_get_state_address+2
                                    inx h 
                                    mov a,m 
                                    sta bios_selected_IO_device_set_state_address+1
                                    inx h  
                                    mov a,m 
                                    sta bios_selected_IO_device_set_state_address+2
                                    inx h 
                                    mov a,m 
                                    sta bios_selected_IO_device_read_byte_address+1 
                                    inx h 
                                    mov a,m 
                                    sta bios_selected_IO_device_read_byte_address+2 
                                    inx h 
                                    mov a,m  
                                    sta bios_selected_IO_device_write_byte_address+1 
                                    inx h 
                                    mov a,m  
                                    sta bios_selected_IO_device_write_byte_address+2
                                    mvi a,bios_selected_devices_flags_IO_selected
                                    sta bios_selected_devices_flags
                                    mvi a,bios_operation_ok
                                    jmp bios_select_IO_device_end
bios_select_IO_device_error:        mvi a,bios_IO_device_not_found 
bios_select_IO_device_end:          pop h 
                                    pop d 
                                    pop b 
                                    ret 


;bios_get_IO_device_informations restituisce le informazioni sul dispositivo specificato. 

;A -> id del dispositivo 
;PSW <- se il dispositivo non è stato trovato assume 1
;A <- se CY = 1 restituisce un errore
;SP <- se CY = 0 restituisce i bytes che identificano il dispositivo (4 bytes)

bios_get_IO_device_informations:            push b 
                                            push d 
                                            push h 
                                            call bios_search_IO_device
                                            jnc bios_get_IO_device_informations_next 
                                            mvi a,bios_IO_device_not_found 
                                            jmp bios_get_IO_device_informations_end
bios_get_IO_device_informations_next:       push h 
                                            lxi h,0 
                                            dad sp 
                                            xchg 
                                            lxi h,$ffff-bios_device_IO_device_record_name_dimension+1 
                                            dad sp
                                            sphl  
                                            xchg 
                                            mvi b,10 
bios_get_IO_device_informations_sp_shift:   mov a,m 
                                            stax d 
                                            inx d 
                                            inx h 
                                            dcr b 
                                            jnz bios_get_IO_device_informations_sp_shift
                                            pop h 
                                            mvi b,bios_device_IO_device_record_name_dimension
bios_get_IO_device_informations_write_info: mov a,m 
                                            stax d 
                                            inx d 
                                            inx h 
                                            dcr b 
                                            jnz bios_get_IO_device_informations_write_info
                                            stc 
                                            cmc 
                                            mvi a,bios_operation_ok
bios_get_IO_device_informations_end:        pop h 
                                            pop d 
                                            pop b 
                                            ret 

bios_disk_device_device_record_dimension                .equ 17

bios_disk_device_device_record_initialize_position      .equ 0 
bios_disk_device_device_record_read_sector_position     .equ 2
bios_disk_device_device_record_write_sector_position    .equ 4
bios_disk_device_device_record_get_state_position       .equ 6
bios_disk_device_device_record_set_motor_position       .equ 8 
bios_disk_device_device_record_format_position          .equ 10
bios_disk_device_device_record_hnum_position            .equ 12
bios_disk_device_device_record_tph_position             .equ 13
bios_disk_device_device_record_spt_position             .equ 15
bios_disk_device_device_record_bps_position             .equ 16 

bios_disk_device_system_initialize:             lda bios_selected_devices_flags
                                                ani $ff-bios_selected_devices_flags_head-bios_selected_devices_flags_sector-bios_selected_devices_flags_track
                                                sta bios_selected_devices_flags
                                                xra a
                                                sta bios_disk_device_vector_address
                                                sta bios_disk_device_vector_address+1 
                                                lxi b,bios_device_disk_table
                                                lxi d,bios_device_disk_table_end 
bios_disk_device_system_initialize_disks:       mov a,c 
                                                sub e 
                                                mov a,b 
                                                sbb d 
                                                jnc bios_disk_device_system_initialize_end
                                                ldax b 
                                                mov l,a 
                                                inx b 
                                                ldax b 
                                                mov h,a 
                                                inx b 
                                                push b 
                                                push d  
                                                lxi b,bios_disk_device_system_initialize_disk_next
                                                push b 
                                                pchl 
bios_disk_device_system_initialize_disk_next:   pop d 
                                                pop b 
                                                mvi a,bios_disk_device_device_record_dimension-2 
                                                add c 
                                                mov c,a 
                                                mov a,b 
                                                aci 0 
                                                mov b,a 
                                                jmp bios_disk_device_system_initialize_disks
bios_disk_device_system_initialize_end:         ret 

bios_disk_device_select_drive:              push h 
                                            push d 
                                            push b 
                                            cpi $41 
                                            jnc bios_disk_device_select_drive_next 
bios_disk_device_Select_drive_error:        mvi a,bios_bad_argument 
                                            jmp bios_disk_device_select_drive_end
bios_disk_device_select_drive_next:         cpi $5b 
                                            jnc bios_disk_device_select_drive_error 
                                            sui $41
                                            mov b,a 
                                            mvi c,bios_disk_device_device_record_dimension
                                            lxi h,bios_device_disk_table
                                            lxi d,bios_device_disk_table_end 
                                            call unsigned_multiply_byte
                                            dad b 
                                            mov a,l 
                                            sub e 
                                            mov a,h 
                                            sbb d 
                                            jc bios_disk_device_select_drive_next2
                                            mvi a,bios_disk_device_device_not_found
                                            jmp bios_disk_device_select_drive_end
bios_disk_device_select_drive_next2:        shld bios_disk_device_vector_address
                                            lda bios_selected_devices_flags
                                            ani $ff-bios_selected_devices_flags_head-bios_selected_devices_flags_sector-bios_selected_devices_flags_track
                                            sta bios_selected_devices_flags
                                            mvi a,bios_operation_ok
bios_disk_device_select_drive_end:          pop b 
                                            pop d 
                                            pop h 
                                            ret 

;bios_disk_device_get_bps restituisce il numero di bytes per settore 

;A <- bytes per settore (codificato in multipli di 128 bytes) 
;     ritorna il codice dell'errore se non è stato selezionato un dispositivo
;PSW <- CY assume 1 se si è verificato un errore 

bios_disk_device_get_bps:       push h 
                                push d 
                                lhld bios_disk_device_vector_address
                                mov a,l 
                                ora h 
                                jnz bios_disk_device_get_bps_next 
                                mvi a,bios_disk_device_device_not_selected 
                                stc 
                                jmp bios_disk_device_get_bps_end    
bios_disk_device_get_bps_next:  lxi d,bios_disk_device_device_record_bps_position
                                dad d 
                                mov a,m 
                                stc 
                                cmc 
bios_disk_device_get_bps_end:   pop d 
                                pop h             
                                ret 

;bios_disk_device_get_spt restituisce il numero di settori per traccia (00 se il disco non è stato selezionato)
;A <- numero di settori per traccia
;     ritorna il codice dell'errore se non è stato selezionato un dispositivo
;PSW <- CY assume 1 se si è verificato un errore 
bios_disk_device_get_spt:       push h 
                                push d 
                                lhld bios_disk_device_vector_address
                                mov a,l 
                                ora h 
                                jnz bios_disk_device_get_spt_next 
                                mvi a,bios_disk_device_device_not_selected 
                                stc 
                                jmp bios_disk_device_get_spt_end    
bios_disk_device_get_spt_next:  lxi d,bios_disk_device_device_record_spt_position
                                dad d 
                                mov a,m 
                                stc 
                                cmc 
bios_disk_device_get_spt_end:   pop d 
                                pop h             
                                ret 

;bios_disk_device_get_tph restituisce il numero di tracce per testina 
;HL <- numero di settori per traccia (0000 se il disco non è stato selezionato)
;A <- ritorna il codice dell'errore se non è stato selezionato un dispositivo
;PSW <- CY assume 1 se si è verificato un errore 
bios_disk_device_get_tph:       push d 
                                lhld bios_disk_device_vector_address
                                mov a,l 
                                ora h 
                                jnz bios_disk_device_get_tph_next 
                                mvi a,bios_disk_device_device_not_selected 
                                lxi h,0 
                                stc 
                                jmp bios_disk_device_get_tph_end    
bios_disk_device_get_tph_next:  lxi d,bios_disk_device_device_record_tph_position
                                dad d 
                                mov e,m 
                                inx h 
                                mov d,m 
                                xchg 
                                stc 
                                cmc 
bios_disk_device_get_tph_end:   pop d             
                                ret 

;bios_disk_device_get_head_number restituisce il numero di testine del disco (00 se il disco non è stato selezionato)
;A <- numero di testine
;     ritorna il codice dell'errore se non è stato selezionato un dispositivo
;PSW <- CY assume 1 se si è verificato un errore 
bios_disk_device_get_head_number:       push h 
                                        push d 
                                        lhld bios_disk_device_vector_address
                                        mov a,l 
                                        ora h 
                                        jnz bios_disk_device_get_head_number_next 
                                        mvi a,bios_disk_device_device_not_selected 
                                        stc 
                                        jmp bios_disk_device_get_head_number_end    
bios_disk_device_get_head_number_next:  lxi d,bios_disk_device_device_record_hnum_position
                                        dad d 
                                        mov a,m 
                                        stc 
                                        cmc 
bios_disk_device_get_head_number_end:   pop d 
                                        pop h             
                                        ret 

;bios_disk_device_select_sector
; A -> settore da selezionare 
; A <- esito dell'operazione
bios_disk_device_select_sector:         push h
                                        push d
                                        mov e,a 
                                        lhld bios_disk_device_vector_address
                                        mov a,l 
                                        ora h 
                                        jnz bios_disk_device_select_sector_next 
                                        mvi a,bios_disk_device_device_not_selected
                                        jmp bios_disk_device_select_sector_end
bios_disk_device_select_sector_next:    mvi a,bios_disk_device_device_record_spt_position
                                        add l 
                                        mov l,a 
                                        mov a,h 
                                        adi 0 
                                        mov h,a 
                                        mov a,e 
                                        cmp m 
                                        jc bios_disk_device_select_sector_ok 
                                        mvi a,bios_disk_device_number_overflow 
                                        jmp bios_disk_device_select_sector_end 
bios_disk_device_select_sector_ok:      sta bios_disk_device_selected_sector
                                        lda bios_selected_devices_flags
                                        ori bios_selected_devices_flags_sector 
                                        sta bios_selected_devices_flags
                                        mvi a,bios_operation_ok
bios_disk_device_select_sector_end:     pop d 
                                        pop h 
                                        ret 

;bios_disk_device_select_track
; HL -> traccia da selezionare
; A <- esito dell'operazione
bios_disk_device_select_track:          push h
                                        push d
                                        xchg 
                                        lhld bios_disk_device_vector_address
                                        mov a,l 
                                        ora h 
                                        jnz bios_disk_device_select_track_next 
                                        mvi a,bios_disk_device_device_not_selected
                                        jmp bios_disk_device_select_track_end
bios_disk_device_select_track_next:     mvi a,bios_disk_device_device_record_tph_position
                                        add l 
                                        mov l,a 
                                        mov a,h 
                                        adi 0 
                                        mov h,a 
                                        mov a,e 
                                        sub l 
                                        mov a,d 
                                        sbb h 
                                        jc bios_disk_device_select_track_ok 
                                        mvi a,bios_disk_device_number_overflow 
                                        jmp bios_disk_device_select_track_end 
bios_disk_device_select_track_ok:       xchg 
                                        shld bios_disk_device_selected_track
                                        lda bios_selected_devices_flags
                                        ori bios_selected_devices_flags_track 
                                        sta bios_selected_devices_flags
                                        mvi a,bios_operation_ok
bios_disk_device_select_track_end:      pop d 
                                        pop h 
                                        ret  

;bios_disk_device_select_head
; A -> testina da selezionare
; A <- esito dell'operazione
bios_disk_device_select_head:           push h
                                        push d
                                        mov e,a 
                                        lhld bios_disk_device_vector_address
                                        mov a,l 
                                        ora h 
                                        jnz bios_disk_device_select_head_next 
                                        mvi a,bios_disk_device_device_not_selected
                                        jmp bios_disk_device_select_head_end
bios_disk_device_select_head_next:      mvi a,bios_disk_device_device_record_hnum_position
                                        add l 
                                        mov l,a 
                                        mov a,h 
                                        adi 0 
                                        mov h,a 
                                        mov a,e 
                                        cmp m 
                                        jc bios_disk_device_select_head_ok 
                                        mvi a,bios_disk_device_number_overflow 
                                        jmp bios_disk_device_select_head_end 
bios_disk_device_select_head_ok:        sta bios_disk_device_selected_head 
                                        lda bios_selected_devices_flags
                                        ori bios_selected_devices_flags_head 
                                        sta bios_selected_devices_flags
                                        mvi a,bios_operation_ok
bios_disk_device_select_head_end:       pop d 
                                        pop h 
                                        ret 


;bios_disk_device_status restituisce lo stato della memoria di massa
;PSW <- CY viene settato a 1 se si è verificto un errore 
; A <- se CY=1 restituisce l'errore, altrimenti restituisce lo stato del dispositivo 
bios_disk_device_status:            push h 
                                    push d 
                                    push b 
                                    lhld bios_disk_device_vector_address
                                    mov a,l 
                                    ora h 
                                    jnz bios_disk_device_status_next 
                                    mvi a,bios_disk_device_device_not_selected
                                    stc 
                                    jmp bios_disk_device_status_end
bios_disk_device_status_next:       lxi d,bios_disk_device_device_record_get_state_position
                                    dad d
                                    mov e,m 
                                    inx h 
                                    mov d,m 
                                    xchg 
                                    lxi d,bios_disk_device_status_ok
                                    push d 
                                    pchl  
bios_disk_device_status_ok:         stc 
                                    cmc 
bios_disk_device_status_end:        pop b 
                                    pop d 
                                    pop h 
                                    ret 

;bios_disk_device_set_motor avvia o disattiva il motore della memoria di massa 
;A -> $00 se si vuole disattivare il motore, altro per attivarlo



bios_disk_device_set_motor:         push h 
                                    push d 
                                    push b 
                                    lhld bios_disk_device_vector_address
                                    mov a,l 
                                    ora h 
                                    jnz bios_disk_device_set_motor_next 
                                    mvi a,bios_disk_device_device_not_selected
                                    jmp bios_disk_device_set_motor_end
bios_disk_device_set_motor_next:    lxi d,bios_disk_device_device_record_set_motor_position
                                    dad d
                                    mov e,m 
                                    inx h 
                                    mov d,m 
                                    xchg 
                                    lxi d,bios_disk_device_set_motor_ok
                                    push d 
                                    pchl  
bios_disk_device_set_motor_ok:      mvi a,bios_operation_ok
bios_disk_device_set_motor_end:     pop b 
                                    pop d 
                                    pop h 
                                    ret           

;Le seguenti funzioni servono per interagire con il lettore selezionato nella memoria di massa.
;-  bios_disk_device_write_sector scrive i dati nel settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo in memoria dei dati da scrivere
;-  bios_disk_device_read_sector legge i dati dal settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo della ram per indicare dove scrivere i dati ricevuti
;-  bios_disk_device_format_drive formatta l'intero disco sovrascrivendo tutti i dati e restituisce l'esito dell'operazione

;bios_disk_device_write_sector
; HL -> indirizzo in memoria 
; A <- esito dell'operazione
; HL <- indirizzo di memoria dopo l'esecuzione

bios_disk_device_write_sector:              push b 
                                            push d 
                                            push h 
                                            lhld bios_disk_device_vector_address
                                            mov a,l 
                                            ora h 
                                            jnz bios_disk_device_write_sector_next 
                                            mvi a,bios_disk_device_device_not_selected
                                            pop h 
                                            jmp bios_disk_device_write_sector_end
bios_disk_device_write_sector_next:         lda bios_selected_devices_flags              
                                            xri $ff 
                                            ani bios_selected_devices_flags_head+bios_selected_devices_flags_sector+bios_selected_devices_flags_track
                                            ora a 
                                            jz bios_disk_device_write_sector_next2 
                                            mvi a,bios_disk_device_values_not_setted 
                                            pop h 
                                            jmp bios_disk_device_write_sector_end
bios_disk_device_write_sector_next2:        lxi d,bios_disk_device_device_record_write_sector_position
                                            dad d
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            xchg 
                                            lxi d,bios_disk_device_write_sector_ok
                                            pop psw  
                                            push d 
                                            push psw 
                                            lda bios_disk_device_selected_head 
                                            mov b,a 
                                            lda bios_disk_device_selected_sector
                                            mov c,a
                                            lda bios_disk_device_selected_track
                                            mov e,a 
                                            lda bios_disk_device_selected_track+1 
                                            mov d,a  
                                            xthl 
                                            ret  
bios_disk_device_write_sector_ok:           mvi a,bios_operation_ok
bios_disk_device_write_sector_end:          pop d  
                                            pop b 
                                            ret 

; bios_disk_device_read_sector
; HL -> indirizzo in memoria
; A <- esito dell'operazione
; HL <- indirizzo di memoria dopo l'esecuzione
bios_disk_device_read_sector:               push b 
                                            push d 
                                            push h 
                                            lhld bios_disk_device_vector_address
                                            mov a,l 
                                            ora h 
                                            jnz bios_disk_device_read_sector_next 
                                            mvi a,bios_disk_device_device_not_selected
                                            pop h 
                                            jmp bios_disk_device_read_sector_end
bios_disk_device_read_sector_next:          lda bios_selected_devices_flags                        
                                            xri $ff 
                                            ani bios_selected_devices_flags_head+bios_selected_devices_flags_sector+bios_selected_devices_flags_track
                                            ora a 
                                            jz bios_disk_device_read_sector_next2 
                                            mvi a,bios_disk_device_values_not_setted 
                                            pop h 
                                            jmp bios_disk_device_read_sector_end
bios_disk_device_read_sector_next2:         lxi d,bios_disk_device_device_record_read_sector_position
                                            dad d
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            xchg 
                                            lxi d,bios_disk_device_read_sector_ok
                                            pop psw  
                                            push d 
                                            push psw  
                                            lda bios_disk_device_selected_head 
                                            mov b,a 
                                            lda bios_disk_device_selected_sector
                                            mov c,a
                                            lda bios_disk_device_selected_track
                                            mov e,a 
                                            lda bios_disk_device_selected_track+1 
                                            xthl 
                                            ret 
bios_disk_device_read_sector_ok:            mvi a,bios_operation_ok
bios_disk_device_read_sector_end:           pop d  
                                            pop b 
                                            ret 

;bios_disk_device_format_drive
; A <- esito dell'operazione
bios_disk_device_format_drive:              push h 
                                            push d 
                                            push b 
                                            lhld bios_disk_device_vector_address
                                            mov a,l 
                                            ora h 
                                            jnz bios_disk_device_format_drive_next 
                                            mvi a,bios_disk_device_device_not_selected
                                            jmp bios_disk_device_format_drive_end
bios_disk_device_format_drive_next:         lxi d,bios_disk_device_device_record_format_position
                                            dad d
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            xchg 
                                            lxi d,bios_disk_device_format_drive_ok
                                            push d 
                                            pchl 
bios_disk_device_format_drive_ok:           mvi a,bios_operation_ok
bios_disk_device_format_drive_end:          pop b 
                                            pop d 
                                            pop h 
                                            ret  

;----- system ram -----
;Il parametro system_ram_dimension viene utilizzato dalla mms per capire quanto spazio ha a disposizione per eseguire i programmi e mantenere i segmenti di memoria attivi. 
;Da ricordare che la zona dedicata alla RAM deve partire dal'indirizzo $0000 e una dimensione minima di 20KB 
system_ram_dimension        .equ 32768-16
bios_reserved_memory        .equ system_ram_dimension 

bios_avabile_ram_memory:    lxi h,system_ram_dimension
                            ret 
                            
;----- interrupt handlers -----
;bios_RST55_interrupt_handler viene richiamato al verificarsi di un interrupt hardware (RST6.5 per 8085 o INT mode 1 per Z80)
;tutti i registri utilizzati devono essere ripristinati a fine interrupt
bios_hardware_interrupt_handler:    ret 

;----- data transfer ----- 
;opzionalmente può essere inserito un dispositivo DMA per gestire il flusso dati CPU/IO in modo più efficente. Il dispositivo DMa può essere inizializzato nelle funzioni cold_boot e warm_boot e i trasferimenti
;possono essere avviati e gestiti tramite le funzioni bios_disk_device_write_sector e bios_disk_device_read_sector.

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
dma_address_register	    .equ $04
dma_word_count_register     .equ $05

dma_reset:	out dma_master_clear
			mvi a,%00001000			;dack active low, drq active high, compressed timing, m-to-m disable
			out dma_command_register
			mvi a,%00001011			;set dma channels 0,1,3 mask bit
			out dma_all_mask_register
			ret

;bios_memory_transfer viene utilizzata per la copia di grandi quantità di dati all'interno della memoria. Dato che alcuni dispositivi DMA possono gestire il trasferimento mem-to-mem si preferisce mantenere 
;questa funzione nel bios. Nel caso non sia presente un dispositivo DMA o non sia disponibile la funzionalità, è possibile implementare una copoa software dei dati
; BC -> numero di bytes da trasferire 
; DE -> indirizzo sorgente
; HL -> indirizzo destinazione

; A <- esito dell'operazione 
; BC <- $0000
; DE <- indirizzo sorgente dopo l'esecuzione
; HL <- indirizzo destinazione dopo l'esecuzione 

bios_memory_transfer:       mov a,b     
                            ora c 
                            jz bios_memory_transfer_end
                            ldax d 
                            mov m,a 
                            dcx b 
                            inx h 
                            inx d 
                            jmp bios_memory_transfer
bios_memory_transfer_end:   mvi a,bios_operation_ok 
                            ret 

;bios_memory_transfer_reverse ha la funzione analoga di bios_memory_transfer ma trasferisce i dati decrementando a partire dall'indirizzo fornito
; BC -> numero di bytes da trasferire 
; DE -> indirizzo sorgente
; HL -> indirizzo destinazione

; A <- esito dell'operazione 
; BC <- $0000
; DE <- indirizzo sorgente dopo l'esecuzione
; HL <- indirizzo destinazione dopo l'esecuzione 

bios_memory_transfer_reverse:       mov a,b     
                                    ora c 
                                    jz bios_memory_transfer_reverse_end
                                    ldax d 
                                    mov m,a 
                                    dcx b 
                                    dcx h 
                                    dcx d 
                                    jmp bios_memory_transfer_reverse
bios_memory_transfer_reverse_end:   mvi a,bios_operation_ok 
                                    ret 


;----- device drivers ----- 

;----- dispositivi I/O -----
;I dispositivi I/O hanno un identificativo formato da un byte che può assumere un numero da $00 a $ff.
;l'id $00 viene sempre assegnato alla console base, che è sempre bidirezionale e viene utilizzato come dispositivo basilare di input/output dalla shell del sistema. 

;Ad ogni Id vengono assegnte le seguenti funzioni:
;- la funzione bios_get_selected_device_state restituisce le informazioni sulla disponibilità di lettura o scrittura di un byte sul dispositivo tramite un byte che contiene delle flags
;- la funzione bios_get_IO_device_informations restituisce le informazioni sulla tipologia del dispositivo sempre tramite un byte contenente delle flags
;- la funzione bios_read_selected_device_byte riceve un byte al dispositivo
;- la funzione bios_write_selected_device_byte invia un byte al dispositivo
;- la funzione bios_initialize_selected_device reinizializza il dispositivo 
;- la funzione bios_set_selected_device_state modifica le impostazioni del dispositivo 

;per avere una velocità computazionale migliore nel scegliere i dispositivi viene utilizzata una tabella dati in cui ogni record contiene:

;-  quattro bytes ASCII che identificano il tipo di dispositivo
;-  due bytes che contengono l'indirizzo della funzione bios_device_initialize_relativo
;   questa funzione inizializza il dispositivo I/O. I registri che vengono utilizzati devono essere ripristinati. 
;   La funzione non riceve in ingresso nessun parametro.

;-  due bytes che contengono l'indirizzo della funzione bios_get_selected_device_state relativa 
;   La funzione restituisce un byte in cui ogni bit contiene un'informazione sul dispositivo. Ad esempio, nel caso di una console di base:
    ;bios_IO_device_connected_mask       .equ %10000000  ;per indicare se il dispositivo è collegato o scollegato (caso ad esempio di un dispositivo seriale)
    ;bios_IO_device_input_byte_ready     .equ %01000000  ;per indicare se il dispositivo è pronto per inviare un byte al sistema 
    ;bios_IO_device_output_byte_ready    .equ %00100000  ;per indicare se il dispositivo è pronto per ricevere un byte dal sistema 
    ;quindi la funzione restituisce 
    ;A <- bios_IO_device_connected_mask (dato che deve essere sempre collegata) + bios_IO_device_input_byte_ready (se è stato letto un dato dalla tastiera) + bios_IO_device_output_byte_ready (se è possibile scrivere un byte sullo schermo) 
;   CY <- '0'

;-  due bytes che contengono l'indirizzo della funzione bios_set_selected_device_state relativa 
;   La funzione invia al dispositivo un byte in cui ogni bit del dispositivo contiene un'impostazione specifica.
;   A -> impostazioni 
;   CY <- '0'

;-  due bytes che contengono l'indirizzo della funzione bios_read_selected_device_byte
;   La funzione legge un dato dal dispositivo. Per esempio, nel caso della console di base il byte letto è un carattere ASCII inserito dalla tastiera
;   A <- dato letto 
;   CY <- '0'

;-  due bytes che contengono l'indirizzo della funzione bios_write_selected_device_byte
;   La funzione invia un dato al dispositivo. Per esempio, nel caso della console di base, il byte da inviare è un carattere ASCII che verrà stampato sullo schermo. 
;   A -> dato da inviare 
;   CY <- '0'

;Al termine dell'esecuzione, tutte le funzioni devono impostare CY a '0' per indicare l'esecuzione completa. 

;Nella tabella deve essere sempre registrato almeno un dispositivo di tipo "BTTY", che identifica la console basilare del sistema. 

;per aggiungere un dispositivo basta inserire un campo tramite la macro .text "tipo" e i relativi indirizzi alle funzioni 
bios_device_IO_table:       .text "BTTY"
                            .word display_reset
                            .word bios_console_get_state
                            .word bios_console_set_state 
                            .word keyboard_char_in
                            .word display_char_out

                            .text "UART"
                            .word uart_initialize
                            .word uart_get_state
                            .word uart_set_state
                            .word uart_read_byte 
                            .word uart_write_byte 

                            ;inserisci qui il vettore 
bios_device_IO_table_end:                                                                                               

display_low_port		        .equ $20			
display_high_port		        .equ $21			
display_data_port		        .equ $22			
display_status_port 	        .equ $20			
keyboard_input_port		        .equ $21		

display_pointer_address     	.equ    bios_reserved_memory

display_character_number		.equ 	512
display_character_x_number 		.equ 	32
display_character_y_number		.equ 	16
display_character_x_mask        .equ    display_character_x_number-1
display_character_tab_space     .equ    8

display_character_x_dimension	.equ 	2
display_character_y_dimension	.equ 	3

display_memory_dimension        .equ    512
display_background_character    .equ    %10000000
display_white_character			.equ 	%10111111
display_line_feed_verify        .equ    %00000001

keyboard_input_mask				.equ 	%10000000
keyboard_data_mask				.equ 	%01111111
delay_millis_value				.equ 	91
keyboard_insert_delay			.equ 	100

display_reset:      push psw
                    push h
                    push d
                    lxi h,0
					shld display_pointer_address
                    lxi d,display_memory_dimension
                    shld display_pointer_address
display_reset_loop: mvi a,display_background_character
                    call display_out_nv
                    dcx d
                    inx h
                    mov a,d
                    ora e
                    jnz display_reset_loop
display_reset_end:  pop d
                    pop h
                    pop psw
                    stc 
                    cmc 
                    ret


keyboard_char_in:               in keyboard_input_port
                                cma 
                                ani keyboard_data_mask 
                                push b 
                                mov c,a 
                                mvi b,keyboard_insert_delay
keyboard_char_in_delay_loop1:   mvi a,delay_millis_value	        
keyboard_char_in_delay_loop2:	dcr a						
                                jnz keyboard_char_in_delay_loop2	
                                dcr b 
                                jnz keyboard_char_in_delay_loop1
                                mov a,c 
                                pop b 
                                stc 
                                cmc 					
                                ret		

display_char_out:			push h
							lhld display_pointer_address
							push psw
							push d
							lxi d,display_character_number
							mov a,h
							cmp d
							jc display_char_out_next
							mov a,l
							cmp e
							jc display_char_out_next
display_lines_shift_up:		push b
							lxi h,0
							lxi b,display_character_number-display_character_x_number
							lxi d,display_character_x_number
display_line_shift_up_loop:	xchg 
							call display_in_nv 
							xchg 
							call display_out_nv 	
							dcx b
							inx h
							inx d
							mov a,b
							ora c
							jnz display_line_shift_up_loop
							pop b
							shld display_pointer_address
							lxi d,display_character_x_number
display_line_shift_up_lp2:	mvi a,display_background_character
							call display_out
							inx h
							dcx d
							mov a,d
							ora e
							jnz display_line_shift_up_lp2
							lhld display_pointer_address
display_char_out_next:		pop d
							pop psw
							push psw
							ani %01111111
							cpi $20
							jnc display_character_print
							cpi $0a 
							jz display_new_line
							cpi $0d
							jz display_carriage_return
							cpi $08
							jz display_backspace
                            cpi $09
                            jz display_tab 
							jmp display_character_send_end
display_new_line:			mvi a,display_character_x_number
							add l
							mov l,a
							mov a,h
							aci 0
							mov h,a
							jmp display_character_send_end
display_carriage_return:	xra a
							sui display_character_x_number
							ana l
							mov l,a
							jmp display_character_send_end
display_tab:                lxi b,display_character_x_mask
                            mov a,l 
                            ana c 
                            mov e,a 
                            mov a,h 
                            ana b 
                            mov d,a 
display_tab_offset:         mov a,e 
                            sui display_character_tab_space 
                            mov a,d 
                            sbi 0 
                            jc display_tap_offset_end
                            mov d,a 
                            mov a,e 
                            sui display_character_tab_space 
                            mov e,a 
                            jmp display_tab_offset
display_tap_offset_end:     mov a,e 
                            ora d  
                            jnz display_tap_offset_end2
                            lxi d,display_character_tab_space 
display_tap_offset_end2:    dad d 
                            jmp display_character_send_end
display_backspace:			mvi a, display_background_character
							call display_out
							dcx h
							jmp display_character_send_end
display_character_print:	cpi $61
							jc display_character_out
							cpi $7B
							jnc display_character_out
							ani %11011111
display_character_out:		call display_out
							inx h
display_character_send_end:	shld display_pointer_address
							pop psw
							pop h
                            stc
                            cmc 
							ret

display_out_nv:     push psw
                    jmp display_out_send
display_out:	   	push psw
display_out_ver:    in  display_status_port
		            ani display_line_feed_verify
		            jnz display_out_ver
display_out_send:	mov a,l
		            out display_low_port
                    mov a,h
                    out display_high_port
                    pop psw
                    out display_data_port
                    ret		

display_in:		    in display_status_port
 		            ani display_line_feed_verify
 		            jnz display_in
display_in_nv:	    mov a,l
		            out display_low_port
  		            mov a,h
		            out display_high_port
		            in display_data_port
 		            ret

display_out_ad_nv:		push h
						push psw
						jmp display_out_addr_send
display_out_addr:		push h
						push psw
display_out_addr_vr:	in display_status_port			
		            	ani display_line_feed_verify	
		            	jnz display_out_addr_vr		
display_out_addr_send:	lhld display_pointer_address
						mov a,l
						out display_low_port
						mov a,h
						out display_high_port
						pop psw
						out display_data_port
						inx h
						shld display_pointer_address
						pop h
						ret



;bios_console_output_ready
; A <- stato della console
bios_console_get_state:                 in keyboard_input_port
					                    ani keyboard_input_mask
                                        jnz bios_console_get_state2
                                        mvi a,bios_IO_console_connected_mask+bios_IO_console_input_byte_ready+bios_IO_console_output_byte_ready
                                        jmp bios_console_get_state_end
bios_console_get_state2:		        mvi a,bios_IO_console_connected_mask+bios_IO_console_output_byte_ready
bios_console_get_state_end:             stc 
                                        cmc 
                                        ret 


;bios_console_set_state (funzione che non ha bisogno di essere implementata)
bios_console_set_state:                 stc 
                                        cmc 
                                        ret 

uart_command_port	                    .equ $27
uart_data_port       	                .equ $26
uart_settings_flags 	                .equ $4d

uart_initialize:                        xra a 	
                                        out uart_command_port		
                                        out uart_command_port	
                                        out uart_command_port	
                                        mvi a,$40
                                        out uart_command_port	
                                        mvi a,uart_settings_flags
                                        out uart_command_port	
                                        mvi a,$37
                                        out uart_command_port	
                                        in uart_data_port 	
                                        stc 
                                        cmc 
                                        ret 

uart_get_state:                         push b
                                        mvi c,bios_IO_console_connected_mask
                                        in uart_command_port
                                        mov b,a 
                                        ani %00000001 
                                        jz uart_get_state_next
                                        mov a,c 
                                        ori bios_IO_console_output_byte_ready
                                        mov c,a 
uart_get_state_next:                    mov a,b
                                        ani %00000010      
                                        jz uart_get_state_next2
                                        mov a,c 
                                        ori bios_IO_console_input_byte_ready
                                        mov c,a 
uart_get_state_next2:                   mov a,c 
                                        pop b
                                        stc 
                                        cmc 
                                        ret  

uart_set_state:                         stc 
                                        cmc 
                                        ret 

uart_read_byte:                         stc 
                                        cmc 
                                        ret 

uart_write_byte:                        stc 
                                        cmc 
                                        ret 

;---- disk devices ----- 
;come per i device drivers, è possibile registrare più dispositivi per la gestione dei dischi 
;ongni record della tabella viene assegnato a un identificativo del disco, partendo dal carattere ASCII "A" fino a "Z". Un record contiene:
;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_initialize relativa 
;   Questa funzione inizializza ll dispositivo. Viene richiamata una volta all'avvio del computer. 

;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_read_sector relativa 
;   Questa funzione posiziona la testina del disco alla posizione fornita e procede con il caricamento del settore nella RAM all'indirizzo specificato. 
;   Alla fine dell'esecuzione deve restituire l'indirizzo RAM incrementato della dimensione del settore caricato 
;   B -> numero di testina 
;   C -> numero di settore nella traccia 
;   DE -> numero di traccia nella testina 
;   HL -> indirizzo di caricamento dei dati 

;   HL <- indirizzo incrementato

;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_write_sector relativa 
;   Questa funzione posiziona la testina del disco alla posizione fornita e procede con il caricamento dei dati dalla RAM all'indirizzo specificato al settore selezionato.
;   Alla fine dell'esecuzione deve restituire l'indirizzo RAM incrementato della dimensione del settore caricato 
;   B -> numero di testina 
;   C -> numero di settore nella traccia 
;   DE -> numero di traccia nella testina 
;   HL -> indirizzo di caricamento dei dati 

;   HL <- indirizzo incrementato

;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_status relativa 
;   Questa funzione restituisce lo stato del dispositivo sotto forma di byte. La funzione deve restituire le flags nel formato riconosciuto dal sistema operativo.

;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_set_motor relativa
;   Questa funzione serve per abilitare o disabilitare il motore del drive 
;   A -> $00 se il motore deve essere disabilitato, altro se deve essere abilitato

;-  due bytes che contengono l'indirizzo per la funzione bios_disk_device_format_drive relativa 
;   Questa funzione viene utilizzata per formattare la memoria di massa. La formattazione deve cancellare tutti i dati presenti nel disco ed, eventualmente, sostituirli con un valore predefinito.

;-  un byte che contiene il numero di testine del disco 
;-  due bytes che contiene il numero di tracce per testina del disco 
;-  un byte che contiene il numero di settori per traccia del disco 
;-  un byte che contiene il numero di bytes per settore (codificato in multipli di 128bytes)

;Le funzioni possono anche non preservare il contenuto dei registri che utilizzano ma, tuttavia, devono rispettare le convenzioni sull'output.
;le coordinate del settore fornite nelle funzioni bios_disk_device_write_sector e bios_disk_device_read_sector sono sempre verificate secondo i parametri inseriti nel record del dispositivo.

bios_device_disk_table:         .word bios_rom_disk_initialize
                                .word bios_rom_disk_read_sector
                                .word bios_rom_disk_write_sector
                                .word bios_rom_disk_status
                                .word bios_rom_disk_set_motor  
                                .word bios_rom_disk_format_drive 
                                .byte bios_rom_disk_heads_number
                                .word bios_rom_disk_tph_number
                                .byte bios_rom_disk_spt_number
                                .byte bios_rom_disk_bps_coded_number

                                ;inserisci i dispositivi qui 
bios_device_disk_table_end: 

bios_rom_disk_address_start          .equ $8800
bios_rom_disk_address_end            .equ $ffff

bios_rom_disk_heads_number           .equ 1
bios_rom_disk_tph_number             .equ 15 
bios_rom_disk_spt_number             .equ 8
bios_rom_disk_bps_coded_number       .equ 2 
bios_rom_disk_bps_uncoded_number     .equ 256
   
bios_rom_disk_format_fill_byte       .equ $ff 

bios_rom_disk_initialize:           ret

bios_rom_disk_read_sector:          mvi a,$AA
                                    push h  
                                    push d 
                                    push b 
                                    mov c,b 
                                    mvi b,0 
                                    lxi d,bios_rom_disk_tph_number
                                    call unsigned_multiply_word 
                                    inx sp 
                                    inx sp 
                                    pop h 
                                    push h 
                                    lhld bios_disk_device_selected_track
                                    dcx sp 
                                    dcx sp 
                                    dad d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,bios_rom_disk_spt_number
                                    call unsigned_multiply_word 
                                    xthl
                                    mov a,l
                                    xthl 
                                    mov l,a 
                                    mvi h,0 
                                    dad d 
                                    xchg 
                                    lxi b,bios_rom_disk_bps_uncoded_number
                                    call unsigned_multiply_word 
                                    lxi h,bios_rom_disk_address_start
                                    dad d 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    pop d 
                                    lxi b,bios_rom_disk_bps_uncoded_number
                                    xchg 
                                    call bios_memory_transfer
                                    ret 

bios_rom_disk_write_sector:         push h  
                                    push d 
                                    push b 
                                    mov c,b 
                                    mvi b,0 
                                    lxi d,bios_rom_disk_tph_number
                                    call unsigned_multiply_word 
                                    inx sp 
                                    inx sp 
                                    pop h 
                                    push h 
                                    lhld bios_disk_device_selected_track
                                    dcx sp 
                                    dcx sp 
                                    dad d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,bios_rom_disk_spt_number
                                    call unsigned_multiply_word 
                                    xthl
                                    mov a,l
                                    xthl 
                                    mov l,a 
                                    mvi h,0 
                                    dad d 
                                    xchg 
                                    lxi b,bios_rom_disk_bps_uncoded_number
                                    call unsigned_multiply_word 
                                    lxi h,bios_rom_disk_address_start
                                    dad d 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    pop d 
                                    lxi b,bios_rom_disk_bps_uncoded_number
                                    call bios_memory_transfer
                                    xchg 
                                    ret 

bios_rom_disk_status:       mvi a,bios_disk_device_controller_ready_status_bit_mask+bios_disk_device_disk_inserted_status_bit_mask
                            ret 

bios_rom_disk_format_drive:             lxi h,bios_rom_disk_address_start
                                        lxi d,bios_rom_disk_address_end 
bios_rom_disk_format_drive_loop:        mvi m,bios_rom_disk_format_fill_byte
                                        inx h 
                                        inx d 
                                        mov a,e 
                                        sub l 
                                        mov a,d 
                                        sbb h 
                                        jc bios_rom_disk_format_drive_loop
                                        ret  

bios_rom_disk_set_motor:    ret 

BIOS_layer_end:     
.print "Space left in BIOS layer ->",BIOS_dimension-BIOS_layer_end+BIOS
.memory "fill", BIOS_layer_end, BIOS_dimension-BIOS_layer_end+BIOS,$00
.print "BIOS load address ->",BIOS
.print "All functions built successfully"