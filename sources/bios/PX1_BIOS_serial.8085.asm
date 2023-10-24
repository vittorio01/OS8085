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
system_ram_dimension        .equ 32768-64

bios_avabile_ram_memory:    lxi h,system_ram_dimension
                            ret 
                            
;----- interrupt handlers -----
;bios_RST55_interrupt_handler viene richiamato al verificarsi di un interrupt hardware (RST6.5 per 8085 o INT mode 1 per Z80)
;tutti i registri utilizzati devono essere ripristinati a fine interrupt
bios_hardware_interrupt_handler:    ret 

;----- data transfer ----- 
;opzionalmente può essere inserito un dispositivo DMA per gestire il flusso dati CPU/IO in modo più efficente. Il dispositivo DMa può essere inizializzato nelle funzioni cold_boot e warm_boot e i trasferimenti
;possono essere avviati e gestiti tramite le funzioni bios_disk_device_write_sector e bios_disk_device_read_sector.

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

firmware_functions          .equ $8000
firmware_boot               .equ firmware_functions
firmware_serial_connect     .equ firmware_boot+3
firmware_send_char          .equ firmware_serial_connect+3
firmware_request_char       .equ firmware_send_char+3
firmware_disk_information   .equ firmware_request_char+3
firmware_disk_read_sector   .equ firmware_disk_information+3
firmware_disk_write_sector  .equ firmware_disk_read_sector+3
system_transfer_and_boot    .equ firmware_disk_write_sector+3

;per aggiungere un dispositivo basta inserire un campo tramite la macro .text "tipo" e i relativi indirizzi alle funzioni 
bios_device_IO_table:       .text "BTTY"
                            .word bios_serial_connect
                            .word bios_serial_get_state
                            .word bios_serial_set_state 
                            .word bios_serial_request_char
                            .word bios_serial_send_char

                            ;inserisci qui il vettore 
bios_device_IO_table_end:                                                                                               

bios_serial_connect:        call serial_reset_connection
                            ret 

bios_serial_get_state:      mvi a,%11100000
                            stc 
                            cmc 
                            ret 

bios_serial_request_char:   call serial_request_terminal_char
                            stc 
                            cmc 
                            ret 

bios_serial_send_char:      call serial_send_terminal_char
                            stc 
                            cmc 
                            ret 

bios_serial_set_state:          stc 
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

bios_device_disk_table:         .word bios_serial_disk_initialize
                                .word bios_serial_disk_read_sector
                                .word bios_serial_disk_write_sector
                                .word bios_serial_disk_status
                                .word bios_serial_disk_set_motor  
                                .word bios_serial_disk_format_drive 
                                .byte bios_serial_disk_heads_number
                                .word bios_serial_disk_tph_number
                                .byte bios_serial_disk_spt_number
                                .byte bios_serial_disk_bps_coded_number

                                ;inserisci i dispositivi qui 
bios_device_disk_table_end: 


bios_serial_disk_heads_number           .equ 2
bios_serial_disk_tph_number             .equ 80 
bios_serial_disk_spt_number             .equ 18
bios_serial_disk_bps_coded_number       .equ 4 
bios_serial_disk_bps_uncoded_number     .equ 512
   

bios_serial_disk_initialize:            ;mvi a,$c0 
                                        ;sim 
                                        ret

bios_serial_disk_status:        push b 
                                push d 
                                push h 
bios_serial_disk_status_retry:  call serial_request_disk_information
                                jc bios_serial_disk_status_end
                                call serial_reset_connection
                                jmp bios_serial_disk_status_retry
bios_serial_disk_status_end:    mov a,b
                                pop b 
                                pop d 
                                pop h 
                                ret 

bios_serial_disk_read_sector:       push b 
                                    push d 
                                    push h 
bios_serial_disk_read_sector_try:   call serial_request_disk_sector     
                                    jc bios_serial_disk_read_sector_end
                                    call serial_reset_connection
                                    pop h
                                    pop d 
                                    pop b 
                                    jmp bios_serial_disk_read_sector
bios_serial_disk_read_sector_end:   pop psw 
                                    pop d 
                                    pop b 
                                    ret 

bios_serial_disk_write_sector:      push b 
                                    push d 
                                    push h 
bios_serial_disk_write_sector_try:  call serial_write_disk_sector     
                                    jc bios_serial_disk_write_sector_end
                                    call serial_reset_connection
                                    pop h
                                    pop d 
                                    pop b 
                                    jmp bios_serial_disk_write_sector
bios_serial_disk_write_sector_end:  pop psw 
                                    pop d 
                                    pop b 
                                    ret 

bios_serial_disk_format_drive:         ret  

bios_serial_disk_set_motor:            ret 


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

serial_wait_timeout_value_short:       .equ 200
serial_wait_timeout_value_long:        .equ 1500


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
device_boardId          .text   "FENIX 1 FULL"                       
device_boardId_dimension .equ 12    ;dimension of the string

; ------ memory addresses ------
;This implementation uses also a portion of memory to save important informations. 
;To manage terminal chars received from the slave, a small array queue is used  

;To change the posizion of this memory space the variable memory_space_base_address can be modified.
memory_space_base_address                       .equ $7fb8
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

BIOS_layer_end:     
.print "Space left in BIOS layer ->",BIOS_dimension-BIOS_layer_end+BIOS
.memory "fill", BIOS_layer_end, BIOS_dimension-BIOS_layer_end+BIOS,$00
.print "BIOS load address ->",BIOS
.print "All functions built successfully"