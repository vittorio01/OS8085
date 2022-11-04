;Il BIOS prevede l'implementazione di una serie di funzioni a basso livello che devono adattarsi alle varie specifiche della macchina fisica. 
;Tra le funzioni disponibili troviamo:
;-  funzioni di avvio (bios_cold_boot e bios_warm_boot) che servono per inizializzare le risorse ed eventualmente eseguire test preliminari. In particolare, bios_cold_boot
;   viene invocata dopo l'avvio del computer, mentre bios_warm_boot viene utilizzata invocata quando è necessario un reset interno
;-  funzioni per la gestione dei dispositivi I/O tra cui la console, che serve per la gestione dei dispositivi base per l'interazione con l'utente (lettura di caratteri e stampa su schermo)
;-  funzioni per la gestione delle memorie di massa, tra cui sono presenti alcune dedicate alla selezione di tracce, settori e testine e altre alla gestione del flusso dei dati, tra cui lettura
;   scrittura di una traccia e formattazione del disco
;-  funzioni per la copia di blocchi di memoria, che vengono utilizzati nel caso di trasferimenti di grandi blocchi di dati da e verso la memoria. 

;----- dispositivi I/O -----
;I dispositivi I/O hanno un identificativo formato da un byte che può assumere un numero da $00 a $ff.
;Un dispositivo può coprire anche più identificativi, nel caso in cui si vuole accedere a dspositivi che necessitano di più porte I/O hardware per la loro gestione. 
;Un identificativo I/O può essere assegnato a un dispositivo hardware secondo tre modalità:
;-  sola lettura (il dispositivo può solamente inviare i dati)
;-  sola scritura (il dispositivo può solamente leggere i dati)
;-  bidirezionale (il dispositivo può leggere o scrivere i dati)

;l'id $00 viene sempre assegnato alla console base, che è sempre bidirezionale e viene utilizzato come dispositivo basilare di input/output dalla shell del sistema. 
;Ad esempio:
;-  se si desidera aggiungere un dispositivo seriale si può utilizzare un unico ID bidirezionale
;-  se si desidera registrare un dispositivo grafico ASCII si possono utilizzare due ID (uno di sola scrittura per indicare la posizione del carattere e uno bidirezionale per leggere/scrivere il carattere sullo schermo)
;Ad ogni Id vengono assegnte due funzioni per leggere e scrivere un unico byte, una funzione per richiedere informazioni sul dispositivo e una funzione per richiedere lo stato attuale del dispositivo:
;- la funzione bios_get_selected_device_state restituisce le informazioni sulla disponibilità di lettura o scrittura di un byte sul dispositivo tramite un byte che contiene delle flags
;- la funzione bios_get_IO_device_informations restituisce le informazioni sulla tipologia del dispositivo sempre tramite un byte contenente delle flags


.include "os_constraints.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "execution_codes.8085.asm"

;le seguenti variabili vengono utilizzate per identificare il tipo di dispositivo. Il byte risultante è formato da:
;- due bytes per indicare la direzionalità 
;- sei bytes per indicare il tipo di dispositivo 
;il risultato finale si ottiene mettendo in OR le seguenti informazioni. Ad esempio 
;A <- bios_IO_device_readable_mask + bios_IO_device_writerable_mask + bios_IO_device_type_console viene usato per identificare la console basilare

;bios_IO_device_readable_mask e bios_IO_device_writerable_mask indicano la direzionalità del dispositivo (tre combinazioni disponibili) 
bios_IO_device_readable_mask    .equ %10000000
bios_IO_device_writerable_mask  .equ %01000000

;vengono usati i restanti 6 bytes per identificare il tipo di dispositivo (64 diversi tipi di dispositivi)
bios_IO_device_type_console    .equ %00000000     ;il tipo %0000000 viene assegnato per identificare una console basilare I/O  

;si possono aggiungere liberamente altre tipologie di dispositivo, dato che l'applicazione deve saperlo utilizzare, 
;ma devono essere sempre mantenuti i due bytes per indicare la direzionaità del dispositivo 

;la funzione bios_get_selected_device_state restituisce le seguenti flags messe in or logico fra loro
bios_IO_device_connected_mask       .equ %10000000  ;per indicare se il dispositivo è collegato o scollegato (caso ad esempio di un dispositivo seriale)
bios_IO_device_input_byte_ready     .equ %01000000  ;per indicare se il dispositivo è pronto per inviare un byte al sistema 
bios_IO_device_output_byte_ready    .equ %00100000  ;per indicare se il dispositivo è pronto per ricevere un byte dal sistema 

;Ad esempio, nel caso della console di base:
;A <- bios_IO_device_connected_mask (dato che deve essere sempre collegata) + bios_IO_device_input_byte_ready (se è stato letto un dato dalla tastiera) + bios_IO_device_output_byte_ready (se è possibile scrivere un byte sullo schermo) 

bios_selected_IO_device_get_state_address   .equ reserved_memory_start+$0000
bios_selected_IO_device_write_byte_address  .equ reserved_memory_start+$0004
bios_selected_IO_device_read_byte_address   .equ reserved_memory_start+$0007
bios_selected_IO_device_flags               .equ reserved_memory_start+$000A

bios_selected_IO_device_flags_Selected      .equ %10000000

bios_functions: .org BIOS 
                jmp bios_cold_boot 
                jmp bios_warm_boot 
                jmp bios_select_IO_device
                jmp bios_get_IO_device_informations 
                jmp bios_get_selected_device_state
                jmp bios_read_selected_device_byte
                jmp bios_write_selected_device_byte 
                jmp bios_mass_memory_select_drive 
                jmp bios_mass_memory_select_sector 
                jmp bios_mass_memory_select_track 
                jmp bios_mass_memory_select_head 
                jmp bios_mass_memory_get_bps
                jmp bios_mass_memory_get_spt
                jmp bios_mass_memory_get_tph 
                jmp bios_mass_memory_get_head_number 
                jmp bios_mass_memory_status 
                jmp bios_mass_memory_write_sector 
                jmp bios_mass_memory_read_sector  
                jmp bios_mass_memory_format_drive 
                jmp bios_memory_transfer
                jmp bios_memory_transfer_reverse 

;per avere una velocità computazionale migliore nel scegliere i dispositivi viene utilizzata una tabella dati in cui ogni record contiene:
;-  un byte che contiene l'identificativo 
;-  un byte che identifica il tipo di dispositivo 
;-  due bytes che contengono l'indirizzo della funzione bios_get_selected_device_state relativa 
;-  due bytes che contengono l'indirizzo della funzione bios_read_selected_device_byte
;-  due bytes che contengono l'indirizzo della funzione bios_write_selected_device_byte

;per aggiungere un dispositivo basta inserire un campo tramite la macro .byte "flags del dipositivo"
bios_device_IO_table:       .byte $00                                                                                       
                            .byte bios_IO_device_readable_mask+bios_IO_device_writerable_mask+bios_IO_device_type_console   
                            .word bios_console_get_state
                            .word bios_console_input_read_character
                            .word bios_console_output_write_character
bios_device_IO_table_end:                                                                                              
;una volta selezionato il dispsitivo il BIOS deve sapere l'indirizzo delle tre funzioni 

;implementazione delle funzioni inserite nell'bios_device_IO_table (la console è già stata inserita nella tabella)
;Tutte le funzioni prima dell'istruzione RET devono anche settare la flag CY a 0 

;bios_console_output_write_character, bios_console_input_read_character e bios_console_output_get_state sono vengono dedicate alla gestione della console.
;bios_console_output_write_character
; A -> carattere ASCII da scrivere
bios_console_output_write_character:    ;da implementare
                                        mvi a,$AA
                                        stc 
                                        cmc 
                                        ret 

; A <- carattere ASCII in ingresso
bios_console_input_read_character:      ;da implementare
                                        mvi a,$BB 
                                        stc 
                                        cmc 
                                        ret 

;bios_console_output_ready
; A <- stato della console
bios_console_get_state:                 ;da implementare
                                        mvi a,$CC 
                                        stc 
                                        cmc 
                                        ret  


;funzioni relative alla gestione della bios_device_IO_table

bios_search_IO_device:              mov b,a 
                                    lxi d,bios_device_IO_table_end
                                    lxi h,bios_device_IO_table
bios_search_IO_device_loop:         mov a,m 
                                    cmp b 
                                    jz bios_search_IO_device_search_found
                                    mvi a,8 
                                    add l 
                                    mov l,a 
                                    mov a,h 
                                    aci 0 
                                    mov h,a 
                                    mov a,e 
                                    sub l 
                                    mov a,d 
                                    sbb h 
                                    jc bios_search_IO_device_loop 
                                    ret 
bios_search_IO_device_search_found: mvi a,7 
                                    add l 
                                    mov l,a 
                                    mov a,h 
                                    aci 0 
                                    mov h,a 
                                    mov b,m 
                                    dcx h 
                                    mov c,m 
                                    dcx h 
                                    mov d,m 
                                    dcx h 
                                    mov e,m 
                                    dcx h 
                                    push h 
                                    mov a,m 
                                    xthl 
                                    mov h,a 
                                    xthl 
                                    dcx h 
                                    mov a,m 
                                    xthl 
                                    mov l,a 
                                    xthl 
                                    dcx h 
                                    mov a,m 
                                    pop h 
                                    stc 
                                    ret 

bios_IO_device_initialize:          lxi h,0 
                                    mvi a,$c3 
                                    sta bios_selected_IO_device_get_state_address
                                    sta bios_selected_IO_device_write_byte_address
                                    sta bios_selected_IO_device_read_byte_address
                                    shld bios_selected_IO_device_get_state_address+1 
                                    shld bios_selected_IO_device_write_byte_address+1 
                                    shld bios_selected_IO_device_read_byte_address+1 
                                    xra a 
                                    sta bios_selected_IO_device_flags
                                    ret 

;bios_select_IO_device viene utilizzata per selezionare il dispositivo desiderato ($00 seleziona la console)
;A -> Id del dispositivo 
;A <- esito dell'operazione 

bios_select_IO_device:              push b 
                                    push d  
                                    push h 
                                    call bios_search_IO_device
                                    jnc bios_select_IO_device_error
                                    shld bios_selected_IO_device_get_state_address+1
                                    xchg 
                                    shld bios_selected_IO_device_read_byte_address+1 
                                    mov l,c 
                                    mov h,b 
                                    shld bios_selected_IO_device_write_byte_address+1 
                                    mvi a,bios_selected_IO_device_flags_selected
                                    sta bios_selected_IO_device_flags
                                    
                                    mvi a,bios_operation_ok
                                    jmp bios_select_IO_device_error_end
bios_select_IO_device_error:        mvi a,bios_IO_device_not_found 
bios_select_IO_device_error_end:    pop h 
                                    pop d 
                                    pop b 
                                    ret 


;bios_get_IO_device_informations restituisce le informazioni sul dispositivo specificato. Se il BIOS esiste, restituisce le seguenti informazioni sul dispositivo:
;-  tipo di dispositivo (seriale, grafico, tastiera, ...)
;-  direzionalità (sola lettura, sola scrittura o bidirezionale)
;Le informazioni vengono assegnate secondo flags e numeri messe in OR in un unico byte (vedi le informazioni sui dispositivi I/O)

;A -> id del dispositivo 
;A <- flags di tipologia (se non esiste ritorna $00)

bios_get_IO_device_informations:        push b 
                                        push d 
                                        push h 
                                        call bios_search_IO_device
                                        jc bios_get_IO_device_informations_end
                                        xra a 
bios_get_IO_device_informations_end:    pop h 
                                        pop d 
                                        pop b 
                                        ret 

;bios_read_selected_device_byte legge il byte del dispositivo selezionato precedentemente
;A <- byte da leggere 
;PSW <- cy viene settato ad 1 se il dispositivo non è stato selezionato 

bios_read_selected_device_byte:         lda bios_selected_IO_device_flags
                                        ani bios_selected_IO_device_flags_selected
                                        jz bios_read_selected_device_byte_end
                                        jmp bios_selected_IO_device_read_byte_address
bios_read_selected_device_byte_end:     xra a 
                                        stc 
                                        ret 

;bios_write_selected_device_byte scrive il byte del dispositivo selezionato precedentemente
;A -> byte da scrivere 
;PSW <- cy viene settato ad 1 se il dispositivo non è stato selezionato 

bios_write_selected_device_byte:        lda bios_selected_IO_device_flags
                                        ani bios_selected_IO_device_flags_selected
                                        jz bios_write_selected_device_byte_end
                                        jmp bios_selected_IO_device_write_byte_address
bios_write_selected_device_byte_end:    xra a 
                                        stc 
                                        ret

;bios_get_selected_device_state restituisce lo stato del dispositivo selezionato precedentemente
;A <- flags del dispositivo 
;PSW <- cy viene settato ad 1 se il dispositivo non è stato selezionato 

bios_get_selected_device_state:         lda bios_selected_IO_device_flags
                                        ani bios_selected_IO_device_flags_selected
                                        jz bios_get_selected_device_state_end
                                        jmp bios_selected_IO_device_get_state_address
bios_get_selected_device_state_end:     xra a 
                                        stc 
                                        ret

;bios_cold_boot esegue un test e un reset della memoria ram e procede con l'inizializzazione delle risorse hardware. Tra le operazioni che deve eseguire troviamo quindi:
;- inizializzazione e test (facoltativo) della ram 
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa

bios_cold_boot:         call bios_IO_device_initialize
                        ;da implementare
                        ret 

;bios_warm_boot esegue delle operazioni simili a bios_warm_boot escludendo il test e l'inizializzazione della ram. Prevede quindi:
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa
;tuttavia, è possibile specificare operazioni diverse per la gestione dei dispositivi IO, in caso si desidera ad esempio lasciare invariato il setup dei dispositivi
bios_warm_boot:         call bios_IO_device_initialize
                        ;da implementare
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
; A <- esito dell'operazione

bios_mass_memory_select_drive:  ;da implementare
                                ret 

;bios_mass_memory_get_bps restituisce il numero di bytes per settore 

;A <- bytes per settore (codificato in multipli di 128 bytes) 
;     assume 0 se non è stato selezionato un dispositivo

bios_mass_memory_get_bps:           ;da implementare
                                    ret 

;bios_mass_memory_get_spt restituisce il numero di settori per traccia
;A <- bytes settori per traccia
;     assume 0 se non è stato selezionato un dispositivo

bios_mass_memory_get_spt:           ;da implementare 
                                    ret 

;bios_mass_memory_get_tph restituisce il numero di tracce per testina
;HL <- traccia per testina
;     assume 0 se non è stato selezionato un dispositivo
bios_mass_memory_get_tph:           ;da implementare
                                    ret 


;bios_mass_memory_get_head_number restituisce il numero di destine del dispositivo
;A <- numero di testine
;     assume 0 se non è stato selezionato un dispositivo
bios_mass_memory_get_head_number:   ;da implementare
                                    ret 

;bios_mass_memory_select_sector
; A -> settore da selezionare 
; A <- esito dell'operazione
bios_mass_memory_select_sector: ;da implementare
                                ret 

;bios_mass_memory_select_track
; HL -> traccia da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_track:  ;da implementare
                                ret 

;bios_mass_memory_select_head
; A -> testina da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_head:   ;da implementare
                                ret 

;bios_mass_memory_status verifica lo stato del dispositivo selezionato 
; A <- stato del dispositivo ($ff se è operativo)
bios_mass_memory_status:    ;da implementare
                            ret 

;Le seguenti funzioni servono per interagire con il lettore selezionato nella memoria di massa.
;-  bios_mass_memory_write_sector scrive i dati nel settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo in memoria dei dati da scrivere
;-  bios_mass_memory_read_sector legge i dati dal settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo della ram per indicare dove scrivere i dati ricevuti
;-  bios_mass_memory_format_drive formatta l'intero disco, sovrascrivendo tutti i dati e restituisce l'esito dell'operazione

;bios_mass_memory_write_sector
; HL -> indirizzo in memoria 
; A <- esito dell'operazione
bios_mass_memory_write_sector:      ;da implementare
                                    ret 

; bios_mass_memory_read_sector
; HL -> indirizzo in memoria
; A <- esito dell'operazione
bios_mass_memory_read_sector:       ;da implementare
                                    ret 

;bios_mass_memory_format_drive
; A <- esito dell'operazione
bios_mass_memory_format_drive:  ;da implementare
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

;bios_memory_transfer_reverse viene utilizzata per la copia di grandi quantità di dati all'interno della memoria. Dato che alcuni dispositivi DMA possono gestire il trasferimento mem-to-mem si preferisce mantenere 
;questa funzione nel bios. Nel caso non sia presente un dispositivo DMA o non sia disponibile la funzionalità, è possibile implementare una copoa software dei dati
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

;l'implementazione della funzione può essere utilizzato in tutte le implementazioni. Se viene installato un dispositivo DMA può essere modificata secondo le sue caratteristiche

BIOS_layer_end:
.print "Space left in MMS layer ->",BIOS_dimension-BIOS_layer_end+BIOS
.memory "fill", BIOS_layer_end, BIOS_dimension-BIOS_layer_end+BIOS,$00
.print "BIOS load address ->",BIOS
.print "All functions built successfully"