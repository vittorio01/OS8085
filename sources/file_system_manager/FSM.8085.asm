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
fsm_selected_disk_loaded_page           .equ $0073

;fsm_selected_disk_loaded_page_flags contiene le informazioni sul disco selezionato 
;bit 7 -> pagina caricata in memoria
;bit 6 -> tipo di pagina (FAT 0 o data 1)
;bit 5 -> disco selezionato precedentemente 
;bit 4 -> il disco selezionato è formattato 

fsm_selected_disk_loaded_page_flags     .equ $0075




fsm_coded_page_dimension            .equ 16
fsm_uncoded_page_dimension          .equ 2048

fsm_format_marker_lenght            .equ 6 
fsm_header_dimension                .equ 32 
fsm_disk_name_max_lenght            .equ 20
fsm_header_name_dimension           .equ 20
fsm_header_extension_dimenson       .equ 5 

fsm_mass_memory_sector_not_found    .equ $20
fsm_bad_argument                    .equ $21
fsm_disk_not_selected               .equ $22
fsm_formatting_fat_generation_error .equ $23
fsm_unformatted_disk                .equ $24
fsm_device_not_found                .equ $25
fsm_operation_ok                    .equ $ff

fsm_format_marker   .text "SFS1.0"
                    .b $00

fsm_default_disk_name   .text "NO NAME"

fsm_functions:  .org FSM 
                jmp fsm_init 
                jmp fsm_disk_format 
                ;jmp fsm_disk_wipe 
                ;jmp fsm_disk_mount 

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
                                mvi a,fsm_device_not_found
                                jmp fsm_select_disk_end
fsm_select_next2:               sta fsm_selected_disk_bps_number
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
                                mvi a,%00100000
                                sta fsm_selected_disk_loaded_page_flags
                                lhld fsm_page_buffer_segment_address
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
fsm_select_disk_formatted_disk: lhld fsm_page_buffer_segment_address
                                mvi a,fsm_format_marker_lenght+7 
                                add l 
                                mov l,a 
                                mov a,h 
                                aci 0 
                                mov h,a 
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
                                lda fsm_selected_disk_loaded_page_flags
                                ori %00010000
                                sta fsm_selected_disk_loaded_page_flags
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
   
;fsm_get_free_page_number ricava il numero di pagine libere del disco 
;A <- esito dell'operazioni
;HL 

fsm_get_free_page_number:   


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
                                                lhld fsm_page_buffer_segment_address
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
                                                inx h 
                                                mvi m,0 
                                                lhld fsm_page_buffer_segment_address 
                                                mvi b,fsm_header_dimension
                                                dad b 
                                                mvi m,0 
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
                                jz fsm_move_data_page_load
fsm_move_data_page_writeback:   call fsm_write_data_page
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
fsm_move_data_page_load:        mov l,e 
                                mov h,d  
                                shld fsm_selected_disk_loaded_page
                                call fsm_read_data_page
                                cpi fsm_operation_ok
                                jnz fsm_move_data_page_end
fsm_move_data_page_next:        mvi a,fsm_operation_ok
fsm_move_data_page_end:         pop h 
                                pop d 
                                ret 

;fsm_read_fat_page legge la pagina desiderata e salva il contenuto nel buffer in memoria
;A <- esito dell'operazione 

fsm_read_fat_page:                  push b
                                    push d 
                                    push h 
                                    mov b,a 
                                    lda fsm_selected_disk_fat_page_number 
                                    mov c,a 
                                    mov a,b 
                                    sub c
                                    jc fsm_read_fat_page_not_overflow
                                    xra a 
                                    sta fsm_selected_disk_loaded_page_flags
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
                                    xra a 
                                    sta fsm_selected_disk_loaded_page_flags
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_operation_ok:     lda fsm_selected_disk_loaded_page_flags
                                    ani %00111111
                                    sta fsm_selected_disk_loaded_page_flags
                                    call fsm_reselect_mms_segment
                                    lda fsm_selected_disk_spp_number  
                                    push psw 
fsm_read_fat_page_operation_loop:   call bios_mass_memory_read_sector
                                    cpi bios_operation_ok
                                    jz fsm_read_fat_page_operation_loop2
                                    inx sp 
                                    inx sp 
                                    jmp fsm_read_fat_page_end
fsm_read_fat_page_operation_loop2:  inr e 
                                    mov a,d 
                                    aci 0 
                                    mov d,a 
                                    mov a,c 
                                    aci 0 
                                    mov c,a 
                                    mov b,a 
                                    aci 0 
                                    mov b,a 
                                    call fsm_seek_disk_sector
                                    xthl 
                                    dcr h 
                                    xthl 
                                    jnz fsm_read_fat_page_operation_loop
                                    lda fsm_selected_disk_loaded_page_flags
                                    ori %10000000
                                    sta fsm_selected_disk_loaded_page_flags
                                    mvi a,fsm_operation_ok
                                    inx sp 
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
                                    lda fsm_selected_disk_fat_page_number 
                                    mov c,a 
                                    mov a,b 
                                    sub c
                                    jc fsm_write_fat_page_not_overflow
                                    xra a 
                                    sta fsm_selected_disk_loaded_page_flags
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
fsm_write_fat_page_operation_ok:    lda fsm_selected_disk_loaded_page_flags
                                    ani %00111111
                                    sta fsm_selected_disk_loaded_page_flags
                                    sta fsm_selected_disk_loaded_page_flags
                                    call fsm_reselect_mms_segment
                                    lda fsm_selected_disk_spp_number  
                                    push psw 
fsm_write_fat_page_operation_loop:  call bios_mass_memory_write_sector
                                    cpi bios_operation_ok
                                    jz fsm_write_fat_page_operation_loop2
                                    inx sp 
                                    inx sp 
                                    jmp fsm_write_fat_page_end
fsm_write_fat_page_operation_loop2: inr e 
                                    mov a,d 
                                    aci 0 
                                    mov d,a 
                                    mov a,c 
                                    aci 0 
                                    mov c,a 
                                    mov b,a 
                                    aci 0 
                                    mov b,a 
                                    call fsm_seek_disk_sector
                                    xthl 
                                    dcr h 
                                    xthl 
                                    jnz fsm_write_fat_page_operation_loop
                                    lda fsm_selected_disk_loaded_page_flags
                                    ori %10000000
                                    sta fsm_selected_disk_loaded_page_flags
                                    mvi a,fsm_operation_ok
                                    inx sp 
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
                                        xchg 
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
fsm_read_data_page_operation_loop:      call bios_mass_memory_read_sector
                                        cpi bios_operation_ok
                                        jz fsm_read_data_page_operation_loop2
                                        inx sp 
                                        inx sp 
                                        jmp fsm_read_data_page_end
fsm_read_data_page_operation_loop2:     inr e 
                                        mov a,d 
                                        aci 0 
                                        mov d,a 
                                        mov a,c 
                                        aci 0 
                                        mov c,a 
                                        mov b,a 
                                        aci 0 
                                        mov b,a 
                                        call fsm_seek_disk_sector
                                        xthl 
                                        dcr h 
                                        xthl 
                                        jnz fsm_read_fat_page_operation_loop
                                        lda fsm_selected_disk_loaded_page_flags
                                        ori %11000000
                                        sta fsm_selected_disk_loaded_page_flags
                                        mvi a,fsm_operation_ok
                                        inx sp 
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
                                        xchg 
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
fsm_write_data_page_operation_loop:     call bios_mass_memory_write_sector
                                        cpi bios_operation_ok
                                        jz fsm_write_data_page_operation_loop2
                                        inx sp 
                                        inx sp 
                                        jmp fsm_write_data_page_end
fsm_write_data_page_operation_loop2:    inr e 
                                        mov a,d 
                                        aci 0 
                                        mov d,a 
                                        mov a,c 
                                        aci 0 
                                        mov c,a 
                                        mov b,a 
                                        aci 0 
                                        mov b,a 
                                        call fsm_seek_disk_sector
                                        xthl 
                                        dcr h 
                                        xthl 
                                        jnz fsm_write_fat_page_operation_loop
                                        mvi a,fsm_operation_ok
                                        inx sp 
                                        inx sp 
fsm_write_data_page_end:                pop h 
                                        pop d 
                                        pop b 
                                        ret 

;fsm_seek_mass_memory_sector posiziona la testina nel settore specificato
;BCDE -> posizione in settori
;A <- esito dell'operazione
fsm_seek_disk_sector:                       push b 
                                            push d 
                                            push h 
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
                                            call bios_mass_memory_select_sector
                                            cpi bios_operation_ok
                                            jnz fsm_seek_disk_sector_error
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
                                            call bios_mass_memory_select_track
                                            cpi bios_operation_ok
                                            jnz fsm_seek_disk_sector_error
                                            mov a,c 
                                            call bios_mass_memory_select_head
                                            cpi bios_operation_ok
                                            jnz fsm_seek_disk_sector_error
                                            mvi a,fsm_operation_ok
fsm_seek_disk_sector_error:                 pop h 
                                            pop d 
                                            pop b 
                                            ret 

