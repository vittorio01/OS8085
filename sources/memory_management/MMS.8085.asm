;La Memory Management Unit ha il compito di gestire il flusso di dati presente nella memoria RAM. 

;La gestione della RAM
;-----------------------------------------------------------
;- Riservato al sistema - low ram - CPS - FDS - mms - BIOS -
;-----------------------------------------------------------
;                                 ^                        ^
;                                 |        high ram        |

;La ram è organizzata in:
; - Riservato al sistema    -> Spazio dedicato al salvataggio delle informazioni di sistema e alla gestione degli interrupt
; - low ram                 -> Spazio dedicato al caricamento e all'esecuzione dei programmi
; - high ram                -> Spazio dedicato al mantenimento del sistema operativo

;* Riservato al sistema
;Il primo spazio di memoria viene dedicato alla gestione degli interrupt di sistema e al salvataggio delle informazioni importanti tra cui:
;- informazioni sulla memoria di massa (questa parte viene gestita dalla FSM)
;- informazioni riguardanti la gestione della RAM

;*high ram
;La high ram è lo spazio di memoria dedicato al caricamento del sistema operativo. Viene di conseguenza suddiviso secondo i vari livelli del sistema operativo 
;Il firmware base del computer deve, all'avvio, caricare i dati presenti nel disco di avvio il sistema operativo a partire dall'inizio della high memory

;*low ram
;La low ram è la parte di memoria dedicata al caricamento dei programmi e alla gestione dei dati da parte del sistema operativo. viene suddivisa in due sottosezioni di dimensione variabile

;-----------------------------------------
;- Program low ram - xxxx - Data low ram -
;-----------------------------------------

;Nei vecchi processori a 8bit non è possibile gestire la ram come una memoria segmentata, dato che non esistono indirizzi virtuali. Di conseguenza un programma deve essere compilato in modo da avere un offset degli indirizzi
;fisso. Tuttavia, il sistema, ed eventualmente i programmi, potrebbero aver bisogno di allocare uno spazio variabile in memoria dedicato al salvataggio dei dati. 
;Per soddisfare questo bisogno, mantenendo comunque la possibilità di eseguire i programmi in modo semplice, è necessario dividere la low ram in due sezioni:
;- la program low ram è uno spazio dedicato allèesecuzione dei programmi di dimensione variabile. L'inizio di questo spazio è fisso e corrisponde all'estremo sinistro della low ram, 
;  e di dimensione variabile, in modo da garantire flessibilità nella gestione della data low ram
;- La data low ram è uno spazio dedicato al mantenimento dei dati. Questa sottosezione è gestita come una memoria segmentata di dimensione variabile in cu viene definita la fine, che corrisponde all'estremo destro della low ram
;  In questa sezione è possibile quindi allocare un certo numero di blocchi di dati, che vengono impilati partendo dall'estremo alto in modo da permettere uno sviluppo verso il basso verso il basso.

;----------------------------------------------------------
;- Programma - xxxx - xxxx - bocco dati 1 - blocco dati 2 -
;----------------------------------------------------------
;^                                                        ^
;|                                                        |
;inizio della low ram                    fine della low ram 

;i programmi quindi vengono caricati ed eseguiti uno alla volta, mentre è possibile allocare e deallocare più blocchi di dati in memoria

;La mms quindi tiene conto di due posizioni:
;- la fine della program low ram
;- l'inizio della data low ram
;Quando viene caricato un programma, viene aggiornato il puntatore alla fine della program low ram e quando esso termina la sua esecuzione il puntatore viene settato all'inizio della low ram
;In modo analogo, quando viene allocato o deallocato un blocco dati viene aggiornato il puntatore della data low ram.
;La mms deve far in modo da non far coincidere i due puntatori in modo da non creare una sovrapposizione dei due spazi. 

;I segmenti di dati presenti nella low data ram sono dotati di un'intestazione e di un corpo. 
;----------------------------
;- segment name - dimension -
;----------------------------
; L'intestazione è formata da:
; - segment name            -> 8 bytes che contengono l'identificativo del segmento
; - dimension               -> 2 bytes che indicano la dimensione del corpo in bytes

;la mms permette di inserire, eliminare, cercare un segmento, ma non può eliminarlo

;Il corpo del segmento contiene semplicamante i dati che si vogliono memorizzare

;Uno schema completo della RAM è quindi:
;----------------------------------------------------------------------------------
;- Riservato al sistema - Program low ram - Data low ram - CPS - FDS - mms - BIOS -
;----------------------------------------------------------------------------------
;^                      ^                                ^                        ^   
;|                      |                                |                        |
;inizio della memoria   inizio low ram                   inizio high ram          fine della memoria


;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;                                Aggiornamento 2
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

;i cambiamenti eseguiti vengono elencati di seguito:
;- l'intestazione dei segmenti di dati viene modificata nel seguente modo:
;   * al posto del segment name è presente un numero identificativo di 8 bit
;   * viene aggiunto un byte con le informazioni del segmento
;-  A seconda dell'identificativo assegnato, il segmento può essere normale o di sistema.

;- Non è necessario includere un numero identificativo per la creazione del segmento dati. 
;  Di conseguenza, l'identificativo del segmento creato viene restituito dalla system call dopo essere stata eseguita.

;- Per agire su un segmento è necessario prima selezionarlo. Quando viene creato un segmento automaticamente viene selezionato e dopo l'eliminazione di un segmento è necessario selezionarne un altro.

;- Per modificare i dati di un segmento si devono utilizzare delle funzioni read e write messe a disposizione dalla mms, che prendono in input la posizione nel segmento e restituiscono/scrivono il byte desiderato. 
;  Le funzioni di lettura e scrittura e di creazione di un segmento utilizzano la flag CY per segnalare eventuali errori. Per ottenere informazioni sull'errore generato si deve utilizzare una funzione predisposta dalla mms

;- Per aumentare la velocità di alcune operazioni, esistono alcune funzioni dedicate appositamente:
;- copia di dati fra due segmenti

;L'intestazione prevede quindi:
;----------------------------------------------------------------
;- Tipologia di segmento - Identificativo - dimensione in bytes -
;----------------------------------------------------------------
;Dove:
;- Tipologia di segmento    -> 1 byte che include le seguenti flags:
;                              - bit 7  -> indica la presenza di un segmento valido
;                              - bit 6  -> indica la tipologia di segmento (1 di sistema o 0 utente)
;                              - bit 5  -> nel caso di un segmento utente indica se è permanente o temporaneo (un segmento di sistema deve essere per forza permanente)
;- Idetificativo            -> 1 byte che indica l'identificativo del segmento (può assumere un numero fra 1 e 255)
;- dimensione in bytes      -> 2 bytes che indicano la dimensione del segmento

;Per l'assegnazione dei segmenti viene inserita una tabella in bitstream di lunghezza complessiva di 32 bytes (256 bit) per tenere traccia dei numeri di segmenti assegnati.
;In particolare nel bitstream un bit segnato a 1 indica un numero assegnato (il numero viene identificato dalla posizione del bit nel bitstream)

;spazio della memoria riservata dedicato alla mms
mms_program_high_pointer                    .equ reserved_memory_start+$0050
mms_data_low_pointer                        .equ reserved_memory_start+$0052
mms_data_selected_segment_id                .equ reserved_memory_start+$0054
mms_data_selected_segment_address           .equ reserved_memory_start+$0055
mms_data_selected_segment_dimension         .equ reserved_memory_start+$0057
mms_data_segment_generated_error_code       .equ reserved_memory_start+$0059

;flags utilizzate nelle intestazioni dei segmenti e nella gestione della ram
mms_low_memory_valid_segment_mask:          .equ %10000000
mms_low_memory_type_segment_mask            .equ %01000000
mms_low_memory_temporary_segment_mask       .equ %00100000
mms_low_memory_bitstream_start              .equ low_memory_end - 32

;codici di esecuzione che possono essere sollevati durante l'esecuzione delle funzioni
mms_not_enough_ram_error_code               .equ $11
mms_segment_data_not_found_error_code       .equ $12
mms_segment_segmentation_fault_error_code   .equ $13
mms_segment_number_overflow_error_code      .equ $14
mms_segment_bad_argument                    .equ $15
mms_operation_ok                            .equ $ff

mms_functions:  .org MMS 
                jmp mms_low_memory_initialize
                jmp mms_free_low_ram_bytes
                jmp mms_load_low_memory_program 
                jmp mms_unload_low_memory_program 
                
            
                 
;Implementazioni delle system calls della mms

;La funzione mms_low_memory_initialize inizializza i puntatori della low ram in modo da rendere disponibile il caricamento dei dati

mms_low_memory_initialize:      push h
                                push psw 
                                lxi h,low_memory_start
                                shld mms_program_high_pointer
                                lxi h,mms_low_memory_bitstream_start 
                                shld mms_data_low_pointer 
                                xra a 
                                sta mms_data_selected_segment_id  
                                lxi h,0 
                                shld mms_data_selected_segment_address
                                mvi a,$ff 
                                sta mms_data_segment_generated_error_code
                                call mms_data_bitstream_reset
                                pop psw 
                                pop h 
                                ret 

;La funzione mms_free_low_ram_byte restiuisce il numero di bytes disponibili nella low ram
; HL <- numero di bytes della ram disponibili
mms_free_low_ram_bytes: push d
                        push psw 
                        lhld mms_data_low_pointer
                        xchg 
                        lhld mms_program_high_pointer
                        mov a,e 
                        sub l 
                        mov l,a 
                        mov e,d 
                        sbb h 
                        mov h,a
                        pop psw 
                        pop d 
                        ret 

;la funzione mms_load_low_memory_program riceve in ingresso il numero di bytes dedicati all'allocazione del programma desiderato e controlla se il puntatore dati non entra in collisione con la low data ram
; HL -> dimensione del blocco da allocare
; A  <- risultato dell'operazione
; HL <- posizione iniziale del blocco allocato

mms_load_low_memory_program:    push d  
                                lxi d,low_memory_start 
                                dad d 
                                xchg 
                                lhld mms_data_low_pointer
                                mov a,l  
                                sub e 
                                mov a,h 
                                sbb d 
                                jc mms_program_not_enough_ram
                                xchg
                                shld mms_program_high_pointer
                                mvi a,mms_operation_ok
                                lxi h,low_memory_start
                                pop d 
                                ret 
mms_program_not_enough_ram:     mvi a,mms_not_enough_ram_error_code
                                lxi h,0
                                pop d 
                                ret

;La funzione mms_unload_low_memory_program libera la zona della ram dedicata al programma caricato precedentemente
mms_unload_low_memory_program:  push h 
                                lxi h,low_memory_start
                                shld mms_program_high_pointer
                                pop h 
                                ret 

;la funzione mms_create_low_memory_user_data_segment crea un nuovo segmento. Prima della creazione viene verificato se lo spazio nella ram è disponibile
; A  -> flags del segmento
; HL -> dimensione del segmento da creare
; A  <- ID del segmento creato. Se non è stato creato correttamente assume $00
;       in caso di errore nella creazione, per ottenere informazioni sull'errore generato si deve lanciare la funzione mms_read_data_segment_operation_error_code

mms_create_low_memory_data_segment:                         push psw 
                                                            push d 
                                                            push h 
                                                            push h 
                                                            mov a,l 
                                                            ora h 
                                                            jz mms_create_low_memory_data_segment_bad_argument 
                                                            lxi d,4
                                                            dad d 
                                                            xchg 
                                                            lhld mms_data_low_pointer
                                                            mov a,l 
                                                            sub e 
                                                            mov l,a 
                                                            mov a,h 
                                                            sbb d 
                                                            mov h,a 
                                                            jc mms_create_low_memory_data_segment_not_enough_ram_error
                                                            xchg 
                                                            lhld mms_program_high_pointer
                                                            mov a,e 
                                                            sub l 
                                                            mov a,d 
                                                            sbb h 
                                                            xchg  
                                                            jc mms_create_low_memory_data_segment_not_enough_ram_error
                                                            shld mms_data_low_pointer
                                                            xthl 
                                                            mov a,h 
                                                            xthl 
                                                            mvi a,mms_low_memory_valid_segment_mask
                                                            ori mms_low_memory_valid_segment_mask
                                                            mov m,a 
                                                            inx h 
                                                            call mms_data_bitstream_number_request 
                                                            ora a 
                                                            jz mms_create_low_memory_data_segment_overflow_error
                                                            sta mms_data_selected_segment_id
                                                            mov m,a 
                                                            inx h 
                                                            xthl 
                                                            mov e,l 
                                                            mov d,h
                                                            xthl 
                                                            mov m,e 
                                                            inx h 
                                                            mov m,d 
                                                            inx h 
                                                            shld mms_data_selected_segment_address
                                                            xchg 
                                                            shld mms_data_selected_segment_dimension
                                                            xchg 
                                                            mvi a,mms_operation_ok
                                                            sta mms_data_segment_generated_error_code
                                                            lda mms_data_selected_segment_id
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_overflow_error:          mvi a,mms_segment_number_overflow_error_code 
                                                            sta mms_data_segment_generated_error_code
                                                            lxi h,0
                                                            shld mms_data_selected_segment_dimension
                                                            shld mms_data_selected_segment_address 
                                                            xra a 
                                                            sta mms_data_selected_segment_id
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_not_enough_ram_error:    mvi a,mms_not_enough_ram_error_code
                                                            sta mms_data_segment_generated_error_code
                                                            lxi h,0
                                                            shld mms_data_selected_segment_dimension
                                                            shld mms_data_selected_segment_address 
                                                            xra a 
                                                            sta mms_data_selected_segment_id
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_bad_argument:            mvi a,mms_segment_bad_argument
                                                            sta mms_data_segment_generated_error_code
                                                            lxi h,0
                                                            shld mms_data_selected_segment_dimension
                                                            shld mms_data_selected_segment_address 
                                                            xra a 
                                                            sta mms_data_selected_segment_id

mms_create_low_memory_data_segment_return:                  inx sp 
                                                            inx sp 
                                                            inx sp 
                                                            inx sp 
                                                            pop h 
                                                            pop d 
                                                            ret 

;la funzione mms_select_low_memory_data_segment permette di selezionare un segmento utente
;A -> segmento da selezionare
;A <- risultato dell'operazione

mms_select_low_memory_data_segment:         push h 
                                            push psw 
                                            call mms_search_data_segment
                                            ora a 
                                            jz mms_select_low_memory_data_segment_not_found
                                            pop psw 
                                            sta mms_data_selected_segment_id
                                            shld mms_data_selected_segment_address
                                            dcx h 
                                            mov a,m 
                                            sta mms_data_selected_segment_dimension+1
                                            dcx h 
                                            mov a,m 
                                            sta mms_data_selected_segment_dimension
                                            pop h 
                                            mvi a,mms_operation_ok
                                            sta mms_data_segment_generated_error_code
                                            ret 

mms_select_low_memory_data_segment_not_found:   inx sp 
                                                inx sp 
                                                pop h 
                                                mvi a,mms_segment_data_not_found_error_code
                                                sta mms_data_segment_generated_error_code
                                                ret 

;la funzione mms_delete_selected_low_memory_user_data_segment elimina il segmento precedentemente selezionato. La funzione procede allo scorrimento dei segmenti 
;verso la parte alta della RAM in modo da rimuovere frammenti di spazio vuoto

; A <- risultato dell'operazione

mms_delete_selected_low_memory_data_segment:            push h
                                                        push b 
                                                        push d 
                                                        lda mms_data_selected_segment_id
                                                        ora a 
                                                        jnz mms_delete_selected_low_memory_data_segment2
                                                        mvi a,mms_segment_data_not_found_error_code
                                                        sta mms_data_segment_generated_error_code
                                                        jmp mms_delete_data_segment_end
mms_delete_selected_low_memory_data_segment2:           call mms_data_bitstream_reset_requested_bit
                                                        lhld mms_data_selected_segment_address
                                                        dcx h 
                                                        mov d,m 
                                                        dcx h 
                                                        mov e,m 
                                                        mov c,l 
                                                        mov b,h 
                                                        dcx b 
                                                        dcx b 
                                                        inx h 
                                                        dad d           ;HL -> destinazione
                                                        mov e,c         ;BC -> sorgente
                                                        mov d,b 
                                                        lda mms_data_low_pointer
                                                        mov c,a 
                                                        lda mms_data_low_pointer+1 
                                                        mov b,a                
                                                        mov a,e  
                                                        sub c
                                                        mov c,a 
                                                        mov a,d 
                                                        sbb b
                                                        mov b,a 
                                                        jz mms_delete_data_segment_end2
                                                        dcx d
                                                        call bios_memory_transfer_reverse
                                                        cpi bios_operation_ok
                                                        jnz mms_delete_data_segment_end
                                                        inx h 
                                                        shld mms_data_low_pointer
                                                        xra a
                                                        sta mms_data_selected_segment_id
                                                        lxi h,0
                                                        shld mms_data_selected_segment_address
                                                        shld mms_data_selected_segment_dimension
mms_delete_data_segment_end2:                           mvi a,mms_operation_ok
                                                        sta mms_data_segment_generated_error_code
mms_delete_data_segment_end:                            pop d 
                                                        pop b 
                                                        pop h 
                                                        ret 



;mms_search_data_segment verifica l'esistenza del segmento specificato nella low ram

mms_search_data_segment:                    push b 
                                            push d 
                                            push psw 
                                            lxi b,mms_low_memory_bitstream_start
                                            lhld mms_data_low_pointer
                                            mov a,l  
                                            sub c
                                            mov a,h
                                            sbb b
                                            jnc mms_search_data_segment_not_found
mms_search_data_segment_loop:               inx h 
                                            mov a,m 
                                            xthl 
                                            cmp h 
                                            xthl 
                                            jz mms_search_data_segment_found 
mms_search_data_segment_loop_skip:          inx h 
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            inx h 
                                            dad d 
                                            mov a,l 
                                            sub c 
                                            mov a,h 
                                            sbb b 
                                            jc mms_search_data_segment_loop 
mms_search_data_segment_not_found:          xra a 
                                            lxi h,0
                                            jmp mms_search_data_segment_end

mms_search_data_segment_found:              inx h 
                                            inx h 
                                            inx h  
                                            mvi a,$ff 
mms_search_data_segment_end:                inx sp 
                                            inx sp 
                                            pop d 
                                            pop b 
                                            ret 

;mms_bistream_reset inizializza il bitstream system e lo prepara per l'associazione degli ID dei segmenti
mms_data_bitstream_reset:   push h 
                            push b
                            lxi h,mms_low_memory_bitstream_start
                            mvi m,%01111111
                            inx h 
                            mvi b,31 
mms_data_bitstream_loop:    mvi m,$ff
                            inx h 
                            dcr b 
                            jnz mms_data_bitstream_loop
                            pop b 
                            pop h 
                            ret 

;mms_data_bitstream_number_request vefifica se è disponibile un valore nel bitstream user e, in caso positivo, restituisce l'ID da associare al segmento

mms_data_bitstream_number_request:              push h 
                                                push b 
                                                lxi h,mms_low_memory_bitstream_start
                                                mvi b,0
                                                mov a,m 
mms_data_bitstream_number_request_search_bit:   add a 
                                                jc mms_data_bitstream_number_request_pos_found 
                                                dcr b 
                                                jz mms_data_bitstream_number_request_bit_not_found
                                                mov c,a 
                                                mov a,b 
                                                ani %00000111
                                                mov a,c
                                                jnz mms_data_bitstream_number_request_search_bit
                                                inx h 
                                                mov a,m
                                                jmp mms_data_bitstream_number_request_search_bit
mms_data_bitstream_number_request_pos_found:    dcr b 
                                                mov a,b 
                                                ani %00000111
                                                xri %00000111
                                                mov c,a 
                                                mvi a,%01111111
                                                jz mms_data_bitstream_number_request_pos_write                               
mms_data_bitstream_number_request_pos_shift:    rrc
                                                dcr c 
                                                jnz mms_data_bitstream_number_request_pos_shift
mms_data_bitstream_number_request_pos_write:    ana m 
                                                mov m,a 
                                                mov a,b 
                                                xri %11111111
                                                pop b 
                                                pop h 
                                                ret  

mms_data_bitstream_number_request_bit_not_found:    xra a 
                                                    pop b 
                                                    pop h 
                                                    ret 

;mms_data_bitstream_reset_requested_bit elimina il riferimento dell'ID selezionato nel bitstream user

mms_data_bitstream_reset_requested_bit:             ora a 
                                                    rz 
                                                    push h 
                                                    push b 
                                                    lxi h,mms_low_memory_bitstream_start
mms_data_bitstream_reset_requested_bit_search:      cpi 8 
                                                    jc mms_data_bitstream_reset_requested_bit_posfound
                                                    sui 8
                                                    inx h 
                                                    jmp mms_data_bitstream_reset_requested_bit_search
mms_data_bitstream_reset_requested_bit_posfound:    mov b,a 
                                                    ora a 
                                                    mvi a,%10000000
                                                    jz mms_data_bitstream_reset_requested_bit_shift_end
mms_data_bitstream_reset_requested_bit_shift:       rrc 
                                                    dcr b
                                                    jnz mms_data_bitstream_reset_requested_bit_shift
mms_data_bitstream_reset_requested_bit_shift_end:   ora m 
                                                    mov m,a 
                                                    pop b 
                                                    pop h 
                                                    ret 

