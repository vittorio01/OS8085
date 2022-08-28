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

fsm_selected_disk                       .equ $0060
fsm_selected_disk_head_number           .equ $0061
fsm_selected_disk_tph_number            .equ $0062 
fsm_selected_disk_spt_number            .equ $0064 
fsm_selected_disk_bps_number            .equ $0065
fsm_selected_disk_sectors_number        .equ $0066
fsm_selected_disk_spp_number            .equ $006A
fsm_selected_disk_data_first_sector     .equ $006B

fsm_page_buffer_segment_id              .equ $006D
fsm_page_buffer_segment_address         .equ $006E

fsm_selected_disk_data_page_number      .equ $0070
fsm_selected_disk_fat_page_number       .equ $0072


;fsm_selected_disk_loaded_page_flags contiene le informazioni sul disco selezionato 
;bit 7 -> pagina caricata in memoria
;bit 6 -> tipo di pagina (FAT 0 o data 1)
;bit 5 -> disco selezionato precedentemente 
;bit 4 -> il disco selezionato è formattato 
;bit 3 -> è stata selezionata un'intestazione

fsm_selected_disk_loaded_page               .equ $0073
fsm_selected_disk_loaded_page_flags         .equ $0075
fsm_selected_disk_free_page_number          .equ $0076
fsm_selected_disk_first_free_page_address   .equ $0078

fsm_selected_file_header_page_address       .equ $007A
fsm_selected_file_header_php_address        .equ $007C



fsm_coded_page_dimension            .equ 16
fsm_uncoded_page_dimension          .equ 2048

fsm_format_marker_lenght            .equ 6 

fsm_header_per_page_number          .equ 64 
fsm_header_dimension                .equ 32 
fsm_disk_name_max_lenght            .equ 20
fsm_header_name_dimension           .equ 20
fsm_header_extension_dimension      .equ 5 
fsm_header_valid_bit                .equ %10000000
fsm_header_deleted_bit              .equ %01000000
fsm_header_system_bit               .equ %00100000
fsm_header_program_bit              .equ %00010000
fsm_header_hidden_bit               .equ %00001000
fsm_header_readonly_bit             .equ %00000100

fsm_mass_memory_sector_not_found    .equ $20
fsm_bad_argument                    .equ $21
fsm_disk_not_selected               .equ $22
fsm_formatting_fat_generation_error .equ $23
fsm_unformatted_disk                .equ $24
fsm_device_not_found                .equ $25
fsm_not_enough_spage_left           .equ $26
fsm_list_is_empty                   .equ $27
fsm_header_not_found                .equ $28
fsm_header_not_selected             .equ $2a
fsm_end_of_disk                     .equ $29
fsm_header_exist                    .equ $2A 
fsm_end_of_list                     .equ $2B 
fsm_operation_ok                    .equ $ff 

fsm_functions:  .org FSM 
                jmp fsm_init 
                jmp fsm_disk_format 
                ;jmp fsm_disk_wipe 
                ;jmp fsm_disk_mount 

fsm_format_marker   .text "SFS1.0"
                    .b $00

fsm_default_disk_name   .text "NO NAME"



;fsm_init inizializza la fsm 

fsm_init:   push h 
            xra a 
            sta fsm_selected_disk
            sta fsm_selected_disk_loaded_page
            sta fsm_selected_disk_loaded_page+1
            sta fsm_selected_disk_loaded_page_flags
            lxi h,fsm_uncoded_page_dimension
            call mms_create_low_memory_system_data_segment
            ora a 
            jz fsm_disk_external_generated_error
            sta fsm_page_buffer_segment_id 
            call mms_read_selected_system_segment_data_address
            shld fsm_page_buffer_segment_address
            pop h 
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
fsm_select_next2:               sta fsm_selected_disk_bps_number
                                mvi a,%00100000
                                sta fsm_selected_disk_loaded_page_flags
                                mov a,b 
                                sta fsm_selected_disk_spt_number
                                mov a,c 
                                sta fsm_selected_disk_head_number
                                xchg 
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
                                call fsm_reselect_mms_segment
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end
                                call bios_mass_memory_read_sector
                                cpi bios_operation_ok
                                jnz fsm_select_disk_end    

                                call fsm_reselect_mms_segment
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end
                                inx h 
                                inx h 
                                inx h 
                                lxi d,fsm_format_marker
                                mvi a,fsm_format_marker_lenght
                                call string_ncompare
                                ora a 
                                jnz fsm_select_disk_formatted_disk
                                mvi a,fsm_unformatted_disk 
                                jmp fsm_select_disk_end
fsm_select_disk_formatted_disk: lda fsm_selected_disk_loaded_page_flags
                                ori %00010000
                                sta fsm_selected_disk_loaded_page_flags
                                call fsm_reselect_mms_segment
                                cpi fsm_operation_ok
                                jnz fsm_select_disk_end
                                lxi d,fsm_format_marker_lenght+7 
                                dad d 
                                mov a,m 
                                sta fsm_selected_disk_spp_number
                                inx h 
                                mov a,m 
                                sta fsm_selected_disk_fat_page_number
                                inx h 
                                mov a,m 
                                sta fsm_selected_disk_data_page_number
                                inx h 
                                mov a,m 
                                sta fsm_selected_disk_data_page_number+1
                                inx h 
                                mov a,m 
                                sta fsm_selected_disk_data_first_sector
                                inx h 
                                mov a,m 
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

fsm_disk_format:                        push b 
                                        push d 
                                        push h 
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani %00100000
                                        jnz fsm_disk_format_next
                                        mvi a,fsm_bad_argument
                                        jmp fsm_disk_external_generated_error
fsm_disk_format_next:                   call bios_mass_memory_format_device
                                        cpi bios_operation_ok 
                                        jnz fsm_disk_external_generated_error
                                        lda fsm_selected_disk
                                        call bios_mass_memory_select_drive
                                        ora a 
                                        jnz fsm_disk_format_next2
                                        mvi a,fsm_device_not_found
                                        jmp fsm_disk_external_generated_error
fsm_disk_format_next2:                  sta fsm_selected_disk_bps_number
                                        mov a,b 
                                        sta fsm_selected_disk_spt_number
                                        mov a,c 
                                        sta fsm_selected_disk_head_number
                                        xchg 
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
                                        pop d 
                                        push d 
                                        call unsigned_divide_word
                                        mov a,e 
                                        ora d 
                                        jz fsm_disk_format_jump1
                                        inx b 
fsm_disk_format_jump1:                  inx b 
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
                                        mvi m,$c9 
                                        inx h 
                                        inx h 
                                        inx h 
                                        lxi d,fsm_format_marker
                                        mvi a,fsm_format_marker_lenght 
                                        call string_ncopy
                                        mvi a,fsm_format_marker_lenght 
                                        add l 
                                        mov l,a 
                                        mov a,h 
                                        aci 0 
                                        mov h,a 
                                        lda fsm_selected_disk_sectors_number
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+1
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+2
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_sectors_number+3
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_spp_number
                                        mov m,a 
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
                                        jz fsm_disk_format_jump2 
                                        mvi a,1
fsm_disk_format_jump2:                  pop d 
                                        pop b 
                                        add e 
                                        mov e,a 
                                        sta fsm_selected_disk_fat_page_number
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_data_page_number
                                        sub e 
                                        mov m,a 
                                        inx h 
                                        sta fsm_selected_disk_data_page_number
                                        lda fsm_selected_disk_data_page_number+1
                                        sbi 0 
                                        mov m,a 
                                        inx h 
                                        sta fsm_selected_disk_data_page_number+1
                                        lda fsm_selected_disk_data_first_sector
                                        mov m,a 
                                        inx h 
                                        lda fsm_selected_disk_data_first_sector+1  
                                        mov m,a 
                                        inx h 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        lhld fsm_page_buffer_segment_address
                                        call bios_mass_memory_write_sector
                                        cpi bios_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        call fsm_clear_fat_table
                                        cpi fsm_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        lxi d,fsm_default_disk_name
                                        call fsm_disk_set_name
                                        cpi fsm_operation_ok
                                        jnz fsm_disk_external_generated_error
                                        mvi a,%00110000
                                        sta fsm_selected_disk_loaded_page_flags
                                        mvi a,fsm_operation_ok 
fsm_disk_external_generated_error:      pop h 
                                        pop d 
                                        pop b 
                                        ret 

;fsm_disk_set_name sostituisce il nome del disco con quello fornito
;DE -> puntatore alla stringa del nome 
;A <- esito dell'operazione

fsm_disk_set_name:                  lda fsm_selected_disk_loaded_page_flags
                                    ani %00110000
                                    xri $ff 
                                    jnz fsm_disk_set_name_disk_selected
                                    mvi a,fsm_disk_not_selected
                                    ret 
fsm_disk_set_name_disk_selected:    push h
                                    lxi h,0 
                                    call fsm_move_data_page
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    call fsm_reselect_mms_segment
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    mvi a,fsm_disk_name_max_lenght
                                    call string_ncopy
                                    lxi h,0 
                                    call fsm_write_data_page
                                    cpi fsm_operation_ok
                                    jnz fsm_disk_set_name_end
                                    mvi a,fsm_operation_ok
fsm_disk_set_name_end:              pop h 
                                    ret 

;fsm_selected_file_append_data_bytes aumenta la dimensione del file selezionato del numero di bytes richiesto (massimo 64k)
;hL -> numero di bytes da aggiungere 
;A <- esito dell'operazione

fsm_selected_file_append_data_bytes:        push b 
                                            push d  
                                            push h 
                                            xchg   
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            lxi b,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                            dad b 
                                            mov a,e 
                                            add m 
                                            mov e,a 
                                            inx h 
                                            mov a,d  
                                            adc m 
                                            mov d,a 
                                            inx h 
                                            mov a,m  
                                            aci 0
                                            mov c,a 
                                            inx h 
                                            mov a,m 
                                            aci 0
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
                                            jz fsm_selected_file_append_data_bytes_next
                                            mvi a,1 
fsm_selected_file_append_data_bytes_next:   pop d 
                                            inx sp 
                                            inx sp 
                                            add e 
                                            mov e,a 
                                            mov a,d 
                                            aci 0 
                                            mov d,a  
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            mvi a,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
                                            push d 
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            inx h 
                                            mov c,m 
                                            inx h 
                                            mov b,m 
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
                                            jz fsm_selected_file_append_data_bytes_next2
                                            mvi a,1 
fsm_selected_file_append_data_bytes_next2:  pop d 
                                            inx sp 
                                            inx sp 
                                            add e 
                                            mov e,a 
                                            mov a,d 
                                            aci 0 
                                            mov d,a 
                                            pop b 
                                            mov a,c 
                                            sub e 
                                            mov c,a 
                                            mov a,b 
                                            sbb d 
                                            mov b,a 
                                            mov a,c 
                                            ora b 
                                            jz fsm_selected_file_append_data_bytes_next3
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+5
                                            dad d
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            xchg 
                                            mov a,l
                                            ana h 
                                            cpi $ff 
                                            jnz fsm_selected_file_append_data_bytes_next4
                                            mov a,c 
                                            call fsm_get_first_free_page_list
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            mov c,l 
                                            mov b,h 
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+5
                                            dad d
                                            mov m,c  
                                            inx h 
                                            mov m,b 
                                            lxi d,$fffB
                                            dad d
                                            jmp fsm_selected_file_append_data_bytes_next5
fsm_selected_file_append_data_bytes_next4:  mov a,c 
                                            call fsm_append_pages
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end 
                                            call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_selected_file_append_data_bytes_end
                                            lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1
                                            dad d 
fsm_selected_file_append_data_bytes_next5:  xthl 
                                            mov e,l 
                                            mov d,h 
                                            xthl
                                            mov a,e 
                                            add m 
                                            mov m,a 
                                            inx h 
                                            mov a,d 
                                            adc m 
                                            mov m,a 
                                            inx h 
                                            mov a,m 
                                            aci 0 
                                            mov m,a 
                                            inx h 
                                            mov a,m 
                                            aci 0 
                                            mov m,a 
fsm_selected_file_append_data_bytes_next3:  mvi a,fsm_operation_ok
fsm_selected_file_append_data_bytes_end:    pop h                      
                                            pop d   
                                            pop b   
                                            ret 

;fsm_selected_file_clear elimina tutto il contenuto del file selezionato precedentemente 
; A <- esito dell'operazione 

fsm_selected_file_wipe:         push d 
                                push h 
                                call fsm_load_selected_file_header
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_truncate_data_bytes_end 
                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+5 
                                dad d 
                                mov e,m 
                                inx h 
                                mov d,m 
                                xchg 
                                push h 
                                lxi b,0 
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
fsm_selected_file_wipe_next3:   inx sp 
                                inx sp 
                                jmp fsm_selected_file_wipe_end 
fsm_selected_file_wipe_next2:   lhld fsm_selected_disk_first_free_page_address
                                xchg 
                                call fsm_set_page_link
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_wipe_next3
                                lhld fsm_selected_disk_free_page_number
                                dad b 
                                shld fsm_selected_disk_free_page_number
fsm_selected_file_wipe_next4:   pop h 
                                shld fsm_selected_disk_first_free_page_address
                                call fsm_load_selected_file_header
                                cpi fsm_operation_ok
                                jnz fsm_selected_file_wipe_end
                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+6 
                                dad d 
                                mvi m,$ff 
                                dcx h 
                                mvi m,$ff 
                                dcx h 
                                mvi m,0 
                                dcx h 
                                mvi m,0 
                                dcx h 
                                mvi m,0 
                                dcx h 
                                mvi m,0 
                                mvi a,fsm_operation_ok
fsm_selected_file_wipe_end:     pop h 
                                pop d 
                                ret 

;fsm_selected_file_truncate_data_bytes rimuove i bytes desiderati dal file (partendo dalla fine)

;HL -> numero di bytes da eliminare
;A <- esito dell'operazione

fsm_selected_file_truncate_data_bytes:          push b 
                                                push d 
                                                push h 
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end 
                                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                dad d 
                                                mov a,m 
                                                inx h 
                                                xthl 
                                                sub l 
                                                mov e,a 
                                                xthl 
                                                mov a,m 
                                                inx h 
                                                xthl 
                                                sbb h 
                                                mov d,a 
                                                xthl 
                                                mov a,m 
                                                sbi 0 
                                                mov c,a 
                                                inx h 
                                                mov a,m 
                                                sbi 0 
                                                mov b,a 
                                                jnc fsm_selected_file_truncate_data_bytes_next 
                                                lxi b,0 
                                                lxi d,0 
fsm_selected_file_truncate_data_bytes_next:     lxi h,0 
                                                push h 
                                                lxi h,fsm_uncoded_page_dimension
                                                push h 
                                                push b 
                                                push d 
                                                call unsigned_divide_long
                                                pop b
                                                mov a,c 
                                                ora b 
                                                pop b 
                                                ora c 
                                                ora b 
                                                jz fsm_selected_file_truncate_data_bytes_next2
                                                mvi a,1 
fsm_selected_file_truncate_data_bytes_next2:    pop b 
                                                add c 
                                                mov c,a 
                                                mov a,b 
                                                aci 0 
                                                mov b,a 
                                                inx sp 
                                                inx sp 
                                                ora c 
                                                jnz fsm_selected_file_truncate_data_bytes_next22
                                                call fsm_selected_file_wipe 
                                                jmp fsm_selected_file_truncate_data_bytes_end 
fsm_selected_file_truncate_data_bytes_next22:   call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end
                                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+4 
                                                dad d
                                                lxi d,0 
                                                push d
                                                lxi d,fsm_uncoded_page_dimension
                                                push d
                                                mov d,m 
                                                dcx h 
                                                mov e,m 
                                                push d 
                                                dcx h 
                                                mov d,m 
                                                dcx h 
                                                mov e,m 
                                                push d 
                                                call unsigned_divide_long 
                                                pop d
                                                mov a,e 
                                                ora d 
                                                pop d 
                                                ora e 
                                                ora d 
                                                jz fsm_selected_file_truncate_data_bytes_next3
                                                mvi a,1 
fsm_selected_file_truncate_data_bytes_next3:    pop d 
                                                add e 
                                                mov e,a 
                                                mov a,d 
                                                aci 0 
                                                mov d,a 
                                                inx sp 
                                                inx sp 
                                                mov a,e 
                                                sub c 
                                                mov e,a 
                                                mov a,d 
                                                sbb b 
                                                mov d,a  
                                                ora e 
                                                jz fsm_selected_file_truncate_data_bytes_next5
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end
                                                push d 
                                                mvi a,fsm_header_name_dimension+fsm_header_extension_dimension+5 
                                                add l 
                                                mov l,a 
                                                mov a,h
                                                aci 0 
                                                mov h,a 
                                                mov e,m 
                                                inx h 
                                                mov d,m 
                                                xchg 
                                                pop d 
                                                push d 
fsm_selected_file_truncate_data_bytes_loop:     dcx b 
                                                mov a,c 
                                                ora b 
                                                jz fsm_selected_file_truncate_data_bytes_next4
                                                call fsm_get_page_link
                                                cpi fsm_operation_ok
                                                jz fsm_selected_file_truncate_data_bytes_loop
                                                inx sp 
                                                inx sp 
                                                jmp fsm_selected_file_truncate_data_bytes_end
fsm_selected_file_truncate_data_bytes_next4:    pop b 
                                                mov e,l 
                                                mov d,h 
                                                call fsm_get_page_link
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end
                                                mov a,c 
                                                call fsm_set_first_free_page_list
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end
                                                xchg 
                                                lxi d,$ffff 
                                                call fsm_set_page_link
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end
fsm_selected_file_truncate_data_bytes_next5:    call fsm_load_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz fsm_selected_file_truncate_data_bytes_end 
                                                lxi d,fsm_header_name_dimension+fsm_header_extension_dimension+1 
                                                dad d 
                                                mov a,m 
                                                xthl 
                                                sub l 
                                                xthl 
                                                mov m,a 
                                                inx h 
                                                mov a,m 
                                                xthl
                                                sbb h 
                                                xthl 
                                                mov m,a 
                                                inx h 
                                                mov a,m 
                                                sbi 0 
                                                mov m,a 
                                                inx h 
                                                mov a,m 
                                                sbi 0 
                                                mov m,a 
                                                mvi a,fsm_operation_ok
fsm_selected_file_truncate_data_bytes_end:      pop h 
                                                pop d 
                                                pop b 
                                                ret 

;fsm_reset_file_header_scan_pointer inizializza il puntatore al file corrente

fsm_reset_file_header_scan_pointer: push h 
                                    lxi h,0 
                                    shld fsm_selected_file_header_page_address 
                                    lxi h,1 
                                    shld fsm_selected_file_header_php_address 
                                    pop h 
                                    ret 

;fsm_increment_file_header_scan_pointer seleziona la prima intestazione valida successiva a quella corrente
; A <- esito dell'operazione 

fsm_increment_file_header_scan_pointer:         push h 
                                                push d 
                                                push b 
                                                call fsm_load_selected_file_header
                                                cpi fsm_operation_ok                
                                                jnz fsm_increment_file_header_scan_pointer_end2  
                                                push h 
                                                xchg 
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_increment_file_header_scan_pointer_end 
                                                mov a,e 
                                                sub l 
                                                mov l,a 
                                                mov a,d 
                                                sbb h                               ;BC -> dimensione del buffer
                                                mov h,a                             ;DE -> pagina corrente
                                                lxi d,0                             ;HL -> puntatore al buffer
                                                lxi b,fsm_uncoded_page_dimension    ;SP -> [pozizione nel buffer][b][d][h]
                                                xthl 
fsm_increment_file_header_scan_pointer_loop:    mvi a,fsm_header_dimension
                                                add l 
                                                mov l,a 
                                                mov a,h 
                                                aci 0 
                                                mov h,a 
                                                xthl 
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
                                                xthl 
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
fsm_increment_file_header_scan_pointer_loop2:   mov a,m 
                                                ani fsm_header_valid_bit
                                                jz fsm_increment_file_header_scan_pointer_eol 
                                                mov a,m 
                                                ani fsm_header_deleted_bit
                                                jnz fsm_increment_file_header_scan_pointer_loop
                                                xchg  
                                                shld fsm_selected_file_header_page_address
                                                xthl 
                                                mov c,l 
                                                mov b,h 
                                                lxi d,fsm_header_dimension
                                                call unsigned_divide_word
                                                mov l,c 
                                                mov h,b 
                                                shld fsm_selected_file_header_php_address
                                                mvi a,fsm_operation_ok
                                                jmp fsm_increment_file_header_scan_pointer_end  
fsm_increment_file_header_scan_pointer_eol:     mvi a,fsm_end_of_list  
fsm_increment_file_header_scan_pointer_end:     inx sp 
                                                inx sp
fsm_increment_file_header_scan_pointer_end2:    pop b 
                                                pop d 
                                                pop h 
                                                ret 

;fsm_get_selected_file_header_flags restituisce le caratteristiche del file 
; A <- esito dell'operazione
; B <- flags 

fsm_get_selected_file_header_flags:     push h 
                                        call fsm_load_selected_file_header
                                        cpi fsm_operation_ok
                                        jnz fsm_get_selected_file_header_flags_end
                                        mov b,m 
fsm_get_selected_file_header_flags_end: pop h 
                                        ret 

;fsm_set_selected_file_header_flags imposta le flags al file selezionato precedentemente
; A <- esito dell'operazione
; B <- flags 

fsm_set_selected_file_header_flags:         push h 
                                            push psw 
                                            ani fsm_header_valid_bit
                                            jnz fsm_set_selected_file_header_flags_next
                                            mvi a,fsm_bad_argument
                                            jmp fsm_set_selected_file_header_flags_end
fsm_set_selected_file_header_flags_next:    xthl 
                                            mov a,h 
                                            xthl 
                                            ani fsm_header_deleted_bit
                                            jz fsm_set_selected_file_header_flags_next2
                                            mvi a,fsm_bad_argument
                                            jmp fsm_set_selected_file_header_flags_end
fsm_set_selected_file_header_flags_next2:   call fsm_load_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz fsm_set_selected_file_header_flags_end
                                            mov b,m 
fsm_set_selected_file_header_flags_end:     inx sp 
                                            inx sp 
                                            pop h 

;fsm_get_selected_file_header_first_page_address restituisce il primo indirizzo della pagina che punta al corpo del file selezionato precedentemente 
;A <- esito dell'operazione 
;HL <- indirizzo alla prima pagina
fsm_get_selected_file_header_first_page_address:        push d 
                                                        call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_get_selected_file_header_first_page_address_end 
                                                        lxi d,fsm_header_dimension-2 
                                                        dad h 
                                                        mov e,m 
                                                        inx h 
                                                        mov d,m 
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
                                            dad h 
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            inx h 
                                            mov c,m 
                                            inx h 
                                            mov b,m 
fsm_get_selected_file_header_dimension_end: pop h 
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
fsm_get_selected_file_header_name_dimension_loop:       mov a,m 
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
                                                        call string_ncopy
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

;fsm_set_selected_file_header_name_and_extension modfica il nome e l'estenzione del file desiderato
;BC -> nome del file 
;DE -> estensione 

;A <- esito dell'operazione 
fsm_set_selected_file_header_name_and_extension:        push h 
                                                        push d 
                                                        push b 
                                                        call fsm_load_selected_file_header
                                                        cpi fsm_operation_ok
                                                        jnz fsm_set_selected_file_header_name_and_extension_end
                                                        inx h 
                                                        push d 
                                                        push b 
                                                        pop d 
                                                        pop b 
                                                        mvi a,fsm_header_name_dimension
                                                        call string_ncompare
                                                        lxi d,fsm_header_name_dimension
                                                        dad d 
                                                        mov e,c 
                                                        mov d,b 
                                                        mov c,a 
                                                        mvi a,fsm_header_extension_dimension
                                                        call string_ncompare
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
                                                        call string_ncopy
                                                        lxi d,fsm_header_name_dimension
                                                        dad d 
                                                        mvi a,fsm_header_extension_dimension
                                                        mov e,c 
                                                        mov d,b 
                                                        call string_ncopy
                                                        mvi a,fsm_operation_ok
fsm_set_selected_file_header_name_and_extension_end:    pop b 
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
fsm_get_selected_file_header_extension_dimension_loop:      mov a,m 
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
                                                            call string_ncopy
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
                                        ani %00001000
                                        jnz fsm_load_selected_file_header_next
                                        mvi a,fsm_header_not_selected 
                                        jmp fsm_load_selected_file_header_end
fsm_load_selected_file_header_next:     lhld fsm_selected_file_header_page_address
                                        call fsm_move_data_page
                                        cpi fsm_operation_ok
                                        jnz fsm_get_selected_file_header_flags_end
                                        lhld fsm_selected_file_header_php_address
                                        xchg 
                                        lxi b,fsm_header_dimension
                                        call unsigned_multiply_word 
                                        call fsm_reselect_mms_segment
                                        cpi fsm_operation_ok
                                        jnz fsm_get_selected_file_header_flags_end
                                        dad d 
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
                                            push psw
                                            lxi h,0 
                                            call fsm_move_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok                ;BC -> dimensione del buffer 
                                            jnz fsm_create_file_header_end      ;DE -> pagina corrente
                                            lxi d,0                             ;HL -> puntatore al buffer
                                            lxi b,fsm_uncoded_page_dimension    ;SP -> [pozizione nel buffer][psw][b][d][h]
                                            push h 
                                            lxi h,fsm_header_dimension 
                                            xthl 
                                            mvi a,fsm_header_dimension
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
fsm_create_file_header_search_loop:         mov a,m 
                                            ani fsm_header_valid_bit
                                            jz fsm_create_file_header_end_of_list 
                                            mov a,m 
                                            ani fsm_header_deleted_bit
                                            jnz fsm_create_file_header_deleted_replace 
                                            mvi a,fsm_header_dimension
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
                                            xthl 
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
                                            xthl 
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
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            xthl 
                                            lxi h,0 
                                            xthl 
                                            jmp fsm_create_file_header_search_loop
fsm_create_file_header_deleted_replace:     call fsm_create_file_header_write_bytes
                                            jmp fsm_create_file_header_next
fsm_create_file_header_end_of_page_list:    mov l,e 
                                            mov h,d 
                                            mvi a,1
                                            call fsm_append_pages
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            mov e,l 
                                            mov d,h 
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            call fsm_clear_mms_segment
                                            call fsm_create_file_header_write_bytes
                                            xchg 
                                            call fsm_write_data_page
                                            cpi fsm_operation_ok
                                            jnz fsm_create_file_header_end
                                            jmp fsm_create_file_header_next2
fsm_create_file_header_end_of_list:         call fsm_create_file_header_write_bytes
                                            xthl 
                                            mov a,l 
                                            sub c 
                                            mov a,h 
                                            sbb b 
                                            xthl 
                                            jnc fsm_create_file_header_next
                                            mvi m,0
fsm_create_file_header_next:                ;call fsm_writeback_page
                                            ;cpi fsm_operation_ok
                                            ;jnz fsm_create_file_header_end
fsm_create_file_header_next2:               mvi a,fsm_operation_ok
fsm_create_file_header_end:                 inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            pop b 
                                            pop d 
                                            pop h 
                                            ret 
                                        
fsm_create_file_header_write_bytes:     push d 
                                        lxi d,6 
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        xthl 
                                        mov a,h 
                                        xthl 
                                        mov m,a 
                                        inx h 
                                        inx sp 
                                        inx sp 
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
                                        mvi a,fsm_header_name_dimension
                                        call string_ncopy
                                        lxi d,fsm_header_name_dimension
                                        dad d 
                                        lxi d,10 
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg 
                                        xthl 
                                        mov c,l 
                                        mov b,h 
                                        xthl 
                                        lxi d,$fff6 
                                        xchg 
                                        dad sp 
                                        sphl 
                                        xchg
                                        mov e,c 
                                        mov d,b 
                                        mvi a,fsm_header_extension_dimension
                                        call string_ncopy
                                        lxi d,fsm_header_extension_dimension
                                        dad d 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        inx h 
                                        mvi m,0 
                                        inx h 
                                        mvi m,$ff 
                                        inx h 
                                        mvi m,$ff 
                                        inx h 
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
                                            ori %00001000
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
                                            jnz fsm_search_file_header_end2
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok                ;BC -> dimensione del buffer 
                                            jnz fsm_search_file_header_end      ;DE -> pagina corrente
                                            lxi d,0                             ;HL -> puntatore al buffer
                                            lxi b,fsm_uncoded_page_dimension    ;SP -> [pozizione nel buffer][psw][b][d][h]
                                            push h 
                                            lxi h,fsm_header_dimension 
                                            xthl 
                                            mvi a,fsm_header_dimension
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
fsm_search_file_header_search_loop:         mov a,m 
                                            ani fsm_header_valid_bit
                                            jz fsm_search_file_header_end_of_list 
                                            mov a,m 
                                            ani fsm_header_deleted_bit
                                            jnz fsm_search_file_header_search_loop2
                                            push h 
                                            push d 
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
                                            lxi d,$fffa
                                            xchg 
                                            dad sp 
                                            sphl 
                                            xchg 
                                            mov e,c 
                                            mov d,b 
                                            mvi a,fsm_header_name_dimension
                                            call string_ncompare
                                            ora a 
                                            jz fsm_search_file_header_search_loop_next
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
                                            call string_ncompare
                                            ora a 
                                            jz fsm_search_file_header_search_loop_next
                                            pop d 
                                            pop h 
                                            xthl 
                                            xchg 
                                            mov c,e 
                                            mov b,d 
                                            lxi d,fsm_header_dimension
                                            call unsigned_divide_word 
                                            xchg 
                                            mov e,c 
                                            mov d,b 
                                            mov c,l 
                                            mov b,h 
                                            mvi a,fsm_operation_ok
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            inx sp 
                                            pop h 
                                            ret 
fsm_search_file_header_search_loop_next:    pop d 
                                            pop h 
                                            lxi b,fsm_uncoded_page_dimension
fsm_search_file_header_search_loop2:        mvi a,fsm_header_dimension
                                            add l 
                                            mov l,a 
                                            mov a,h 
                                            aci 0 
                                            mov h,a 
                                            xthl 
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
                                            xthl 
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
                                            call fsm_reselect_mms_segment
                                            cpi fsm_operation_ok
                                            jnz fsm_search_file_header_end
                                            xthl 
                                            lxi h,0 
                                            xthl 
                                            jmp fsm_search_file_header_search_loop
fsm_search_file_header_end_of_list:         mvi a,fsm_header_not_found 
                                            lxi d,0 
                                            lxi b,0 
fsm_search_file_header_end:                 inx sp 
                                            inx sp
fsm_search_file_header_end2:                pop b 
                                            pop d 
                                            pop h 
                                            ret 

;fsm_append_pages concatena il numero di pagine libere desiderato alla lista 
; A -> numero di pagine da aggiungere
; HL -> indirizzo di partenza della lista 
; A <- esito dell'operazione 
; HL <- indirizzo della nuova pagina aggiunta

fsm_append_pages:       push d 
                        push b 
                        push psw 
fsm_append_pages_loop:  mov e,l 
                        mov d,h 
                        call fsm_get_page_link
                        cpi fsm_operation_ok
                        jnz fsm_append_pages_end
                        mov a,h
                        cpi $ff 
                        jnz fsm_append_pages_loop
                        mov a,l 
                        cpi $ff 
                        jnz fsm_append_pages_loop
                        xthl 
                        mov a,h 
                        xthl 
                        call fsm_get_first_free_page_list
                        cpi fsm_operation_ok
                        jnz fsm_append_pages_end
                        mov c,l 
                        mov b,h 
                        xchg 
                        call fsm_set_page_link
                        cpi fsm_operation_ok
                        jnz fsm_append_pages_end
                        call fsm_writeback_page
                        cpi fsm_operation_ok
                        jnz fsm_append_pages_end
                        mvi a,fsm_operation_ok
                        mov l,c 
                        mov h,b 
fsm_append_pages_end:   inx sp 
                        inx sp 
                        pop b 
                        pop d 
                        ret 

;fsm_get_first_free_page_list restituisce una lista concatenata di pagine libere 
;A <- numero di pagine da prelevare
;HL <- indirizzo alla prima pagina della lista prelevata 

fsm_get_first_free_page_list:           push d
                                        push b 
                                        push psw 
                                        ora a 
                                        jnz fsm_get_first_free_page_list_next
                                        mvi a,fsm_bad_argument
                                        lxi h,$ffff
                                        jmp fsm_get_first_free_page_list_end
fsm_get_first_free_page_list_next:      lhld fsm_selected_disk_free_page_number
                                        mov e,a 
                                        mov a,l 
                                        sub e 
                                        mov l,a 
                                        mov a,h 
                                        sbi 0 
                                        mov h,a 
                                        jz fsm_get_first_free_page_list_next2
                                        jnc fsm_get_first_free_page_list_next2
                                        mvi a,fsm_not_enough_spage_left
                                        lxi h,$ffff
                                        jmp fsm_get_first_free_page_list_end
fsm_get_first_free_page_list_next2:     shld fsm_selected_disk_free_page_number
                                        lhld fsm_selected_disk_first_free_page_address
                                        mov c,l 
                                        mov b,h 
fsm_get_first_free_page_list_loop:      xthl 
                                        dcr h 
                                        xthl 
                                        jz fsm_get_first_free_page_list_loop_end 
                                        call fsm_get_page_link
                                        cpi fsm_operation_ok
                                        jnz fsm_get_first_free_page_list_end
                                        jmp fsm_get_first_free_page_list_loop
fsm_get_first_free_page_list_loop_end:  mov e,l 
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
fsm_get_first_free_page_list_end:       inx sp 
                                        inx sp 
                                        pop b 
                                        pop d 
                                        ret      
                                

;fsm_set_first_free_page_list preleva il numero di pagine concatenate desiderato e le aggiunge alla lista delle pagine libere 
;Dopo l'operazione, la lista di partenza viene agiuntata, in modo da evitare problemi di inconsistenza
;A -> numero di pagine da liberare
;HL -> indirizzo alla prima pagina della lista da liberare 

;A <- esito dell'operazione 
;HL -> indirizzo alla prima pagina della sottolista troncata (da riallacciare sempre riallacciare la lista di partenza dopo aver chiamato la funzione)

fsm_set_first_free_page_list:           push d 
                                        push b 
                                        push psw 
                                        mov c,l 
                                        mov b,h 
                                        mov e,a 
fsm_set_first_free_page_list_loop:      dcr e 
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
                                        add h 
                                        mov e,a 
                                        mov a,d 
                                        aci 0 
                                        mov d,a 
                                        xthl 
                                        xchg 
                                        shld fsm_selected_disk_free_page_number
                                        xchg 
                                        mvi a,fsm_operation_ok
fsm_set_first_free_page_list_end:       inx sp 
                                        inx sp 
                                        pop b
                                        pop d 
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
                                            lxi d,fsm_disk_name_max_lenght
                                            dad d 
                                            mov a,m 
                                            sta fsm_selected_disk_free_page_number
                                            inx h 
                                            mov a,m 
                                            sta fsm_selected_disk_free_page_number+1 
                                            inx h 
                                            mov a,m 
                                            sta fsm_selected_disk_first_free_page_address
                                            inx h 
                                            mov a,m 
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
                                    mov a,e 
                                    add a 
                                    mov e,a 
                                    mov a,d 
                                    ral 
                                    mov d,a 
                                    dad d 
                                    mov e,m 
                                    inx h 
                                    mov d,m 
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
                                    mov a,e 
                                    add a 
                                    mov e,a 
                                    mov a,d 
                                    ral 
                                    mov d,a 
                                    dad d 
                                    pop d 
                                    push d 
                                    mov m,e  
                                    inx h 
                                    mov m,d  
                                    mvi a,fsm_operation_ok
fsm_set_page_link_end:              pop d 
                                    pop h 
                                    pop b 
                                    ret 

;fsm_fat_reset inizializza la fat table del dispositivo selezionato
fsm_clear_fat_table:                            lda fsm_selected_disk_loaded_page_flags
                                                ani %00110000
                                                xri $ff 
                                                jnz fsm_clear_fat_table_disk_selected
                                                mvi a,fsm_disk_not_selected
                                                ret 
fsm_clear_fat_table_disk_selected:              push h 
                                                push d 
                                                push b 
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_clear_fat_table_reset_end
                                                call fsm_clear_mms_segment
                                                xchg 
                                                lhld fsm_selected_disk_data_page_number
                                                push h                                  
                                                lxi h,0                                 ; sp -> [pagina fat][numero di pagine]
                                                push h                                  ; HL -> puntatore al buffer
                                                xchg                                    ; de -> pagina corrente 
                                                lxi b,fsm_uncoded_page_dimension        ; bc -> dimensione del buffer 
                                                mvi m,$ff 
                                                inx h 
                                                mvi m,$ff 
                                                inx h 
                                                inx d
                                                inx d 
                                                dcx b 
                                                dcx b
fsm_clear_fat_table_loop:                       inx sp 
                                                inx sp 
                                                xthl 
                                                mov a,l 
                                                sub e 
                                                mov a,h 
                                                sbb d 
                                                xthl 
                                                dcx sp 
                                                dcx sp 
                                                jc fsm_clear_fat_table_loop_end
                                                mov a,c 
                                                ora b 
                                                jz fsm_clear_fat_table_load_page
                                                mov m,e 
                                                inx h 
                                                mov m,d 
                                                inx h 
                                                dcx b 
                                                dcx b 
                                                inx d 
                                                jmp fsm_clear_fat_table_loop
fsm_clear_fat_table_load_page:                  lxi b,fsm_uncoded_page_dimension
                                                xthl 
                                                mov a,l 
                                                inr l 
                                                xthl 
                                                call fsm_write_fat_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_clear_fat_table_load_page_error
                                                call fsm_clear_mms_segment
                                                lhld fsm_page_buffer_segment_address
                                                jmp fsm_clear_fat_table_loop
fsm_clear_fat_table_load_page_error:            inx sp 
                                                inx sp 
                                                inx sp 
                                                inx sp 
                                                jmp fsm_clear_fat_table_reset_end
fsm_clear_fat_table_loop_end:                   dcx h 
                                                mvi m,$ff 
                                                dcx h 
                                                mvi m,$ff
                                                xthl 
                                                mov a,l 
                                                call fsm_write_fat_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_clear_fat_table_load_page_error
                                                lxi h,0 
                                                call fsm_read_data_page
                                                cpi fsm_operation_ok
                                                jnz fsm_clear_fat_table_load_page_error
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_clear_fat_table_reset_end
                                                lxi b,fsm_disk_name_max_lenght
                                                dad b 
                                                xchg 
                                                lhld fsm_selected_disk_data_page_number
                                                xchg 
                                                dcx d 
                                                mov m,e 
                                                inx h 
                                                mov m,d 
                                                inx h 
                                                mvi m,1 
                                                inx h 
                                                mvi m,0 
                                                call fsm_reselect_mms_segment
                                                cpi fsm_operation_ok
                                                jnz fsm_clear_fat_table_reset_end
                                                lxi b,fsm_header_dimension
                                                dad b 
                                                lxi b,fsm_uncoded_page_dimension-fsm_header_dimension 
fsm_clear_fat_table_header_space_format:        mvi m,0 
                                                dcx b 
                                                inx h 
                                                mov a,c 
                                                ora b 
                                                jnz fsm_clear_fat_table_header_space_format
                                                lxi h,0 
                                                call fsm_write_data_page
                                                cpi fsm_operation_ok                   
                                                jnz fsm_clear_fat_table_load_page_error
fsm_clear_fat_table_loop_end2:                  inx sp 
                                                inx sp 
                                                inx sp 
                                                inx sp 
                                                mvi a,fsm_operation_ok
fsm_clear_fat_table_reset_end:                  pop b 
                                                pop d 
                                                pop h 
                                                ret 

;fsm_reselect_mms_segment riseleziona il segmento di buffer e aggiorna l'indirizzo in memoria assogiato se è stato modificato
;A <- esito dell'operazione
;HL <- indirizzo aggiornato

fsm_reselect_mms_segment:   lda fsm_page_buffer_segment_id
                            call mms_select_low_memory_system_data_segment
                            cpi mms_operation_ok
                            rnz
                            call mms_read_selected_system_segment_data_address
                            shld fsm_page_buffer_segment_address
                            mvi a,fsm_operation_ok 
                            ret 

;fsm_clear_mms_segment riempie il buffer di memoria con degli zeri

fsm_clear_mms_segment:      push h 
                            push d 
                            call fsm_reselect_mms_segment
                            cpi fsm_operation_ok
                            jnz fsm_clear_mms_segment_end
                            lxi d,fsm_uncoded_page_dimension
fsm_clear_mms_segment_loop: mvi m,0 
                            inx h 
                            dcx d 
                            mov a,d 
                            ora e 
                            jnz fsm_clear_mms_segment_loop
                            mvi a,fsm_operation_ok
fsm_clear_mms_segment_end:  pop d 
                            pop h 
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
                            ani %10000000
                            jz fsm_move_fat_page_load 
                            lda fsm_selected_disk_loaded_page_flags
                            ani %01000000
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
fsm_move_fat_page_load:     mov a,d 
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
                                ani %10000000
                                jz fsm_move_data_page_load 
                                lda fsm_selected_disk_loaded_page_flags
                                ani %01000000
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
fsm_move_data_page_load:        mov l,e 
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
                                lxi d, fsm_disk_name_max_lenght
                                dad d 
                                xchg 
                                lhld fsm_selected_disk_free_page_number
                                mov a,l
                                stax d 
                                inx d 
                                mov a,h 
                                stax d 
                                lhld fsm_selected_disk_first_free_page_address
                                mov a,l
                                stax d 
                                inx d 
                                mov a,h 
                                stax d 
fsm_move_data_page_next:        mvi a,fsm_operation_ok
fsm_move_data_page_end:         pop h 
                                pop d 
                                ret 

;fsm_writeback_page salva in memoria la pagina contenuta nel buffer (salva le modifiche all'ultima pagina caricata)

fsm_writeback_page:     push h 
                        lda fsm_selected_disk_loaded_page_flags
                        ani %10000000
                        jz fsm_writeback_page_end
                        lda fsm_selected_disk_loaded_page_flags
                        ani %01000000
                        jz fsm_writeback_page_fat 
                        lhld fsm_selected_disk_loaded_page
                        call fsm_write_data_page
                        cpi fsm_operation_ok
                        jnz fsm_writeback_page_end
                        jmp fsm_writeback_page_ok
fsm_writeback_page_fat: lda fsm_selected_disk_loaded_page
                        call fsm_write_fat_page
                        cpi fsm_operation_ok
                        jnz fsm_writeback_page_end
fsm_writeback_page_ok:  mvi a,fsm_operation_ok
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
                                    ani %00110000
                                    jz fsm_read_fat_page_next
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani %00100000
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
                                    ani %01111111
                                    sta fsm_selected_disk_loaded_page_flags
                                    pop psw 
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_operation_ok:     lda fsm_selected_disk_loaded_page_flags
                                    ani %00111111
                                    sta fsm_selected_disk_loaded_page_flags
                                    call fsm_reselect_mms_segment
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
                                    call bios_mass_memory_read_sector
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
                                    ori %10000000
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
                                    ani %00110000
                                    jz fsm_write_fat_page_next
                                    lda fsm_selected_disk_loaded_page_flags
                                    ani %00100000
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
                                    call bios_mass_memory_write_sector
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
                                        ani %00110000
                                        jz fsm_read_data_page_next
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani %00100000
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
                                        ani %01111111
                                        sta fsm_selected_disk_loaded_page_flags
                                        pop psw 
                                        jmp fsm_read_data_page_end
fsm_read_data_page_operation_ok:        lda fsm_selected_disk_loaded_page_flags
                                        ani %01111111
                                        ori %01000000
                                        sta fsm_selected_disk_loaded_page_flags
                                        call fsm_reselect_mms_segment
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
                                        call bios_mass_memory_read_sector
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
                                        ori %11000000
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
                                        ani %00110000
                                        jz fsm_write_data_page_next
                                        lda fsm_selected_disk_loaded_page_flags
                                        ani %00100000
                                        jnz fsm_write_data_page_not_formatted
                                        mvi a,fsm_disk_not_selected
                                        jmp fsm_write_data_page_end
fsm_write_data_page_not_formatted:       mvi a,fsm_unformatted_disk
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
                                        call bios_mass_memory_write_sector
                                        cpi bios_operation_ok
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
fsm_write_data_page_operation_loop2:     xthl 
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