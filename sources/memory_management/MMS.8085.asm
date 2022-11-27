;La Memory Management Unit ha il compito di gestire il flusso di dati presente nella memoria RAM. 

;La gestione della RAM
;-----------------------------------------------------------
;- Riservato al sistema - low ram - MSI - FDS - mms - BIOS -
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
;- Riservato al sistema - Program low ram - Data low ram - MSI - FDS - mms - BIOS -
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


;- vengono inserite delle funzioni per la manipolazione dei programmi nella memoria e per la gestione della memoria di massa. In particolare:
;   *   vengono inserite due funzioni per copiare i dati da un segmento nella zona riservata ai programmi e viceversa
;   *   vengono inserite due funzioni per gestire la copia di un settore in un segmento e viceversa

;- viene inserita una funzione per eliminare tutti i segmenti temporanei nella memoria

;- viene inserita una funzione per l'esecuzione del programma caricato precedentemente

;L'intestazione prevede quindi:
;----------------------------------------------------------------
;- Tipologia di segmento - Identificativo - dimensione in bytes -
;----------------------------------------------------------------
;Dove:
;- Tipologia di segmento    -> 1 byte che include le seguenti flags:
;                              - bit 7  -> indica la presenza di un segmento valido
;                              - bit 6  -> indica la tipologia di segmento (1 di sistema o 0 utente)
;                              - bit 5  -> nel caso di un segmento utente indica se è permanente o temporaneo (un segmento di sistema deve essere per forza permanente)
;                              i bit rimanenti possono essere utilizzati per evidenziare caratteristiche minori che non si distinguono dal punto di vista della mms
;- Identificativo           -> 1 byte che indica l'identificativo del segmento (può assumere un numero fra 1 e 255)
;- dimensione in bytes      -> 2 bytes che indicano la dimensione del segmento

;Per l'assegnazione dei segmenti viene inserita una tabella in bitstream di lunghezza complessiva di 32 bytes (256 bit) per tenere traccia dei numeri di segmenti assegnati.
;In particolare nel bitstream un bit segnato a 1 indica un numero assegnato (il numero viene identificato dalla posizione del bit nel bitstream)

.include "os_constraints.8085.asm"
.include "bios_system_calls.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "environment_variables.8085.asm"

mms_low_memory_valid_segment_mask           .equ %10000000
mms_low_memory_type_segment_mask            .equ %01000000
mms_low_memory_temporary_segment_mask       .equ %00100000

;spazio della memoria riservata dedicato alla mms
mms_program_high_pointer                    .equ reserved_memory_start+$0020
mms_data_low_pointer                        .equ reserved_memory_start+$0022
mms_data_selected_segment_id                .equ reserved_memory_start+$0024
mms_data_selected_segment_address           .equ reserved_memory_start+$0025
mms_data_selected_segment_dimension         .equ reserved_memory_start+$0027


mms_low_memory_bitstream_start              .equ low_memory_end - 32

mms_functions:  .org MMS 
                jmp mms_low_memory_initialize
                jmp mms_free_low_ram_bytes
                jmp mms_load_low_memory_program 
                jmp mms_get_low_memory_program_dimension
                jmp mms_unload_low_memory_program 
                jmp mms_start_low_memory_loaded_program 
                jmp mms_create_low_memory_data_segment
                jmp mms_select_low_memory_data_segment
                jmp mms_delete_selected_low_memory_data_segment
                jmp mms_read_selected_data_segment_byte
                jmp mms_write_selected_data_segment_byte
                jmp mms_segment_data_transfer
                jmp mms_set_selected_data_segment_flags
                jmp mms_get_selected_data_segment_dimension
                jmp mms_get_selected_data_segment_flags
                jmp mms_delete_all_temporary_segments
                jmp mms_program_bytes_write 
                jmp mms_program_bytes_read 
                jmp mms_disk_device_read_sector
                jmp mms_disk_device_write_sector
                jmp mms_get_selected_segment_ID  
                jmp mms_dselect_low_memory_data_segment 


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

;mms_get_low_mmory_program_dimension restituisce la dimensione della zona programma allocata
; HL <- dimensione dedicata all'allocazione del programma (0000 se la zona non è stata allocata)

mms_get_low_memory_program_dimension:       push d 
                                            lhld mms_program_high_pointer
                                            lxi d,low_memory_start
                                            mov a,l 
                                            sub e 
                                            mov l,a 
                                            mov a,h 
                                            sbb d 
                                            mov h,a 
mms_get_low_memory_program_dimension_end:   pop d    
                                            ret 
;mms_program_bytes_write esegue la copia dei dati da un segmento in memoria selezionato alla sezione programma 
;BC -> numero di bytes 
;DE -> offset di dati nel segmento
;HL -> offset dei dati nella zona del programma

;A <- esito dell'operazione 
;BC <- numero di bytes non copiati 
;DE <- offset nel segmento dati (dopo l'esecuzione)
;HL <- offset nella zona del programma (dopo l'esecuzione)
mms_program_bytes_write:        mvi a,$ff
                                push psw 
                                push b
                                push h 
                                push d 
                                lda mms_data_selected_segment_id
                                ora a 
                                jnz mms_program_bytes_write_next
                                mvi a,mms_source_segment_not_selected
                                jmp mms_program_bytes_write_end
mms_program_bytes_write_next:   dad b 
                                xchg 
                                call mms_get_low_memory_program_dimension
                                mov a,e 
                                sub l 
                                mov e,a 
                                mov a,d 
                                sbb h 
                                mov d,a 
                                jc mms_program_bytes_write_next2
                                mov a,e 
                                ora d 
                                jz mms_program_bytes_write_next2
                                mov a,c 
                                sub e 
                                mov c,a 
                                mov a,b 
                                sbb d 
                                mov b,a 
                                push h 
                                lxi h,8 
                                dad sp 
                                sphl 
                                xthl 
                                mvi h,mms_destination_segment_overflow
                                xthl 
                                lxi h,$ffff-8+1 
                                dad sp 
                                sphl 
                                pop h 
mms_program_bytes_write_next2:  pop d 
                                push d 
                                lhld mms_data_selected_segment_dimension
                                xchg 
                                dad b 
                                mov a,l 
                                sub e 
                                mov e,a 
                                mov a,h 
                                sbb d 
                                mov d,a 
                                jc mms_program_bytes_write_next3
                                mov a,e 
                                ora d 
                                jz mms_program_bytes_write_next3
                                mov a,c 
                                sub e 
                                mov c,a 
                                mov a,b 
                                sbb d 
                                mov b,a 
                                push h 
                                lxi h,8 
                                dad sp 
                                sphl 
                                xthl 
                                mvi h,mms_source_segment_overflow
                                xthl 
                                lxi h,$ffff-8+1 
                                dad sp 
                                sphl 
                                pop h 
mms_program_bytes_write_next3:  pop d 
                                pop h 
                                push h 
                                push d 
                                push b 
                                lxi b,low_memory_start 
                                dad b
                                xchg 
                                mov c,l 
                                mov b,h
                                lhld mms_data_selected_segment_address
                                dad b 
                                xchg 
                                pop b 
                                push b 
                                call bios_memory_transfer
                                cpi bios_operation_ok
                                jnz mms_program_bytes_write_end
                                mov c,l 
                                mov b,h 
                                lhld mms_data_selected_segment_address
                                mov a,e 
                                sub l 
                                mov e,a 
                                mov a,d 
                                sbb h 
                                mov d,a 
                                lxi h,low_memory_start
                                mov a,c 
                                sub l 
                                mov l,a 
                                mov a,b 
                                sbb h 
                                mov h,a 
                                pop b 
                                inx sp 
                                inx sp 
                                inx sp 
                                inx sp 
                                xthl 
                                mov a,l 
                                sub c 
                                mov c,a 
                                mov a,h 
                                sbb b 
                                mov b,a 
                                xthl 
                                inx sp 
                                inx sp 
                                pop psw 
                                ret 
mms_program_bytes_write_end:    pop d
                                pop h
                                pop b
                                inx sp 
                                inx sp 
                                ret 

;mms_program_bytes_read esegue la copia dei dati dalla sezione programma a un segmento dati in memoria selezionato
;BC -> bytes da copiare
;DE -> offset di dati nella zona del programma
;HL -> offset dei dati nel segmento di destinazione

;A <- esito dell'operazione 
;BC <- numero di bytes non copiati 
;DE <- offset di dati nella zona del programma (dopo l'esecuzione)
;HL <- offset dei dati nel segmento di destinazione (dopo l'esecuzione)

mms_program_bytes_read:         mvi a,$ff
                                push psw 
                                push b
                                push h 
                                push d 
                                lda mms_data_selected_segment_id
                                ora a 
                                jnz mms_program_bytes_read_next
                                mvi a,mms_source_segment_not_selected
                                jmp mms_program_bytes_read_end
mms_program_bytes_read_next:    dad b 
                                xchg 
                                call mms_get_low_memory_program_dimension
                                mov a,e 
                                sub l 
                                mov e,a 
                                mov a,d 
                                sbb h 
                                mov d,a 
                                jc mms_program_bytes_read_next2
                                mov a,e 
                                ora d 
                                jz mms_program_bytes_read_next2
                                mov a,c 
                                sub e 
                                mov c,a 
                                mov a,b 
                                sbb d 
                                mov b,a 
                                push h 
                                lxi h,8 
                                dad sp 
                                sphl 
                                xthl 
                                mvi h,mms_destination_segment_overflow
                                xthl 
                                lxi h,$ffff-8+1 
                                dad sp 
                                sphl 
                                pop h 
mms_program_bytes_read_next2:   pop d 
                                push d 
                                lhld mms_data_selected_segment_dimension
                                xchg 
                                dad b 
                                mov a,l 
                                sub e 
                                mov e,a 
                                mov a,h 
                                sbb d 
                                mov d,a 
                                jc mms_program_bytes_read_next3
                                mov a,e 
                                ora d 
                                jz mms_program_bytes_read_next3
                                mov a,c 
                                sub e 
                                mov c,a 
                                mov a,b 
                                sbb d 
                                mov b,a 
                                push h 
                                lxi h,8 
                                dad sp 
                                sphl 
                                xthl 
                                mvi h,mms_source_segment_overflow
                                xthl 
                                lxi h,$ffff-8+1 
                                dad sp 
                                sphl 
                                pop h 
mms_program_bytes_read_next3:   pop d 
                                pop h 
                                push h
                                push d 
                                push b 
                                lxi b,low_memory_start 
                                xchg 
                                dad b
                                mov c,e
                                mov b,d
                                xchg 
                                lhld mms_data_selected_segment_address
                        
                                dad b 
                                pop b 
                                push b 
                                call bios_memory_transfer
                                cpi bios_operation_ok
                                jnz mms_program_bytes_read_end
                                mov c,l 
                                mov b,h 
                                lxi h,low_memory_start
                                mov a,e 
                                sub l 
                                mov e,a 
                                mov a,d 
                                sbb h 
                                mov d,a 
                                lhld mms_data_selected_segment_address
                                mov a,c 
                                sub l 
                                mov l,a 
                                mov a,b 
                                sbb h 
                                mov h,a 
                                pop b 
                                inx sp 
                                inx sp 
                                inx sp 
                                inx sp 
                                xthl 
                                mov a,l 
                                sub c 
                                mov c,a 
                                mov a,h 
                                sbb b 
                                mov b,a 
                                xthl 
                                inx sp 
                                inx sp 
                                pop psw 
                                ret 
mms_program_bytes_read_end:     pop d
                                pop h
                                pop b
                                inx sp 
                                inx sp 
                                ret 

;mms_start_low_memory_loaded_program esegue il programma caricato precedentemente in memoria 
;all'avvio del programma lo stack pointer viene posizionato automaticamente alla fine della program_low_memory 
; A <- errore di esecuzione (nel caso in cui il programma non sia partito)

mms_start_low_memory_loaded_program:        push h 
                                            push d 
                                            push psw 
                                            lhld mms_program_high_pointer
                                            lxi d,low_memory_start
                                            mov a,e 
                                            sub l 
                                            mov a,d 
                                            sbb h 
                                            jnc mms_start_low_memory_loaded_program_end
                                            pop psw 
                                            lhld mms_program_high_pointer
                                            sphl 
                                            lxi h,0 
                                            lxi d,0 
                                            lxi b,0 
                                            jmp low_memory_start
mms_start_low_memory_loaded_program_end:    mvi a,mms_program_not_loaded 
                                            inx sp 
                                            inx sp 
                                            pop d 
                                            pop h 
                                            ret     

;la funzione mms_create_low_memory_user_data_segment crea un nuovo segmento. Prima della creazione viene verificato se lo spazio nella ram è disponibile
; A  -> flags del segmento
; HL -> dimensione del segmento da creare
; A  <- ID del segmento creato. Se non è stato creato correttamente assume $00
;       in caso di errore nella creazione, per ottenere informazioni sull'errore generato si deve lanciare la funzione mms_read_data_segment_operation_error_code

mms_create_low_memory_data_segment:                         push d 
                                                            push h 
                                                            push psw 
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
                                                            inx sp  
                                                            inx sp 
                                                            xthl 
                                                            mov a,h 
                                                            xthl 
                                                            dcx sp 
                                                            dcx sp 
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
                                                            lda mms_data_selected_segment_id
                                                            stc 
                                                            cmc 
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_overflow_error:          mvi a,mms_segment_number_overflow_error_code
                                                            stc 
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_not_enough_ram_error:    mvi a,mms_not_enough_ram_error_code
                                                            stc 
                                                            jmp mms_create_low_memory_data_segment_return

mms_create_low_memory_data_segment_bad_argument:            mvi a,mms_segment_bad_argument
                                                            stc 
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
                                            ret 

mms_select_low_memory_data_segment_not_found:   inx sp 
                                                inx sp 
                                                pop h 
                                                mvi a,mms_segment_data_not_found_error_code
                                               
                                                ret 

;mms_dselect_low_memory_data_segment deseleziona il segmento corrente (se è stato selezionato)
;A <- $00
mms_dselect_low_memory_data_segment:    xra a 
                                        sta mms_data_selected_segment_dimension
                                        sta mms_data_selected_segment_dimension+1 
                                        sta mms_data_selected_segment_id
                                        sta mms_data_selected_segment_address
                                        sta mms_data_selected_segment_address+1 

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
                                                       
                                                        jmp mms_delete_data_segment_end
mms_delete_selected_low_memory_data_segment2:           call mms_data_bitstream_reset_requested_bit
                                                        lhld mms_data_selected_segment_address
                                                        xchg 
                                                        lhld mms_data_low_pointer
                                                        mov c,l 
                                                        mov b,h 
                                                        xchg 
                                                        dcx h 
                                                        mov d,m 
                                                        dcx h 
                                                        mov e,m 
                                                        dcx h 
                                                        dcx h 
                                                        push b 
                                                        mov a,l  
                                                        sub c
                                                        mov c,a 
                                                        mov a,h 
                                                        sbb b
                                                        ora c 
                                                        pop b 
                                                        jnz mms_delete_selected_low_memory_data_segment3
                                                        inx h 
                                                        inx h 
                                                        inx h 
                                                        inx h 
                                                        dad d 
                                                        shld mms_data_low_pointer
                                                        jmp mms_delete_data_segment_end2
mms_delete_selected_low_memory_data_segment3:           mov c,l 
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
                                                        ora c 
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

;la funzione mms_read_selected_data_segment_byte permette di leggere il byte memorizzato nel segmento selezionato precedentemente.
;HL  -> posizione del byte nel segmento (offset)
;A   <- byte letto (assume $00 se si è verificato un errore nella lettura)
;PSW <- risultato dell'operazione (se è andata a buon fine il carry assume 0, altrimenti 1)
;per ricevere informazioni in caso di errore si deve chiamare la funzione mms_read_data_segment_operation_error_code

mms_read_selected_data_segment_byte:                    
                                                        push h 
                                                        inx h 
                                                        lda mms_data_selected_segment_dimension
                                                        sub l 
                                                        lda mms_data_selected_segment_dimension+1 
                                                        sbb h 
                                                        dcx h 
                                                        jnc mms_read_selected_data_segment_byte_next 
mms_read_selected_data_segment_byte_error:              lda mms_data_selected_segment_dimension
                                                        mov l,a 
                                                        lda mms_data_selected_segment_dimension+1
                                                        ora l 
                                                        jnz mms_read_selected_data_segment_byte_segmentation_fault
                                                        mvi a,mms_segment_data_not_found_error_code
                                                        stc 
                                                        jmp mms_read_selected_data_segment_byte_end
mms_read_selected_data_segment_byte_segmentation_fault: mvi a,mms_segment_segmentation_fault_error_code
                                                        stc 
                                                        jmp mms_read_selected_data_segment_byte_end
mms_read_selected_data_segment_byte_next:               lda mms_data_selected_segment_address
                                                        add l 
                                                        mov l,a 
                                                        lda mms_data_selected_segment_address+1 
                                                        adc h 
                                                        mov h,a 
                                                        mov a,m 
                                                        stc
                                                        cmc 
mms_read_selected_data_segment_byte_end:                pop h
                                                        ret  


;la funzione mms_write_selected_data_segment_byte permette di scrivere il byte memorizzato nel segmento selezionato precedentemente.
;HL  -> posizione del byte nel segmento (offset)
;A   -> byte da scrivere
;PSW <- risultato dell'operazione (se è andata a buon fine il carry assume 0, altrimenti 1)
;per ricevere informazioni in caso di errore si deve chiamare la funzione mms_write_data_segment_operation_error_code

mms_write_selected_data_segment_byte:                       push h 
                                                            push psw 
                                                            inx h 
                                                            lda mms_data_selected_segment_dimension
                                                            sub l 
                                                            lda mms_data_selected_segment_dimension+1 
                                                            sbb h 
                                                            dcx h
                                                            jnc mms_write_selected_data_segment_byte_next 
mms_write_selected_data_segment_byte_error:                 lda mms_data_selected_segment_dimension
                                                            mov l,a 
                                                            lda mms_data_selected_segment_dimension+1
                                                            ora l 
                                                            jnz mms_write_selected_data_segment_byte_segmentation_fault
                                                            mvi a,mms_segment_data_not_found_error_code
                                                            inx sp 
                                                            inx sp 
                                                            stc 
                                                            jmp mms_write_selected_data_segment_byte_end
mms_write_selected_data_segment_byte_segmentation_fault:    mvi a,mms_segment_segmentation_fault_error_code
                                                            inx sp 
                                                            inx sp 
                                                            stc 
                                                            jmp mms_write_selected_data_segment_byte_end
mms_write_selected_data_segment_byte_next:                  lda mms_data_selected_segment_address
                                                            add l 
                                                            mov l,a 
                                                            lda mms_data_selected_segment_address+1 
                                                            adc h 
                                                            mov h,a 
                                                            pop psw 
                                                            mov m,a 
                                                            stc
                                                            cmc 
mms_write_selected_data_segment_byte_end:                   pop h
                                                            ret  

;mms_read_selected_system_segment_dimension restituisce la dimensione del segmento selezionato
;A  <- risultato dell'operazione
;HL <- dimensione del segmento (se esiste)
mms_read_selected_data_segment_dimension:       lhld mms_data_selected_segment_dimension
                                                mov a,l 
                                                ora h 
                                                jnz mms_read_selected_data_segment_dimension_next
                                                mvi a,mms_segment_data_not_found_error_code
                                                ret 
mms_read_selected_data_segment_dimension_next:  mvi a,mms_operation_ok
                                                ret 

;mms_set_selected_data_segment_flags imposta le flags del segmento selezionato
; A -> flags 
; A <- esito dell'operazione 

mms_set_selected_data_segment_flags:            push h
                                                push psw 
                                                lda mms_data_selected_segment_id
                                                ora a 
                                                jnz mms_set_selected_data_segment_flags_next 
                                                mvi a,mms_segment_data_not_found_error_code  
                                               
                                                jmp mms_set_selected_data_segment_flags_end
mms_set_selected_data_segment_flags_next:       lhld mms_data_selected_segment_address
                                                dcx h 
                                                dcx h 
                                                dcx h 
                                                xthl 
                                                mov a,h 
                                                xthl 
                                                ori mms_low_memory_valid_segment_mask
                                                mov m,a 
                                                mvi a,mms_operation_ok
mms_set_selected_data_segment_flags_end:        inx sp 
                                                inx sp 
                                                pop h
                                                ret 

;mms_get_selected_data_segment_flags legge le flags del segmento selezionato
;A <- flags (se si verifica un errore ritorna il codice di esecuzione)
;PSW <- se il segmento non è stato selezionato viene generato un errore (CY=1)
mms_get_selected_data_segment_flags:            push h
                                                lda mms_data_selected_segment_id
                                                ora a 
                                                jnz mms_get_selected_data_segment_flags_next 
                                                mvi a,mms_segment_data_not_found_error_code  
                                                stc 
                                                jmp mms_get_selected_data_segment_flags_end
mms_get_selected_data_segment_flags_next:       lhld mms_data_selected_segment_address
                                                dcx h 
                                                dcx h 
                                                dcx h 
                                                dcx h 
                                                mov a,m 
                                                stc 
                                                cmc 
mms_get_selected_data_segment_flags_end:        pop h
                                                ret 


;mms_get_selected_data_segment_dimension restituisce la dimensione del segmento selezionato 
;HL <- dimensione del segmento (0 se si è verificato un errore)

mms_get_selected_data_segment_dimension:        lda mms_data_selected_segment_id
                                                ora a 
                                                jz mms_get_selected_data_segment_dimension_end
                                                lhld mms_data_selected_segment_dimension
                                                ret 
mms_get_selected_data_segment_dimension_end:    lxi h,0 
                                                ret 

;mms_get_selected_segment_ID restituisce l'id del segmento attualmente selezionato 
;A <- id del segmento (0 se non è stato selezionato un segmento)
mms_get_selected_segment_ID:        lda mms_data_selected_segment_id
                                    ret 

;mms_segment_data_transfer copia i dati da un segmento ad un altro (il segmento sorgente è quello selezionato precedentemente). In caso di overflow di sorgente o destinazione vengono copiati solo i dati che non 
;escono fuori dai segmenti
;A -> segmento di destinazione 
;BC -> numero di bytes 
;DE -> indirizzo di partenza (offset rispetto all'indirizzo del segmento)
;HL -> indirizzo di destinazione (offset rispetto all'indirizzo del segmento)

;A <- esito dell'operazione
;BC -> numero di bytes che non sono stati copiati
;DE -> indirizzo di partenza dopo l'operazione (offset rispetto all'indirizzo del segmento)
;HL -> indirizzo di destinazione dopo l'esecuzione (offset rispetto all'indirizzo del segmento)

mms_segment_data_transfer:          push psw 
                                    xthl 
                                    mvi l,$ff 
                                    xthl 
                                    push b
                                    push d 
                                    push h 
                                    call mms_search_data_segment
                                    ora a 
                                    jnz mms_segment_data_transfer_next 
                                    mvi a,mms_destination_segment_not_found 
                                    jmp mms_segment_data_transfer_end
mms_segment_data_transfer_next:     lda mms_data_selected_segment_id
                                    ora a 
                                    jnz mms_segment_data_transfer_next2
                                    mvi a,mms_source_segment_not_selected
                                    jmp mms_segment_data_transfer_end
mms_segment_data_transfer_next2:    push h                                      ;SP -> [indirizzo destinazione][offset destinazione][offset sorgente][numero bytes][id segmento | esito operazione]
                                    dcx h 
                                    mov d,m 
                                    dcx h 
                                    mov e,m 
                                    inx sp 
                                    inx sp 
                                    xthl 
                                    mov a,l 
                                    add c 
                                    xthl 
                                    mov l,a 
                                    xthl 
                                    mov a,h 
                                    adc b 
                                    xthl 
                                    mov h,a 
                                    dcx sp 
                                    dcx sp 
                                    mov a,l 
                                    sub e 
                                    mov e,a 
                                    mov a,h 
                                    sbb d 
                                    mov d,a 
                                    jc mms_segment_data_transfer_next3 
                                    mov a,e 
                                    ora d 
                                    jz mms_segment_data_transfer_next3
                                    mov a,c 
                                    sub e 
                                    mov c,a 
                                    mov a,b 
                                    sbb d 
                                    mov b,a 
                                    push h
                                    lxi h,10 
                                    dad sp 
                                    sphl
                                    xthl 
                                    mvi l,mms_destination_segment_overflow 
                                    xthl
                                    lxi h,$ffff-10+1 
                                    dad sp 
                                    sphl 
                                    pop h 
mms_segment_data_transfer_next3:    pop d                                       ;SP -> [offset destinazione][offset sorgente][numero bytes][id segmento]
                                    xthl 
                                    mov a,e 
                                    add l 
                                    mov e,a 
                                    mov a,d 
                                    adc h 
                                    mov d,a 
                                    xthl 
                                    push d                                      ;SP -> [indirizzo destinazione][offset destinazione][offset sorgente][numero bytes][id segmento]
                                    lxi h,4 
                                    dad sp 
                                    sphl 
                                    xthl 
                                    mov a,l 
                                    add c 
                                    mov e,a 
                                    mov a,h
                                    adc b
                                    mov d,a 
                                    xthl 
                                    lxi h,$ffff-3
                                    dad sp 
                                    sphl 
                                    lhld mms_data_selected_segment_dimension
                                    mov a,e 
                                    sub l 
                                    mov l,a 
                                    mov a,d 
                                    sbb h
                                    mov h,a 
                                    jc mms_segment_data_transfer_next4
                                    mov a,l 
                                    ora h 
                                    jz mms_segment_data_transfer_next4
                                    mov a,c 
                                    sub l 
                                    mov c,a 
                                    mov a,b  
                                    sbb h 
                                    mov b,a 
                                    push h
                                    lxi h,10
                                    dad sp 
                                    sphl
                                    xthl 
                                    mvi l,mms_source_segment_overflow 
                                    xthl
                                    lxi h,$ffff-10+1 
                                    dad sp 
                                    sphl 
                                    pop h 
mms_segment_data_transfer_next4:    lhld mms_data_selected_segment_address
                                    xchg 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    xthl 
                                    mov a,e 
                                    add l 
                                    mov e,a 
                                    mov a,d 
                                    adc h 
                                    mov d,a 
                                    xthl 
                                    dcx sp 
                                    dcx sp 
                                    dcx sp 
                                    dcx sp 
                                    pop h                                   ;SP -> [offset destinazione][offset sorgente][numero bytes][id segmento]
                                    push b 
                                    call bios_memory_transfer 
                                    pop b 
                                    cpi bios_operation_ok
                                    jnz mms_segment_data_transfer_end
                                    push h                                  ;SP -> [indirizzo destinazione finale][offset destinazione][offset sorgente][numero bytes][id segmento]
                                    lhld mms_data_selected_segment_address
                                    mov a,e 
                                    sub l 
                                    mov e,a 
                                    mov a,d 
                                    sbb h 
                                    mov d,a 
                                    lxi h,8 
                                    dad sp 
                                    sphl 
                                    xthl 
                                    mov a,h 
                                    xthl 
                                    lxi h,$ffff-7
                                    dad sp 
                                    sphl 
                                    call mms_search_data_segment
                                    xthl 
                                    mov a,l 
                                    xthl 
                                    sub l 
                                    mov l,a 
                                    xthl 
                                    mov a,h 
                                    xthl 
                                    sbb h 
                                    mov h,a 
                                    inx sp 
                                    inx sp                                  ;SP -> [offset destinazione][offset sorgente][numero bytes][id segmento]
                                    inx sp 
                                    inx sp 
                                    inx sp 
                                    inx sp 

                                    xthl 
                                    mov a,l 
                                    sub c 
                                    mov c,a 
                                    mov a,h 
                                    sbb b 
                                    mov b,a 
                                    xthl 
                                    inx sp
                                    inx sp 
                                    xthl 
                                    mov a,l 
                                    xthl 
                                    inx sp 
                                    inx sp 
                                    ret  
mms_segment_data_transfer_end:      pop h
                                    pop d 
                                    pop b 
                                    inx sp 
                                    inx sp 
                                    ret               

;mms_delete_all_temporary_segments elimina tutti i segmenti temporanei non di sistema presenti in RAM 

mms_delete_all_temporary_segments:          push h 
                                            push d 
mms_delete_all_temporary_segments_loop:     lhld mms_data_low_pointer
                                            lxi d,mms_low_memory_bitstream_start
                                            mov a,l 
                                            sub e 
                                            mov a,h 
                                            sbb d 
                                            jnc mms_delete_all_temporary_segments_end
mms_delete_all_temporary_segments_loop2:    mov a,m 
                                            ani mms_low_memory_type_segment_mask
                                            jnz mms_delete_all_temporary_segments_loop4
                                            mov a,m 
                                            ani mms_low_memory_temporary_segment_mask
                                            jz mms_delete_all_temporary_segments_loop4
mms_delete_all_temporary_segments_loop3:    inx h 
                                            mov a,m 
                                            sta mms_data_selected_segment_id
                                            inx h 
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            inx h 
                                            shld mms_data_selected_segment_address
                                            xchg 
                                            shld mms_data_selected_segment_dimension   
                                            call mms_delete_selected_low_memory_data_segment
                                            cpi mms_operation_ok
                                            jz mms_delete_all_temporary_segments_loop 
                                            jmp mms_delete_all_temporary_segments_end2
mms_delete_all_temporary_segments_loop4:    inx h 
                                            inx h 
                                            mov e,m 
                                            inx h 
                                            mov d,m 
                                            inx h 
                                            dad d 
                                            lxi d,mms_low_memory_bitstream_start
                                            mov a,l 
                                            sub e 
                                            mov a,h 
                                            sbb d 
                                            jnc mms_delete_all_temporary_segments_end
                                            jmp mms_delete_all_temporary_segments_loop2
mms_delete_all_temporary_segments_end:      xra a  
                                            sta mms_data_selected_segment_id    
                                            lxi h,0 
                                            shld mms_data_selected_segment_address
                                            shld mms_data_selected_segment_dimension
mms_delete_all_temporary_segments_end2:     pop d 
                                            pop h 
                                            ret 

;mms_disk_device_read_sector preleva un settore dalla memoria di massa e salva i dati nel segmento selezionato
;HL -> offset nel segmento dati

;A <- esito dell'operazione
;HL -> offset nel segmento dati (dopo l'esecuzione)

mms_disk_device_read_sector:        push d
                                    push b 
                                    push h 
                                    lda mms_data_selected_segment_id
                                    ora a 
                                    jnz mms_disk_device_read_sector_next 
                                    mvi a,mms_destination_segment_not_selected
                                    pop h
                                    jmp mms_disk_device_read_sector_end 
mms_disk_device_read_sector_next:   call bios_disk_device_get_bps
                                    jnc mms_disk_device_read_sector_next2
                                    mvi a,mms_disk_device_not_selected 
                                    pop h
                                    jmp mms_disk_device_read_sector_end 
mms_disk_device_read_sector_next2:  mvi b,7 
                                    mvi d,0 
                                    mov e,a 
mms_disk_device_read_sector_loop:   mov a,e 
                                    add a   
                                    mov e,a 
                                    mov a,d 
                                    ral
                                    mov d,a 
                                    dcr b 
                                    jnz mms_disk_device_read_sector_loop
                                    mov c,l 
                                    mov b,h 
                                    dad d 
                                    xchg 
                                    lhld mms_data_selected_segment_dimension
                                    mov a,l 
                                    sub e 
                                    mov a,h
                                    sbb d
                                    jnc mms_disk_device_read_sector_next3 
                                    mvi a,mms_destination_segment_overflow
                                    pop h
                                    jmp mms_disk_device_read_sector_end 
mms_disk_device_read_sector_next3:  lhld mms_data_selected_segment_address
                                    dad b 
                                    call bios_disk_device_read_sector
                                    xchg 
                                    lhld mms_data_selected_segment_address
                                    mov a,e 
                                    sub l 
                                    mov l,a 
                                    mov a,d 
                                    sbb h 
                                    mov h,a 
                                    inx sp 
                                    inx sp
                                    mvi a,mms_operation_ok
mms_disk_device_read_sector_end:    pop b 
                                    pop d 
                                    ret 

;mms_disk_device_write_sector salva i dati nel segmento selezionato in un settore nella memoria di massa 
;HL -> offset nel segmento dati

;A <- esito dell'operazione
;HL -> offset nel segmento dati (dopo l'esecuzione)

mms_disk_device_write_sector:       push d
                                    push b 
                                    push h 
                                    lda mms_data_selected_segment_id
                                    ora a 
                                    jnz mms_disk_device_write_sector_next 
                                    mvi a,mms_destination_segment_not_selected
                                    pop h
                                    jmp mms_disk_device_write_sector_end 
mms_disk_device_write_sector_next:  call bios_disk_device_get_bps
                                    jnc mms_disk_device_write_sector_next2
                                    mvi a,mms_disk_device_not_selected 
                                    pop h
                                    jmp mms_disk_device_write_sector_end 
mms_disk_device_write_sector_next2: mvi b,7 
                                    mvi d,0 
                                    mov e,a 
mms_disk_device_write_sector_loop:  mov a,e 
                                    add a   
                                    mov e,a 
                                    mov a,d 
                                    ral
                                    mov d,a 
                                    dcr b 
                                    jnz mms_disk_device_write_sector_loop
                                    mov c,l 
                                    mov b,h 
                                    dad d 
                                    xchg 
                                    lhld mms_data_selected_segment_dimension
                                    mov a,l
                                    sub e
                                    mov a,h
                                    sbb d
                                    jnc mms_disk_device_write_sector_next3 
                                    mvi a,mms_source_segment_overflow
                                    pop h
                                    jmp mms_disk_device_write_sector_end 
mms_disk_device_write_sector_next3: lhld mms_data_selected_segment_address
                                    dad b 
                                    call bios_disk_device_write_sector 
                                    xchg 
                                    lhld mms_data_selected_segment_address
                                    mov a,e 
                                    sub l 
                                    mov l,a 
                                    mov a,d 
                                    sbb h 
                                    mov h,a 
                                    inx sp 
                                    inx sp
                                    mvi a,mms_operation_ok
mms_disk_device_write_sector_end:   pop b 
                                    pop d 
                                    ret 

;mms_data_bitstream_number_request verifica se è disponibile un valore nel bitstream user e, in caso positivo, restituisce l'ID da associare al segmento

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

mms_layer_end:     
.print "Space left in MMS layer ->",mms_dimension-mms_layer_end+MMS 
.memory "fill", mms_layer_end, mms_dimension-mms_layer_end+MMS,$00
.print "MMS load address ->",MMS
.print "All functions built successfully"