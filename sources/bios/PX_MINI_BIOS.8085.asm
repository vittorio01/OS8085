
;L'hardware del computer PX MINI prevede:
;-  una porta seriale per comunicare con computers moderni
;-  un timer per generare il clock per la porta seriale ed, eventualmente, generare interrupts al processore
;-  una RAM da 32kb
;-  una ROM da 32kb
;Nel computer non viene preinstallato nessun dipositivo per l'utilizzo delle memorie di massa. Essendo sprovvisto di una memoria secondaria, per il funzionamento
; del SO viene utilizzata parte della ROM (quella non utilizzata dal firmware base) come una finta memoria di massa.

;Il BIOS prevede l'implementazione di una serie di funzioni a basso livello che devono adattarsi alle varie specifiche della macchina fisica. 
;Tra le funzioni disponibili troviamo:
;-  funzioni di avvio (bios_cold_boot e bios_warm_boot) che servono per inizializzare le risorse ed eventualmente eseguire test preliminari. In particolare, bios_cold_boot
;   viene invocata dopo l'avvio del computer, mentre bios_warm_boot viene utilizzata invocata quando è necessario un reset interno
;-  funzioni per la gestione della console, che servono per la gestione dei dispositivi base per l'interazione con l'utente (lettura di caratteri e stampa su schermo)
;-  funzioni per la gestione delle memorie di massa, tra cui sono presenti alcune dedicate alla selezione di tracce, settori e testine e altre alla gestione del flusso dei dati, tra cui lettura
;   scrittura di una traccia e formattazione del disco
;-  funzioni per la copia di blocchi di memoria, che vengono utilizzati nel caso di trasferimenti di grandi blocchi di dati da e verso la memoria. 

;parametri hardware standard
bios_ram_dimension          .equ 32768
bios_serial_data_port       .equ $22 
bios_serial_command_port    .equ $21

bios_mass_memory_rom_address_start          .equ $9000
bios_mass_memory_rom_address_end            .equ $ffff
bios_mass_memory_rom_id                     .equ $41
bios_mass_memory_rom_heads_number           .equ 1
bios_mass_memory_rom_tracks_number          .equ 15 
bios_mass_memory_rom_spt_number             .equ 14 
bios_mass_memory_rom_bps_coded_number       .equ 2 
bios_mass_memory_rom_bps_uncoded_number     .equ 256
bios_mass_memory_rom_write_enable           .equ $ff    
bios_mass_memory_rom_format_fill_byte       .equ $ff 

;codici di esecuzione che possono essere generati dalle funzioni
bios_operation_ok                       .equ $ff 
bios_mass_memory_write_only             .equ $01
bios_mass_memory_device_not_found       .equ $02
bios_mass_memory_device_not_selected    .equ $03
bios_mass_memory_bad_argument           .equ $04
bios_mass_memory_transfer_error         .equ $05
bios_mass_memory_seek_error             .equ $06
bios_console_not_ready                  .equ $07
bios_memory_transfer_error              .equ $08 

;memoria dedicata al salvataggio delle informazioni
bios_mass_memory_selected_sector    .equ reserved_memory_start+$0040
bios_mass_memory_selected_track     .equ reserved_memory_start+$0041
bios_mass_memory_selected_head      .equ reserved_memory_start+$0043
bios_mass_memory_selected_device    .equ reserved_memory_start+$0044
bios_mass_memory_select_mask        .equ reserved_memory_start+$0045

bios_functions: .org BIOS 
                jmp bios_cold_boot 
                jmp bios_warm_boot 
                jmp bios_console_output_write_character
                jmp bios_console_output_ready 
                jmp bios_console_input_read_character 
                jmp bios_console_input_ready 
                jmp bios_mass_memory_select_drive 
                jmp bios_mass_memory_select_sector 
                jmp bios_mass_memory_select_track 
                jmp bios_mass_memory_select_head 
                jmp bios_mass_memory_write_enable_status 
                jmp bios_mass_memory_write_sector 
                jmp bios_mass_memory_read_sector  
                jmp bios_mass_memory_format_drive 
                jmp bios_mass_memory_status 
                jmp bios_memory_transfer
                
;bios_cold_boot esegue un test e un reset della memoria ram e procede con l'inizializzazione delle risorse hardware. Tra le operazioni che deve eseguire troviamo quindi:
;- inizializzazione e test (facoltativo) della ram 
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa

bios_cold_boot:         lxi h,0                     ;esempio di inizializzazione della RAM (facolatativo)
                        lxi d,bios_ram_dimension 
bios_memory_test_loop:  mvi m,0 
                        inx h 
                        mov a,e 
                        sub l 
                        mov a,d 
                        sbb h 
                        jnz bios_memory_test_loop
                        mvi a,0 
                        sta bios_mass_memory_selected_device
                        ;da implementare
                        ret 

;bios_warm_boot esegue delle operazioni simili a bios_warm_boot escludendo il test e l'inizializzazione della ram. Prevede quindi:
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa
;tuttavia, è possibile specificare operazioni diverse per la gestione dei dispositivi IO, in caso si desidera ad esempio lasciare invariato il setup dei dispositivi
bios_warm_boot:         mvi a,0 
                        sta bios_mass_memory_selected_device
                        ret 

;bios_console_output_write_character e bios_console_output_ready sono due funzioni dedicate alla gestione del lato output della console (monitor). In particolare:
;-  bios_console_output_ready restituisce lo stato dell'output della console (pronto per ricevere dati o no)
;-  bios_console_output_write_character manda in output il carattere ASCII ricevuto

;bios_console_output_write_character
; A -> carattere ASCII da scrivere
bios_console_output_write_character:    ;da implementare
                                        ret 

;bios_console_output_ready
; A <- stato della console (lato output)
bios_console_output_ready:  ;da implementare
                            ret 

;bios_console_input_read_character e bios_console_input_ready sono due funzioni dedicate alla gestione del lato input della console (tastiera). In particolare:
;-  bios_console_input_ready restituisce lo stato dell'input della console (dato in attesa di essere letto o no)
;-  bios_console_input_read_character preleva il carattere ASCII in ingresso dalla console

;bios_console_input_ready
; A <- stato della console (lato input)
bios_console_input_ready:   ;da implementare
                            ret 

;bios_console_input_read_character 
; A <- carattere ASCII in ingresso
bios_console_input_read_character:  ;da implementare
                                    ret 

;le prossime funzioni servono per la gestione della memoria di massa. Troviamo quindi le seguente funzioni di selezione:
;-  bios_mass_memory_select_drive seleziona il drive, restituisce l'esito dell'operazione e le informazioni sul dispositivo selezionato. 
;   Si possno gestire fino a 25 dispositivi
;-  bios_mass_memory_select_sector seleziona il settore nella traccia desiderato nella memoria di massa (gia selezionata in precedenza) e restituisce l'esito dell'operazione.
;   Possono essere gestiti fino a 256 settori in un'unica traccia
;-  bios_mass_memory_select_track seleziona la traccia desiderata nella memoria di massa (gia selezionata in precedenza) e restituisce l'esito dell'operazione.
;   Possono essere gestite fino a 65536 tracce per testina
;-  bios_mass_memory_select_head seleziona la testina desiderata nella memoria di massa (gia selezionata in precedenza) e restituisce l'esito dell'operazione.
;   Possono essere gestite fino a 256 testine 

;bios_mass_memory_select_drive
; A -> dispositivo da selezionare (sono diponibili 25 identificativi da $41 a $5A)
; A <- bytes per settore codificati in potenza di 2 da 128. Assume $00 se l'operazione non ha avuto successo 
; B <- numero di settori per traccia
; C <- numero di testine
; DE <- numero di tracce

bios_mass_memory_select_drive:              cpi bios_mass_memory_rom_id
                                            jnz bios_mass_memory_select_drive_not_found
                                            sta bios_mass_memory_selected_device
                                            lda bios_mass_memory_select_mask
                                            ani %00001111
                                            ori %10000000
                                            sta bios_mass_memory_select_mask
                                            mvi a,bios_mass_memory_rom_bps_coded_number
                                            mvi b,bios_mass_memory_rom_spt_number
                                            mvi c,bios_mass_memory_rom_heads_number
                                            lxi d,bios_mass_memory_rom_tracks_number
                                            ret 

bios_mass_memory_select_drive_not_found:    mvi a,bios_mass_memory_bad_argument
                                            ret 
;bios_mass_memory_select_sector
; A -> settore da selezionare 
; A <- esito dell'operazione
bios_mass_memory_select_sector:     push psw 
                                    lda bios_mass_memory_selected_device
                                    ora a 
                                    jnz bios_mass_memory_sector_dselected
                                    pop psw 
                                    mvi a,bios_mass_memory_device_not_selected 
                                    ret 
bios_mass_memory_sector_dselected:  pop psw 
                                    cpi bios_mass_memory_rom_spt_number 
                                    jc bios_mass_memory_sector_selected
                                    mvi a,bios_mass_memory_bad_argument
                                    ret 
bios_mass_memory_sector_selected:   sta bios_mass_memory_selected_sector
                                    lda bios_mass_memory_select_mask
                                    ori %00010000
                                    sta bios_mass_memory_select_mask
                                    mvi a,bios_operation_ok
                                    ret 

;bios_mass_memory_select_track
; HL -> traccia da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_track:      lda bios_mass_memory_selected_device
                                    ora a 
                                    jnz bios_mass_memory_track_dselected
                                    mvi a,bios_mass_memory_device_not_selected
                                    ret 
bios_mass_memory_track_dselected:   push d 
                                    lxi d,bios_mass_memory_rom_tracks_number
                                    mov a,l 
                                    sub e 
                                    mov a,h 
                                    sbb d 
                                    jc bios_mass_memory_track_selected
                                    pop d 
                                    mvi a,bios_mass_memory_bad_argument
                                    ret 
bios_mass_memory_track_selected:    pop d 
                                    shld bios_mass_memory_selected_track
                                    lda bios_mass_memory_select_mask
                                    ori %00100000
                                    sta bios_mass_memory_select_mask
                                    mvi a,bios_operation_ok
                                    ret 

;bios_mass_memory_select_head
; A -> testina da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_head:       push psw 
                                    lda bios_mass_memory_selected_device
                                    ora a 
                                    jnz bios_mass_memory_head_dselected
                                    pop psw 
                                    mvi a,bios_mass_memory_device_not_selected 
                                    ret 
bios_mass_memory_head_dselected:    pop psw 
                                    cpi bios_mass_memory_rom_heads_number
                                    jc bios_mass_memory_head_selected
                                    mvi a,bios_mass_memory_bad_argument
                                    ret 
bios_mass_memory_head_selected:     sta bios_mass_memory_selected_head
                                    lda bios_mass_memory_select_mask
                                    ori %00100000
                                    sta bios_mass_memory_select_mask
                                    mvi a,bios_operation_ok
                                    ret

;bios_mass_memory_write_enable_status verifica se la memoria di massa è abilitata alla scrittura.
; A <- esito dell'operazione ($ff se è scrivibile, $00 se è di sola lettura)
bios_mass_memory_write_enable_status:       lda bios_mass_memory_selected_device    
                                            ora a 
                                            jnz bios_mass_memory_write_status_dselected
                                            mvi a,bios_mass_memory_device_not_selected
                                            ret 
bios_mass_memory_write_status_dselected:    mvi a,bios_mass_memory_rom_write_enable
                                            ret 

;Le seguenti funzioni servono per interagire con il lettore selezionato nella memoria di massa.
;-  bios_mass_memory_write_sector scrive i dati nel settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo in memoria dei dati da scrivere
;-  bios_mass_memory_read_sector legge i dati dal settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo della ram per indicare dove scrivere i dati ricevuti
;-  bios_mass_memory_format_drive formatta l'intero disco sovrascrivendo tutti i dati e restituisce l'esito dell'operazione

;bios_mass_memory_write_sector
; HL -> indirizzo in memoria 
; A <- esito dell'operazione
; HL <- indirizzo di memoria dopo l'esecuzione
bios_mass_memory_write_sector:      lda bios_mass_memory_select_mask
                                    ani %11110000
                                    jnz bios_mass_memory_write_dselected
                                    mvi a,bios_mass_memory_device_not_selected
                                    ret 
bios_mass_memory_write_dselected:   push b 
                                    push d 
                                    push h 
                                    lda bios_mass_memory_selected_head
                                    mov c,a 
                                    mvi b,0 
                                    lxi d,bios_mass_memory_rom_tracks_number
                                    call unsigned_multiply_word 
                                    lhld bios_mass_memory_selected_track
                                    dad d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,bios_mass_memory_rom_spt_number
                                    call unsigned_multiply_word 
                                    lhld bios_mass_memory_selected_sector
                                    dad d 
                                    xchg 
                                    lxi b,bios_mass_memory_rom_bps_uncoded_number
                                    call unsigned_multiply_word 
                                    lxi h,bios_mass_memory_rom_address_start
                                    dad d 
                                    pop d 
                                    lxi b,bios_mass_memory_rom_bps_uncoded_number
                                    call bios_memory_transfer
                                    mvi a,bios_operation_ok 
                                    pop d 
                                    pop b 
                                    ret 

; bios_mass_memory_read_sector
; HL -> indirizzo in memoria
; A <- esito dell'operazione
; HL <- indirizzo di memoria dopo l'esecuzione
bios_mass_memory_read_sector:       lda bios_mass_memory_select_mask
                                    ani %11110000
                                    jnz bios_mass_memory_read_dselected
                                    mvi a,bios_mass_memory_device_not_selected
                                    ret 
bios_mass_memory_read_dselected:    push b 
                                    push d 
                                    push h 
                                    lda bios_mass_memory_selected_head
                                    mov c,a 
                                    mvi b,0 
                                    lxi d,bios_mass_memory_rom_tracks_number
                                    call unsigned_multiply_word 
                                    lhld bios_mass_memory_selected_track
                                    dad d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,bios_mass_memory_rom_spt_number
                                    call unsigned_multiply_word 
                                    lhld bios_mass_memory_selected_sector
                                    dad d 
                                    xchg 
                                    lxi b,bios_mass_memory_rom_bps_uncoded_number
                                    call unsigned_multiply_word 
                                    lxi h,bios_mass_memory_rom_address_start
                                    dad d 
                                    pop d 
                                    lxi b,bios_mass_memory_rom_bps_uncoded_number
                                    xchg 
                                    call bios_memory_transfer
                                    mvi a,bios_operation_ok 
                                    pop d 
                                    pop b 
                                    ret 

;bios_mass_memory_format_drive
; A <- esito dell'operazione
bios_mass_memory_format_drive:          lda bios_mass_memory_selected_device
                                        ora a 
                                        jz bios_mass_memory_format_device
                                        mvi a,bios_mass_memory_device_not_selected
bios_mass_memory_format_device:         push h 
                                        push d 
                                        lxi h,bios_mass_memory_rom_address_start
                                        lxi d,bios_mass_memory_rom_address_end 
bios_mass_memory_format_device_loop:    mvi m,bios_mass_memory_rom_format_fill_byte
                                        inx h 
                                        inx d 
                                        mov a,e 
                                        sub l 
                                        mov a,d 
                                        sbb h 
                                        jc bios_mass_memory_format_device_loop
                                        pop d 
                                        pop h 
                                        lda bios_mass_memory_select_mask
                                        ani %10001111
                                        sta bios_mass_memory_select_mask
                                        mvi a,bios_operation_ok
                                        ret 

;opzionalmente può essere inserito un dispositivo DMA per gestire il flusso dati CPU/IO in modo più efficente. Il dispositivo DMa può essere inizializzato nelle funzioni cold_boot e warm_boot e i trasferimenti
;possono essere avviati e gestiti tramite le funzioni bios_mass_memory_write_sector e bios_mass_memory_read_sector.

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

;l'implementazione della funzione può essere utilizzato in tutte le implementazioni. Se viene installato un dispositivo DMA può essere modificata secondo le sue caratteristiche
