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
;               * bit 8 -> bit di valdità settato sempre per indicare che in quela posizione +è presente un intestazione
;               * bit 7 -> bit che indica se il file è di sistema o no
;               * bit 6 -> bit che identifica se il file è eseguibile o no
;               * bit 5 -> bit che indica se il file è nascosto 
;               
;-  nome        -> 20 bytes per memorizzare nome ed estenzione del file, separate da un punto (ad esempio file.exe) 
;-  data        -> 7 bytes che memorizzano la data di creazione del file (codificata in BCD a partire dall'anno)
;-  dimensione  -> 2 bytes per indicare il numero di blocchi occupati dal file
;-  dati        -> 2 bytes che mantengono l'indirizzo della prima pagina dei dati

;-------------------------------------------------------------------------------------------
;- tipo - nome ed estenzione - dimensione (in pagine) - puntatore alla prima pagina dati -
;-------------------------------------------------------------------------------------------

;L'intestazione di un file è quindi di dimensione fissa prestabilita (32 bytes)

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

;         ---------------
;  0001   ----  0040 ----
;         ***************
;  0030   ----  EOF  ----
;         ***************
;  0040   ---- 0030  ----
;         ---------------

;Fisicamente, la tabella viene memorizzata nelle prime pagine (in modo adiacente) del file system e le riche vengono inserite in modo sequenziale (una riga occupa due bytes)

;            0      1      2      3      4              <- parte meno significativa dell'indirizzo (considrando $0000 il primo byte nella pagina della tabella)
;  0000   | xxxx | xxxx | xxxx | xxxx | xxxx | ***
;  0010   | xxxx | xxxx | xxxx | xxxx | xxxx | ***
;  0010   | xxxx | xxxx | xxxx | xxxx | xxxx | ***

;Per salvare i dati è quindi necessario inserire l'intestazione, che contiene l'indirizzo della pagina di partenza, e modificare opportunamente la tabella di allocazione

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
;       * nome del disco                        (16 bytes)
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
fsm_selected_disk_loaded_page_flags     .equ $0075


fsm_coded_page_dimension            .equ 16
fsm_uncoded_page_dimension          .equ 2048

fsm_format_marker_lenght            .equ 6 
fms_disk_name_max_lenght            .equ 16 

fsm_page_loaded_mask            .equ %10000000
fsm_page_type_mask              .equ %01000000 ;(0 per tipo fat, 1 per tipo data)

fsm_mass_memory_sector_not_found    .equ $20
fsm_operation_ok                    .equ $ff

fsm_format_marker   .text "SFS1.0"
                    .b $00


fsm_functions:  .org FSM 
                jmp fsm_init 
                jmp fsm_disk_format 
                ;jmp fsm_disk_wipe 
                ;jmp fsm_disk_mount 

;fsm_init inizializza la fsm 

fsm_init:   xra a 
            sta fsm_selected_disk
            sta fsm_selected_disk_loaded_page
            sta fsm_selected_disk_loaded_page+1
            sta fsm_selected_disk_loaded_page_flags
            ret 

;fsm_disk_format formatta il disco e prepara il file system di base 
; A  -> disco da formattare 
; DE -> nome del disco (puntatore a una stringa)
; HL -> dimensione della sezione riservata al sistema (in bytes)
fsm_disk_format:        
                        push b 
                        push d 
                        push h 
                        push psw 
                        ;call bios_mass_memory_format_device
                        ;cpi bios_operation_ok 
                        pop psw 
                        ;jz fsm_disk_external_generated_error
                        sta fsm_selected_disk
                        call bios_mass_memory_select_drive
                        ora a 
                        jz fsm_disk_external_generated_error
                        sta fsm_selected_disk_bps_number
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
                        jnz fsm_disk_format_jump1
                        inx b 
fsm_disk_format_jump1:  inx b 
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
                        mvi b,fsm_coded_page_dimension 
                        mvi c,128 
                        call unsigned_multiply_byte
                        mov l,c 
                        mov h,b 
                        call mms_create_low_memory_system_data_segment
                        ora a 
                        jz fsm_disk_external_generated_error
                        sta fsm_page_buffer_segment_id 
                        call mms_read_selected_system_segment_data_address
                        shld fsm_page_buffer_segment_address
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
                        inx sp 
                        inx sp 
                        pop d 
                        push d 
                        dcx sp 
                        dcx sp 
                        mvi a,fms_disk_name_max_lenght
                        call string_ncopy
                        mvi a,fms_disk_name_max_lenght
                        add l 
                        mov l,a 
                        mov a,h 
                        aci 0 
                        mov h,a 
                        inx h
                        mvi m,0 
                        inx h 
                        lda fsm_selected_disk_head_number
                        mov m,a 
                        inx h 
                        lda fsm_selected_disk_tph_number
                        mov m,a 
                        inx h 
                        lda fsm_selected_disk_tph_number+1 
                        mov m,a 
                        inx h 
                        lda fsm_selected_disk_spt_number
                        mov m,a 
                        inx h 
                        lda fsm_selected_disk_spp_number
                        mov m,a 
                        inx h 
                        lxi d,0 
                        push d 
                        lxi d,fsm_uncoded_page_dimension 
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
                        lxi b,2
                        call unsigned_multiply_word 
                        push d 
                        push b 
                        call unsigned_divide_long
                        pop d 
                        pop b 
                        mov a,e 
                        ora d 
                        ora c 
                        ora b 
                        jz fsm_disk_format_jump2 
                        mvi a,1
fsm_disk_format_jump2:  pop d 
                        pop b 
                        mov a,e 
                        add a 
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
                        inx h 
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

                        mvi a,fsm_operation_ok 
                        pop h 
                        pop d 
                        pop b 
                        ret 

fsm_disk_external_generated_error:      pop h 
                                        pop d 
                                        pop b 
                                        ret 



fsm_clear_mms_segment:      push h 
                            push d 
                            lhld fsm_page_buffer_segment_address
                            lxi d,fsm_uncoded_page_dimension
fsm_clear_mms_segment_loop: mvi m,0 
                            inx h 
                            dcx d 
                            mov a,d 
                            ora e 
                            jnz fsm_clear_mms_segment_loop
                            pop d 
                            pop h 
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
                                            lda fsm_selected_disk_sectors_number+2
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

