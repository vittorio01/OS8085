;La FSM ha il compito si mantenere, creare, aggiornare strutture dati per la gestione delle memorie di massa. Nel BIOS vengono già implementate le funzioni per:
;-  selezionare un dispositivo  (selezione)
;-  selezionare un settore      (ricerca)
;-  leggere un settore          (scrittura)
;-  srivere su un settore       (lettura)

;Definiamo come file l'insieme di dati di N byte di lunghezza suddivisi in due differenti sezioni:
;-  intestazione, che contiene le informazioni sul file (nome, estenzione, permessi, tipologia, data di creazione ecc)
;-  corpo, che rappresenta il contenuto del file 

;Cosideriamo la memoria di massa ideale come un grande spazio di archiviazione in cui è possibile effettuare accesso sequenziale e non randomico come avviene nelle RAM.   
;Di conseguenza:
;-  Per leggere un dato nella posizione M bisogna attraversare tutti i dati nelle posizioni p < M
;-  Per modificare i dati bisogna caricarli in memoria RAM, dato che la memoria di massa conta come un dispositivo IO
;-  Invece di prelevare un singolo dato viene caricato in memoria un blocco di lunghezza predefinita.
;Generalmente memoria di massa viene molto spesso organizzata in dischi, suddivisi in:
;-  Testine, che identificano il supporto di memorizzazione desiderato (ad esempio in un hard disk possono essere presenti più dischi)
;-  Tracce, che identificano il cilindo da cui prelevare i dati
;-  Settori, che identificano il blocco di dati all'interno della traccia selezionata

;Di conseguenza, in un supporto di memorizzazione si possono salvare fino a
;(numero blocchi) = (numero testine) * (numero di tracce per testina) * (numero settori per traccia)

;Il problema nella gestione dei dati si manifesta quando si vanno incontro a questi problemi:
;-  vengono memorizzati molto spesso files di dimensione differente
;-  i files possono essere aggiunti, rimossi, modificati in dimensione (lunghezza variabile del file) o spostati

;per comodità viene presa in considerazione un insieme di settori del disco (una pagina) composta da  più settori.
;----- Struttura dei files -----
;Un file è dotato di intestazine e corpo, che vengono separati e memorizzati in due diverse zone della memoria. L'intestazione è formata da:
;-  tipo        ->  un byte che identifica la tipologia di file. I bit assumono valori diversi secondo le seguenti caratteristiche:
;               * bit 8 -> distingue il marker EOL (0) da un intestazione valida (1)
;               * bit 7 -> indica se l'intestazione è stata eliminata (1) 
;               * bit 6 -> indica se il file è di sistema (1) 
;               * bit 5 -> indica se il file è eseguibile (1)
;               * bit 4 -> indica se il file è nascosto (1)
;               * bit 3 -> indica se il file è di sola lettura (1)
;               
;-  nome        -> 20 bytes per memorizzare nome del file. La stringa prevede una dimensione massima di 20 bytes, ma può essere interrotta prima di questo limite 
;                  tramite il carattere terminatore ($00)
;-  estenzione  -> 5 bytes per memorizzare l'estenzione del file. La stringa prevede una dimensione massima di 5 bytes, ma può essere interrotta prima di questo limite 
;                  tramite il carattere terminatore ($00)
;-  dimensione  -> 4 bytes che indicano la dimensione del file (in bytes)
;-  dati        -> 2 bytes che mantengono l'indirizzo della prima pagina dei dati

;-------------------------------------------------------------------------------------------
;- tipo - nome ed estenzione - dimensione (in pagine) - puntatore alla prima pagina dati -
;-------------------------------------------------------------------------------------------

;L'intestazione di un file è quindi di dimensione fissa prestabilita (28 bytes)

;----- Tabella di allocazione -----
;Il corpo dei files viene spezzato in pagine e salvato in posizioni non per forza contigue del disco. Un file di dimensione N se deve essere salvato in un disco 
;che contiene pagine di dimensione P occupa N/P blocchi per memorizzare le informazioni (senza contare l'intestazione di dimensione fissa)

;Per tener traccia della posizione di tutti i blocchi occupati dal file viene utilizzata una lista concatenata:

; --- 0001 ---      --- 0040 ---        --- 0030 ---
; - pagina 1 -  ->  - pagina 2 -    ->  - pagina 3 -
; ------------      ------------        ------------

;Per fare questo la tabella di allocazione ha il compito di mantenere al suo interno la posizione di tutti i blocchi salvati nel disco:
;-  la tabella è formata da linee a 16 bit che contengono l'indirizzo al blocco successivo
;-  ad ogni riga della tabella è associato un blocco di riferimento (ad esempio alla riga 3 è associata la pagina 3)

;nell'esempio precedente la tabella contiene 

;         --------------
;  0001   ---- 0040 ----
;         ***************
;  0030   ---- EOF  ----
;         ***************
;  0040   ---- 0030 ----
;         --------------

;Fisicamente, la tabella viene memorizzata nelle prime pagine (in modo adiacente) del file system e le riche vengono inserite in modo sequenziale (una riga occupa due bytes)

;            0      1      2      3      4              <- parte meno significativa dell'indirizzo (considrando $0000 il primo byte nella pagina della tabella)
;  0000   | xxxx | xxxx | xxxx | xxxx | xxxx | ***
;  0010   | xxxx | xxxx | xxxx | xxxx | xxxx | ***
;  0010   | xxxx | xxxx | xxxx | xxxx | xxxx | ***

;Per salvare i dati è quindi necessario inserire l'intestazione, che contiene l'indirizzo della pagina di partenza, e modificare opportunamente la tabella di allocazione
;Nella tabella, se l'indirizzo della pagina successiva risulta $ffff vuol dire che non è concatenata a nessun'altra pagina (EOF)
;----- Gestione delle intestazioni -----
;le intestazioni hanno tutte la stessa dimensione e, dato che non è presente un sistema per la gestione delle directories, vengono messe in modo sequenziale all'interno delle pagine
;nel caso in cui i dati superano la dimensione di una pagina, viene creata una seconda pagina in cui verranno inseriti in seguito le nuove intestazioni.
;Le pagine vengono poi collegate utilizzando la stessa tabella di allocazione introdotta precedentemente.

;----- Gestione dei blocchi liberi -----
;Per tener traccia dei blocchi liberi viene utilizzata ancora una volta la tabella di allocazione. In particolare, ogni blocco libero mantiene nella sua riga relativa l'indirizzo alla prossima
; pagina libera.

; -------------------------         -------------------------       -------------------------
; - pagina intestazioni 1 -  ->     - pagina intestazioni 2 -  ->   - pagina intestazioni 3 -  -> ***
; -------------------------         -------------------------       -------------------------
;            |                                  |                               
;        ----------                         ----------
;          File 1                             File 2 
;        ----------                         ----------
;            |                                  |
;         pagina 0                           pagina 0
;            |                                  | 
;         pagina 1                           pagina 1 
;            |                                  |
;          *****                              *****

;----- Struttura del file system ------
; Il disco viene scomposto nelle seguenti parti:
;-  Il settore di avvio (il primo settore) contiene tutte le specifiche del disco tra cui:
;       * istruzione di salto                   (3 bytes) un istruzione di salto alla parte eseguibile del settore di avvio
;       * marcatore di formattazione            (6 bytes)
;       * numero di testine del disco           (1 byte)
;       * numero di tracce per testina          (2 bytes)
;       * numero di settori per traccia         (1 byte)
;       * numero di bytes per settore           (1 byte)
;       * numero di settori per pagina          (1 byte)
;       * numero di pagine dedicate alla fat    (1 byte)
;       * numero di pagine dedicate ai dati     (2 bytes)
;       * puntatore al primo settore della fat  (4 bytes)
;       Il resto del settore contiene le istruzioni per l'avvio del sistema operativo (se presenti)

;-  Il sistema operativo occupa una certa zona riservata del disco, oltre alla parte rimanente del settore di avvio, e può avere una dimensione massima di 64KB (dato che deve essere caricao in memoria)
;   All'avvio, il computer carica in memoria tutto il codice de sistema operativo ed esegue l'istruzione di salto del settore di avvio
;-  La File Allocation Table contiene la tabella di allocazione, la sua dimensione dipende dal numero di pagine disponibili nel disco 
;-  La zona dati comprende la parte restante del disco e contiene intestazioni e corpo dei files, organizzati come detto precedentemente
;----------------------------------------------------------------------
;- settore di avvio - sistema operativo (opzionale) - FAT - Zona dati -
;----------------------------------------------------------------------
;La prima intestazione presente nella zona dati comprende i dati generali sul file system:
;-  Nome del disco (20 bytes)
;-  numero di blocchi liberi (2 bytes)
;-  puntatore al primo blocco libero (2 bytes)

.include "os_constraints.8085.asm"
.include "mms_system_calls.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "bios_system_calls.8085.asm"
.include "environment_variables.8085.asm"

fsm_selected_disk                       .equ reserved_memory_start + $0030
fsm_selected_disk_head_number           .equ reserved_memory_start + $0031
fsm_selected_disk_tph_number            .equ reserved_memory_start + $0032 
fsm_selected_disk_spt_number            .equ reserved_memory_start + $0034 
fsm_selected_disk_bps_number            .equ reserved_memory_start + $0035
fsm_selected_disk_sectors_number        .equ reserved_memory_start + $0036
fsm_selected_disk_spp_number            .equ reserved_memory_start + $003A
fsm_selected_disk_data_first_sector     .equ reserved_memory_start + $003B

fsm_page_buffer_segment_id              .equ reserved_memory_start + $003D
fsm_page_buffer_segment_address         .equ reserved_memory_start + $003E

fsm_selected_disk_data_page_number      .equ reserved_memory_start + $0040
fsm_selected_disk_fat_page_number       .equ reserved_memory_start + $0042


;fsm_selected_disk_loaded_page_flags contiene le informazioni sul disco selezionato 

fsm_disk_loaded_flags_selected_disk_mask        .equ %10000000
fsm_disk_loaded_flags_formatted_disk_mask       .equ %01000000
fsm_disk_loaded_flags_bootable_disk             .equ %00100000
fsm_disk_loaded_flags_loaded_page_mask          .equ %00010000
fsm_disk_loaded_flags_loaded_page_type_mask     .equ %00001000
fsm_disk_loaded_flags_header_modified_page_mask .equ %00000100
fsm_disk_loaded_flags_header_selected_mask      .equ %00000010
fsm_disk_loaded_flags_header_data_pointer_mask  .equ %00000001

fsm_selected_disk_loaded_page               .equ reserved_memory_start + $0043
fsm_selected_disk_loaded_page_flags         .equ reserved_memory_start + $0045
fsm_selected_disk_free_page_number          .equ reserved_memory_start + $0046
fsm_selected_disk_first_free_page_address   .equ reserved_memory_start + $0048

fsm_selected_file_header_page_address       .equ reserved_memory_start + $004A
fsm_selected_file_header_php_address        .equ reserved_memory_start + $004C

fsm_selected_file_data_pointer_page_address .equ reserved_memory_start + $004E 
fsm_selected_file_data_pointer_offset       .equ reserved_memory_start + $0050

fsm_coded_page_dimension                .equ 4
fsm_uncoded_page_dimension              .equ 512
fsm_boot_sector_start_position          .equ $0020
fsm_boot_sector_compile_address_offset  .equ low_memory_start

fsm_format_marker_lenght            .equ 6 

fsm_header_dimension                .equ 32 



fsm_functions:  .org FSM 
                ;funzioni dedicate alla gestione del disco 
                jmp fsm_init                                        ;inizializza le risorse della fsm
                jmp fsm_close                                       ;chiude le risorse della fsm
                jmp fsm_select_disk                                 ;seleziona il drive desiderato
                jmp fsm_format_disk                                 ;formatta il disco precedentemente selezionato
                jmp fsm_wipe_disk                                   ;elimina tutti i file nel disco (non elimina la zona riservata al sistema)
                jmp fsm_disk_set_name                               ;imposta il nome al disco
                jmp fsm_disk_get_name                               ;legge il nome del disco
                jmp fsm_disk_get_free_space                         ;restituisce il numero di bytes disponibili nel disco 
                ;funzioni dedicate alla gestione delle intestazioni 
                jmp fsm_search_file_header                          ;ricerca il file desiderato
                jmp fsm_select_file_header                          ;seleziona il file desiderato
                jmp fsm_create_file_header                          ;crea il file desiderato        
                jmp fsm_get_selected_file_header_name               ;restituisce il nome del file selezionato
                jmp fsm_get_selected_file_header_extension          ;restituisce l'estenzione del file selezionato
                jmp fsm_get_selected_file_header_flags              ;restituisce le informazioni sul tipo di file selezionato
                jmp fsm_get_selected_file_header_dimension          ;restituisce la dimensione del file selezionato
                jmp fsm_set_selected_file_header_name_and_extension ;imposta nome ed estenzione al file selezionato 
                jmp fsm_set_selected_file_header_flags              ;imposta le informazioni sul file selezionato
                jmp fsm_delete_selected_file_header                 ;elimina il file selezionato
                jmp fsm_reset_file_header_scan_pointer              ;resetta il puntatore alla lista dei files diponibili  
                jmp fsm_increment_file_header_scan_pointer          ;incrementa il puntatore alla lista dei files disponibili
                ;funzioni dedicate alla gestione del corpo dei files 
                jmp fsm_selected_file_append_data_bytes             ;aumenta la dimensione del file selezionato
                jmp fsm_selected_file_remove_data_bytes             ;diminuisce la dimensione del file selezionato
                jmp fsm_selected_file_write_bytes                   ;scrive dei dati sul file selezionato
                jmp fsm_selected_file_read_bytes                    ;legge dei dati dal file selezionato
                jmp fsm_selected_file_wipe                          ;elimina tutto il contenuto del file 
                jmp fsm_selected_file_set_data_pointer              ;imposta il puntatore nel corpo del file 
                jmp fsm_load_selected_program                       ;carica il programma nella memoria e lo predispone per essere avviato
                ;funzioni per la gestione della sezione riservata al sistema 
                jmp fsm_selected_disk_get_system                    ;legge i dati dalla sezione riservata al sistema 
                jmp fsm_selected_disk_set_system                    ;scrive i dati dalla sezione riservata al sistema
                jmp fsm_selected_disk_get_boot_section              ;legge i dati dalla boot section 
                jmp fsm_selected_disk_set_boot_section              ;scrive i dati nella boot section 
                jmp fsm_selected_disk_set_bootable                  ;imposta il disco come avviabile 
                jmp fsm_selected_disk_unset_bootable                ;imposta il disco come non avviabile 
                jmp fsm_selected_disk_get_boot_section_dimension    ;restituisce la dimensione della zona dedicata alla boot section 
                jmp fsm_selected_disk_get_system_section_dimension  ;restituisce la dimensione della zona dedicata al sistema 
                jmp fsm_selected_disk_is_bootable                   ;indica sel il disco selezionato è avviabile o non

fsm_format_marker   .text "SFS1.0"
                    .b $00

fsm_default_disk_name   .text "NEW DISK"
                        .b $00


;fsm_init inizializza la fsm 

fsm_init:       push h 
                xra a 
                sta fsm_selected_disk
                sta fsm_selected_disk_loaded_page
                sta fsm_selected_disk_loaded_page+1
                sta fsm_selected_disk_loaded_page_flags
                mvi a,$ff
                sta fsm_page_buffer_segment_id
                call fsm_reselect_mms_segment
                cpi fsm_operation_ok
                jnz fsm_init_end 
fsm_init_end:   pop h 
                ret 


;fsm_close chiude tutte le risorse della fsm 
;A <- esito dell'operazione 

fsm_close:      call fsm_writeback_page
                cpi fsm_operation_ok
                rnz 
                lda fsm_page_buffer_segment_id
                call mms_delete_selected_low_memory_data_segment
                cpi mms_operation_ok
                rnz 
                mvi a,fsm_operation_ok
                ret 

;fsm_select_disk seleziona il disco desiderato 
;A -> disco da selezionare (ASCII)
;A <- esito dell'operazione

fsm_select_disk:                cpi $41
                                jc fsm_select_disk_bad_argument
                                cpi $5A
                                jc fsm_select_disk_next
fsm_select_disk_bad_argument:   mvi a,fsm_bad_argument 
                                ret 
fsm_select_disk_next:           sta fsm_selected_disk 
                                push h
                                push d 
                                call bios_mass_memory_select_drive
                                ora a  
                                jnz fsm_select_next2
                                mvi a,%00000000
                                sta fsm_selected_disk_loaded_page_flags
                                mvi a,fsm_device_not_found
                                jmp fsm_select_disk_end
fsm_select_next2:               call bios_mass_memory_get_bps
                                sta fsm_selected_disk_bps_number
                                mvi a,fsm_disk_loaded_flags_selected_disk_mask
                                sta fsm_selected_disk_loaded_page_flags
                                call bios_mass_memory_get_spt
                                mov b,a 
                                sta fsm_selected_disk_spt_number
                                call bios_mass_memory_get_head_number
                                mov c,a 
                                sta fsm_selected_disk_head_number
                                call bios_mass_memory_get_tph
                                shld fsm_selected_disk_tph_number
                                call unsigned_multiply_byte
                                xchg 
                                call unsigned_multiply_word 
                                xchg 
                                shld fsm_selected_disk_sectors_number
                                xchg 
                                mov l,c 
                                mov h,b 
                                shld fsm_selected_disk_sectors_number+2
                                lxi b,0 
                                lxi d,0 
                                call fsm_seek_disk_sector
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end       
                                mov a,b 
                                call bios_mass_memory_select_sector
                                cpi bios_operation_ok
                                jnz fsm_select_disk_end
                                mov a,c 
                                call bios_mass_memory_select_head
                                cpi bios_operation_ok
                                jnz fsm_select_disk_end
                                xchg 
                                call bios_mass_memory_select_track
                                cpi bios_operation_ok
                                jnz fsm_select_disk_end
                                call fsm_reselect_mms_segment
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end
                                lxi h,0
                                call mms_mass_memory_read_sector
                                cpi mms_operation_ok
                                jnz fsm_select_disk_end    
                                lxi h,3
                                lxi d,fsm_format_marker
                                mvi a,fsm_format_marker_lenght
                                call string_segment_ncompare
                                ora a 
                                jnz fsm_select_disk_formatted_disk
                                mvi a,fsm_unformatted_disk 
                                jmp fsm_select_disk_end
fsm_select_disk_formatted_disk: lda fsm_selected_disk_loaded_page_flags
                                ori fsm_disk_loaded_flags_formatted_disk_mask
                                sta fsm_selected_disk_loaded_page_flags
                                lxi h,0 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end 
                                cpi $c9 
                                jnz fsm_select_disk_not_bootable
                                lda fsm_selected_disk_loaded_page_flags 
                                ori fsm_disk_loaded_flags_bootable_disk
                                sta fsm_selected_disk_loaded_page_flags 
fsm_select_disk_not_bootable:   lxi h,fsm_format_marker_lenght+7 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end 
                                sta fsm_selected_disk_spp_number
                                inx h 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end 
                                sta fsm_selected_disk_fat_page_number
                                inx h 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end  
                                sta fsm_selected_disk_data_page_number
                                inx h 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end  
                                sta fsm_selected_disk_data_page_number+1
                                inx h 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end 
                                sta fsm_selected_disk_data_first_sector
                                inx h 
                                call mms_read_selected_data_segment_byte
                                jc fsm_select_disk_end  
                                sta fsm_selected_disk_data_first_sector+1
                                call fsm_reset_file_header_scan_pointer
                                call fsm_load_disk_free_pages_informations
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end
                                mvi a,fsm_operation_ok
fsm_select_disk_end:            pop d 
                                pop h 
                                ret 

;fsm_disk_format formatta il disco e prepara il file system di base 
; HL -> dimensione della sezione riservata al sistema (in bytes)

fsm_format_disk:                        push b 
                                        push d 
                                        push h 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani fsm_disk_loaded_flags_selected_disk_mask
                                        jnz fsm_format_disk_next
                                        mvi a,fsm_disk_not_selected
                                        jmp fsm_disk_external_generated_error
fsm_format_disk_next:                   call bios_mass_memory_format_drive   
                                        cpi bios_operation_ok 
                                        jnz fsm_disk_external_generated_error
                                        lda fsm_selected_disk
                                        call bios_mass_memory_select_drive
                                        ora a 
                                        jnz fsm_format_disk_next2
                                        mvi a,fsm_device_not_found
                                        jmp fsm_disk_external_generated_error
fsm_format_disk_next2:                  call bios_mass_memory_get_bps
                                        sta fsm_selected_disk_bps_number
                                        mvi a,fsm_disk_loaded_flags_selected_disk_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        call bios_mass_memory_get_spt
                                        mov b,a 
                                        sta fsm_selected_disk_spt_number
                                        call bios_mass_memory_get_head_number
                                        mov c,a 
                                        sta fsm_selected_disk_head_number
                                        call bios_mass_memory_get_tph
                                        shld fsm_selected_disk_tph_number
                                        call unsigned_multiply_byte
                                        xchg 
                                        call unsigned_multiply_word 
                                        xchg 
                                        shld fsm_selected_disk_sectors_number
                                        xchg 
                                        mov l,c 
                                        mov h,b 
                                        shld fsm_selected_disk_sectors_number+2
                                        lda fsm_selected_disk_bps_number
                                        mov c,a 
                                        mvi b,fsm_coded_page_dimension
                                        call unsigned_divide_byte 
                                        mov a,b
                                        sta fsm_selected_disk_spp_number 
                                        lda fsm_selected_disk_bps_number
                                        mov b,a 
                                        mvi c,128
                                        call unsigned_multiply_byte
                                        mov e,c 
                                        mov d,b 
                                        pop b
                                        push b
                                        mov a,b
                                        ora c
                                        jz fsm_format_disk_jump1
                                        call unsigned_divide_word
                                        mov a,e 
                                        ora d 
                                        jz fsm_format_disk_jump1
                                        inx b 
fsm_format_disk_jump1:                  inx b 
                                        mov l,c 
                                        mov h,b 
                                        shld fsm_selected_disk_data_first_sector
                                        xra a 
                                        call bios_mass_memory_select_head
                                        cpi bios_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        xra a 
                                        call bios_mass_memory_select_sector
                                        cpi bios_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        lxi h,0 
                                        call bios_mass_memory_select_track
                                        cpi bios_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        call fsm_reselect_mms_segment
                                        cpi fsm_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        call fsm_clear_mms_segment
                                        cpi fsm_operation_ok
                                        lxi h,0 
                                        jnz fsm_disk_external_generated_error
                                        mvi a,$c9 
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error 
                                        inx h 
                                        inx h 
                                        inx h 
                                        lxi d,fsm_format_marker
                                        mvi a,fsm_format_marker_lenght 
                                        call string_segment_ncopy
                                        mvi a,fsm_format_marker_lenght 
                                        add l 
                                        mov l,a 
                                        mov a,h 
                                        aci 0 
                                        mov h,a 
                                        lda fsm_selected_disk_sectors_number
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+1
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+2
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error 
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+3
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        lda fsm_selected_disk_spp_number
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        lxi d,0 
                                        push d 
                                        lxi d,fsm_coded_page_dimension 
                                        push d 
                                        lda fsm_selected_disk_data_first_sector
                                        mov e,a 
                                        lda fsm_selected_disk_data_first_sector+1
                                        mov d,a 
                                        lda fsm_selected_disk_sectors_number
                                        sub e 
                                        mov e,a 
                                        lda fsm_selected_disk_sectors_number+1
                                        sub d 
                                        mov d,a 
                                        lda fsm_selected_disk_sectors_number+2
                                        sbi 0 
                                        mov c,a 
                                        lda fsm_selected_disk_sectors_number+3
                                        sbi 0 
                                        mov b,a 
                                        push b 
                                        push d 
                                        call unsigned_divide_long
                                        pop d 
                                        pop d 
                                        pop d 
                                        pop b
                                        mov a,e 
                                        sta fsm_selected_disk_data_page_number
                                        mov a,d 
                                        sta fsm_selected_disk_data_page_number+1
                                        push b  
                                        lxi b,fsm_uncoded_page_dimension+2
                                        push b 
                                        lxi b,0
                                        mov a,e 
                                        add a 
                                        mov e,a 
                                        mov a,d 
                                        ral 
                                        mov d,a 
                                        mov a,c 
                                        ral 
                                        mov c,a
                                        push b 
                                        push d 
                                        call unsigned_divide_long
                                        pop d 
                                        pop b 
                                        mov a,e 
                                        ora d 
                                        ora c 
                                        ora b 
                                        jz fsm_format_disk_jump2 
                                        mvi a,1
fsm_format_disk_jump2:                  pop d 
                                        pop b 
                                        add e 
                                        mov e,a 
                                        sta fsm_selected_disk_fat_page_number
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error 
                                        inx h 
                                        lda fsm_selected_disk_data_page_number
                                        sub e 
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        sta fsm_selected_disk_data_page_number
                                        lda fsm_selected_disk_data_page_number+1
                                        sbi 0 
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        sta fsm_selected_disk_data_page_number+1
                                        lda fsm_selected_disk_data_first_sector
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        lda fsm_selected_disk_data_first_sector+1  
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error  
                                        inx h 
                                        mvi A,0 
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error 
                                        inx h 
                                        mvi a,0 
                                        call mms_write_selected_data_segment_byte
                                        jc fsm_disk_external_generated_error 
                                        lxi h,0
                                        call mms_mass_memory_write_sector
                                        cpi mms_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        mvi a,fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        call fsm_wipe_disk 
                                        cpi fsm_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        lxi d,fsm_default_disk_name
                                        call fsm_disk_set_name
                                        cpi fsm_operation_ok
                                        mvi a,fsm_operation_ok 
fsm_disk_external_generated_error:      pop h 
                                        pop d 
                                        pop b 
                                        ret 


;fsm_disk_set_name sostituisce il nome del disco con quello fornito
;DE -> puntatore alla stringa del nome 
;A <- esito dell'operazione

fsm_disk_set_name:                  push h
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                    xri $ff 
                                    jnz fsm_disk_set_name_next 
                                    mvi a,fsm_disk_not_selected
                                    jmp fsm_disk_set_name_end
fsm_disk_set_name_next:             lxi h,0 
                                    call fsm_move_data_page
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    lxi h,0 
                                    mvi a,fsm_disk_name_max_lenght
                                    call string_segment_ncopy
                                    call fsm_writeback_page
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    mvi a,fsm_operation_ok
fsm_disk_set_name_end:              pop h 
                                    ret 

;fsm_disk_get_name restituisce il nome del disco 
; A <- esito dell'operazione 
; SP <- [nome del disco]

fsm_disk_get_name:                  push h 
                                    push d
                                    push b 
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                    xri $ff 
                                    jnz fsm_disk_get_name_next 
                                    mvi a,fsm_disk_not_selected
                                    jmp fsm_disk_set_name_end
fsm_disk_get_name_next:             lxi h,0 
                                    call fsm_move_data_page
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_get_name_end
                                    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_get_name_end
                                    lxi h,0 
                                    lxi d,fsm_disk_name_max_lenght
fsm_disk_get_name_loop:             call fsm_read_selected_data_segment_byte
                                    jc fsm_disk_get_name_end
                                    ora a  
                                    jz fsm_disk_get_name_loop_end
                                    inx h 
                                    dcx d 
                                    mov a,e 
                                    ora d 
                                    jnz fsm_disk_get_name_loop
fsm_disk_get_name_loop_end:         xchg 
                                    lxi d,fsm_disk_name_max_lenght+1
                                    mov a,e 
                                    sub l 
                                    mov e,a 
                                    mov c,a 
                                    mov a,d 
                                    sbb h 
                                    mov d,a
                                    mov b,a 
                                    lxi h,0 
                                    dad sp 
                                    mov a,l 
                                    sub e 
                                    mov l,a 
                                    mov a,h 
                                    sbb d 
                                    mov h,a 
                                    mvi d,4 
fsm_disk_get_name_stack_push:       xthl 
                                    mov a,l 
                                    xthl 
                                    mov m,a 
                                    inx h 
                                    xthl 
                                    mov a,h 
                                    xthl 
                                    mov m,a 
                                    inx h 
                                    inx sp 
                                    inx sp 
                                    dcr d 
                                    jnz fsm_disk_get_name_stack_push
                                    mov e,l 
                                    mov d,h 
                                    mov a,e 
                                    sui 8 
                                    mov l,a 
                                    mov a,d 
                                    sbi 0 
                                    mov h,a 
                                    sphl 
                                    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_get_name_end
                                    lxi h,0
                                    xchg 
                                    mvi a,fsm_disk_name_max_lenght
                                    call string_segment_source_ncopy
                                    dad b 
                                    mvi m,0 
                                    mvi a,fsm_operation_ok 
fsm_disk_get_name_end:              pop b 
                                    pop d 
                                    pop h 
                                    ret 

;fsm_disk_get_free_space restituisce il numero di bytes disponibili nel disco 
;A <- esito dell'operazione 
;BCDE <- dimensione dello spazio disponibile 

fsm_disk_get_free_space:            lda fsm_selected_disk_loaded_page_flags
                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                    xri $ff 
                                    jnz fsm_disk_get_free_space_next 
                                    mvi a,fsm_disk_not_selected
                                    ret 
fsm_disk_get_free_space_next:       push h 
                                    lhld fsm_selected_disk_free_page_number
                                    xchg 
                                    pop h 
                                    lxi b,fsm_uncoded_page_dimension
                                    call unsigned_multiply_word
                                    mvi a,fsm_operation_ok
                                    ret 

;fsm_wipe_disk inizializza la fat table del dispositivo selezionato
;A -> esito dell'operazione

fsm_wipe_disk:                                  lda fsm_selected_disk_loaded_page_flags
                                                ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                xri $ff 
                                                jnz fsm_wipe_disk_disk_selected
                                                mvi a,fsm_disk_not_selected
                                                ret 
fsm_wipe_disk_disk_selected:                    push h 
                                                push d 
                                                push b 
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_wipe_disk_reset_end
                                                call fsm_clear_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_wipe_disk_reset_end
                                                lxi h,0 
                                                xchg                                    ; bc -> pagina fat 
                                                lhld fsm_selected_disk_data_page_number ; de -> pagina corrente (valore da scrivere)
                                                push h                                  ; HL -> puntatore al buffer
                                                lxi h,0                                 ; sp -> [numero di pagine]                                      
                                                xchg                                                                                                                           
                                                mvi a,$ff 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                inx h 
                                                mvi a,$ff 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                inx h 
                                                inx d
                                                inx d 
fsm_wipe_disk_loop:                             xthl 
                                                mov a,l 
                                                sub e 
                                                mov a,h 
                                                sbb d 
                                                xthl 
                                                jc fsm_wipe_disk_loop_end
                                                mov a,e 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_loop_buffer_verify 
                                                inx h 
                                                mov a,d 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_loop_buffer_verify
                                                inx h 
                                                inx d 
                                                jmp fsm_wipe_disk_loop
fsm_wipe_disk_loop_buffer_verify:               cpi mms_segment_segmentation_fault_error_code
                                                jnz fsm_wipe_disk_reset_end
fsm_wipe_disk_load_page:                        mov a,c 
                                                inr c 
                                                call fsm_write_fat_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_wipe_disk_load_page_error
                                                call fsm_clear_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_wipe_disk_load_page_error
                                                lxi h,0
                                                jmp fsm_wipe_disk_loop
fsm_wipe_disk_loop_end:                         dcx h 
                                                mvi a,$ff 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                dcx h 
                                                mvi a,$ff 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                mov a,c
                                                call fsm_write_fat_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_wipe_disk_load_page_error
                                                lxi h,0 
                                                call fsm_read_data_page
                                                cpi fsm_operation_ok
                                                jnz fsm_wipe_disk_load_page_error
                                                lxi h,fsm_disk_name_max_lenght
                                                xchg 
                                                lhld fsm_selected_disk_data_page_number
                                                dcx h 
                                                xchg 
                                                mov a,e 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                inx h 
                                                mov a,d 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                inx h 
                                                mvi a,1 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                inx h 
                                                mvi a,0 
                                                call fsm_write_selected_data_segment_byte
                                                jc fsm_wipe_disk_load_page_error
                                                shld fsm_selected_disk_first_free_page_address
                                                lxi h,fsm_header_dimension
fsm_wipe_disk_header_space_format:              mvi a,0 
                                                call fsm_write_selected_data_segment_byte
                                                inx h 
                                                jnc fsm_wipe_disk_header_space_format
                                                cpi mms_segment_segmentation_fault_error_code
                                                jnz fsm_wipe_disk_load_page_error
                                                lxi h,0 
                                                call fsm_write_data_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_wipe_disk_load_page_error
fsm_wipe_disk_loop_end2:                        inx sp 
                                                inx sp  
                                                call fsm_load_disk_free_pages_informations
                                                cpi fsm_operation_ok
                                                jnz fsm_wipe_disk_reset_end
                                                mvi a,fsm_operation_ok
fsm_wipe_disk_reset_end:                        pop b 
                                                pop d 
                                                pop h 
                                                ret 
fsm_wipe_disk_load_page_error:                  inx sp 
                                                inx sp 
                                                jmp fsm_wipe_disk_reset_end

;funzioni dedicate allo spazio riservato

;fsm_selected_disk_get_boot_section_dimension restituice la dimensione della boot section 
;A <- esito dell'operazione
;HL <- dimensione in bytes
fsm_selected_disk_get_boot_section_dimension:                   lda fsm_selected_disk_loaded_page_flags
                                                                xri $ff 
                                                                ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                                jz fsm_selected_disk_get_boot_section_dimension_next
                                                                ani fsm_disk_loaded_flags_selected_disk_mask
                                                                jz fsm_selected_disk_get_boot_section_dimension_not_formatted
                                                                mvi a,fsm_disk_not_selected
                                                                lxi h,0 
                                                                ret
fsm_selected_disk_get_boot_section_dimension_not_formatted:     mvi a,fsm_unformatted_disk 
                                                                lxi h,0 
                                                                ret  
fsm_selected_disk_get_boot_section_dimension_next:              lda fsm_selected_disk_bps_number
                                                                stc 
                                                                cmc 
                                                                mvi l,0 
                                                                rar
                                                                mov h,a 
                                                                mov a,l 
                                                                rar 
                                                                sbi fsm_boot_sector_start_position
                                                                mov l,a 
                                                                mov a,h 
                                                                sbi 0 
                                                                mov h,a 
                                                                jc fsm_selected_disk_get_boot_section_dimension_error
                                                                ora l 
                                                                jnz fsm_selected_disk_get_boot_section_dimension_ok
fsm_selected_disk_get_boot_section_dimension_error:             mvi a,fsm_boot_section_not_found 
                                                                ret                                               
fsm_selected_disk_get_boot_section_dimension_ok:                mvi a,fsm_operation_ok
                                                                ret 

;fsm_selected_disk_get_system_section_dimension restituisce la dimensione dello spazio dedicato al sistema 
;A <- esito dell'operazione 
;HL <- dimensione in bytes
fsm_selected_disk_get_system_section_dimension:                     lda fsm_selected_disk_loaded_page_flags
                                                                    xri $ff 
                                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                                    jz fsm_selected_disk_get_system_section_dimension_next
                                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                                    jz fsm_selected_disk_get_system_section_dimension_not_formatted
                                                                    mvi a,fsm_disk_not_selected
                                                                    lxi h,0 
                                                                    ret
fsm_selected_disk_get_system_section_dimension_not_formatted:       mvi a,fsm_unformatted_disk 
                                                                    lxi h,0 
                                                                    ret  
fsm_selected_disk_get_system_section_dimension_next:                push d 
                                                                    push b 
                                                                    lda fsm_selected_disk_bps_number
                                                                    stc 
                                                                    cmc 
                                                                    mvi c,0 
                                                                    rar
                                                                    mov b,a 
                                                                    mov a,c
                                                                    rar 
                                                                    mov c,a 
                                                                    lhld fsm_selected_disk_data_first_sector
                                                                    dcx h 
                                                                    mov a,l 
                                                                    ora h  
                                                                    jnz fsm_selected_disk_get_system_section_dimension_ok
                                                                    mvi a,fsm_system_section_not_found 
                                                                    jmp fsm_selected_disk_get_system_section_dimension_end
fsm_selected_disk_get_system_section_dimension_ok:                  xchg 
                                                                    call unsigned_multiply_word
                                                                    xchg 
                                                                    mvi a,fsm_operation_ok
fsm_selected_disk_get_system_section_dimension_end:                 pop b 
                                                                    pop d 
                                                                    ret 

;fsm_selected_disk_is_bootable indica se il disco è avviabile o non 
;A <- stato del disco (in caso di errore restituisce l'error code)

fsm_selected_disk_is_bootable:                      lda fsm_selected_disk_loaded_page_flags
                                                    xri $ff 
                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                    jz fsm_selected_disk_is_bootable_next
                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                    jz fsm_selected_disk_is_bootable_not_formatted
                                                    mvi a,fsm_disk_not_selected
                                                    ret
fsm_selected_disk_is_bootable_not_formatted:        mvi a,fsm_unformatted_disk 
                                                    ret  
fsm_selected_disk_is_bootable_next:                 lda fsm_selected_disk_loaded_page_flags
                                                    ani fsm_disk_loaded_flags_bootable_disk
                                                    jnz fsm_selected_disk_bootable
                                                    mvi a,fsm_disk_not_bootable
                                                    ret 
fsm_selected_disk_bootable:                         mvi a,fsm_disk_bootable
                                                    ret  

;fsm_selected_disk_set_boot_section trasferisce il contenuto da un segmento di memoria al settore di avvio del disco 
;A -> segmento sorgente
;HL -> offset nel segmento sorgente
fsm_selected_disk_set_boot_section:                 push b
                                                    push d
                                                    push h
                                                    push psw 
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    
                                                    xri $ff 
                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                    jz fsm_selected_disk_set_boot_section_next
                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                    jz fsm_selected_disk_set_boot_section_not_formatted
                                                    mvi a,fsm_disk_not_selected
                                                    jmp fsm_selected_disk_set_boot_section_end
fsm_selected_disk_set_boot_section_not_formatted:   mvi a,fsm_unformatted_disk 
                                                    jmp fsm_selected_disk_set_boot_section_end
fsm_selected_disk_set_boot_section_next:            call fsm_writeback_page
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    lxi b,0 
                                                    lxi d,0 
                                                    call fsm_seek_disk_sector
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    mov a,b 
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    lxi b,fsm_boot_sector_start_position
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi e,0 
                                                    rar
                                                    mov d,a 
                                                    mov a,e 
                                                    rar 
                                                    mov e,a
                                                    lxi b,fsm_boot_sector_start_position
                                                    mov a,e 
                                                    sub c 
                                                    mov c,a 
                                                    mov a,d 
                                                    sbb b 
                                                    mov b,a 
                                                    lxi h,fsm_uncoded_page_dimension
                                                    mov a,l 
                                                    sub e 
                                                    mov l,a 
                                                    mov a,h 
                                                    sbb d 
                                                    mov h,a 
                                                    mov e,l 
                                                    mov d,h  
                                                    call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    call mms_mass_memory_read_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    xthl 
                                                    mov a,h 
                                                    xthl 
                                                    call mms_select_low_memory_data_segment
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    mov l,e 
                                                    mov h,d 
                                                    mvi a,fsm_boot_sector_start_position
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    lda fsm_page_buffer_segment_id 
                                                    push d
                                                    inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov e,l 
                                                    mov d,h 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    call mms_segment_data_transfer
                                                    pop h
                                                    cpi mms_operation_ok
                                                    jz fsm_selected_disk_set_boot_section_transfer_ok
                                                    cpi mms_destination_segment_overflow
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    mvi a,fsm_not_enough_spage_left
                                                    jmp fsm_selected_disk_set_boot_section_end
fsm_selected_disk_set_boot_section_transfer_ok:     call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    call mms_mass_memory_write_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_boot_section_end
                                                    mvi a,fsm_operation_ok
fsm_selected_disk_set_boot_section_end:             inx sp 
                                                    inx sp 
                                                    pop h
                                                    pop d
                                                    pop b
                                                    ret 

;fsm_selected_disk_get_boot_section trasferisce il contenuto del settore di avvio nel segmento di memoria
;A -> segmento destinazione 
;HL -> offset nel segmento destinazione
fsm_selected_disk_get_boot_section:                 push b
                                                    push d
                                                    push h
                                                    push psw 
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    xri $ff 
                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                    jz fsm_selected_disk_get_boot_section_next
                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                    jz fsm_selected_disk_get_boot_section_not_formatted
                                                    mvi a,fsm_disk_not_selected
                                                    jmp fsm_selected_disk_get_boot_section_end
fsm_selected_disk_get_boot_section_not_formatted:   mvi a,fsm_unformatted_disk 
                                                    jmp fsm_selected_disk_get_boot_section_end
fsm_selected_disk_get_boot_section_next:            call fsm_writeback_page
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    lxi b,0 
                                                    lxi d,0 
                                                    call fsm_seek_disk_sector
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    lxi b,fsm_boot_sector_start_position
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi e,0 
                                                    rar
                                                    mov d,a 
                                                    mov a,e 
                                                    rar 
                                                    mov e,a
                                                    lxi b,fsm_boot_sector_start_position
                                                    mov a,e 
                                                    sub c 
                                                    mov c,a 
                                                    mov a,d 
                                                    sbb b 
                                                    mov b,a 
                                                    lxi h,0
                                                    call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    call mms_mass_memory_read_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end
                                                    lxi h,fsm_boot_sector_start_position
                                                    xthl 
                                                    mov a,h 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov e,l 
                                                    mov d,h 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    xchg 
                                                    call mms_segment_data_transfer
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_get_boot_section_end      
fsm_selected_disk_get_boot_section_transfer_ok:     mvi a,fsm_operation_ok
fsm_selected_disk_get_boot_section_end:             inx sp 
                                                    inx sp 
                                                    pop h
                                                    pop d
                                                    pop b
                                                    ret 
            

;fsm_selected_disk_set_bootable rende il disco selezionato avviabile 
;HL -> load address del settore di avvio (vedi note)
;A <- esito dell'operazione
fsm_selected_disk_set_bootable:                 push b
                                                push d 
                                                push h
                                                lda fsm_selected_disk_loaded_page_flags
                                                xri $ff 
                                                ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                                jz fsm_selected_disk_set_bootable_next
                                                ani fsm_disk_loaded_flags_selected_disk_mask
                                                jz fsm_selected_disk_set_bootable_not_formatted
                                                mvi a,fsm_disk_not_selected
                                                jmp fsm_selected_disk_set_bootable_end
fsm_selected_disk_set_bootable_not_formatted:   mvi a,fsm_unformatted_disk
                                                jmp fsm_selected_disk_set_bootable_end
fsm_selected_disk_set_bootable_next:            call fsm_writeback_page
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end 
                                                lxi b,0 
                                                lxi d,0 
                                                call fsm_seek_disk_sector
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end
                                                mov a,c 
                                                call bios_mass_memory_select_head
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end
                                                xchg 
                                                call bios_mass_memory_select_track
                                                cpi bios_operation_ok 
                                                jnz fsm_selected_disk_set_bootable_end
                                                mov a,b 
                                                call bios_mass_memory_select_sector
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end
                                                lxi h,0 
                                                call fsm_reselect_mms_segment
                                                call mms_mass_memory_read_sector
                                                cpi mms_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end
                                                pop h 
                                                push h 
                                                lxi d,fsm_boot_sector_start_position
                                                dad d 
                                                xchg 
                                                lxi h,0 
                                                mvi a,$c3
                                                call mms_write_selected_data_segment_byte
                                                jc fsm_selected_disk_set_bootable_end
                                                inx h 
                                                mov a,e 
                                                call mms_write_selected_data_segment_byte
                                                jc fsm_selected_disk_set_bootable_end
                                                inx h 
                                                mov a,d 
                                                call mms_write_selected_data_segment_byte
                                                jc fsm_selected_disk_set_bootable_end
                                                lxi h,0 
                                                call mms_mass_memory_write_sector
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_set_bootable_end
                                                lda fsm_selected_disk_loaded_page_flags
                                                ori fsm_disk_loaded_flags_bootable_disk
                                                sta fsm_selected_disk_loaded_page_flags
                                                mvi a,fsm_operation_ok
fsm_selected_disk_set_bootable_end:             pop h
                                                pop d 
                                                pop b
                                                ret 

;fsm_selected_disk_unset_bootable rende il disco selezionato non avviabile 

fsm_selected_disk_unset_bootable:               push h 
                                                push d 
                                                push b 
                                                lda fsm_selected_disk_loaded_page_flags
                                                xri $ff
                                                ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask 
                                                jz fsm_selected_disk_unset_bootable_next
                                                ani fsm_disk_loaded_flags_selected_disk_mask
                                                jz fsm_selected_disk_unset_bootable_not_formatted
                                                mvi a,fsm_disk_not_selected
                                                jmp fsm_selected_disk_unset_bootable_end
fsm_selected_disk_unset_bootable_not_formatted: mvi a,fsm_unformatted_disk
                                                jmp fsm_selected_disk_unset_bootable_end
fsm_selected_disk_unset_bootable_next:          call fsm_writeback_page
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                lxi b,0 
                                                lxi d,0 
                                                call fsm_seek_disk_sector
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                mov a,c 
                                                call bios_mass_memory_select_head
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                xchg 
                                                call bios_mass_memory_select_track
                                                cpi bios_operation_ok 
                                                jnz fsm_selected_disk_unset_bootable_end
                                                mov a,b 
                                                call bios_mass_memory_select_sector
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                lxi h,0 
                                                call fsm_reselect_mms_segment
                                                call mms_mass_memory_read_sector
                                                cpi mms_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                lxi h,0 
                                                mvi a,$c9 
                                                call mms_write_selected_data_segment_byte
                                                jc fsm_selected_disk_unset_bootable_end
                                                lxi h,0 
                                                call mms_mass_memory_write_sector
                                                cpi bios_operation_ok
                                                jnz fsm_selected_disk_unset_bootable_end
                                                lda fsm_selected_disk_loaded_page_flags
                                                ani $ff-fsm_disk_loaded_flags_bootable_disk
                                                sta fsm_selected_disk_loaded_page_flags
                                                mvi a,fsm_operation_ok
fsm_selected_disk_unset_bootable_end:           pop b 
                                                pop d 
                                                pop h 
                                                ret 

;fsm_selected_disk_get_system legge i dati dalla zona riservata al sistema operativo del disco e li salva nel segmento di destinazione
;A -> id del segmento di destinazione
;BC -> numero di dati da prelevare
;DE -> offset nella zona riservata
;HL -> offset nel segmento di destinazione 

;A <- esito dell'operazione

fsm_selected_disk_get_system:                       push d
                                                    push b
                                                    push h
                                                    push psw 
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    xri $ff
                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask 
                                                    jz fsm_selected_disk_get_system_next
                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                    jz fsm_selected_disk_get_system_not_formatted
                                                    mvi a,fsm_disk_not_selected
                                                    jmp fsm_selected_disk_get_system_end
fsm_selected_disk_get_system_not_formatted:         mvi a,fsm_unformatted_disk
                                                    jmp fsm_selected_disk_get_system_end
fsm_selected_disk_get_system_next:                  call fsm_writeback_page
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_system_end
                                                    call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end
                                                    xchg 
                                                    dad b 
                                                    xchg 
                                                    mov c,e 
                                                    mov b,d
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi e,0 
                                                    rar
                                                    mov d,a 
                                                    mov a,e 
                                                    rar 
                                                    mov e,a
                                                    call unsigned_divide_word 
                                                    mov a,e 
                                                    ora d 
                                                    jz fsm_selected_disk_get_system_no_remainder
                                                    inx b 
fsm_selected_disk_get_system_no_remainder:          lhld fsm_selected_disk_data_first_sector
                                                    dcx h 
                                                    mov a,l 
                                                    sub c 
                                                    mov a,h 
                                                    sbb b 
                                                    jnc fsm_selected_disk_get_system_dimension_ok
                                                    mvi a,fsm_system_section_overflow 
                                                    jmp fsm_selected_disk_get_system_end
fsm_selected_disk_get_system_dimension_ok:          xchg 
                                                    lxi b,0 
                                                    lxi d,1 
                                                    call fsm_seek_disk_sector
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_system_end
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_end
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_end
                                                    xchg 
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_end
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi l,0 
                                                    rar
                                                    mov h,a 
                                                    mov a,l 
                                                    rar 
                                                    mov l,a
                                                    lxi b,fsm_uncoded_page_dimension
                                                    mov a,c 
                                                    sub l 
                                                    mov l,a 
                                                    mov a,b 
                                                    sbb h 
                                                    mov h,a 
                                                    push h 
                                                    call mms_mass_memory_read_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end3
                                                    pop h 
                                                    push h 
                                                    dad d 
                                                    push h
                                                    lxi h,6
                                                    dad sp 
                                                    sphl  
                                                    xthl 
                                                    mov e,l 
                                                    mov d,h  
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov c,l 
                                                    mov b,h 
                                                    xthl                      ;BC -> numero di bytes da copiare 
                                                    lxi h,$ffff-8+1          ;DE -> offset buffer di partenza 
                                                    dad sp 
                                                    sphl                      ;HL -> offset nel segmento di destinazione 
                                                    xchg                      ;SP -> [settore corrente][offset iniziale][id segmento]
                                                    pop d  
                                                    push psw                    
                                                    xthl 
                                                    lxi h,1 
                                                    xthl
fsm_selected_disk_get_system_loop:                  inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,h 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    call mms_segment_data_transfer
                                                    cpi mms_operation_ok
                                                    jz fsm_selected_disk_get_system_loop_ok
                                                
                                                    cpi mms_source_segment_overflow
                                                    jnz fsm_selected_disk_get_system_loop_end
                                                    xthl 
                                                    inx h 
                                                    push d 
                                                    push b 
                                                    mov e,l 
                                                    mov d,h 
                                                    lxi b,0
                                                    call fsm_seek_disk_sector
                                                    
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end2
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end2
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end2
                                                    xchg 
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end2
                                                    pop b 
                                                    pop d 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    pop d 
                                                    push d
                                                    dcx sp 
                                                    dcx sp 
                                                    xchg 
                                                    call mms_mass_memory_read_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_get_system_loop_end 
                                                    xchg 
                                                    inx sp 
                                                    inx sp 
                                                    pop d
                                                    push d 
                                                    dcx sp 
                                                    dcx sp 
                                                    jmp fsm_selected_disk_get_system_loop
fsm_selected_disk_get_system_loop_ok:               mvi a,fsm_operation_ok
                                                    jmp fsm_selected_disk_get_system_loop_end
fsm_selected_disk_get_system_loop_end2:             pop b 
                                                    pop d       
fsm_selected_disk_get_system_loop_end:              inx sp 
                                                    inx sp  
fsm_selected_disk_get_system_loop_end3:             inx sp 
                                                    inx sp                           
fsm_selected_disk_get_system_end:                   inx sp 
                                                    inx sp 
                                                    pop h
                                                    pop b
                                                    pop d 
                                                    ret 

;fsm_selected_disk_set_system legge i dati dalla zona riservata al sistema operativo del disco e li salva nel segmento di destinazione
;A -> id del segmento di destinazione
;BC -> numero di dati da prelevare
;DE -> offset nel segmento sorgente
;HL -> offset nella zona di sistema

;A <- esito dell'operazione

fsm_selected_disk_set_system:                       push d
                                                    push b
                                                    push h
                                                    push psw 
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    xri $ff
                                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask 
                                                    jz fsm_selected_disk_set_system_next
                                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                                    jz fsm_selected_disk_set_system_not_formatted
                                                    mvi a,fsm_disk_not_selected
                                                    jmp fsm_selected_disk_set_system_end
fsm_selected_disk_set_system_not_formatted:         mvi a,fsm_unformatted_disk
                                                    jmp fsm_selected_disk_set_system_end
fsm_selected_disk_set_system_next:                  call fsm_writeback_page
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_end
                                                    call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    
                                                    dad b 
                                                    xchg 
                                                    mov c,e 
                                                    mov b,d
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi e,0 
                                                    rar
                                                    mov d,a 
                                                    mov a,e 
                                                    rar 
                                                    mov e,a
                                                    call unsigned_divide_word 
                                                    mov a,e 
                                                    ora d 
                                                    jz fsm_selected_disk_set_system_no_remainder
                                                    inx b 
fsm_selected_disk_set_system_no_remainder:          lhld fsm_selected_disk_data_first_sector
                                                    dcx h 
                                                    mov a,l 
                                                    sub c 
                                                    mov a,h 
                                                    sbb b 
                                                    jnc fsm_selected_disk_set_system_dimension_ok
                                                    mvi a,fsm_system_section_overflow 
                                                    jmp fsm_selected_disk_set_system_end
fsm_selected_disk_set_system_dimension_ok:          xchg 
                                                    lxi b,0 
                                                    lxi d,1 
                                                    call fsm_seek_disk_sector
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_end
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_end
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_end
                                                    xchg 
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_end
                                                    lda fsm_selected_disk_bps_number
                                                    stc 
                                                    cmc 
                                                    mvi l,0 
                                                    rar
                                                    mov h,a 
                                                    mov a,l 
                                                    rar 
                                                    mov l,a
                                                    lxi b,fsm_uncoded_page_dimension
                                                    mov a,c 
                                                    sub l 
                                                    mov l,a 
                                                    mov a,b 
                                                    sbb h 
                                                    mov h,a 
                                                    push h 
                                                    call mms_mass_memory_read_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end3
                                                    pop h 
                                                    push h 
                                                    dad d 
                                                    push h
                                                    lxi h,6
                                                    dad sp 
                                                    sphl  
                                                    xthl 
                                                    mov e,l 
                                                    mov d,h  
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov c,l 
                                                    mov b,h 
                                                    xthl                      ;BC -> numero di bytes da copiare 
                                                    lxi h,$ffff-8+1           ;DE -> offset nel segmento di partenza
                                                    dad sp 
                                                    sphl                      ;HL -> offset nel buffer di destinazione 
                                                    xchg                      ;SP -> [settore corrente][offset iniziale][id segmento]
                                                    pop d  
                                                    push psw                    
                                                    xthl 
                                                    lxi h,1 
                                                    xthl
                                                    xchg 
                                                    
fsm_selected_disk_set_system_loop:                  inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,h 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    dcx sp 
                                                    call mms_select_low_memory_data_segment
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    lda fsm_page_buffer_segment_id
                                                    call mms_segment_data_transfer
                                                    cpi mms_operation_ok
                                                    jz fsm_selected_disk_set_system_loop_ok                             
                                                    cpi mms_destination_segment_overflow
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    call fsm_reselect_mms_segment
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    inx sp 
                                                    inx sp 
                                                    pop h 
                                                    push h
                                                    dcx sp 
                                                    dcx sp
                                                    call mms_mass_memory_write_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    xthl 
                                                    inx h 
                                                    push d 
                                                    push b 
                                                    mov e,l 
                                                    mov d,h 
                                                    lxi b,0
                                                    call fsm_seek_disk_sector
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    xchg 
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    pop b 
                                                    pop d 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    pop h 
                                                    push h
                                                    dcx sp 
                                                    dcx sp
                                                    call mms_mass_memory_read_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    inx sp 
                                                    inx sp 
                                                    pop h
                                                    push h 
                                                    dcx sp 
                                                    dcx sp 
                                                    jmp fsm_selected_disk_set_system_loop
fsm_selected_disk_set_system_loop_ok:               xthl 
                                                    mov e,l 
                                                    mov d,h 
                                                    lxi b,0
                                                    call fsm_seek_disk_sector
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    mov a,c
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    xchg 
                                                    call bios_mass_memory_select_track
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    xchg 
                                                    mov a,b
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end2
                                                    inx sp 
                                                    inx sp 
                                                    pop h 
                                                    push h 
                                                    dcx sp 
                                                    dcx sp 
                                                    call mms_mass_memory_write_sector
                                                    cpi mms_operation_ok
                                                    jnz fsm_selected_disk_set_system_loop_end
                                                    mvi a,fsm_operation_ok
                                                    jmp fsm_selected_disk_set_system_loop_end
fsm_selected_disk_set_system_loop_end2:             pop b 
                                                    pop d       
fsm_selected_disk_set_system_loop_end:              inx sp 
                                                    inx sp  
fsm_selected_disk_set_system_loop_end3:             inx sp 
                                                    inx sp                           
fsm_selected_disk_set_system_end:                   inx sp 
                                                    inx sp 
                                                    pop h
                                                    pop b
                                                    pop d 
                                                    ret 


;funzioni dedicare alla gestone del corpo dei files

;fsm_load_selected_program carica in memoria il file precedentemente selezionato (verifica se è eseguibile e se rientra nella dimensione della ram disponibile)
;A <- esito dell'operazione 
fsm_load_selected_program:                      push h 
                                                push d 
                                                push b 
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_load_selected_program_end
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                ani fsm_header_program_bit
                                                jnz fsm_load_selected_program_verified
                                                mvi a,fsm_selected_file_not_executable 
fsm_load_selected_program_verified:             lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                dad d 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                mov e,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                mov d,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end 
                                                mov c,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                mov b,a 
                                                inx h
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                mov a,c 
                                                ora b 
                                                jz fsm_load_selected_program_dimension_check
                                                mvi a,fsm_program_too_big 
                                                jmp fsm_load_selected_program_end
fsm_load_selected_program_dimension_check:      mov c,e 
                                                mov b,d 
                                                xchg 
                                                call mms_free_low_ram_bytes
                                                mov a,l 
                                                sub c 
                                                mov a,h 
                                                sbb b
                                                jnc fsm_load_selected_program_dimension_ok 
                                                mvi a,fsm_program_too_big
                                                jmp fsm_load_selected_program_end
fsm_load_selected_program_dimension_ok:         mov l,c 
                                                mov h,b 
                                                call mms_load_low_memory_program
                                                cpi mms_operation_ok
                                                jnz fsm_load_selected_program_end
                                                xchg 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end
                                                mov e,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_load_selected_program_end 
                                                mov d,a 
                                                xchg 
                                                call fsm_move_data_page
                                                cpi fsm_operation_ok
                                                jnz fsm_load_selected_program_end
                                                push h                                  ;SP -> [pagina corrente]
                                                lxi d,0 
                                                lxi h,0 
fsm_load_selected_program_load_loop:            call mms_program_bytes_write
                                                cpi mms_operation_ok
                                                jz fsm_load_selected_program_load_loop_end
                                                cpi fsm_source_segment_overflow
                                                jnz fsm_load_selected_program_end2
                                                xthl 
                                                call fsm_get_page_link
                                                cpi fsm_operation_ok
                                                jnz fsm_load_selected_program_end2
                                                call fsm_move_data_page
                                                cpi fsm_operation_ok
                                                jnz fsm_load_selected_program_end2
                                                lxi d,0 
                                                xthl 
                                                jmp fsm_load_selected_program_load_loop
fsm_load_selected_program_load_loop_end:        mvi a,fsm_operation_ok
fsm_load_selected_program_end2:                 inx sp 
                                                inx sp 
fsm_load_selected_program_end:                  pop b 
                                                pop d 
                                                pop h 
                                                ret 

;fsm_selected_file_write_bytes scrive i bytes contenuti nel file precedentemente selezionato di un segmento di memoria a scelta 
;A -> id del segmento di destinazione 
;BC -> numero di bytes da copiare 
;HL -> offset nel segmento sorgente

;A <- esito dell'operazione 
;BC <- numero di bytes non copiati
;HL -> offset dopo l'esecuzione

fsm_selected_file_write_bytes:              push d   
                                            push psw 
                                            lda fsm_selected_disk_loaded_page_flags
                                            ani fsm_disk_loaded_flags_header_data_pointer_mask
                                            jnz fsm_selected_file_write_bytes_next 
                                            mvi a,fsm_data_pointer_not_setted
                                            jmp fsm_selected_file_write_bytes_end2
fsm_selected_file_write_bytes_next:         call fsm_get_selected_file_header_flags
                                            jc fsm_selected_file_write_bytes_end2
                                            ani fsm_header_readonly_bit
                                            jz fsm_selected_file_write_bytes_next2
                                            mvi a,fsm_read_only_file
                                            jmp fsm_selected_file_write_bytes_end2
fsm_selected_file_write_bytes_next2:        xchg               
                                            lhld fsm_selected_file_data_pointer_page_address 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_write_bytes_end2
                                            push h                                              ;SP -> [pagina corrente][id sorgente]
                                            lhld fsm_selected_file_data_pointer_offset  
fsm_Selected_file_write_bytes_loop:         inx sp 
                                            inx sp 
                                            xthl 
                                            mov a,h 
                                            xthl 
                                            dcx sp 
                                            dcx sp 
                                            call mms_select_low_memory_data_segment
                                            cpi mms_operation_ok
                                            jnz fsm_selected_file_write_bytes_end
                                            lda fsm_page_buffer_segment_id
                                            call fsm_page_set_modified_flag
                                            
                                            call mms_segment_data_transfer
                                            
                                            cpi mms_operation_ok
                                            jz fsm_selected_file_write_bytes_loop_end
                                            cpi mms_source_segment_overflow
                                            jnz fsm_selected_file_write_bytes_loop2
                                            mvi a,fsm_source_segment_overflow
                                            jmp fsm_selected_file_write_bytes_end
fsm_Selected_file_write_bytes_loop2:        cpi mms_destination_segment_overflow
                                            jnz fsm_selected_file_write_bytes_end
                                            xthl 
                                            call fsm_get_page_link
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_write_bytes_end
                                        
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_write_bytes_end
                                            xthl 
                                            lxi h,0 
                                            jmp fsm_Selected_file_write_bytes_loop
fsm_Selected_file_write_bytes_loop_end:     
                                            call fsm_writeback_page
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_write_bytes_end
                                            mvi a,fsm_operation_ok
fsm_selected_file_write_bytes_end:          inx sp 
                                            inx sp 
fsm_selected_file_write_bytes_end2:         inx sp 
                                            inx sp 
                                            xchg 
                                            pop d 
                                            ret 

;fsm_selected_file_read_bytes scrive i bytes contenuti in un segmento nel file precedentemente selezionato
;A -> id del segmento di destinazione 
;BC -> numero di bytes da copiare 
;HL -> offset nel segmento sorgente

;A <- esito dell'operazione 
;BC <- numero di bytes non copiati
;HL <- offset dopo l'esecuzione 

fsm_selected_file_read_bytes:               push d 
                                            push psw  
                                            lda fsm_selected_disk_loaded_page_flags
                                            ani fsm_disk_loaded_flags_header_data_pointer_mask
                                            jnz fsm_selected_file_read_bytes_next  
                                            mvi a,fsm_data_pointer_not_setted
                                            jmp fsm_selected_file_read_bytes_end2   
fsm_selected_file_read_bytes_next:          xchg               
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_read_bytes_end2                        
                                            lhld fsm_selected_file_data_pointer_page_address 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_read_bytes_end2
                                            push h                                              ;SP -> [pagina corrente][id destinazione]
                                            lhld fsm_selected_file_data_pointer_offset  
                                            xchg
fsm_Selected_file_read_bytes_loop:          inx sp 
                                            inx sp 
                                            xthl 
                                            mov a,h 
                                            xthl 
                                            dcx sp 
                                            dcx sp                  
                                            call fsm_page_set_modified_flag
                                            call mms_segment_data_transfer
                                            cpi mms_operation_ok
                                            jz fsm_Selected_file_read_bytes_loop_end
                                            cpi mms_destination_segment_overflow
                                            jnz fsm_Selected_file_read_bytes_loop2
                                            mvi a,fsm_destination_segment_overflow
                                            jmp fsm_selected_file_read_bytes_end
fsm_Selected_file_read_bytes_loop2:         cpi mms_source_segment_overflow
                                            jnz fsm_selected_file_read_bytes_end
                                            xthl 
                                            call fsm_get_page_link
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_read_bytes_end3
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_read_bytes_end3
                                            xthl 
                                            lxi d,0 
                                            jmp fsm_Selected_file_read_bytes_loop
fsm_Selected_file_read_bytes_end3:          xthl 
                                            jmp fsm_selected_file_read_bytes_end
fsm_Selected_file_read_bytes_loop_end:      mvi a,fsm_operation_ok
fsm_selected_file_read_bytes_end:           inx sp 
                                            inx sp 
                                            xchg 
fsm_selected_file_read_bytes_end2:          xchg 
                                            inx sp 
                                            inx sp 
                                            pop d 
                                            ret 

;fsm_selected_file_set_data_pointer imposta la posizione del puntatore nel file precedentemente selezionato 
;BCDE -> posizione 
; A <- esito dell'operazione 
fsm_selected_file_set_data_pointer:             push h 
                                                push b
                                                push d 
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_set_data_pointer_end
fsm_selected_file_set_data_pointer_next:        lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1
                                                dad b 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov e,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov d,a 
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov c,a 
                                                inx h  
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov b,a 
                                                inx h 
                                                xthl 
                                                mov a,l 
                                                sub e
                                                mov a,h 
                                                sbb d 
                                                xthl 
                                                inx sp 
                                                inx sp 
                                                xthl 
                                                mov a,l 
                                                sbb c
                                                mov a,h
                                                sbb b
                                                xthl 
                                                dcx sp 
                                                dcx sp 
                                                jnc fsm_selected_file_set_data_pointer_error
                                                xthl 
                                                mov e,l 
                                                mov d,h 
                                                xthl 
                                                inx sp 
                                                inx sp 
                                                xthl 
                                                mov c,l 
                                                mov b,h 
                                                xthl 
                                                dcx sp 
                                                dcx sp 
                                                push h  
                                                lxi h,0 
                                                push h 
                                                lxi h,fsm_uncoded_page_dimension
                                                push h 
                                                push b 
                                                push d  
                                                call unsigned_divide_long 
                                                pop h
                                                shld fsm_selected_file_data_pointer_offset
                                                inx sp 
                                                inx sp  
                                                pop b
                                                inx sp 
                                                inx sp 
                                                pop h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov e,a
                                                inx h 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_selected_file_set_data_pointer_end
                                                mov d,a 
                                                xchg 
fsm_selected_file_set_data_pointer_loop:        mov a,c 
                                                ora b 
                                                jz fsm_selected_file_set_data_pointer_loop_end 
                                                call fsm_get_page_link
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_set_data_pointer_end
                                                dcx b 
                                                jmp fsm_selected_file_set_data_pointer_loop
fsm_selected_file_set_data_pointer_loop_end:    shld fsm_selected_file_data_pointer_page_address
                                                lda fsm_selected_disk_loaded_page_flags
                                                ori fsm_disk_loaded_flags_header_data_pointer_mask
                                                sta fsm_selected_disk_loaded_page_flags
                                                mvi a,fsm_operation_ok
                                                jmp fsm_selected_file_set_data_pointer_end
fsm_selected_file_set_data_pointer_error:       mvi a,fsm_file_pointer_overflow              
fsm_selected_file_set_data_pointer_end:         pop d  
                                                pop b
                                                pop h 
                                                ret  

;fsm_selected_file_remove_data_bytes aumenta la dimensione del file selezionato del numero di bytes richiesti
;il puntatore al copro del file viene resettato dopo l'esecuzione della funzione
;BCDE -> numero di bytes da aggiungere
;A <- esito dell'operazione

fsm_selected_file_remove_data_bytes:                push h 
                                                    push b 
                                                    push d  
                                                    call fsm_get_selected_file_header_flags
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    ani fsm_header_readonly_bit
                                                    jz fsm_selected_file_remove_data_bytes_rwfile
                                                    mvi a,fsm_read_only_file
                                                    jmp fsm_selected_file_remove_data_bytes_end
fsm_selected_file_remove_data_bytes_rwfile:         call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end
                                                    push d 
                                                    lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                    dad d 
                                                    pop d 
                                                                
                                                    push b 
                                                    push d                                           ;SP -> [numero di bytes (4)]
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end3
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end3
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end3
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end3
                                                    mov b,a 
                                                    xthl 
                                                    mov a,e 
                                                    sub l 
                                                    mov e,a 
                                                    mov a,d 
                                                    sbb h 
                                                    mov d,a 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,c 
                                                    sbb l 
                                                    mov c,a 
                                                    mov a,b 
                                                    sbb h 
                                                    mov b,a 
                                                    inx sp 
                                                    inx sp      
                                                    jc fsm_selected_file_remove_data_bytes_wipe   
                                                    ora c 
                                                    ora d 
                                                    ora e                                   
                                                    jnz fsm_selected_file_remove_data_bytes_no_wipe
fsm_selected_file_remove_data_bytes_wipe:           call fsm_selected_file_wipe
                                                    jmp fsm_selected_file_remove_data_bytes_end
fsm_selected_file_remove_data_bytes_no_wipe:        lxi h,0 
                                                    push h 
                                                    lxi h,fsm_uncoded_page_dimension
                                                    push h 
                                                    push b 
                                                    push d 
                                                    call unsigned_divide_long
                                                    pop h 
                                                    mov a,l 
                                                    ora h 
                                                    pop h 
                                                    ora l 
                                                    ora h 
                                                    jz fsm_selected_file_remove_data_bytes_remainder1 
                                                    mvi a,1 
fsm_selected_file_remove_data_bytes_remainder1:     pop h 
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    inx sp 
                                                    inx sp                          
                                                    push h                                                              ;SP -> [numero di pagine finale]
                                                    call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                    dad b 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov b,a 
                                                    lxi h,0 
                                                    push h 
                                                    lxi h,fsm_uncoded_page_dimension
                                                    push h 
                                                    push b 
                                                    push d 
                                                    call unsigned_divide_long
                                                    pop h 
                                                    mov a,l 
                                                    ora h 
                                                    pop h 
                                                    ora l 
                                                    ora h 
                                                    jz fsm_selected_file_remove_data_bytes_remainder2
                                                    mvi a,1
fsm_selected_file_remove_data_bytes_remainder2:     pop h 
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    inx sp 
                                                    inx sp 
                                                    pop d   
                                                    mov a,l
                                                    sub e 
                                                    mov l,a 
                                                    mov a,h 
                                                    sbb d 
                                                    mov h,a 
                                                    ora l
                                                    jz fsm_selected_file_remove_data_bytes_next4
                                                    push h                                              ;SP -> [pagine da eliminare]
                                                    call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end
                                                    mvi a,fsm_header_name_dimension+fsm_header_extension_dimension+5
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end4
                                                    mov b,a 
                                                    mov l,c  
                                                    mov h,b
fsm_selected_file_remove_data_bytes_loop:           mov a,e 
                                                    ora d 
                                                    jz fsm_selected_file_remove_data_bytes_loop_end 
                                                    dcx d
                                                    call fsm_get_page_link
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end4
                                                    jmp fsm_selected_file_remove_data_bytes_loop
fsm_selected_file_remove_data_bytes_loop_end:       pop d 
                                                    call fsm_set_first_free_page_list
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end
fsm_selected_file_remove_data_bytes_next4:          call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_remove_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1
                                                    dad b
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    mov b,a 
                                                    xthl 
                                                    mov a,e 
                                                    sub l 
                                                    mov e,a 
                                                    mov a,d 
                                                    sbb h 
                                                    mov d,a 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,c 
                                                    sbb l 
                                                    mov c,a 
                                                    mov a,b 
                                                    sbb h 
                                                    mov b,a 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    mov a,b 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    dcx h 
                                                    mov a,c 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    dcx h 
                                                    mov a,d 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    dcx h 
                                                    mov a,e 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_remove_data_bytes_end
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    ani $ff-fsm_disk_loaded_flags_header_data_pointer_mask
                                                    sta fsm_selected_disk_loaded_page_flags 
                                                    call fsm_writeback_page
                                                    jmp fsm_selected_file_remove_data_bytes_end
fsm_selected_file_remove_data_bytes_end3:           inx sp 
                                                    inx sp 
fsm_selected_file_remove_data_bytes_end4:           inx sp 
                                                    inx sp 
fsm_selected_file_remove_data_bytes_end:            pop d   
                                                    pop b   
                                                    pop h 
                                                    ret 

;fsm_selected_file_clear elimina tutto il contenuto del file selezionato precedentemente 
;il puntatore al copro del file viene resettato dopo l'esecuzione della funzione
; A <- esito dell'operazione 

fsm_selected_file_wipe:         push d 
                                push h 
                                push b 
                                call fsm_load_selected_file_header
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_wipe_end
                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+5 
                                dad d 
                                call fsm_read_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end
                                mov e,a 
                                inx h 
                                call fsm_read_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end
                                mov d,a 
                                xchg  
                                lxi b,0 
                                push h 
fsm_selected_file_wipe_next:    mov a,l 
                                ana h 
                                cpi $ff 
                                jz fsm_selected_file_wipe_next2
                                mov e,l 
                                mov d,h 
                                inx b 
                                call fsm_get_page_link
                                cpi fsm_operation_ok
                                jz fsm_selected_file_wipe_next 
                                inx sp 
                                inx sp 
                                jmp fsm_selected_file_wipe_end 
fsm_selected_file_wipe_next2:   mov a,c 
                                ora b 
                                jz fsm_selected_file_wipe_end2
                                pop h  
                                mov e,c 
                                mov d,b 
                                call fsm_set_first_free_page_list
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_wipe_end
                                call fsm_load_selected_file_header
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_wipe_end
                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+5 
                                dad d 
                                mvi a,$ff
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end
                                dcx h 
                                mvi a,$ff 
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end
                                dcx h 
                                mvi a,0
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end 
                                dcx h 
                                mvi a,0
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end 
                                dcx h 
                                mvi a,0
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end 
                                dcx h 
                                mvi a,0
                                call fsm_write_selected_data_segment_byte
                                jc fsm_selected_file_wipe_end 
fsm_selected_file_wipe_end2:    lda fsm_selected_disk_loaded_page_flags
                                ani $ff-fsm_disk_loaded_flags_header_data_pointer_mask-fsm_disk_loaded_flags_header_selected_mask
                                sta fsm_selected_disk_loaded_page_flags
                                call fsm_writeback_page
fsm_selected_file_wipe_end:     pop b 
                                pop h 
                                pop d 
                                ret 

;fsm_selected_file_append_data_bytes aumenta la dimensione del file selezionato del numero di bytes richiesti
;il puntatore al copro del file viene resettato dopo l'esecuzione della funzione
;BCDE -> numero di bytes da aggiungere
;A <- esito dell'operazione

fsm_selected_file_append_data_bytes:                push h 
                                                    push b 
                                                    push d  
                                                    call fsm_get_selected_file_header_flags 
                                                    jc fsm_selected_file_append_data_bytes_rwfile
                                                    ani fsm_header_readonly_bit
                                                    jz fsm_selected_file_append_data_bytes_rwfile
                                                    mvi a,fsm_read_only_file
                                                    jmp fsm_selected_file_append_data_bytes_end
fsm_selected_file_append_data_bytes_rwfile:         call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    push d 
                                                    lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                    dad d 
                                                    pop d 
                                                                
                                                    push b 
                                                    push d                                           ;SP -> [numero di bytes (4)]
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end3
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end3
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end3
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end3
                                                    mov b,a 
                                                    xthl 
                                                    mov a,e 
                                                    add l 
                                                    mov e,a 
                                                    mov a,d 
                                                    adc h 
                                                    mov d,a 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,c 
                                                    adc l 
                                                    mov c,a 
                                                    mov a,b 
                                                    adc h 
                                                    mov b,a 
                                                    inx sp 
                                                    inx sp                                          
                                                    
                                                    lxi h,0 
                                                    push h 
                                                    lxi h,fsm_uncoded_page_dimension
                                                    push h 
                                                    push b 
                                                    push d 
                                                    call unsigned_divide_long
                                                    pop h 
                                                    mov a,l 
                                                    ora h 
                                                    pop h 
                                                    ora l 
                                                    ora h 
                                                    jz fsm_selected_file_append_data_bytes_remainder1 
                                                    mvi a,1 
fsm_selected_file_append_data_bytes_remainder1:     pop h 
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    inx sp 
                                                    inx sp                          
                                                    push h                                           ;SP -> [numero di pagine finale]
                                                    call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                    dad b 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end4
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end4
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end4
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end4
                                                    mov b,a 
                                                    lxi h,0 
                                                    push h 
                                                    lxi h,fsm_uncoded_page_dimension
                                                    push h 
                                                    push b 
                                                    push d 
                                                    call unsigned_divide_long
                                                    pop h 
                                                    mov a,l 
                                                    ora h 
                                                    pop h 
                                                    ora l 
                                                    ora h 
                                                    jz fsm_selected_file_append_data_bytes_remainder2
                                                    mvi a,1
fsm_selected_file_append_data_bytes_remainder2:     pop h 
                                                    add l 
                                                    mov l,a 
                                                    mov a,h 
                                                    aci 0 
                                                    mov h,a 
                                                    inx sp 
                                                    inx sp 
                                                    xchg 
                                                    pop h                                       
                                                    mov a,l 
                                                    sub e 
                                                    mov l,a 
                                                    mov a,h 
                                                    sbb d 
                                                    mov h,a 
                                                    ora l
                                                    jz fsm_selected_file_append_data_bytes_next4
fsm_selected_file_append_data_bytes_next2:          xchg 
                                                    call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+5
                                                    dad b
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov b,a 
                                                    mov l,c 
                                                    mov h,b 
                                                    mov a,l 
                                                    ana h 
                                                    cpi $ff 
                                                    jnz fsm_selected_file_append_data_bytes_next3 
                                                    xchg 
                                                    call fsm_get_first_free_page_list
                                                    
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    xchg 
                                                    call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+5
                                                    dad b  
                                                    mov a,e 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    inx h 
                                                    mov a,d 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    jmp fsm_selected_file_append_data_bytes_next4
fsm_selected_file_append_data_bytes_next3:          mov l,c  
                                                    mov h,b 
                                                    call fsm_append_pages
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end4
fsm_selected_file_append_data_bytes_next4:          call fsm_load_selected_file_header
                                                    cpi fsm_operation_ok
                                                    jnz fsm_selected_file_append_data_bytes_end
                                                    lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1
                                                    dad b
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov e,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov d,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov c,a 
                                                    inx h 
                                                    call fsm_read_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    mov b,a 
                                                    xthl 
                                                    mov a,e 
                                                    add l 
                                                    mov e,a 
                                                    mov a,d 
                                                    adc h 
                                                    mov d,a 
                                                    xthl 
                                                    inx sp 
                                                    inx sp 
                                                    xthl 
                                                    mov a,c 
                                                    adc l 
                                                    mov c,a 
                                                    mov a,b 
                                                    adc h 
                                                    mov b,a 
                                                    xthl 
                                                    dcx sp 
                                                    dcx sp 
                                                    mov a,b 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    dcx h 
                                                    mov a,c 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    dcx h 
                                                    mov a,d 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    dcx h 
                                                    mov a,e 
                                                    call fsm_write_selected_data_segment_byte
                                                    jc fsm_selected_file_append_data_bytes_end
                                                    lda fsm_selected_disk_loaded_page_flags
                                                    ani $ff-fsm_disk_loaded_flags_header_data_pointer_mask
                                                    sta fsm_selected_disk_loaded_page_flags
                                                    call fsm_writeback_page
                                                    jmp fsm_selected_file_append_data_bytes_end

fsm_selected_file_append_data_bytes_end3:           inx sp 
                                                    inx sp 
fsm_selected_file_append_data_bytes_end4:           inx sp 
                                                    inx sp 
fsm_selected_file_append_data_bytes_end:            pop d   
                                                    pop b   
                                                    pop h 
                                                    ret 



;funzioni dedicate alla gestione fegli headers

;fsm_reset_file_header_scan_pointer inizializza il puntatore al file corrente

fsm_reset_file_header_scan_pointer: push h 
                                    lxi h,0 
                                    shld fsm_selected_file_header_page_address 
                                    lxi h,1 
                                    shld fsm_selected_file_header_php_address 
                                    pop h 
                                    ret 

;fsm_delete_selected_file_header elimina l'intestazione selezionata precedentemente 
; A <- esito dell'operazione 

fsm_delete_selected_file_header:        push h 
                                        push d 
                                        push b 
                                        call fsm_get_selected_file_header_flags
                                        jc fsm_delete_selected_file_header_end
                                        ani fsm_header_readonly_bit
                                        jz fsm_delete_selected_file_header_rwfile 
                                        mvi a,fsm_read_only_file
                                        jmp fsm_delete_selected_file_header_end
fsm_delete_selected_file_header_rwfile: lhld fsm_selected_file_header_page_address
                                        xchg 
                                        lda fsm_selected_file_header_php_address
                                        mov c,a 
                                        lda fsm_selected_file_header_php_address+1 
                                        mov b,a 
                                        call fsm_increment_file_header_scan_pointer
                                        cpi fsm_end_of_list
                                        jz fsm_delete_selected_file_header_last
                                        cpi fsm_operation_ok
                                        jnz fsm_delete_selected_file_header_end
                                        xchg 
                                        shld fsm_selected_file_header_page_address 
                                        mov l,c 
                                        mov h,b 
                                        shld fsm_selected_file_header_php_address
                                        call fsm_load_selected_file_header
                                        cpi fsm_operation_ok
                                        jnz fsm_delete_selected_file_header_end
                                        call fsm_read_selected_data_segment_byte
                                        jc fsm_delete_selected_file_header_end
                                        push psw 
                                        mvi a,fsm_header_deleted_bit
                                        xthl 
                                        ora h 
                                        xthl 
                                        inx sp 
                                        inx sp  
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_delete_selected_file_header_end
                                        call fsm_writeback_page
                                        jmp fsm_delete_selected_file_header_end
fsm_delete_selected_file_header_last:   xchg 
                                        shld fsm_selected_file_header_page_address 
                                        mov l,c 
                                        mov h,b 
                                        shld fsm_selected_file_header_php_address
                                        call fsm_load_selected_file_header
                                        cpi fsm_operation_ok
                                        jnz fsm_delete_selected_file_header_end
                                        call fsm_read_selected_data_segment_byte
                                        jc fsm_delete_selected_file_header_end
                                        push psw 
                                        xthl 
                                        mvi a,fsm_header_valid_bit
                                        xri $ff 
                                        ana h 
                                        xthl 
                                        inx sp 
                                        inx sp 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_delete_selected_file_header_end
                                        call fsm_reset_file_header_scan_pointer 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani $ff-fsm_disk_loaded_flags_header_selected_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        mvi a,fsm_operation_ok
fsm_delete_selected_file_header_end:    pop b 
                                        pop d 
                                        pop h 
                                        ret 

;fsm_increment_file_header_scan_pointer seleziona la prima intestazione valida successiva a quella corrente
; A <- esito dell'operazione 

fsm_increment_file_header_scan_pointer:         push h 
                                                push d 
                                                push b 
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok                                ;BC -> dimensione del buffer
                                                jnz fsm_increment_file_header_scan_pointer_end      ;DE -> pagina corrente                                 
                                                lxi d,0                                             ;HL -> puntatore al buffer    
fsm_increment_file_header_scan_pointer_loop:    lxi b,fsm_header_dimension
                                                dad b 
                                                lxi b,fsm_uncoded_page_dimension 
                                                mov a,l  
                                                sub c 
                                                mov a,h 
                                                sbb b
                                                jc fsm_increment_file_header_scan_pointer_loop2
                                                mov l,e 
                                                mov h,d 
                                                call fsm_get_page_link
                                                cpi fsm_operation_ok
                                                jnz fsm_increment_file_header_scan_pointer_end     
                                                mov a,l 
                                                ana h 
                                                cpi $ff 
                                                jz fsm_increment_file_header_scan_pointer_eol 
                                                call fsm_move_data_page
                                                cpi fsm_operation_ok 
                                                jnz fsm_increment_file_header_scan_pointer_end     
                                                mov e,l 
                                                mov d,h     
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_increment_file_header_scan_pointer_end 
                                                xthl 
                                                lxi h,0 
                                                xthl 
                                                jmp fsm_increment_file_header_scan_pointer_loop
fsm_increment_file_header_scan_pointer_loop2:   call fsm_read_selected_data_segment_byte
                                                jc fsm_increment_file_header_scan_pointer_end
                                                ani fsm_header_valid_bit
                                                jz fsm_increment_file_header_scan_pointer_eol 
                                                call fsm_read_selected_data_segment_byte
                                                jc fsm_increment_file_header_scan_pointer_end 
                                                ani fsm_header_deleted_bit
                                                jnz fsm_increment_file_header_scan_pointer_loop
                                                xchg  
                                                shld fsm_selected_file_header_page_address
                                                mov c,e 
                                                mov b,d 
                                                lxi d,fsm_header_dimension
                                                call unsigned_divide_word
                                                mov l,c 
                                                mov h,b 
                                                shld fsm_selected_file_header_php_address
                                                mvi a,fsm_operation_ok
                                                jmp fsm_increment_file_header_scan_pointer_end  
fsm_increment_file_header_scan_pointer_eol:     mvi a,fsm_end_of_list  
fsm_increment_file_header_scan_pointer_end:     pop b 
                                                pop d 
                                                pop h 
                                                ret 

;fsm_get_selected_file_header_flags restituisce le caratteristiche del file 
; A <- flags 
;PSW <- CY viene settato se la funzione restituisce un errore 

fsm_get_selected_file_header_flags:         push h 
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jz fsm_get_selected_file_header_flags_next 
                                            stc 
                                            jmp fsm_get_selected_file_header_flags_end
fsm_get_selected_file_header_flags_next:    call fsm_read_selected_data_segment_byte
                                            jc fsm_get_selected_file_header_flags_end
                                            stc 
                                            cmc 
fsm_get_selected_file_header_flags_end:     pop h 
                                            ret 

;fsm_set_selected_file_header_flags imposta le flags al file selezionato precedentemente
; A <- esito dell'operazione
fsm_set_selected_file_header_flags:         push h 
                                            ori fsm_header_valid_bit
                                            ani $ff-fsm_header_deleted_bit
                                            push psw 
fsm_set_selected_file_header_flags_next2:   call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_set_selected_file_header_flags_end
                                            pop psw 
                                            call fsm_write_selected_data_segment_byte
                                            jc fsm_set_selected_file_header_flags_end
                                            call fsm_writeback_page
fsm_set_selected_file_header_flags_end:     inx sp 
                                            inx sp 
                                            pop h 
                                            ret 

;fsm_get_selected_file_header_first_page_address restituisce il primo indirizzo della pagina che punta al corpo del file selezionato precedentemente 
;A <- esito dell'operazione 
;HL <- indirizzo alla prima pagina
fsm_get_selected_file_header_first_page_address:        push d 
                                                        call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_get_selected_file_header_first_page_address_end 
                                                        lxi d,fsm_header_dimension-2 
                                                        dad d 
                                                        call fsm_read_selected_data_segment_byte
                                                        jc fsm_get_selected_file_header_first_page_address_end
                                                        mov e,a 
                                                        inx h 
                                                        call fsm_read_selected_data_segment_byte
                                                        jc fsm_get_selected_file_header_first_page_address_end
                                                        mov d,a 
                                                        xchg 
fsm_get_selected_file_header_first_page_address_end:    pop d  
                                                        ret 


;fsm_get_selected_file_header_dimension restituisce la dimensione del file selezionato precedentemente 
;A <- esito dell'operazione
;BCDE <- dimensione del file 

fsm_get_selected_file_header_dimension:     push h 
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_get_selected_file_header_dimension_end
                                            lxi d,fsm_header_dimension-6 
                                            dad d
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_get_selected_file_header_dimension_end
                                            mov e,a 
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_get_selected_file_header_dimension_end
                                            mov d,a 
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_get_selected_file_header_dimension_end
                                            mov c,a 
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_get_selected_file_header_dimension_end
                                            mov b,a 
fsm_get_selected_file_header_dimension_end: pop h 
                                            ret 

;fsm_set_selected_file_header_name_and_extension modfica il nome e l'estenzione del file desiderato
;BC -> nome del file 
;DE -> estensione 

;A <- esito dell'operazione 
fsm_set_selected_file_header_name_and_extension:        push h 
                                                        push d 
                                                        push b 
                                                        call fsm_search_file_header
                                                        cpi fsm_header_not_found
                                                        jz fsm_set_selected_file_header_name_and_extension_ndp
                                                        cpi fsm_operation_ok
                                                        jnz fsm_set_selected_file_header_name_and_extension_end
                                                        mvi a,fsm_header_exist
                                                        jmp fsm_set_selected_file_header_name_and_extension_end
fsm_set_selected_file_header_name_and_extension_ndp:    call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_set_selected_file_header_name_and_extension_end
                                                        inx h 
                                                        push d 
                                                        push b 
                                                        pop d 
                                                        pop b 
                                                        mvi a,fsm_header_name_dimension
                                                        call string_segment_ncompare
                                                        lxi d,fsm_header_name_dimension
                                                        dad d 
                                                        mov e,c 
                                                        mov d,b 
                                                        mov c,a 
                                                        mvi a,fsm_header_extension_dimension
                                                        call string_segment_ncompare
                                                        ana c 
                                                        jz fsm_set_selected_file_header_name_and_extension_next
                                                        inx sp 
                                                        inx sp 
                                                        mvi a,fsm_operation_ok
                                                        jmp fsm_set_selected_file_header_name_and_extension_end
fsm_set_selected_file_header_name_and_extension_next:   xthl 
                                                        mov c,l
                                                        mov b,h 
                                                        xthl 
                                                        inx sp 
                                                        inx sp 
                                                        xthl 
                                                        mov e,l 
                                                        mov d,h 
                                                        xthl 
                                                        dcx sp 
                                                        dcx sp 
                                                        call fsm_search_file_header
                                                        cpi fsm_header_not_found
                                                        jz fsm_set_selected_file_header_name_and_extension_next2
                                                        cpi fsm_operation_ok
                                                        jnz fsm_set_selected_file_header_name_and_extension_end
                                                        mvi a,fsm_header_exist
                                                        jmp fsm_set_selected_file_header_name_and_extension_end
fsm_set_selected_file_header_name_and_extension_next2:  call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_set_selected_file_header_name_and_extension_end
                                                        push b 
                                                        push d 
                                                        pop b 
                                                        pop d 
                                                        inx h 
                                                        mvi a,fsm_header_name_dimension
                                                        call string_segment_ncopy
                                                        lxi d,fsm_header_name_dimension
                                                        dad d 
                                                        mvi a,fsm_header_extension_dimension
                                                        mov e,c 
                                                        mov d,b  
                                                        call string_segment_ncopy
                                                        call fsm_writeback_page
fsm_set_selected_file_header_name_and_extension_end:    pop b 
                                                        pop d 
                                                        pop h 
                                                        ret 

;fsm_get_selected_file_header_name restituisce il nome del file selezionato 

;A <- esito dell'operazione 
;SP <- nome del file (una stringa non limitata in lunghezza con $00 come carattere terminatore)

fsm_get_selected_file_header_name:                      push h 
                                                        push d 
                                                        push b 
                                                        call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_get_selected_file_header_name_end
                                                        lxi d,fsm_header_name_dimension
                                                        dad d 
                                                        mvi b,fsm_header_name_dimension
fsm_get_selected_file_header_name_dimension_loop:       call fsm_read_selected_data_segment_byte
                                                        jc fsm_get_selected_file_header_name_end
                                                        ora a 
                                                        jnz fsm_get_selected_file_header_name_dimension_loop_end
                                                        dcx h 
                                                        dcr b 
                                                        jnz fsm_get_selected_file_header_name_dimension_loop
fsm_get_selected_file_header_name_dimension_loop_end:   mov a,l 
                                                        sub b 
                                                        mov l,a 
                                                        mov a,h 
                                                        sbi 0 
                                                        mov h,a 
                                                        inx h
                                                        mov a,b 
                                                        cpi fsm_header_dimension
                                                        jnc fsm_get_selected_file_header_name_dimension_next
                                                        inr b 
fsm_get_selected_file_header_name_dimension_next:       xchg 
                                                        lxi h,0 
                                                        dad sp 
                                                        mov a,l 
                                                        sub b 
                                                        mov l,a 
                                                        mov a,h 
                                                        sbi 0 
                                                        mov h,a
                                                        mvi c,8
                                                        dcx sp 
fsm_get_selected_file_header_name_stack_loop:           xthl 
                                                        mov a,h 
                                                        xthl 
                                                        mov m,a 
                                                        inx h 
                                                        inx sp 
                                                        dcr c 
                                                        jnz fsm_get_selected_file_header_name_stack_loop      
                                                        mov a,l 
                                                        sui 8 
                                                        mov l,a 
                                                        mov a,h 
                                                        sbi 0 
                                                        mov h,a 
                                                        sphl 
                                                        lxi h,8 
                                                        dad sp 
                                                        mov a,b 
                                                        cpi fsm_header_dimension
                                                        jnc fsm_get_selected_file_header_name_stack_loop_copy
                                                        dcr b 
fsm_get_selected_file_header_name_stack_loop_copy:      mov a,b  
                                                        call string_segment_source_ncopy
                                                        mov a,l 
                                                        add b 
                                                        mov l,a 
                                                        mov a,h 
                                                        aci 0 
                                                        mov h,a 
                                                        mvi m,0 
                                                        mvi a,fsm_operation_ok
fsm_get_selected_file_header_name_end:                  pop b 
                                                        pop d 
                                                        pop h 
                                                        ret 

;fsm_get_selected_file_header_extension restituisce il nome del file selezionato 
;A <- esito dell'operazione 
;SP <- nome del file (una stringa non limitata in lunghezza con $00 come carattere terminatore)

fsm_get_selected_file_header_extension:                     push h 
                                                            push d 
                                                            push b 
                                                            call fsm_load_selected_file_header 
                                                            cpi fsm_operation_ok
                                                            jnz fsm_get_selected_file_header_extension_end
                                                            lxi d,fsm_header_extension_dimension+fsm_header_name_dimension
                                                            dad d 
                                                            mvi b,fsm_header_extension_dimension
fsm_get_selected_file_header_extension_dimension_loop:      call fsm_read_selected_data_segment_byte
                                                            jc fsm_get_selected_file_header_extension_end
                                                            ora a 
                                                            jnz fsm_get_selected_file_header_extension_dimension_loop_end
                                                            dcx h 
                                                            dcr b 
                                                            jnz fsm_get_selected_file_header_extension_dimension_loop
fsm_get_selected_file_header_extension_dimension_loop_end:  mov a,l 
                                                            sub b 
                                                            mov l,a 
                                                            mov a,h 
                                                            sbi 0 
                                                            mov h,a 
                                                            inx h
                                                            mov a,b 
                                                            cpi fsm_header_dimension
                                                            jnc fsm_get_selected_file_header_extension_dimension_next
                                                            inr b 
fsm_get_selected_file_header_extension_dimension_next:      xchg 
                                                            lxi h,0 
                                                            dad sp 
                                                            mov a,l 
                                                            sub b 
                                                            mov l,a 
                                                            mov a,h 
                                                            sbi 0 
                                                            mov h,a
                                                            mvi c,8
                                                            dcx sp 
fsm_get_selected_file_header_extension_stack_loop:          xthl 
                                                            mov a,h 
                                                            xthl 
                                                            mov m,a 
                                                            inx h 
                                                            inx sp 
                                                            dcr c 
                                                            jnz fsm_get_selected_file_header_extension_stack_loop      
                                                            mov a,l 
                                                            sui 8 
                                                            mov l,a 
                                                            mov a,h 
                                                            sbi 0 
                                                            mov h,a 
                                                            sphl 
                                                            lxi h,8 
                                                            dad sp 
                                                            mov a,b 
                                                            cpi fsm_header_dimension
                                                            jnc fsm_get_selected_file_header_extension_stack_loop_copy
                                                            dcr b 
fsm_get_selected_file_header_extension_stack_loop_copy:     mov a,b                          
                                                            call string_segment_source_ncopy
                                                            mov a,l 
                                                            add b 
                                                            mov l,a 
                                                            mov a,h 
                                                            aci 0 
                                                            mov h,a 
                                                            mvi m,0 
                                                            mvi a,fsm_operation_ok
fsm_get_selected_file_header_extension_end:                 pop b 
                                                            pop d 
                                                            pop h 
                                                            ret 

;fsm_load_selected_file_header carica nel buffer l'intestazione selezionata precedentemente e restituisce l'indirizzo in cui è situata

;A <- esito dell'operazione
;HL <- indirizzo dell'intestazione

fsm_load_selected_file_header:          push d 
                                        push b 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani fsm_disk_loaded_flags_header_selected_mask
                                        jnz fsm_load_selected_file_header_next
                                        mvi a,fsm_header_not_selected 
                                        jmp fsm_load_selected_file_header_end
fsm_load_selected_file_header_next:     lhld fsm_selected_file_header_page_address
                                        call fsm_move_data_page
                                        cpi fsm_operation_ok
                                        jnz fsm_load_selected_file_header_end
                                        lhld fsm_selected_file_header_php_address
                                        xchg 
                                        lxi b,fsm_header_dimension
                                        call unsigned_multiply_word 
                                        call fsm_reselect_mms_segment
                                        cpi fsm_operation_ok
                                        jnz fsm_load_selected_file_header_end
                                        xchg 
                                        mvi a,fsm_operation_ok
fsm_load_selected_file_header_end:      pop b 
                                        pop d 
                                        ret 

;fsm_create_file_header crea una nuova intestazione
;A -> flags del file
;DE -> puntatore all'estenzione dell'intestazione (stringa limitata in dimensione)
;BC -> puntatore all nome dell'intestazione (stringa limitata in dimensione)

fsm_create_file_header:                     push h 
                                            push d 
                                            push b 
                                            ori fsm_header_valid_bit
                                            ani $ff-fsm_header_deleted_bit
                                            push psw
                                            call fsm_search_file_header
                                            cpi fsm_header_not_found
                                            jz fsm_create_file_header_no_duplicate 
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            mvi a,fsm_header_exist
                                            jmp fsm_create_file_header_end
fsm_create_file_header_no_duplicate:        lxi h,0 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok                ;BC -> dimensione del buffer 
                                            jnz fsm_create_file_header_end      ;DE -> pagina corrente
                                            lxi d,0                             ;HL -> puntatore al buffer
                                            lxi b,fsm_uncoded_page_dimension    ;SP -> [psw][b][d][h]
                                            lxi h,fsm_header_dimension
fsm_create_file_header_search_loop:         call fsm_read_selected_data_segment_byte
                                            jc fsm_create_file_header_end 
                                            ani fsm_header_valid_bit
                                            jz fsm_create_file_header_end_of_list 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_create_file_header_end 
                                            ani fsm_header_deleted_bit
                                            jnz fsm_create_file_header_deleted_replace 
                                            mvi a,fsm_header_dimension
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
                                            mov a,l  
                                            sub c 
                                            mov a,h 
                                            sbb b 
                                            jc fsm_create_file_header_search_loop
                                            mov l,e 
                                            mov h,d 
                                            call fsm_get_page_link
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end       
                                            mov a,l 
                                            ana h 
                                            cpi $ff 
                                            jz fsm_create_file_header_end_of_page_list 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok 
                                            jnz fsm_create_file_header_end      
                                            mov e,l 
                                            mov d,h     
                                            lxi h,0 
                                            jmp fsm_create_file_header_search_loop
fsm_create_file_header_deleted_replace:     call fsm_create_file_header_write_bytes
                                            jmp fsm_create_file_header_next
fsm_create_file_header_end_of_page_list:    mov l,e 
                                            mov h,d 
                                            push d 
                                            lxi d,1
                                            call fsm_append_pages 
                                            pop d 
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            xchg 
                                            lxi h,0 
                                            call fsm_clear_mms_segment
                                            call fsm_create_file_header_write_bytes
                                            xchg 
                                            jmp fsm_create_file_header_next2
fsm_create_file_header_end_of_list:         call fsm_create_file_header_write_bytes
                                            mov a,l 
                                            sub c 
                                            mov a,h 
                                            sbb b 
                                            jnc fsm_create_file_header_next
                                            mvi a,0
                                            call fsm_write_selected_data_segment_byte
                                            jc fsm_create_file_header_end
fsm_create_file_header_next:                call fsm_writeback_page
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
fsm_create_file_header_next2:               mvi a,fsm_operation_ok
fsm_create_file_header_end:                 inx sp 
                                            inx sp  
                                            pop b 
                                            pop d 
                                            pop h 
                                            ret 


fsm_create_file_header_write_bytes:     push d 
                                        inx h 
                                        lxi d,6
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        xthl 
                                        mov c,l 
                                        mov b,h 
                                        xthl 
                                        lxi d,$fffA
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        mov e,c 
                                        mov d,b 
                                        mvi a,fsm_header_name_dimension
                                        call string_segment_ncopy
                                        lxi d,fsm_header_name_dimension
                                        dad d 
                                        lxi d,8
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        xthl 
                                        mov c,l 
                                        mov b,h 
                                        xthl 
                                        lxi d,$fff8
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg
                                        mov e,c 
                                        mov d,b 
                                        mvi a,fsm_header_extension_dimension
                                        call string_segment_ncopy
                                        lxi d,fsm_header_extension_dimension 
                                        dad d 
                                        mvi a,0 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h 
                                        mvi a,0 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h 
                                        mvi a,0 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h 
                                        mvi a,0 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h 
                                        mvi a,$ff 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h 
                                        mvi a,$ff 
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        inx h
                                        lxi b,$ffff-fsm_header_extension_dimension-fsm_header_name_dimension-7+1
                                        dad b 
                                        inx sp 
                                        inx sp 
                                        inx sp 
                                        inx sp 
                                        xthl 
                                        mov a,h 
                                        xthl 
                                        dcx sp 
                                        dcx sp 
                                        dcx sp 
                                        dcx sp 
                                        
                                        call fsm_write_selected_data_segment_byte
                                        jc fsm_create_file_header_end
                                        lxi b,fsm_header_extension_dimension+fsm_header_name_dimension+7
                                        dad b 
                                        pop d 
                                        lxi b,fsm_uncoded_page_dimension
                                        ret 


;fsm_select_file_header restituisce le coordinate dell'intestazone desiderata
;BC -> puntatore all nome dell'intestazione (stringa limitata in dimensione)
;DE -> puntatore all'estenzione dell'intestazione (stringa limitata in dimensione)
;A <- esito dell'operazione 

fsm_select_file_header:                     push h 
                                            push d 
                                            push b
                                            call fsm_search_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_select_file_header_end
                                            xchg 
                                            shld fsm_selected_file_header_php_address
                                            mov l,c 
                                            mov h,b 
                                            shld fsm_selected_file_header_page_address
                                            lda fsm_selected_disk_loaded_page_flags
                                            ori fsm_disk_loaded_flags_header_selected_mask
                                            sta fsm_selected_disk_loaded_page_flags
                                            mvi a,fsm_operation_ok
fsm_select_file_header_end:                 pop b  
                                            pop d 
                                            pop h 
                                            ret 

;fsm_search_file_header restituisce le coordinate dell'intestazone desiderata
;BC -> puntatore all nome dell'intestazione (stringa limitata in dimensione)
;DE -> puntatore all'estenzione dell'intestazione (stringa limitata in dimensione)

;A <- esito dell'operazione 
;BC -> puntatore alla pagina dell'intestazione 
;DE -> numero di intestazione nella pagina 

fsm_search_file_header:                     push h 
                                            push d 
                                            push b 
                                            lxi h,0 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_search_file_header_end
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok                
                                            jnz fsm_search_file_header_end      ;DE -> pagina corrente
                                            lxi d,0                             ;HL -> puntatore al buffer
                                            lxi h,fsm_header_dimension          ;SP -> [b][d][h]
fsm_search_file_header_search_loop:         call fsm_read_selected_data_segment_byte
                                            jc fsm_search_file_header_end 
                                            ani fsm_header_valid_bit
                                            jz fsm_search_file_header_end_of_list 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_search_file_header_end 
                                            ani fsm_header_deleted_bit
                                            jnz fsm_search_file_header_search_loop2
                                            push h 
                                            push d 
                                            inx h 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            xthl 
                                            mov e,l 
                                            mov d,h 
                                            xthl 
                                            dcx sp 
                                            dcx sp 
                                            dcx sp 
                                            dcx sp 
                                            mvi a,fsm_header_name_dimension
                                            call string_segment_ncompare
                                            ora a 
                                            jz fsm_search_file_header_search_loop_next
                                            lxi d,fsm_header_name_dimension
                                            dad d 
                                            lxi d,6
                                            xchg 
                                            dad sp 
                                            sphl 
                                            xchg 
                                            xthl 
                                            mov c,l 
                                            mov b,h 
                                            xthl 
                                            lxi d,$fffa
                                            xchg 
                                            dad sp 
                                            sphl 
                                            xchg 
                                            mov e,c 
                                            mov d,b 
                                            mvi a,fsm_header_extension_dimension
                                            call string_segment_ncompare
                                            ora a 
                                            jz fsm_search_file_header_search_loop_next
                                            pop d 
                                            pop h  
                                            xchg 
                                            mov c,e 
                                            mov b,d 
                                            lxi d,fsm_header_dimension
                                            call unsigned_divide_word 
                                            mov e,c 
                                            mov d,b 
                                            mov c,l 
                                            mov b,h 
                                            mvi a,fsm_operation_ok
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            pop h 
                                            ret 
fsm_search_file_header_search_loop_next:    pop d 
                                            pop h 
fsm_search_file_header_search_loop2:        lxi b,fsm_header_dimension
                                            dad b 
                                            lxi b,fsm_uncoded_page_dimension
                                            mov a,l  
                                            sub c 
                                            mov a,h 
                                            sbb b
                                            jc fsm_search_file_header_search_loop
                                            mov l,e 
                                            mov h,d 
                                            call fsm_get_page_link
                                            cpi fsm_operation_ok
                                            jnz fsm_search_file_header_end       
                                            mov a,l 
                                            ana h 
                                            cpi $ff 
                                            jz fsm_search_file_header_end_of_list 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok 
                                            jnz fsm_search_file_header_end      
                                            mov e,l 
                                            mov d,h     
                                            lxi h,0 
                                            jmp fsm_search_file_header_search_loop
fsm_search_file_header_end_of_list:         mvi a,fsm_header_not_found 
                                            lxi d,0 
                                            lxi b,0                  
fsm_search_file_header_end:                 pop b 
                                            pop d 
                                            pop h  
                                            ret 


;fsm_append_pages concatena il numero di pagine libere desiderato alla lista 
; DE -> numero di pagine da aggiungere
; HL -> indirizzo di partenza della lista 
; A <- esito dell'operazione 
; HL <- indirizzo della nuova pagina aggiunta

fsm_append_pages:           push d  
                            mov a,h 
                            ana l 
                            cpi $ff 
                            jnz fsm_append_pages_loop
                            mvi a,fsm_bad_argument
                            jmp fsm_append_pages_end
fsm_append_pages_loop:      mov e,l 
                            mov d,h
                            call fsm_get_page_link
                            cpi fsm_operation_ok
                            jnz fsm_append_pages_end
                            mov a,h
                            ana l
                            cpi $ff 
                            jnz fsm_append_pages_loop
fsm_append_pages_loop_end:  xchg 
                            xthl  
                            mov e,l 
                            mov d,h 
                            xthl 
                            xchg 
                            push d 
                            call fsm_get_first_free_page_list
                            pop d 
                            cpi fsm_operation_ok
                            jnz fsm_append_pages_end
                            xchg 
                            call fsm_set_page_link
                            cpi fsm_operation_ok
                            jnz fsm_append_pages_end
                            mvi a,fsm_operation_ok
                            mov l,e 
                            mov h,d 
fsm_append_pages_end:       pop d 
                            ret 

;fsm_get_first_free_page_list restituisce una lista concatenata di pagine libere 
;HL -> numero di pagine da prelevare
;HL <- indirizzo alla prima pagina della lista prelevata 

fsm_get_first_free_page_list:           push b
                                        push d
                                        mov e,l 
                                        mov d,h 
                                        mov a,e
                                        ora d
                                        jnz fsm_get_first_free_page_list_next
                                        mvi a,fsm_bad_argument
                                        lxi h,$ffff
                                        jmp fsm_get_first_free_page_list_end
fsm_get_first_free_page_list_next:      lhld fsm_selected_disk_free_page_number    
                                        mov a,l 
                                        sub e 
                                        mov l,a 
                                        mov a,h 
                                        sbb d 
                                        mov h,a                               
                                        jnc fsm_get_first_free_page_list_next2
                                        mvi a,fsm_not_enough_spage_left
                                        lxi h,$ffff
                                        jmp fsm_get_first_free_page_list_end
fsm_get_first_free_page_list_next2:     shld fsm_selected_disk_free_page_number
                                        lhld fsm_selected_disk_first_free_page_address
                                        mov c,l 
                                        mov b,h 
fsm_get_first_free_page_list_loop:      dcx d 
                                        mov a,e 
                                        ora d
                                        jz fsm_get_first_free_page_list_loop_end 
                                        call fsm_get_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_get_first_free_page_list_end
                                        jmp fsm_get_first_free_page_list_loop
fsm_get_first_free_page_list_loop_end:  
                                        mov e,l 
                                        mov d,h  
                                        call fsm_get_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_get_first_free_page_list_end
                                     
                                        shld fsm_selected_disk_first_free_page_address
                                        lxi h,$ffff 
                                        xchg 
                                        call fsm_set_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_get_first_free_page_list_end
                                        mov l,c 
                                        mov h,b 
                                        mvi a,fsm_operation_ok
fsm_get_first_free_page_list_end:       pop d
                                        pop b 
                                        ret      
                                

;fsm_set_first_free_page_list preleva il numero di pagine concatenate desiderato e le aggiunge alla lista delle pagine libere 
;Dopo l'operazione, la lista di partenza viene aggiuntata, in modo da evitare problemi di inconsistenza
;DE -> numero di pagine da liberare
;HL -> indirizzo alla prima pagina della lista da liberare (elimina a partire dalla pagina successiva)

;A <- esito dell'operazione 

fsm_set_first_free_page_list:           push b 
                                        push d  
                                        push h                   
                                        mov c,l 
                                        mov b,h 
                                        mov a,e 
                                        ora d 
                                        jz fsm_set_first_free_page_list_end
fsm_set_first_free_page_list_loop:      dcx d
                                        mov a,e 
                                        ora d
                                        jz fsm_set_first_free_page_list_loop_end 
                                        call fsm_get_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_set_first_free_page_list_end
                                        mov a,l 
                                        ana h 
                                        cpi $ff 
                                        jnz fsm_set_first_free_page_list_loop
                                        mvi a,fsm_bad_argument 
                                        jmp fsm_set_first_free_page_list_end
fsm_set_first_free_page_list_loop_end:  mov e,l             
                                        mov d,h 
                                        call fsm_get_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_set_first_free_page_list_end
                                        push h 
                                        lhld fsm_selected_disk_first_free_page_address
                                        xchg 
                                        call fsm_set_page_link
                                        pop d 
                                        cpi fsm_operation_ok
                                        jnz fsm_set_first_free_page_list_end
                                        mov l,c 
                                        mov h,b 
                                        shld fsm_selected_disk_first_free_page_address
                                        lhld fsm_selected_disk_free_page_number
                                        xchg 
                                        xthl 
                                        mov a,e
                                        add l
                                        mov e,a 
                                        mov a,d 
                                        adc h 
                                        mov d,a 
                                        xthl 
                                        xchg 
                                        shld fsm_selected_disk_free_page_number
                                        pop h 
                                        push h 
                                        call fsm_set_page_link
                                        mvi a,fsm_operation_ok
fsm_set_first_free_page_list_end:       pop h 
                                        pop d
                                        pop b 
                                        ret 

;fsm_load_disk_free_pages_informations ricarica le informazioni sulle pagine libere disponibili nel disco
;A <- esito dell'operazione 

fsm_load_disk_free_pages_informations:      push h 
                                            push d 
                                            lxi h,0 
                                            call fsm_read_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_load_disk_free_pages_informations_end
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok
                                            jnz fsm_load_disk_free_pages_informations_end
                                            lxi h,fsm_disk_name_max_lenght
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_load_disk_free_pages_informations_end
                                            sta fsm_selected_disk_free_page_number
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_load_disk_free_pages_informations_end 
                                            sta fsm_selected_disk_free_page_number+1 
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_load_disk_free_pages_informations_end
                                            sta fsm_selected_disk_first_free_page_address
                                            inx h 
                                            call fsm_read_selected_data_segment_byte
                                            jc fsm_load_disk_free_pages_informations_end 
                                            sta fsm_selected_disk_first_free_page_address+1 
                                            mvi a,fsm_operation_ok
fsm_load_disk_free_pages_informations_end:  pop d 
                                            pop h 
                                            ret 



;fsm_get_page_link legge l'indirizzo della pagina concatenata datta fat table
;HL -> indirizzo della pagina di riferimento
;HL <- indirizzo della pagina concatenata
;A -> esito dell'operazione

fsm_get_page_link:                  push b 
                                    push d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,fsm_uncoded_page_dimension
                                    stc 
                                    cmc 
                                    mov a,d 
                                    rar 
                                    mov d,a 
                                    mov a,e 
                                    rar 
                                    mov e,a 
                                    call unsigned_divide_word 
                                    mov a,c 
                                    call fsm_move_fat_page
                                    cpi fsm_operation_ok
                                    jnz fsm_get_page_link_end
fsm_get_page_link_offset:           call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_get_page_link_end
                                    lxi h,0
                                    mov a,e 
                                    add a 
                                    mov e,a 
                                    mov a,d 
                                    ral 
                                    mov d,a 
                                    dad d 
                                    call fsm_read_selected_data_segment_byte
                                    jc fsm_get_page_link_end
                                    mov e,a  
                                    inx h 
                                    call fsm_read_selected_data_segment_byte
                                    jc fsm_get_page_link_end
                                    mov d,a
                                    xchg 
                                    mvi a,fsm_operation_ok
fsm_get_page_link_end:              pop d 
                                    pop b 
                                    ret 

;fsm_set_page_link scrive l'indirizzo della pagina concatenata nella fat table
;DE -> insirizzo della pagina da salvare
;HL -> indirizzo della pagina di riferimento
;A -> esito dell'operazione

fsm_set_page_link:                  push b 
                                    push h 
                                    push d 
                                    mov c,l 
                                    mov b,h 
                                    lxi d,fsm_uncoded_page_dimension
                                    stc 
                                    cmc 
                                    mov a,d 
                                    rar 
                                    mov d,a 
                                    mov a,e 
                                    rar 
                                    mov e,a 
                                    call unsigned_divide_word 
                                    mov a,c 
                                    call fsm_move_fat_page
                                    cpi fsm_operation_ok
                                    jnz fsm_set_page_link_end
fsm_set_page_link_offset:           call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_set_page_link_end
                                    lxi h,0 
                                    mov a,e 
                                    add a 
                                    mov e,a 
                                    mov a,d 
                                    ral 
                                    mov d,a 
                                    dad d 
                                    pop d 
                                    push d 
                                    mov a,e  
                                    call fsm_write_selected_data_segment_byte
                                    jc fsm_set_page_link_end
                                    inx h 
                                    mov a,d  
                                    call fsm_write_selected_data_segment_byte
                                    jc fsm_set_page_link_end
                                    mvi a,fsm_operation_ok
fsm_set_page_link_end:              pop d 
                                    pop h 
                                    pop b 
                                    ret 


;fsm_reselect_mms_segment riseleziona il segmento di buffer (nel caso in cui non esiste viene creato)

fsm_reselect_mms_segment:           lda fsm_page_buffer_segment_id
                                    call mms_select_low_memory_data_segment
                                    cpi mms_operation_ok
                                    jz fsm_reselect_mms_segment_end2
                                    cpi mms_segment_data_not_found_error_code
                                    rnz  
                                    push h 
                                    lxi h,fsm_uncoded_page_dimension
                                    mvi a,%11000000
                                    call mms_create_low_memory_data_segment
                                    pop h 
                                    ora a 
                                    rz
fsm_reselect_mms_segment_end:       sta fsm_page_buffer_segment_id 
fsm_reselect_mms_segment_end2:      mvi a,fsm_operation_ok
                                    ret 

;fsm_write_selected_data_segment_byte, fsm_read_selected_data_segment_byte e fsm_mass_memory_read_sector vengono usate per modificare i dati nel buffer 
;quando viene scritto un byte nel buffer viene segnalato implicitamente al sistema di writeback che la pagina corrente è stata modificata
fsm_write_selected_data_segment_byte:   call fsm_page_set_modified_flag
                                        jmp mms_write_selected_data_segment_byte

fsm_read_selected_data_segment_byte     .equ mms_read_selected_data_segment_byte

;fsm_page_set_modified_flag e fsm_page_unset_modified_flag vengono utilizzate per forzare il sistema di writeback in casi speciali

fsm_page_set_modified_flag:             push psw 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ori fsm_disk_loaded_flags_header_modified_page_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        pop psw 
                                        ret 

fsm_page_unset_modified_flag:           push psw 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani $ff-fsm_disk_loaded_flags_header_modified_page_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        pop psw 
                                        ret 
;fsm_clear_mms_segment riempie il buffer di memoria con degli zeri


fsm_clear_mms_segment:      push h 
                            call fsm_reselect_mms_segment
                            cpi fsm_operation_ok
                            jnz fsm_clear_mms_segment_end
                            lxi h,0 
fsm_clear_mms_segment_loop: mvi a,0 
                            call fsm_write_selected_data_segment_byte
                            inx h  
                            jnc fsm_clear_mms_segment_loop
                            cpi mms_segment_segmentation_fault_error_code
                            jnz fsm_clear_mms_segment_end
                            mvi a,fsm_operation_ok
fsm_clear_mms_segment_end:  pop h 
                            ret 

;Le funzioni fsm_move_*_page servono per eseguire automaticamente operazioni di lettura e scrittura nella memoria in modo intelligente:
;- se nel buffer non è stata caricata precedentemente una pagina e la pagina richiesta non è stata caricata nel buffer allora viene prelevata dalla memoria
;- se nel buffer è stata caricata pecedentemente una pagina diversa da quella richiesta allora viene prima salvata in memoria quella presente e poi viene caricata quella richiesta
;- se nel buffer è presente la pagina richiesta la funzione non fa nulla, dato che nel buffer sono presenti i dati richiesti
;Viene previsto quinid un sistema di writeback

;fsm_move_fat_page carica la pagina fat in writeback nel buffer di memoria
;A -> pagina da selezionare
;A <- esito dell'operazione 

fsm_move_fat_page:          push d 
                            push h 
                            mov d,a 
                            lda fsm_selected_disk_loaded_page_flags
                            ani fsm_disk_loaded_flags_loaded_page_mask
                            jz fsm_move_fat_page_load 
                            lda fsm_selected_disk_loaded_page_flags 
                            ani fsm_disk_loaded_flags_header_modified_page_mask
                            jz fsm_move_fat_page_load
                            lda fsm_selected_disk_loaded_page_flags
                            ani fsm_disk_loaded_flags_loaded_page_type_mask
                            jz fsm_move_fat_page_verify
                            lhld fsm_selected_disk_loaded_page
                            call fsm_write_data_page
                            cpi fsm_operation_ok
                            jnz fsm_move_fat_page_end
                            jmp fsm_move_fat_page_load
fsm_move_fat_page_verify:   lda fsm_selected_disk_loaded_page
                            cmp d 
                            jz fsm_move_fat_page_next
                            call fsm_write_fat_page
                            cpi fsm_operation_ok
                            jnz fsm_move_fat_page_end
fsm_move_fat_page_load:     lda fsm_selected_disk_loaded_page_flags 
                            ani $ff-fsm_disk_loaded_flags_header_modified_page_mask
                            sta fsm_selected_disk_loaded_page_flags 
                            mov a,d 
                            sta fsm_selected_disk_loaded_page
                            call fsm_read_fat_page
                            cpi fsm_operation_ok
                            jnz fsm_move_fat_page_end
fsm_move_fat_page_next:     mvi a,fsm_operation_ok
fsm_move_fat_page_end:      pop h 
                            pop d 
                            ret 

;fsm_move_data_page carica la pagina dati in writeback nel buffer di memoria
;HL -> pagina da selezionare
;A <- esito dell'operazione 

fsm_move_data_page:             push d 
                                push h 
                                xchg 
                                lda fsm_selected_disk_loaded_page_flags
                                ani fsm_disk_loaded_flags_loaded_page_mask
                                jz fsm_move_data_page_load 
                                lda fsm_selected_disk_loaded_page_flags 
                                ani fsm_disk_loaded_flags_header_modified_page_mask
                                jz fsm_move_data_page_load
                                lda fsm_selected_disk_loaded_page_flags
                                ani fsm_disk_loaded_flags_loaded_page_type_mask
                                jnz fsm_move_data_page_verify
                                lda fsm_selected_disk_loaded_page
                                call fsm_write_fat_page
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
                                jmp fsm_move_data_page_load
fsm_move_data_page_verify:      lhld fsm_selected_disk_loaded_page
                                mov a,e 
                                cmp l 
                                jnz fsm_move_data_page_writeback
                                mov a,d 
                                cmp h 
                                jz fsm_move_data_page_next
fsm_move_data_page_writeback:   call fsm_write_data_page
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
fsm_move_data_page_load:        lda fsm_selected_disk_loaded_page_flags 
                                ani $ff-fsm_disk_loaded_flags_header_modified_page_mask
                                sta fsm_selected_disk_loaded_page_flags 
                                mov l,e 
                                mov h,d  
                                shld fsm_selected_disk_loaded_page
                                call fsm_read_data_page
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
                                mov a,e 
                                ora d 
                                jnz fsm_move_data_page_next
                                call fsm_reselect_mms_segment
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
                                lxi h, fsm_disk_name_max_lenght
                                xchg 
                                lhld fsm_selected_disk_free_page_number
                                xchg 
                                mov a,e 
                                call fsm_write_selected_data_segment_byte
                                jc fsm_move_data_page_end
                                inx h 
                                mov a,d
                                call fsm_write_selected_data_segment_byte
                                jc fsm_move_data_page_end
                                inx h 
                                xchg 
                                lhld fsm_selected_disk_first_free_page_address
                                xchg 
                                mov a,e 
                                call fsm_write_selected_data_segment_byte
                                jc fsm_move_data_page_end
                                inx h 
                                mov a,d
                                call fsm_write_selected_data_segment_byte
                                jc fsm_move_data_page_end
fsm_move_data_page_next:        mvi a,fsm_operation_ok
fsm_move_data_page_end:         pop h 
                                pop d 
                                ret 

;fsm_writeback_page salva in memoria la pagina contenuta nel buffer (salva le modifiche all'ultima pagina caricata)
;A -> esito dell'operazione
fsm_writeback_page:     push h 
                        lda fsm_selected_disk_loaded_page_flags
                        ani fsm_disk_loaded_flags_loaded_page_mask 
                        jz fsm_writeback_page_ok 
                        lxi h,0 
                        call fsm_move_data_page
                        cpi fsm_operation_ok
                        jnz fsm_writeback_page_end
                        lxi h,0
                        call fsm_write_data_page
                        cpi fsm_operation_ok
                        jnz fsm_writeback_page_end
                        lda fsm_selected_disk_loaded_page_flags
                        ani $ff - fsm_disk_loaded_flags_loaded_page_mask
                        sta fsm_selected_disk_loaded_page_flags
 fsm_writeback_page_ok: mvi a,fsm_operation_ok
fsm_writeback_page_end: pop h 
                        ret 


;fsm_read_fat_page legge la pagina desiderata e salva il contenuto nel buffer in memoria
;A <- esito dell'operazione 

fsm_read_fat_page:                  push b
                                    push d 
                                    push h 
                                    mov b,a 
                                    lda fsm_selected_disk_loaded_page_flags
                                    xri $ff 
                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                    jz fsm_read_fat_page_next
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                    jnz fsm_read_fat_page_not_formatted
                                    mvi a,fsm_disk_not_selected
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_not_formatted:    mvi a,fsm_unformatted_disk
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_next:             lda fsm_selected_disk_fat_page_number 
                                    mov c,a 
                                    mov a,b 
                                    sub c
                                    jc fsm_read_fat_page_not_overflow
                                    mvi a,fsm_bad_argument 
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_not_overflow:     mov a,b 
                                    sta fsm_selected_disk_loaded_page 
                                    xra a 
                                    sta fsm_selected_disk_loaded_page+1
                                    lda fsm_selected_disk_spp_number  
                                    mov c,a 
                                    call unsigned_multiply_byte 
                                    lhld fsm_selected_disk_data_first_sector 
                                    mov a,l 
                                    add c 
                                    mov e,a 
                                    mov a,h 
                                    adc b 
                                    mov d,a 
                                    lxi b,0
                                    mov a,c 
                                    aci 0 
                                    mov c,a 
                                    call fsm_seek_disk_sector
                                    cpi fsm_operation_ok
                                    jz fsm_read_fat_page_operation_ok
                                    push psw 
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani $ff-fsm_disk_loaded_flags_loaded_page_mask
                                    sta fsm_selected_disk_loaded_page_flags
                                    pop psw 
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_operation_ok:     lda fsm_selected_disk_loaded_page_flags
                                    ani $ff-fsm_disk_loaded_flags_loaded_page_mask-fsm_disk_loaded_flags_loaded_page_type_mask
                                    sta fsm_selected_disk_loaded_page_flags
                                    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_read_fat_page_end
                                    lxi h,0 
                                    lda fsm_selected_disk_spp_number  
                                    push psw 
fsm_read_fat_page_operation_loop:   mov a,c 
                                    call bios_mass_memory_select_head
                                    cpi bios_operation_ok
                                    jnz fsm_read_fat_page_end_loop
                                    xchg 
                                    call bios_mass_memory_select_track
                                    xchg 
                                    cpi bios_operation_ok
                                    jnz fsm_read_fat_page_end_loop
                                    mov a,b 
                                    call bios_mass_memory_select_sector
                                    cpi bios_operation_ok
                                    jnz fsm_read_fat_page_end_loop
                                    call mms_mass_memory_read_sector
                                    cpi bios_operation_ok
                                    jnz fsm_read_fat_page_end_loop
                                    inr b 
                                    lda fsm_selected_disk_spt_number
                                    cmp b 
                                    jnz fsm_read_fat_page_operation_loop2
                                    mvi b,0
                                    inx d 
                                    lda fsm_selected_disk_tph_number+1
                                    cmp d  
                                    jnz fsm_read_fat_page_operation_loop2
                                    lda fsm_selected_disk_tph_number
                                    cmp e 
                                    jnz fsm_read_fat_page_operation_loop2
                                    lxi d,0 
                                    inr c 
                                    lda fsm_selected_disk_head_number
                                    cmp e 
                                    jnz fsm_read_fat_page_operation_loop2
                                    mvi a,fsm_end_of_disk
                                    jmp fsm_read_fat_page_end_loop
fsm_read_fat_page_operation_loop2:  xthl 
                                    dcr h 
                                    xthl
                                    jnz fsm_read_fat_page_operation_loop
                                    lda fsm_selected_disk_loaded_page_flags
                                    ori fsm_disk_loaded_flags_loaded_page_mask
                                    sta fsm_selected_disk_loaded_page_flags
                                    mvi a,fsm_operation_ok
fsm_read_fat_page_end_loop:         inx sp 
                                    inx sp  
fsm_read_fat_page_end:              pop h 
                                    pop d 
                                    pop b 
                                    ret 


;fsm_write_fat_page scrive nella pagina desiderata il contenuto nel buffer in memoria
;A -> pagina da selezionare
;A <- esito dell'operazione 

fsm_write_fat_page:                 push b
                                    push d 
                                    push h 
                                    mov b,a 
                                    lda fsm_selected_disk_loaded_page_flags
                                    xri $ff 
                                    ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                    jz fsm_write_fat_page_next
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani fsm_disk_loaded_flags_selected_disk_mask
                                    jnz fsm_write_fat_page_not_formatted
                                    mvi a,fsm_disk_not_selected
                                    jmp fsm_write_fat_page_end
fsm_write_fat_page_not_formatted:   mvi a,fsm_unformatted_disk
                                    jmp fsm_write_fat_page_end
fsm_write_fat_page_next:            lda fsm_selected_disk_fat_page_number 
                                    mov c,a 
                                    mov a,b 
                                    sub c
                                    jc fsm_write_fat_page_not_overflow
                                    mvi a,fsm_bad_argument 
                                    jmp fsm_write_fat_page_end
fsm_write_fat_page_not_overflow:    mov a,b 
                                    sta fsm_selected_disk_loaded_page
                                    xra a 
                                    sta fsm_selected_disk_loaded_page+1
                                    lda fsm_selected_disk_spp_number  
                                    mov c,a 
                                    call unsigned_multiply_byte 
                                    lhld fsm_selected_disk_data_first_sector 
                                    mov a,l 
                                    add c 
                                    mov e,a 
                                    mov a,h 
                                    adc b 
                                    mov d,a 
                                    lxi b,0
                                    mov a,c 
                                    aci 0 
                                    mov c,a 
                                    call fsm_seek_disk_sector
                                    cpi fsm_operation_ok
                                    jz fsm_write_fat_page_operation_ok
                                    xra a 
                                    sta fsm_selected_disk_loaded_page_flags
                                    jmp fsm_write_fat_page_end
fsm_write_fat_page_operation_ok:    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_write_fat_page_end
                                    lxi h,0
                                    lda fsm_selected_disk_spp_number  
                                    push psw 
fsm_write_fat_page_operation_loop:  mov a,c 
                                    call bios_mass_memory_select_head
                                    cpi bios_operation_ok
                                    jnz fsm_write_fat_page_end_loop
                                    xchg 
                                    call bios_mass_memory_select_track
                                    xchg 
                                    cpi bios_operation_ok
                                    jnz fsm_write_fat_page_end_loop
                                    mov a,b 
                                    call bios_mass_memory_select_sector
                                    cpi bios_operation_ok
                                    jnz fsm_write_fat_page_end_loop
                                    call mms_mass_memory_write_sector
                                
                                    cpi bios_operation_ok
                                    jnz fsm_write_fat_page_end_loop
                                    inr b 
                                    lda fsm_selected_disk_spt_number
                                    cmp b 
                                    jnz fsm_write_fat_page_operation_loop2
                                    mvi b,0
                                    inx d 
                                    lda fsm_selected_disk_tph_number+1
                                    cmp d  
                                    jnz fsm_write_fat_page_operation_loop2
                                    lda fsm_selected_disk_tph_number
                                    cmp e 
                                    jnz fsm_write_fat_page_operation_loop2
                                    lxi d,0 
                                    inr c 
                                    lda fsm_selected_disk_head_number
                                    cmp e 
                                    jnz fsm_write_fat_page_operation_loop2
                                    mvi a,fsm_end_of_disk
                                    jmp fsm_write_fat_page_end_loop
fsm_write_fat_page_operation_loop2: xthl 
                                    dcr h 
                                    xthl
                                    jnz fsm_write_fat_page_operation_loop
                                    mvi a,fsm_operation_ok
fsm_write_fat_page_end_loop:        inx sp 
                                    inx sp   
fsm_write_fat_page_end:             pop h 
                                    pop d 
                                    pop b 
                                    ret 


;fsm_read_data_page seleziona la pagina appartenente alla fat 
;HL -> pagina da selezionare
;A <- esito dell'operazione 

fsm_read_data_page:                     push b
                                        push d 
                                        push h 
                                        lda fsm_selected_disk_loaded_page_flags
                                        xri $ff 
                                        ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                        jz fsm_read_data_page_next
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani fsm_disk_loaded_flags_selected_disk_mask
                                        jnz fsm_read_data_page_not_formatted
                                        mvi a,fsm_disk_not_selected
                                        jmp fsm_read_data_page_end
fsm_read_data_page_not_formatted:       mvi a,fsm_unformatted_disk
                                        jmp fsm_read_data_page_end
fsm_read_data_page_next:                xchg 
                                        lhld fsm_selected_disk_data_page_number 
                                        mov a,e
                                        sub l 
                                        mov a,d 
                                        sbb h 
                                        jc fsm_read_data_page_not_overflow
                                        mvi a,fsm_bad_argument 
                                        jmp fsm_read_data_page_end
fsm_read_data_page_not_overflow:        xchg 
                                        shld fsm_selected_disk_loaded_page
                                        lda fsm_selected_disk_fat_page_number
                                        mov c,a 
                                        lda fsm_selected_disk_spp_number  
                                        mov b,a 
                                        call unsigned_multiply_byte
                                        push b 
                                        lda fsm_selected_disk_spp_number  
                                        mov c,l 
                                        mov b,h 
                                        mvi d,0
                                        mov e,a              
                                        call unsigned_multiply_word
                                        pop h 
                                        mov a,l 
                                        add e 
                                        mov e,a 
                                        mov a,h 
                                        adc d 
                                        mov d,a 
                                        mov a,c 
                                        aci 0 
                                        mov c,a 
                                        mov a,b 
                                        aci 0 
                                        mov b,a 
                                        lhld fsm_selected_disk_data_first_sector 
                                        mov a,l
                                        add e 
                                        mov e,a 
                                        mov a,h 
                                        adc d 
                                        mov d,a
                                        mov a,c 
                                        aci 0 
                                        mov b,a
                                        mov a,b 
                                        aci 0 
                                        mov b,a  
                                        call fsm_seek_disk_sector
                                        cpi fsm_operation_ok
                                        jz fsm_read_data_page_operation_ok
                                        push psw 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani $ff-fsm_disk_loaded_flags_loaded_page_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        pop psw 
                                        jmp fsm_read_data_page_end
fsm_read_data_page_operation_ok:        lda fsm_selected_disk_loaded_page_flags
                                        ani $ff-fsm_disk_loaded_flags_loaded_page_mask
                                        ori fsm_disk_loaded_flags_loaded_page_type_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        call fsm_reselect_mms_segment
                                        cpi fsm_operation_ok
                                        jnz fsm_read_data_page_end
                                        lxi h,0 
                                        lda fsm_selected_disk_spp_number
                                        push psw 
fsm_read_data_page_operation_loop:      mov a,c 
                                        call bios_mass_memory_select_head
                                        cpi bios_operation_ok
                                        jnz fsm_read_data_page_end_loop
                                        xchg 
                                        call bios_mass_memory_select_track
                                        xchg 
                                        cpi bios_operation_ok
                                        jnz fsm_read_data_page_end_loop
                                        mov a,b 
                                        call bios_mass_memory_select_sector
                                        cpi bios_operation_ok
                                        jnz fsm_read_data_page_end_loop
                                        call mms_mass_memory_read_sector
                                        cpi bios_operation_ok
                                        jnz fsm_read_data_page_end_loop
                                        inr b 
                                        lda fsm_selected_disk_spt_number
                                        cmp b 
                                        jnz fsm_read_data_page_operation_loop2
                                        mvi b,0
                                        inx d 
                                        lda fsm_selected_disk_tph_number+1
                                        cmp d  
                                        jnz fsm_read_data_page_operation_loop2
                                        lda fsm_selected_disk_tph_number
                                        cmp e 
                                        jnz fsm_read_data_page_operation_loop2
                                        lxi d,0 
                                        inr c 
                                        lda fsm_selected_disk_head_number
                                        cmp e 
                                        jnz fsm_read_data_page_operation_loop2
                                        mvi a,fsm_end_of_disk
                                        jmp fsm_read_data_page_end_loop
fsm_read_data_page_operation_loop2:     xthl 
                                        dcr h 
                                        xthl
                                        jnz fsm_read_data_page_operation_loop
                                        lda fsm_selected_disk_loaded_page_flags
                                        ori fsm_disk_loaded_flags_loaded_page_type_mask+fsm_disk_loaded_flags_loaded_page_mask
                                        sta fsm_selected_disk_loaded_page_flags
                                        mvi a,fsm_operation_ok
fsm_read_data_page_end_loop:            inx sp 
                                        inx sp 
fsm_read_data_page_end:                 pop h 
                                        pop d 
                                        pop b 
                                        ret 

;fsm_write_data_page seleziona la pagina appartenente alla fat 
;HL -> pagina da selezionare
;A <- esito dell'operazione 

fsm_write_data_page:                    push b
                                        push d 
                                        push h 
                                        lda fsm_selected_disk_loaded_page_flags
                                        xri $ff 
                                        ani fsm_disk_loaded_flags_selected_disk_mask+fsm_disk_loaded_flags_formatted_disk_mask
                                        jz fsm_write_data_page_next
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani fsm_disk_loaded_flags_selected_disk_mask
                                        jnz fsm_write_data_page_not_formatted
                                        mvi a,fsm_disk_not_selected
                                        jmp fsm_write_data_page_end
fsm_write_data_page_not_formatted:      mvi a,fsm_unformatted_disk
                                        jmp fsm_write_data_page_end
fsm_write_data_page_next:               xchg 
                                        lhld fsm_selected_disk_data_page_number 
                                        mov a,e
                                        sub l 
                                        mov a,d 
                                        sbb h 
                                        jc fsm_write_data_page_not_overflow
                                        mvi a,fsm_bad_argument 
                                        jmp fsm_write_data_page_end
fsm_write_data_page_not_overflow:       xchg 
                                        shld fsm_selected_disk_loaded_page
                                        lda fsm_selected_disk_fat_page_number
                                        mov c,a 
                                        lda fsm_selected_disk_spp_number  
                                        mov b,a 
                                        call unsigned_multiply_byte
                                        push b 
                                        lda fsm_selected_disk_spp_number  
                                        mov c,l 
                                        mov b,h 
                                        mvi d,0
                                        mov e,a              
                                        call unsigned_multiply_word
                                        pop h 
                                        mov a,l 
                                        add e 
                                        mov e,a 
                                        mov a,h 
                                        adc d 
                                        mov d,a 
                                        mov a,c 
                                        aci 0 
                                        mov c,a 
                                        mov a,b 
                                        aci 0 
                                        mov b,a 
                                        lhld fsm_selected_disk_data_first_sector 
                                        mov a,l
                                        add e 
                                        mov e,a 
                                        mov a,h 
                                        adc d 
                                        mov d,a
                                        mov a,c 
                                        aci 0 
                                        mov b,a
                                        mov a,b 
                                        aci 0 
                                        mov b,a  
                                        call fsm_seek_disk_sector
                                        cpi fsm_operation_ok
                                        jnz fsm_write_data_page_operation_ok
fsm_write_data_page_operation_ok:       call fsm_reselect_mms_segment
                                        cpi fsm_operation_ok
                                        jnz fsm_write_data_page_end
                                        lxi h,0 
                                        lda fsm_selected_disk_spp_number
                                        push psw 
fsm_write_data_page_operation_loop:     mov a,c 
                                        call bios_mass_memory_select_head
                                        cpi bios_operation_ok
                                        jnz fsm_write_data_page_end_loop
                                        xchg 
                                        call bios_mass_memory_select_track
                                        xchg 
                                        cpi bios_operation_ok
                                        jnz fsm_write_data_page_end_loop
                                        mov a,b 
                                        call bios_mass_memory_select_sector
                                        cpi bios_operation_ok
                                        jnz fsm_write_data_page_end_loop
                                        call mms_mass_memory_write_sector
                                        cpi mms_operation_ok
                                        jnz fsm_write_data_page_end_loop
                                        inr b 
                                        lda fsm_selected_disk_spt_number
                                        cmp b 
                                        jnz fsm_write_data_page_operation_loop2
                                        mvi b,0
                                        inx d 
                                        lda fsm_selected_disk_tph_number+1
                                        cmp d  
                                        jnz fsm_write_data_page_operation_loop2
                                        lda fsm_selected_disk_tph_number
                                        cmp e 
                                        jnz fsm_write_data_page_operation_loop2
                                        lxi d,0 
                                        inr c 
                                        lda fsm_selected_disk_head_number
                                        cmp e 
                                        jnz fsm_write_data_page_operation_loop2
                                        mvi a,fsm_end_of_disk
                                        jmp fsm_write_data_page_end_loop
fsm_write_data_page_operation_loop2:    xthl 
                                        dcr h 
                                        xthl
                                        jnz fsm_write_data_page_operation_loop
                                        mvi a,fsm_operation_ok
fsm_write_data_page_end_loop:           inx sp 
                                        inx sp 
fsm_write_data_page_end:                pop h 
                                        pop d 
                                        pop b 
                                        ret 

;fsm_seek_mass_memory_sector decodifica il numero di settore in numeri di testina, traccia e settore
;BCDE -> posizione in settori
;B <- numero di settore 
;C <- numero di testina 
;DE <- numero di traccia

fsm_seek_disk_sector:                       push h 
                                            lda fsm_selected_disk_sectors_number
                                            sub e 
                                            lda fsm_selected_disk_sectors_number+1
                                            sbb d 
                                            lda fsm_selected_disk_sectors_number+2
                                            sbb c 
                                            lda fsm_selected_disk_sectors_number+3
                                            sbb b 
                                            jnc fsm_seek_disk_sector_not_overflow
                                            mvi a,fsm_mass_memory_sector_not_found
                                            jmp fsm_seek_disk_sector_error
fsm_seek_disk_sector_not_overflow:          lxi h,0 
                                            push h                                  ;SP -> [sector, head][track]
                                            push h 
                                            push h 
                                            lda fsm_selected_disk_spt_number
                                            mov l,a
                                            push h 
                                            push b 
                                            push d  
                                            call unsigned_divide_long 
                                            pop h 
                                            inx sp
                                            inx sp 
                                            pop d 
                                            pop b 
                                            mov a,l                
                                            xthl 
                                            mov h,a 
                                            xthl                  
                                            lhld fsm_selected_disk_tph_number
                                            push h 
                                            lxi h,0 
                                            push h 
                                            push b 
                                            push d 
                                            call unsigned_divide_long 
                                            pop h 
                                            inx sp 
                                            inx sp 
                                            pop b 
                                            inx sp 
                                            inx sp
                                            xchg 
                                            inx sp 
                                            inx sp 
                                            xthl 
                                            mov l,e 
                                            mov h,d 
                                            xthl 
                                            dcx sp 
                                            dcx sp 
                                            xchg 
                                            xthl
                                            mov b,h  
                                            xthl 
                                            pop d 
                                            pop d 
                                            mvi a,fsm_operation_ok
fsm_seek_disk_sector_error:                 pop h 
                                            ret 

;string_segment_ncompare verifica se due stringhe sono uguali (un operando è in un segmento di memoria)

;A -> numero massimo di bytes 
;DE -> indirizzo della prima stringa
;HL -> indirizzo della seconda stringa (offset nel segmento selezionato precedentemente)

;A <- esito dell'operazione ($ff se corrispondono, $00 se si verifica un errore o se non corrispondono)


string_segment_ncompare:        push b 
                                push d 
                                push h 
                                ora a 
                                jz string_segment_ncmp_loop_end2
                                mov b,a 
string_segment_ncmp_loop:       dcr b 
                                jnz string_segment_ncmp_loop3
                                ldax d
                                mov c,a 
                                call fsm_read_selected_data_segment_byte
                                jc string_segment_ncmp_loop_end2
                                cmp c 
                                jz string_segment_ncmp_loop_end1
                                jmp string_segment_ncmp_loop_end2
string_segment_ncmp_loop3:      call fsm_read_selected_data_segment_byte
                                
                                jc string_segment_ncmp_loop_end2
                                ora a 
                                jz string_segment_ncmp_loop2
                                ldax d 
                                mov c,a 
                                call fsm_read_selected_data_segment_byte
                                jc string_segment_ncmp_loop_end2
                                cmp c
                                jnz string_segment_ncmp_loop_end2
                                inx h 
                                inx d 
                                jmp string_segment_ncmp_loop
string_segment_ncmp_loop2:      ldax d 
                                ora a 
                                jnz string_segment_ncmp_loop_end2
string_segment_ncmp_loop_end1:  mvi a,$ff
                                jmp string_segment_ncompare_end
string_segment_ncmp_loop_end2:  xra a 
string_segment_ncompare_end:    pop h 
                                pop d 
                                pop b
                                ret

;string_segment_ncopy esegue la copia della stringa sorgente a partire dell'indirizzo specificato come destinazione (in un segmento) imponendo un massimo di caratteri da copiare. 
;La stringa sorgente viene considerata come terminata quando viene rilevato il carattere terminatore.
;A  -> numero massimo di caratteri
;DE -> puntatore alla stringa di sorgente
;HL -> puntatore alla stringa di destinazione (offset nel segmento dati già selezionato)

string_segment_ncopy:       push b 
                            push d 
                            push h 
                            ora a 
                            jz string_segment_ncopy_end1
                            mov b,a 
string_segment_ncopy_loop:  ldax d 
                            ora a 
                            jz string_segment_ncopy_end
                            call fsm_write_selected_data_segment_byte
                            jc string_segment_ncopy_end1 
                            inx h 
                            inx d 
                            dcr b 
                            jnz string_segment_ncopy_loop
string_segment_ncopy_end:   call fsm_write_selected_data_segment_byte
string_segment_ncopy_end1:  pop h 
                            pop d 
                            pop b 
                            ret 

;string_segment_source_ncopy la copia della stringa sorgente a partire dell'indirizzo specificato come destinazione (in un segmento) imponendo un massimo di caratteri da copiare. 
;La stringa sorgente viene considerata come terminata quando viene rilevato il carattere terminatore.
;A  -> numero massimo di caratteri
;DE -> puntatore alla stringa di sorgente (offset nel segmento dati già selezionato)
;HL -> puntatore alla stringa di destinazione 


string_segment_source_ncopy:            push b 
                                        push d 
                                        push h 
                                        ora a 
                                        jz string_segment_source_ncopy_end1
                                        xchg 
                                        mov b,a 
string_segment_source_ncopy_loop:       call fsm_read_selected_data_segment_byte
                                        jc string_segment_source_ncopy_end1 
                                        ora a 
                                        jz string_segment_source_ncopy_end
                                        stax d 
                                        inx h 
                                        inx d 
                                        dcr b 
                                        jnz string_segment_source_ncopy_loop
string_segment_source_ncopy_end:        stax d 
string_segment_source_ncopy_end1:       pop h 
                                        pop d 
                                        pop b 
                                        ret 

fsm_layer_end:      
.print "Space left in FSM layer ->",fsm_dimension-fsm_layer_end+FSM
.memory "fill", fsm_layer_end, fsm_dimension-fsm_layer_end+FSM,$00
.print "FSM load address ->",FSM 
.print "All functions built successfully"
