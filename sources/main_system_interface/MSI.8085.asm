;la Main System Interface è la parte del sistema operativo che fornisce alle applicazioni gli strumenti tutte le system calls appartenenti agli strati sottostanti. 

;Questa sezione del sistema ha il compito di:
;-  inizializzare correttamente il sistema operativo all'avvio della macchina fisica
;-  avviare, fornire e regolare l'accesso delle system calls all'appicazione attualmente in esecuzione 
;-  fornire l'accesso ai dispositivi I/O registrati nel BIOS
;Nella struttura ideale del sistema operativo possiamo considerare la MSI come la componente più astratta dal punto di vista dell'hardware 

;------------------------------------------------------------
;               application                                 -
;------------------------------------------------------------
;-              main sytem interface                        -
;---------------------------------------------------        -
;- file system manager  -       memory             |        -
;------------------------       management         |        -
;       basic      |            system             |        -
;    input/output  |--------------------------------        -        
;       system                                              -
;------------------------------------------------------------
;          hardware         -           libraries           -
;------------------------------------------------------------


;----- system calls -----

;Le system calls vengono chiamate tramite interrupt software (isruzioni rst). Vengono utilizzati gli interrupt come segue:
;-  rst0 viene usato per eseguire un soft reset 
;-  rst1 viene usata per richiamare la maggiorparte delle system calls 
;-  rst2 viene utilizzato per prelevare dati dal dispositivo I/O selezionato 
;-  rst3 viene utilizzato per inviare dati al dispositivo I/O selezionato 
;-  rst4 viene utilizzato per leggere lo stato del dispositivo 

;con l'interrupt rst1 si possono chiamare diverse system call. Quando l'interrupt rst1 viene generato, il registro C deve contenere il codice relativo alla system call desiderata.

;tutte le system calls rst, una volta che vengono richiamate, devono:
;1- salvare il contenuto dei registri della CPU, lo stack pointer e il return address 
;2- impostare lo stack pointer all'indirizzo SP nello spazio riservato al sistema
;3- procedere con l'esecuzione della funzione 
;4- ripristinare i registri che non vengono modificati dalla funzione e lo stack pointer. 
;   Alcune funzioni possono anche restituire variabili nello stack pointer. In questo caso, le variabili vnno trasferite nello stack pointer dell'applicazione. 
;5- utilizzare il return address per riprendere l'esecuzione dell'applicazione 

;----- backup dei registri della CPU ----- 
;In questa fase, tutti i registri devono essere salvati all'interno della memoria, in modo da poter ripristinarli correttamente. 
;Una volta chiamato un interrupt software rst, il return address viene salvato all'interno dello stack dell'applicazione. Per il salvataggio si eseguono quindi i seguenti steps:
;-  viene salvata la coppia dei registri HL tramite l'istruzione SHLD 
;-  viene prelevato e salvato il return address dallo stack dell'applicazione tramite le istruzioni POP H e SHLD
;-  viene prelevato e salvato lo stack pointer tramite le istruzioni LXI H,0, DAD SP e SHLD 
;-  viene trasferito e salvato il contenuto dei registri PSW in HL tramite le istuzioni PUSH PSW, POP H e SHLD
;-  vengono trasferiti i registri BC e DE in HL e poi salvati tramite l'istruzione SHLD 

;Una volta eseguita a funzione, in base al risultato, i registri non modificati e lo stack pointer vanno ripristinati. 
;Nel caso in cui un risultato si trovi all'interno dello stack pointer si deve prima copiare i dati nello stack pointer dell'applicazione e poi restituire l'indirizzo modificato. 

;----- avvio del sistema -----
;Come detto precedentemente, la MSI ha il compito di inizializzare correttamente tutti i layers del sistema operativo. In particolare, tutti i layers devono essere inizializzati seguendo quest'ordine:
;-  BIOS 
;-  MMS 
;-  FSM 
;Per fare questo, ogni layer contiene le istruzioni di inizializzazione (il BIOS deve eseguire un cold boot)

;Nel caso in cui si richiama l'interrupt rst0, tutti i layers devono essere inizializzati nuovamente (il BIOS deve eseguire questa volta un warm boot)

;una volta avviato, il sistema lancia automaticamente la sheel integrata nella MSI, che permetterà all'utente di accedere ad un'interfaccia basilare a linea di comando

;----- sistema a passaggio di messaggi -----
;Ogni appicazione al suo avvio ha i registri azzerati e lo stack pointer preimostato alla fine del program space (vedi mms). 

;Una volta inizializzata l'applicazione, Il registro A può essere inizializzato secondo due criteri differenti:
;-  se A == $00 l'applicazione viene chiamata normalmente 
;-  se A != $00 l'applicazione viene richiamata con un messaggio 

;alla chiusura dell'applicazione, tutti i segmenti utente non permanenti vengono chiusi e viene avviata la sheel di sistema di default, che a sua volta può essere richiamata tramite un messaggio.
;Quando la sheel termina a sua esecuzione, il sistema attende lo spegnimento stampando in output il messaggio di chiusura del sistema.
;un messaggio è solitamente un segmento di memoria permanente di tipo utente che contiene:
;-  un intestazione che contiene il nome dell'applicazione che l'ha creato 
;-  un corpo che varia a seconda del destinatario del messaggio. 

;------------------------
;-  nome del mittente   -
;------------------------
;-  corpo del messaggio -
;------------------------

;Un'applicazione può creare solamente un messaggio e lo può inviare tramite le system calls quando richiede l'avvio di un applicazione.

;----- permessi dell'applicazione -----
;LA MSI si occupa di avviare correttamente le applicazioni. In particolare, a seconda del loro tipo, le applicazioni possono essere di sistema o utente (l'unica cosa che varia sono i permessi di accesso alle system calls):
;-  un'applicazione di sistema può accedere a tutte le system calls e avviare applicaioni di qualsiasi tipo 
;-  un'applicazione non di sistema può accedere solo a un numero ristretto di system calls e avviare applicazioni di tupo utente 
; Viene utilizzata quindi una flag salvata in memoria per tenere traccia del tipo di applicazione in esecuzione.

;----- errori nelle system calls -----
;Quando alla chiamata di una system call si verifica un errore, la MSI può agire in due modi a seconda del tipo:
;-  restituisce un esito negativo all'applicazione che ha rischiesto la system call 
;-  blocca l'esecuzione stampando un messaggio di errore critico (come i BSD di windows)

;----- gestione dei diespositivi I/O -----
;I dispositivi I/O non possono essere gestiti in modo efficace tramite un sistema di drivers a causa delle limitate funzionalità del processore. Tuttavia, possono essere utilizzate le system calls 
;Per richiedere l'accesso ai dispositivi I/O registrati nel BIOS come l'input o l'output da console o altro:
;- Un'applicazione normale può accedere alle funzioni della console e ai dispositivi secondari registrati nel BIOS 
;- un'applicazione di distema può accedere alle funzioni di tutti i dispositivi, comprese quelle delle memorie di massa (questo per eseguire alcune applicazioni di ottimizzazione del filesystem come deframmentazione o pulizia)

;I dispositivi I/O vengono selezionati tramite un identificativo attraverso una system call rst1. Per leggere o scrivere sul dispositivo vengono piu utilizzate 
;le system calls rst2 (per l'input) e rst3 (per l'output). Un dispositivo può essere di sola lettura, di sola scrittura o bidirezionale e può solamente ricevere o inviare un byte alla volta. 
;Per convenzione di identifica con $00 la console (bidirezionale). 

;Dal punto di vista hardware, le applicazioni possono utilizzare direttamente le istruzioni IN e OUT ma devono compunque adeguarsi alle convenzioni di sistema:
;- i dispositivi indirizzati da $00 a $20 vengono dedicati al sistema
;- i dispositivi indirizzati da $21 in poi possono essere utilizzati liberamente

;Le system calls possono anche includere un sistema per identificare i dispositivi predenti nel BIOS (vedi struttura del BIOS)

.include "os_constraints.8085.asm"
.include "bios_system_calls.8085.asm"
.include "mms_system_calls.8085.asm"
.include "fsm_system_calls.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "environment_variables.8085.asm"

rst0_address                .equ    $0000
rst1_address                .equ    $0008
rst2_address                .equ    $0010 
rst3_address                .equ    $0018
rst4_address                .equ    $0020

msi_HL_backup_address               .equ reserved_memory_start+$0050
msi_DE_backup_address               .equ reserved_memory_start+$0052
msi_BC_backup_address               .equ reserved_memory_start+$0054
msi_PSW_backup_address              .equ reserved_memory_start+$0056
msi_PC_backup_address               .equ reserved_memory_start+$0058
msi_SP_backup_address               .equ reserved_memory_start+$005A
msi_ID_segment_backup_address       .equ reserved_memory_start+$005C 

msi_current_program_flags           .equ reserved_memory_start+$005D
msi_segment_ID_backup               .equ reserved_memory_start+$005E


msi_current_program_loaded          .equ %10000000
msi_current_program_permissions     .equ %01000000

MSI_functions:                  .org MSI
                                jmp msi_cold_start 

;per rendere più efficace la ricerca della system call desiderata viene utilizzata una tabella in cui ogni record da 2 bytes identifica l'indirizzo dell'handler dedcato (la posizione identifica l'handler)

msi_system_calls_id_table:      .word msi_system_call_select_IO_device 
                                .word msi_system_call_get_IO_device_informations 
                                .word msi_system_call_mass_memory_select_sector 
                                .word msi_system_call_mass_memory_select_track 
                                .word msi_system_call_mass_memory_select_head 
                                .word msi_system_call_mass_memory_status 
                                .word msi_system_call_mass_memory_get_bps 
                                .word msi_system_call_mass_memory_get_spt 
                                .word msi_system_call_mass_memory_get_tph 
                                .word msi_system_call_mass_memory_get_head_number 
                                .word msi_system_call_mass_memory_write_sector 
                                .word msi_system_call_mass_memory_read_sector 

                                .word msi_system_call_get_free_ram_bytes  
                                .word msi_system_call_create_temporary_memory_segment
                                .word msi_system_call_delete_temporary_memory_segment 
                                .word msi_system_call_select_temporary_memory_segment 
                                .word msi_system_call_read_temporary_segment_byte 
                                .word msi_system_call_write_temporary_segment_byte 
                                .word msi_system_call_read_temporary_segment_dimension 
                                .word msi_system_call_get_current_program_dimension 

                                .word msi_system_call_select_disk 
                                .word msi_system_call_get_disk_format_type 
                                .word msi_system_call_wipe_disk 
                                .word msi_system_call_set_disk_name 
                                .word msi_system_call_get_disk_name 
                                .word msi_system_call_get_disk_free_space 

                                .word msi_system_call_reset_file_scan_pointer 
                                .word msi_system_call_increment_file_scan_pointer 
                                .word msi_system_call_search_file 
                                .word msi_system_call_select_file 
                                .word msi_system_call_create_file 
                                .word msi_system_call_delete_file 
                                .word msi_system_call_get_file_name 
                                .word msi_system_call_get_file_dimension 
                                .word msi_system_call_get_attributes 
                                .word msi_system_call_rename_file
                                .word msi_system_call_set_system_file 
                                .word msi_system_call_set_executable_file 
                                .word msi_system_call_set_read_only_file 
                                .word msi_system_call_set_hidden_file
                                .word msi_system_call_unset_system_file 
                                .word msi_system_call_unset_executable_file 
                                .word msi_system_call_unset_read_only_file 
                                .word msi_system_call_unset_hidden_file
                                
                                .word msi_system_call_change_file_dimension 
                                .word msi_system_call_set_data_pointer 
                                .word msi_system_call_read_file_bytes 
                                .word msi_system_call_write_file_bytes 
                                
                                .word msi_system_call_launch_program
                                .word msi_system_call_launch_program_with_message 
                                .word msi_system_call_exit_program
                            

msi_system_calls_id_table_end:  

msi_cold_start:                 lxi sp,stack_memory_start
                                call bios_cold_boot
                                call mms_low_memory_initialize
                                call fsm_init
                                call msi_interrupt_reset      
                                mvi a,0 
                                sta msi_current_program_flags
                                jmp msi_sheel_startup 
                                 
msi_interrupt_reset:            mvi a,$c3 
                                sta rst0_address
                                sta rst1_address
                                sta rst2_address
                                sta rst3_address 
                                sta rst4_address 
                                lxi h,msi_warm_reset_handler
                                shld rst0_address+1 
                                lxi h,msi_main_system_calls_handler
                                shld rst1_address+1 
                                lxi h,msi_IO_write_system_call_handler
                                shld rst2_address+1 
                                lxi h,msi_IO_read_system_call_handler
                                shld rst3_address+1 
                                lxi h,msi_IO_get_state_system_call_handler
                                shld rst4_address+1 
                                ret 

;msi_warm_reset_handler si occupa di eseguire il warm reset
msi_warm_reset_handler:             call bios_warm_boot 
                                    call mms_low_memory_initialize 
                                    call fsm_init 
                                    call msi_interrupt_reset 
                                    mvi a,0 
                                    sta msi_current_program_flags
                                    jmp msi_sheel_startup 
                                     

;msi_main_system_calls_handler si occupa di gestire tutte le system calls principali  
msi_main_system_calls_handler:          shld msi_HL_backup_address
                                        pop h 
                                        shld msi_PC_backup_address
                                        lxi h,0 
                                        dad sp 
                                        shld msi_SP_backup_address
                                        push psw 
                                        pop h 
                                        shld msi_PSW_backup_address
                                        xchg 
                                        shld msi_DE_backup_address
                                        mov l,c 
                                        mov h,b 
                                        shld msi_BC_backup_address
                                        lxi sp,stack_memory_start
                                        mvi b,0 
                                        mov a,c 
                                        add a 
                                        mov c,a 
                                        mov a,b
                                        ral 
                                        mov b,a 
                                        lxi h,msi_system_calls_id_table
                                        dad b
                                        lxi d,msi_system_calls_id_table_end 
                                        mov a,l
                                        sub e
                                        mov a,h
                                        sbb d
                                        jnc msi_main_system_calls_handler_error 
                                        mov e,m 
                                        inx h 
                                        mov d,m 
                                        xchg 
                                        pchl 

msi_main_system_calls_handler_error:    lhld msi_PSW_backup_address
                                        push h 
                                        pop psw 
                                        mvi a,msi_system_Call_not_found 
                                        lhld msi_SP_backup_address
                                        sphl 
                                        lhld msi_PC_backup_address
                                        push h 
                                        lhld msi_BC_backup_address
                                        mov e,l 
                                        mov b,h 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        lhld msi_HL_backup_address
                                        ret 

msi_system_calls_return:                    shld msi_HL_backup_address
                                            lhld msi_SP_backup_address
                                            sphl 
                                            lhld msi_PC_backup_address
                                            push h 
                                            lhld msi_HL_backup_address
                                            ret 

;msi_selected_segment_backup salva l'ID del segmento di memoria attualmente utilizzato 
msi_selected_segment_backup:        push psw 
                                    call mms_get_selected_segment_ID
                                    sta msi_segment_ID_backup 
                                    pop psw 
                                    ret 

;msi_selected_segment_restore ripristina l'ID del segmento di memoria salvato 
msi_selected_segment_restore:           push psw
                                        lda msi_segment_ID_backup 
                                        ora a 
                                        jz msi_selected_segment_restore_deselect
                                        call mms_select_low_memory_data_segment
                                        pop psw 
                                        ret 
msi_selected_segment_restore_deselect:  call mms_dselect_low_memory_data_segment
                                        pop psw 
                                        ret 

;msi_check_valid_ASCII_character verific se il carattere è valido 
;A -> carattere da verificare 
;A <- $ff se è valido, $00 altrimenti 
msi_check_valid_ASCII_character:            cpi $21 
                                            jc msi_check_valid_ASCII_character_not_valid 
                                            cpi $7e 
                                            jnc msi_check_valid_ASCII_character_not_valid 
                                            cpi $2E
                                            jz msi_check_valid_ASCII_character_not_valid
                                            mvi a,$ff 
                                            ret 
msi_check_valid_ASCII_character_not_valid:  xra a 
                                            ret 


;handlers delle funzioni relative ai dispositivi IO     

;msi_IO_write_system_call_handler viene chiamata tramite l'interrupt rst2 e invia un byte al dispositivo IO selezionato precedentemente con rst1 
;A      -> byte da inviare 
;PSW    <- CY viene settato ad 1 se si è verificato un errore.
;A      <- se CY = 1 ritorna l'errore generato, altrimenti assume lo stesso valore in ingresso alla funzione
msi_IO_write_system_call_handler:       shld msi_HL_backup_address
                                        pop h 
                                        shld msi_PC_backup_address
                                        lxi h,0 
                                        dad sp 
                                        shld msi_SP_backup_address
                                        lxi sp,stack_memory_start
                                        call bios_write_selected_device_byte
                                        lhld msi_HL_backup_address  
                                        jmp msi_system_calls_return

;msi_IO_read_system_call_handler viene richiamata tramite l'interrupt rst3 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è vrificato un errore.
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce il carattere letto dal dispositivo IO

msi_IO_read_system_call_handler:        shld msi_HL_backup_address
                                        pop h 
                                        shld msi_PC_backup_address
                                        lxi h,0 
                                        dad sp 
                                        shld msi_SP_backup_address
                                        lxi sp,stack_memory_start
                                        call bios_read_selected_device_byte
                                        lhld msi_HL_backup_address  
                                        jmp msi_system_calls_return
   

;msi_IO_get_state_system_call_handler viene richiamata tramite l'interrupt rst3 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è verificato un errore.
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce lo stato del dispositivo IO

msi_IO_get_state_system_call_handler:       shld msi_HL_backup_address
                                            pop h 
                                            shld msi_PC_backup_address
                                            lxi h,0 
                                            dad sp 
                                            shld msi_SP_backup_address
                                            lxi sp,stack_memory_start
                                            call bios_get_selected_device_state
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return 

;implementazione delle system calls standard rst1 

;msi_system_call_select_IO_device permette di selezionare il dispositivo IO dal BIOS. 
;A -> id del dispositivo 
;A <- esito dell'operazione 
;PSW <- CY viene settato ad 1 se si è verificato un errore nella selezione 
msi_system_call_select_IO_device:           lhld msi_PSW_backup_address
                                            mov a,h 
                                            call bios_select_IO_device
                                            cpi bios_operation_ok
                                            jnz msi_system_call_select_IO_device_error
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            jmp msi_system_call_select_IO_device_end
msi_system_call_select_IO_device_error:     stc 
msi_system_call_select_IO_device_end:       lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_get_IO_device_informations restituisce le informazioni sul dispositivo IO
;A -> ID del dispositivo IO 
;PSW <- se il dispositivo non esiste CY viene settato ad 1
;A <- se CY = 1 restituisce l'errore generato, altrimenti restituisce le informazioni sul dispositivo 
msi_system_call_get_IO_device_informations:         lda msi_PSW_backup_address+1
                                                    call bios_get_IO_device_informations
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_select_sector permette di selezonare un settore nella memoria di massa selezionata
; A -> numero di settore 
; A <- esito dell'operazione 
; PSW <- se si è verificato un errore CY viene settato ad 1 

msi_system_call_mass_memory_select_sector:          lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_select_sector_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_select_sector_end
msi_system_call_mass_memory_select_sector_next:     lda msi_PSW_backup_address+1
                                                    call bios_mass_memory_select_sector
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_mass_memory_select_sector_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_mass_memory_select_sector_end:      lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_select_head permette di selezonare la testina nella memoria di massa selezionata
; A -> numero di testina
; A <- esito dell'operazione 
; PSW <- se si è verificato un errore CY viene settato ad 1 

msi_system_call_mass_memory_select_head:            lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_select_head_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_select_head_end
msi_system_call_mass_memory_select_head_next:       lda msi_PSW_backup_address+1
                                                    call bios_mass_memory_select_head
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_mass_memory_select_head_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_mass_memory_select_head_end:        lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_select_track permette di selezionare la traccia nella memoria di massa selezionata 
;HL -> numero di traccia 
;A <- esito dell'operazione 
;PSW <- Csi si è verificato un errore CY viene settato ad 1 

msi_system_call_mass_memory_select_track:           lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_select_track_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_select_track_end
msi_system_call_mass_memory_select_track_next:      lhld msi_HL_backup_address
                                                    call bios_mass_memory_select_track 
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_mass_memory_select_track_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_mass_memory_select_track_end:       lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_status restituisce lo stato corrente della memoria di massa selezionata 
;PSW <- CY viene settata ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce lo stato corrente del dispositivo 

msi_system_call_mass_memory_status:                 lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_status_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_status_end
msi_system_call_mass_memory_status_next:            call bios_mass_memory_status
msi_system_call_mass_memory_status_end:             lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_get_bps restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di bytes per settore in multipli di 128b 

msi_system_call_mass_memory_get_bps:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_get_bps_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_get_bps_end
msi_system_call_mass_memory_get_bps_next:           call bios_mass_memory_get_bps
msi_system_call_mass_memory_get_bps_end:            lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_get_spt restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituiscel'errore generato, altrimenti restituisce il numero di settori per traccia

msi_system_call_mass_memory_get_spt:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_get_spt_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_get_spt_end
msi_system_call_mass_memory_get_spt_next:           call bios_mass_memory_get_spt 
msi_system_call_mass_memory_get_spt_end:            lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_get_spt restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di tracce per settori in multipli di 128b 
;HL <- assume 0 se CY=1, altrimenti restituisce il numero di tracce per testina 

msi_system_call_mass_memory_get_tph:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_get_tph_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    lxi h,0
                                                    jmp msi_system_call_mass_memory_get_tph_end
msi_system_call_mass_memory_get_tph_next:           call bios_mass_memory_get_tph
msi_system_call_mass_memory_get_tph_end:            xchg 
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_get_head_number restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di testine del dispositivo

msi_system_call_mass_memory_get_head_number:        lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_get_head_number_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_get_head_number_end
msi_system_call_mass_memory_get_head_number_next:   call bios_mass_memory_get_head_number
msi_system_call_mass_memory_get_head_number_end:    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_mass_memory_write_sector scrive nel settore della memoria di massa i dati precedenti nel segmento di memoria selezionato 
;DE -> offset nel segmento 
;A <- esito dell'operazione 
;PSW <- CY viene settata ad 1 se si è verificato un errore
;DE <- offset nel segmento dopo l'operazione 

msi_system_call_mass_memory_write_sector:           lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_write_sector_next 
msi_system_call_mass_memory_write_sector_perm_err:  lhld msi_DE_backup_address
                                                    xchg 
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_write_sector_end 
msi_system_call_mass_memory_write_sector_next:      call mms_get_selected_segment_ID
                                                    ani mms_low_memory_type_segment_mask
                                                    jnz msi_system_call_mass_memory_write_sector_perm_err
                                                    lhld msi_DE_backup_address
                                                    call mms_mass_memory_write_sector
                                                    cpi mms_operation_ok
                                                    jnz msi_system_call_mass_memory_write_sector_error 
                                                    stc 
                                                    cmc 
                                                    xchg 
                                                    mvi a,msi_operation_ok
                                                    jmp msi_system_call_mass_memory_write_sector_end 
msi_system_call_mass_memory_write_sector_error:     stc 
                                                    lhld msi_DE_backup_address
                                                    xchg 
msi_system_call_mass_memory_write_sector_end:       lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_HL_backup_address
                                                    jmp msi_system_calls_return

;msi_system_call_mass_memory_read_sector legge dal settore della memoria di massa i dati e li salva nel segmento di memoria selezionato 
;DE -> offset nel segmento 
;A <- esito dell'operazione 
;PSW <- CY viene settata ad 1 se si è verificato un errore
;DE <- offset nel segmento dopo l'operazione  
msi_system_call_mass_memory_read_sector:            lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_mass_memory_read_sector_next 
msi_system_call_mass_memory_read_sector_perm_err:   lhld msi_DE_backup_address
                                                    xchg 
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_mass_memory_read_sector_end 
msi_system_call_mass_memory_read_sector_next:       call mms_get_selected_segment_ID
                                                    ani mms_low_memory_type_segment_mask 
                                                    jnz msi_system_call_mass_memory_read_sector_perm_err
                                                    lhld msi_DE_backup_address
                                                    call mms_mass_memory_read_sector
                                                    cpi mms_operation_ok
                                                    jnz msi_system_call_mass_memory_read_sector_error 
                                                    stc 
                                                    cmc 
                                                    xchg 
                                                    mvi a,msi_operation_ok
                                                    jmp msi_system_call_mass_memory_read_sector_end 
msi_system_call_mass_memory_read_sector_error:      stc 
                                                    lhld msi_DE_backup_address
                                                    xchg 
msi_system_call_mass_memory_read_sector_end:        lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_HL_backup_address
                                                    jmp msi_system_calls_return

;msi_system_call_get_free_ram_bytes restituisce il numero di bytes disponibili nella RAM 
;DE <- bytes disponibili 
msi_system_call_get_free_ram_bytes:             call mms_free_low_ram_bytes
                                                xchg 
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_PSW_backup_address
                                                push h 
                                                pop psw 
                                                lhld msi_HL_backup_address
                                                jmp msi_system_calls_return

;msi_system_call_get_current_program_dimension restituisce la dimensione del programma caricato attualmente in memoria 
;DE <- bytes occupati dal programma attualmente in esecuzione (restituisce 0 se non è stato caricato un programma)
msi_system_call_get_current_program_dimension:  call mms_get_low_memory_program_dimension
                                                xchg 
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_PSW_backup_address
                                                push h 
                                                pop psw 
                                                lhld msi_HL_backup_address
                                                jmp msi_system_calls_return

;msi_system_call_create_temporary_memory_segment crea un segmento temporaneo all'interno della RAM 
;PSW <- se si è verificato un errore nella creazione CY assume 1 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce id del segmento creato 
;DE -> dimensione del segmento da creare 
msi_system_call_create_temporary_memory_segment:        lhld msi_DE_backup_address
                                                        mvi a,mms_low_memory_valid_segment_mask+mms_low_memory_temporary_segment_mask
                                                        call mms_create_low_memory_data_segment
                                                        jc msi_system_call_create_temporary_memory_segment_end 
                                                        mvi a,msi_operation_ok
msi_system_call_create_temporary_memory_segment_end:    lhld msi_BC_backup_address
                                                        mov c,l 
                                                        mov b,h 
                                                        lhld msi_DE_backup_address
                                                        xchg 
                                                        lhld msi_HL_backup_address  
                                                        jmp msi_system_calls_return

;msi_system_call_delete_temporary_memory_segment elimina il segmento in memoria selezionato 
;A <- esito dell'operazione 
;PSW <- CY viene settato ad 1 se si verifica un errore nell'esecuzione 
msi_system_call_delete_temporary_memory_segment:        call mms_get_selected_data_segment_flags
                                                        ani mms_low_memory_type_segment_mask
                                                        jz msi_system_call_delete_temporary_memory_segment_next
                                                        mvi a,msi_current_program_permissions_error
                                                        stc 
                                                        jmp msi_system_call_delete_temporary_memory_segment_end 
msi_system_call_delete_temporary_memory_segment_next:   call mms_delete_selected_low_memory_data_segment
                                                        cpi mms_operation_ok
                                                        jnz msi_system_call_delete_temporary_memory_segment_error
                                                        mvi a,fsm_operation_ok
                                                        stc 
                                                        cmc 
                                                        jmp msi_system_call_delete_temporary_memory_segment_end
msi_system_call_delete_temporary_memory_segment_error:  stc 
msi_system_call_delete_temporary_memory_segment_end:    lhld msi_BC_backup_address
                                                        mov c,l 
                                                        mov b,h 
                                                        lhld msi_DE_backup_address
                                                        xchg 
                                                        lhld msi_HL_backup_address  
                                                        jmp msi_system_calls_return

;msi_system_call_select_temporary_memory_segment seleziona il segmento di memoria desiderato 
;A -> ID del segmento da selezionare 
;A <- esito dell'operazione 
;PSW <- se si è verificato un errore CY viene settato a 1 
msi_system_call_select_temporary_memory_segment:        lda msi_PSW_backup_address+1
                                                        mov b,a 
                                                        call mms_get_selected_segment_ID
                                                        mov c,a 
                                                        mov a,b 
                                                        
                                                        call mms_select_low_memory_data_segment
                                                        cpi mms_operation_ok
                                                        jnz msi_system_call_select_temporary_memory_segment_error 
                                                        call mms_get_selected_data_segment_flags
                                                        ani mms_low_memory_type_segment_mask
                                                        jz msi_system_call_select_temporary_memory_segment_next 
                                                        mov a,c 
                                                        call mms_select_low_memory_data_segment
                                                        cpi mms_operation_ok
                                                        jnz msi_system_call_select_temporary_memory_segment_error 
                                                        mvi a,msi_current_program_permissions_error
                                                        jmp msi_system_call_select_temporary_memory_segment_error
msi_system_call_select_temporary_memory_segment_next:   mvi a,msi_operation_ok
                                                        stc 
                                                        cmc 
                                                        jmp msi_system_call_select_temporary_memory_segment_end
msi_system_call_select_temporary_memory_segment_error:  stc 
msi_system_call_select_temporary_memory_segment_end:    lhld msi_BC_backup_address
                                                        mov c,l 
                                                        mov b,h 
                                                        lhld msi_DE_backup_address
                                                        xchg 
                                                        lhld msi_HL_backup_address  
                                                        jmp msi_system_calls_return

;msi_system_call_read_temporary_segment_dimension restituisce la dimensione del segmento di memoria selezionato 
;DE <- dimensione del segmento (ritorna 0 se non è stato selezionato nessun segmento)
;A <- esito dell'operazione
;PSW <- CY viene settato ad 1 se si è verificato un errore 
msi_system_call_read_temporary_segment_dimension:       call mms_get_selected_segment_ID
                                                        ani mms_low_memory_type_segment_mask 
                                                        jz msi_system_call_read_temporary_segment_dimension_next 
                                                        lxi h,0 
                                                        stc 
                                                        mvi a,msi_current_program_permissions_error
                                                        jmp msi_system_call_read_temporary_segment_dimension_end 
msi_system_call_read_temporary_segment_dimension_next:  call mms_get_selected_data_segment_dimension
                                                        stc 
                                                        cmc 
                                                        mvi a,msi_operation_ok
msi_system_call_read_temporary_segment_dimension_end:   xchg 
                                                        lhld msi_BC_backup_address
                                                        mov c,l 
                                                        mov b,h 
                                                        lhld msi_HL_backup_address
                                                        jmp msi_system_calls_return

;msi_system_call_read_temporary_segment_byte il byte dal segmento selezionato 
;DE -> offset nel segmento 
;A <- byte letto (se CY viene settato a 1 restituisce l'errore generato)
;PSW <- se si è verificato un errore nella lettura CY viene settato a 1

msi_system_call_read_temporary_segment_byte:        lhld msi_DE_backup_address 
                                                    call mms_read_selected_data_segment_byte
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_write_temporary_segment_byte il byte dal segmento selezionato 
;A -> byte da scrivere
;DE -> offset nel segmento 
;A <- se CY viene settato a 1 viene restituito l'errore generato (altrimenti rimane invariato)
;PSW <- se si è verificato un errore nella lettura CY viene settato a 1

msi_system_call_write_temporary_segment_byte:       lda msi_PSW_backup_address+1
                                                    lhld msi_DE_backup_address 
                                                    call mms_write_selected_data_segment_byte
                                                    jc msi_system_call_write_temporary_segment_byte_end
                                                    lda msi_PSW_backup_address+1
msi_system_call_write_temporary_segment_byte_end:   lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return


;msi_system_call_select_disk seleziona il disco desiderato 
;A -> id ASCII del disco da seleionare (compreso fra A e Z)
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 
      
msi_system_call_select_disk:        call msi_selected_segment_backup
                                    lda msi_PSW_backup_address+1 
                                    call fsm_select_disk
                                    cpi fsm_operation_ok
                                    jnz msi_system_call_select_disk_error
                                    stc 
                                    cmc 
                                    mvi a,fsm_operation_ok
                                    jmp msi_system_call_select_disk_end
msi_system_call_select_disk_error:  stc 
msi_system_call_select_disk_end:    call msi_selected_segment_restore
                                    lhld msi_BC_backup_address
                                    mov c,l 
                                    mov b,h 
                                    lhld msi_DE_backup_address
                                    xchg 
                                    lhld msi_HL_backup_address  
                                    jmp msi_system_calls_return

;msi_system_call_get_disk_format_type restituisce il tipo di formattazione del disco 
;A <- codice di formattazione 
;PSW <- se si è verificato un errore CY viene settato a 1 
msi_system_call_get_disk_format_type:   call msi_selected_segment_backup
                                        call fsm_get_disk_format_type 
                                        call msi_selected_segment_restore
                                        lhld msi_BC_backup_address
                                        mov c,l 
                                        mov b,h 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        lhld msi_HL_backup_address  
                                        jmp msi_system_calls_return

;msi_system_call_wipe_disk rimuove tutti i file presenti nel disco 
;A <- esito dell'operazione
;PSW <- se si verifica un errore CY viene settato a 1 
msi_system_call_wipe_disk:          call msi_selected_segment_backup
                                    lda msi_PSW_backup_address+1 
                                    call fsm_wipe_disk
                                    cpi fsm_operation_ok
                                    jnz msi_system_call_wipe_disk_error
                                    stc 
                                    cmc 
                                    mvi a,fsm_operation_ok
                                    jmp msi_system_call_wipe_disk_end
msi_system_call_wipe_disk_error:    stc 
msi_system_call_wipe_disk_end:      call msi_selected_segment_restore
                                    lhld msi_BC_backup_address
                                    mov c,l 
                                    mov b,h 
                                    lhld msi_DE_backup_address
                                    xchg 
                                    lhld msi_HL_backup_address  
                                    jmp msi_system_calls_return

;msi_system_call_set_disk_name imposta il nome al disco selezionato 
;DE -> puntatore al nome del disco      ;il nome deve essere una serie di caratteri in ASCII terminata da $00
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si verifica un problema nell'esecuzione
;Sono considerati validi tutti i caratteri ASCII stampabili (fatta eccezione per lo spazio)


msi_system_call_set_disk_name:                          call msi_selected_segment_backup
                                                        lhld msi_DE_backup_address
                                                        call fsm_disk_name_max_dimension 
                                                        mov b,a 
                                                        mov c,a 
msi_system_call_set_disk_name_check_loop:               mov a,m
                                                        inx h 
                                                        ora a 
                                                        jz msi_system_call_set_disk_name_check_ok 
                                                        call msi_check_valid_ASCII_character
                                                        ora a 
                                                        jz msi_system_call_set_disk_name_check_invalid_character
                                                        dcr b 
                                                        jnz msi_system_call_set_disk_name_check_loop
                                                        mvi a,msi_string_too_long 
                                                        stc 
                                                        jmp msi_system_call_set_disk_name_end 
msi_system_call_set_disk_name_check_invalid_character:  mvi a,msi_invalid_character_in_string 
                                                        stc 
                                                        jmp msi_system_call_set_disk_name_end 
msi_system_call_set_disk_name_check_ok:                 mov a,c 
                                                        sub b 
                                                        jnz msi_system_call_set_disk_name_check_dimension_ok
                                                        mvi a,msi_string_empty 
                                                        stc 
                                                        jmp msi_system_call_set_disk_name_end
msi_system_call_set_disk_name_check_dimension_ok:       lhld msi_DE_backup_address
                                                        xchg 
                                                        call fsm_disk_set_name
                                                        cpi fsm_operation_ok
                                                        jnz msi_system_call_set_disk_name_error
                                                        mvi a,msi_operation_ok
                                                        stc 
                                                        cmc 
                                                        jmp msi_system_call_set_disk_name_end
msi_system_call_set_disk_name_error:                    stc            
msi_system_call_set_disk_name_end:                      call msi_selected_segment_restore
                                                        lhld msi_BC_backup_address
                                                        mov c,l 
                                                        mov b,h 
                                                        lhld msi_DE_backup_address
                                                        xchg 
                                                        lhld msi_HL_backup_address  
                                                        jmp msi_system_calls_return

;msi system_call_get_disk_name restituisce il nome del disco 
;A <- esito dell'operazione 
;SP <- [nome del disco] se l'operazione è andata a buon fine 
;PSW <- CY viene settato a 1 se si verifica un errore nell'esecuzione 

msi_system_call_get_disk_name:          call msi_selected_segment_backup
                                        call fsm_disk_get_name 
                                        cpi fsm_operation_ok
                                        jnz msi_system_call_get_disk_name_error 
                                        lxi h,0 
                                        dad sp 
                                        mvi b,0 
msi_system_call_get_disk_name_count:    inr b 
                                        mov a,m 
                                        inx h 
                                        ora a 
                                        jnz msi_system_call_get_disk_name_count
                                        xchg 
                                        lhld msi_SP_backup_address
                                        dcx h
                                        dcx d 
msi_system_call_get_disk_name_copy:     ldax d 
                                        mov m,a 
                                        dcx h
                                        dcx d 
                                        dcr b 
                                        jnz msi_system_call_get_disk_name_copy
                                        inx h 
                                        shld msi_SP_backup_address
                                        mvi a,msi_operation_ok
                                        stc 
                                        cmc 
                                        jmp msi_system_call_get_disk_name_end
msi_system_call_get_disk_name_error:    stc 
msi_system_call_get_disk_name_end:      call msi_selected_segment_restore 
                                        lhld msi_BC_backup_address
                                        mov c,l 
                                        mov b,h 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        lhld msi_HL_backup_address  
                                        jmp msi_system_calls_return

;msi_system_call_get_disk_free_space restituisce il numero di bytes disponibili nel disco 
;BCDE <- numero di bytes disponibili 
;A <- esito dell'operazione 
;PSW <- se si è verificato un errore nell'esecuzione CY viene settato a 1 
msi_system_call_get_disk_free_space:        call msi_selected_segment_backup
                                            call fsm_disk_get_free_space
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_disk_free_space_error
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            call msi_selected_segment_restore
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return
msi_system_call_get_disk_free_space_error:  stc 
                                            call msi_selected_segment_restore
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_string_file_copy_and_load copia la stringa in input nello stack e repara il nome dall'estensione (quando possibile)
;HL -> indirizzo alla stringa da elaborare
;A <- esito dell'operazione 
;BC <- indirizzo del nome 
;DE <- indirizzo dell'estensione
   
msi_string_file_copy_and_load:                  push h
                                                call fsm_file_name_max_dimensions
                                                lxi d,0 
msi_string_file_copy_and_load_check_loop1:      mov a,m 
                                                inx h 
                                                ora a 
                                                jz msi_string_file_copy_and_load_check_loop_end
                                                cpi $2e 
                                                jz msi_string_file_copy_and_load_check_loop2
                                                call msi_check_valid_ASCII_character
                                                ora a 
                                                jz msi_string_file_copy_and_load_check_error
                                                inr d 
                                                dcr b 
                                                jnz msi_string_file_copy_and_load_check_loop1
                                                mvi a,msi_name_too_long
                                                stc 
                                                inx sp 
                                                inx sp 
                                                jmp msi_string_file_copy_and_load_end 
msi_string_file_copy_and_load_check_loop2:      mov a,m 
                                                inx h 
                                                ora a 
                                                jz msi_string_file_copy_and_load_check_loop_end
                                                call msi_check_valid_ASCII_character
                                                ora a 
                                                jz msi_string_file_copy_and_load_check_error
                                                inr e
                                                dcr c
                                                jnz msi_string_file_copy_and_load_check_loop2
                                                mvi a,msi_extension_too_long 
                                                stc 
                                                inx sp 
                                                inx sp 
                                                jmp msi_string_file_copy_and_load_end 
msi_string_file_copy_and_load_check_error:      mvi a,msi_invalid_character_in_string
                                                stc 
                                                inx sp 
                                                inx sp 
                                                jmp msi_string_file_copy_and_load_end 
msi_string_file_copy_and_load_check_loop_end:   mov a,d 
                                                ora a 
                                                jnz msi_string_file_copy_and_load_copy_string
                                                mvi a,msi_string_empty
                                                stc 
                                                inx sp 
                                                inx sp 
                                                jmp msi_string_file_copy_and_load_end
msi_string_file_copy_and_load_copy_string:      mov c,e 
                                                mov b,d 
                                                
                                                pop d 
                                                lxi h,1
                                                dad sp 
                                                mov a,l 
                                                sub b 
                                                mov l,a 
                                                mov a,h 
                                                sbi 0 
                                                mov h,a 
                                                mov a,c 
                                                ora a 
                                                jz msi_string_file_copy_and_load_copy_string2
                                                inr c 
                                                mov a,l 
                                                sub c 
                                                mov l,a 
msi_string_file_copy_and_load_copy_string2:     pop psw 
                                                sphl 
                                                push psw 
                                           
msi_string_file_copy_and_load_copy_loop:        ldax d 
                                                mov m,a 
                                                inx d 
                                                inx h 
                                                ldax d 
                                                ora a 
                                                jnz msi_string_file_copy_and_load_copy_loop
                                                mvi m,0 
                                                lxi h,2
                                                dad sp  
                                                mov e,l 
                                                mov d,h 
                                                mov a,l 
                                                add b 
                                                mov l,a 
                                                mov a,h 
                                                aci 0 
                                                mov h,a 
                                                mov a,m 
                                                ora a 
                                                jz msi_string_file_copy_and_load_function
                                                mvi m,0 
                                                inx h 
msi_string_file_copy_and_load_function:         mov c,e 
                                                mov b,d 
                                                xchg
                                                mvi a,msi_operation_ok 
msi_string_file_copy_and_load_end:              ret 

;msi_system_call_search_file verifica se il file esiste all'interno del disco selezionato 
;DE -> puntatore nome completo del file. Il nome completo è una stringa di caratteri ASCII terminata dal carattere $00 in cui nome ed estensione sono separati da un punto . (l'estensione è facoltativa)

;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore nell'esecuzione

msi_system_call_search_file:                call msi_selected_segment_backup
                                            lhld msi_DE_backup_address
                                            call msi_string_file_copy_and_load
                                            cpi msi_operation_ok
                                            jnz msi_system_call_search_file_error
                                            call fsm_search_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_search_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_search_file_end
msi_system_call_search_file_error:          stc  
msi_system_call_search_file_end:            call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_select_file seleziona il file presente nel disco 
;DE -> puntatore al nome completo del file. Il nome completo è una stringa di caratteri ASCII terminata dal carattere $00 in cui nome ed estensione sono separati da un punto . (l'estensione è facoltativa)

;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore nell'esecuzione
msi_system_call_select_file:                call msi_selected_segment_backup
                                            lhld msi_DE_backup_address
                                            call msi_string_file_copy_and_load
                                            cpi msi_operation_ok
                                            jnz msi_system_call_select_file_error
                                            call fsm_select_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_select_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_select_file_end
msi_system_call_select_file_error:          stc  
msi_system_call_select_file_end:            call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_create_file crea il file nel disco 
;DE -> puntatore al nome completo del file. Il nome completo è una stringa di caratteri ASCII terminata dal carattere $00 in cui nome ed estensione sono separati da un punto . (l'estensione è facoltativa)

;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore nell'esecuzione
msi_system_call_create_file:                call msi_selected_segment_backup
                                            lhld msi_DE_backup_address
                                            call msi_string_file_copy_and_load
                                            cpi msi_operation_ok
                                            jnz msi_system_call_create_file_error
                                            mvi a,fsm_header_valid_bit 
                                            call fsm_create_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_create_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_create_file_end
msi_system_call_create_file_error:          stc  
msi_system_call_create_file_end:            call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_get_file_name restituisce il nome completo del file 
;SP -> [nome completo]
;A <- esito dell'operazione
;PSW <- se si verifica un errore CY viene settato a 1
msi_system_call_get_file_name:              call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_extension
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_file_name_error
                                            lxi h,0 
                                            dad sp  
                                            call fsm_get_selected_file_header_name 
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_file_name_error
                                            mov a,m 
                                            ora a
                                            jz msi_system_call_get_file_name_skip_dot 
                                            dcx h 
                                            mvi m,$2E
msi_system_call_get_file_name_skip_dot:     lxi h,0 
                                            dad sp 
                                            mvi b,0 
msi_system_call_get_file_name_count_loop:   mov a,m 
                                            inx h 
                                            inr b 
                                            ora a 
                                            jnz msi_system_call_get_file_name_count_loop
msi_system_call_get_file_name_count_end:    dcx h 
                                            xchg 
                                            lhld msi_SP_backup_address
                                            dcx h 
msi_system_call_get_file_name_copy_loop:    ldax d 
                                            mov m,a 
                                            dcx d 
                                            dcx h 
                                            dcr b 
                                            jnz msi_system_call_get_file_name_copy_loop
                                            inx h
                                            shld msi_SP_backup_address
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            jmp msi_system_call_get_file_name_end      
msi_system_call_get_file_name_error:        stc 
msi_system_call_get_file_name_end:          call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_get_file_dimension restituisce la dimensione in bytes del file selezionato 
;A <- esito dell'operazione 
;BCDE <- numero di bytes occupati 
;PSW <- CY viene settato a 1 se si è verificato un errore 
msi_system_call_get_file_dimension:         call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_dimension
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_file_dimension_error
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            call msi_selected_segment_restore
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return
msi_system_call_get_file_dimension_error:   stc 
                                            call msi_selected_segment_restore
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_get_attributes restituisce gli attributi del files codificati in un byte 
;A <- flags (se CY=1 restituisce l'errore):
;       bit 8 -> file di sistema
;       bit 7 -> file eseguibile 
;       bit 6 -> file nascosto
;       bit 5 -> file di sola lettura 
      
;PSW <- CY viene settato 1 in caso di errore 

msi_system_call_get_attributes:             call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_flags
                                            jc msi_system_call_get_attributes_end
                                            add a 
                                            add a 
                                            stc 
                                            cmc 
                                            jmp msi_system_call_get_attributes_end
msi_system_call_get_attributes_end:         call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_rename_file reimposta il nome al file selezionato 
;DE -> puntatore al nome completo del file. Il nome completo è una stringa di caratteri ASCII terminata dal carattere $00 in cui nome ed estensione sono separati da un punto . (l'estensione è facoltativa)
;A <- esito dell'operazione 
;PSW <- se si verifica un errore CY viene settato a 1 
msi_system_call_rename_file:                call msi_selected_segment_backup
                                            lhld msi_DE_backup_address
                                            call msi_string_file_copy_and_load
                                            cpi msi_operation_ok
                                            jnz msi_system_call_rename_file_error
                                            call fsm_set_selected_file_header_name_and_extension
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_rename_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_rename_file_end
msi_system_call_rename_file_error:          stc  
msi_system_call_rename_file_end:            call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_set_system_file imposta il file selezionato come di sistema 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_set_system_file:            call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_set_system_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_set_system_file_end
msi_system_call_set_system_file_next:       call fsm_get_selected_file_header_flags
                                            jc msi_system_call_set_system_file_end
                                            
                                            ori fsm_header_system_bit
                                            call fsm_set_selected_file_header_flags
                                            
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_set_system_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_set_system_file_end
msi_system_call_set_system_file_error:      stc 
msi_system_call_set_system_file_end:        call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_unset_system_file imposta il file selezionato come non di sistema 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_unset_system_file:          call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_unset_system_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_unset_system_file_end
msi_system_call_unset_system_file_next:     call fsm_get_selected_file_header_flags
                                            jc msi_system_call_unset_system_file_end
                                            ani $ff-fsm_header_system_bit
                                            call fsm_set_selected_file_header_flags
                                           
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_unset_system_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_unset_system_file_end
msi_system_call_unset_system_file_error:    stc 
msi_system_call_unset_system_file_end:      call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_set_read_only_file imposta il file selezionato come di sola lettura
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_set_read_only_file:         call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_read_only_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_read_only_file_end
msi_system_call_read_only_file_next:        call fsm_get_selected_file_header_flags
                                            jc msi_system_call_read_only_file_end
                                            ori fsm_header_readonly_bit
                                            call fsm_set_selected_file_header_flags
                                            
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_read_only_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_read_only_file_end
msi_system_call_read_only_file_error:       stc 
msi_system_call_read_only_file_end:         call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_unread_only_file imposta il file selezionato come accessibile in scrittura
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_unset_read_only_file:       call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_unset_read_only_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_unset_read_only_file_end
msi_system_call_unset_read_only_file_next:  call fsm_get_selected_file_header_flags
                                            jc msi_system_call_unset_read_only_file_end
                                            ani $ff-fsm_header_readonly_bit
                                            call fsm_set_selected_file_header_flags
                                            
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_unset_read_only_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_unset_read_only_file_end
msi_system_call_unset_read_only_file_error: stc 
msi_system_call_unset_read_only_file_end:   call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_set_executable_file imposta il file selezionato come eseguibile
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_set_executable_file:        call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_flags
                                            jc msi_system_call_set_executable_file_end
                                            ori fsm_header_program_bit
                                            call fsm_set_selected_file_header_flags
                                            
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_set_executable_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_set_executable_file_end
msi_system_call_set_executable_file_error:  stc 
msi_system_call_set_executable_file_end:    call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_unset_executable_file imposta il file selezionato come non eseguibile
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_unset_executable_file:          call msi_selected_segment_backup
                                                call fsm_get_selected_file_header_flags
                                                jc msi_system_call_unset_executable_file_end
                                                ani $ff-fsm_header_program_bit
                                                call fsm_set_selected_file_header_flags
                                               
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_unset_executable_file_error
                                                mvi a,msi_operation_ok
                                                stc 
                                                cmc 
                                                jmp msi_system_call_unset_executable_file_end
msi_system_call_unset_executable_file_error:    stc 
msi_system_call_unset_executable_file_end:      call msi_selected_segment_restore
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return


;msi_system_call_set_hidden_file imposta il file selezionato come nascosto
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_set_hidden_file:            call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_set_hidden_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_set_hidden_file_end
msi_system_call_set_hidden_file_next:       call fsm_get_selected_file_header_flags
                                            jc msi_system_call_set_hidden_file_end
                                            
                                            ori fsm_header_hidden_bit
                                            call fsm_set_selected_file_header_flags
                                         
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_set_hidden_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_set_hidden_file_end
msi_system_call_set_hidden_file_error:      stc 
msi_system_call_set_hidden_file_end:        call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_unset_hidden_file imposta il file selezionato come visibile
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_unset_hidden_file:          call msi_selected_segment_backup
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_unset_hidden_file_next
                                            mvi a,msi_current_program_permissions_error 
                                            stc 
                                            jmp msi_system_call_unset_hidden_file_end
msi_system_call_unset_hidden_file_next:     call fsm_get_selected_file_header_flags
                                            jc msi_system_call_unset_hidden_file_end
                                            ani $ff-fsm_header_hidden_bit
                                            call fsm_set_selected_file_header_flags
                                         
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_unset_hidden_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_unset_hidden_file_end
msi_system_call_unset_hidden_file_error:    stc 
msi_system_call_unset_hidden_file_end:      call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_delete_file elimina il file attualmente selezionato 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 in caso di errore 
msi_system_call_delete_file:                call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_flags
                                            jc msi_system_call_delete_file_end
                                            ani fsm_header_system_bit
                                            jz msi_system_call_delete_file_next 
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_delete_file_next
                                            mvi a,msi_current_program_permissions_error
                                            stc 
                                            jmp msi_system_call_delete_file_end
msi_system_call_delete_file_next:           call fsm_delete_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_delete_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_delete_file_end
msi_system_call_delete_file_error:          stc 
msi_system_call_delete_file_end:            call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_reset_file_scan_pointer reimposta il flne scan spointer alla posizione iniziale 

msi_system_call_reset_file_scan_pointer:    call msi_selected_segment_backup
                                            call fsm_reset_file_header_scan_pointer
                                            call msi_selected_segment_restore
                                            lhld msi_PSW_backup_address
                                            push h 
                                            pop psw 
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_increment_file_scan_pointer incrementa il file scan pointer 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 
msi_system_call_increment_file_scan_pointer:        call msi_selected_segment_backup
                                                    call fsm_increment_file_header_scan_pointer
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_increment_file_scan_pointer_error
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_increment_file_scan_pointer_end
msi_system_call_increment_file_scan_pointer_error:  stc 
msi_system_call_increment_file_scan_pointer_end:    call msi_selected_segment_restore
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_change_file_dimension modifica la dimensione del file selezionato (può aggiungere bytes o troncare il file alla fine)
;DEHL -> nuova dimensione del file 
;A <- esito dell'operazione 
;psw <- CY viene settato a 1 se si è verificato un errore 

msi_system_call_change_file_dimension:              call msi_selected_segment_backup
                                                    call fsm_get_selected_file_header_flags
                                                    jc msi_system_call_change_file_dimension_end
                                                    ani fsm_header_system_bit
                                                    jz msi_system_call_change_file_dimension_next 
                                                    lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_change_file_dimension_next
                                                    mvi a,msi_current_program_permissions_error
                                                    stc 
                                                    jmp msi_system_call_change_file_dimension_end
msi_system_call_change_file_dimension_next:         lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address
                                                    mov a,l 
                                                    ora h 
                                                    ora e 
                                                    ora d 
                                                    jnz msi_system_call_change_file_dimension_modify
                                                    call fsm_selected_file_wipe
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_change_file_dimension_error
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_change_file_dimension_end
msi_system_call_change_file_dimension_modify:       call fsm_get_selected_file_header_dimension
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_change_file_dimension_error
                                                    lhld msi_HL_backup_address
                                                    mov a,e 
                                                    sub l 
                                                    mov e,a 
                                                    mov a,d 
                                                    sbb h 
                                                    mov d,a 
                                                    lhld msi_DE_backup_address
                                                    mov a,c 
                                                    sbb l 
                                                    mov c,a 
                                                    mov a,b 
                                                    sbb h 
                                                    mov b,a 
                                                    jc msi_system_call_change_file_dimension_grow 
                                                    mov a,e 
                                                    ora d 
                                                    ora c 
                                                    ora b 
                                                    jnz msi_system_call_change_file_dimension_decrease
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_change_file_dimension_end
msi_system_call_change_file_dimension_decrease:     call fsm_selected_file_remove_data_bytes
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_change_file_dimension_error
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_change_file_dimension_end
msi_system_call_change_file_dimension_grow:         mov a,e 
                                                    xri $ff 
                                                    mov e,a 
                                                    mov a,d 
                                                    xri $ff 
                                                    mov d,a 
                                                    mov a,b 
                                                    xri $ff 
                                                    mov b,a 
                                                    mov a,c 
                                                    xri $ff 
                                                    mov c,a 
                                                    mvi a,1 
                                                    add e 
                                                    mov e,a 
                                                    mov a,d 
                                                    aci 0 
                                                    mov d,a 
                                                    mov a,c 
                                                    aci 0 
                                                    mov c,a  
                                                    mov a,b 
                                                    aci 0 
                                                    mov b,a 
                                                    
                                                    call fsm_selected_file_append_data_bytes
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_change_file_dimension_error
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_change_file_dimension_end
msi_system_call_change_file_dimension_error:        stc 
msi_system_call_change_file_dimension_end:          call msi_selected_segment_restore
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_read_file_bytes legge i bytes dal file selezionato e li salva nel segmento di memoria specificato
;A -> ID segmento destinazione 
;DE -> numero di bytes da leggere 
;HL -> offset nel segmento destinazione 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore

msi_system_call_read_file_bytes:                call msi_selected_segment_backup
                                                call fsm_get_selected_file_header_flags
                                                jc msi_system_call_read_file_bytes_end
                                                ani fsm_header_system_bit
                                                jz msi_system_call_read_file_bytes_next 
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_read_file_bytes_next
msi_system_call_read_file_bytes_permerr:        mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_read_file_bytes_end
msi_system_call_read_file_bytes_next:           lda msi_PSW_backup_address+1
                                                call mms_select_low_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_system_call_read_file_bytes_error
                                                ani mms_low_memory_type_segment_mask 
                                                jz msi_system_call_read_file_bytes_permerr
                                                lda msi_PSW_backup_address+1 
                                                lhld msi_DE_backup_address
                                                mov c,l  
                                                mov b,h 
                                                lhld msi_HL_backup_address
                                                call fsm_selected_file_read_bytes
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_read_file_bytes_error
                                                mvi a,msi_operation_ok
                                                stc 
                                                cmc 
                                                jmp msi_system_call_read_file_bytes_end
msi_system_call_read_file_bytes_error:          stc 
msi_system_call_read_file_bytes_end:            call msi_selected_segment_restore
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return

;msi_system_call_write_file_bytes scrive i bytes del segmento di memoria specificato nel file selezionato 
;A -> ID segmento sorgente 
;DE -> numero di bytes da leggere 
;HL -> offset nel segmento sorgente
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore

msi_system_call_write_file_bytes:               call msi_selected_segment_backup
                                                call fsm_get_selected_file_header_flags
                                                jc msi_system_call_write_file_bytes_end
                                                ani fsm_header_system_bit
                                                jz msi_system_call_write_file_bytes_next 
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_write_file_bytes_next
msi_system_call_write_file_bytes_permerr:       mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_write_file_bytes_end
msi_system_call_write_file_bytes_next:          lda msi_PSW_backup_address+1
                                                call mms_select_low_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_system_call_write_file_bytes_error
                                                ani mms_low_memory_type_segment_mask 
                                                jz msi_system_call_write_file_bytes_permerr
                                                lda msi_PSW_backup_address+1 
                                                lhld msi_DE_backup_address
                                                mov c,l  
                                                mov b,h 
                                                lhld msi_HL_backup_address
                                                call fsm_selected_file_write_bytes
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_write_file_bytes_error
                                                mvi a,msi_operation_ok
                                                stc 
                                                cmc 
                                                jmp msi_system_call_write_file_bytes_end
msi_system_call_write_file_bytes_error:         stc 
msi_system_call_write_file_bytes_end:           call msi_selected_segment_restore
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return

;msi_system_call_set_data_pointer imposta il data pointer nel file selezionato 
;DEHL -> offset nel file 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 in caso di errore 
msi_system_call_set_data_pointer:           call msi_selected_segment_backup
                                            call fsm_get_selected_file_header_flags
                                            jc msi_system_call_set_data_pointer_end
                                            ani fsm_header_system_bit
                                            jz msi_system_call_set_data_pointer_next 
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_set_data_pointer_next
                                            mvi a,msi_current_program_permissions_error
                                            stc 
                                            jmp msi_system_call_set_data_pointer_end
msi_system_call_set_data_pointer_next:      lhld msi_DE_backup_address  
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_HL_backup_address
                                            xchg 
                                            call fsm_selected_file_set_data_pointer
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_set_data_pointer_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_set_data_pointer_end
msi_system_call_set_data_pointer_error:     stc 
msi_system_call_set_data_pointer_end:       call msi_selected_segment_restore
                                            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_launch_program sostituisce il programma attualmente caricato con quello desiderato. 
;DE -> nome completo del programma 
;A <- errore generato (se si verifica un errore nell'input il programma riprende la sua esecuzione)
;il programma viene eseguito subito dopo il suo caricamento. In caso di errore nel caricamento, viene richiamata la sheel di default con un errore specificato (exit program)

msi_system_call_launch_program:                 call msi_selected_segment_backup
                                                lhld msi_DE_backup_address
                                                call msi_string_file_copy_and_load
                                                cpi msi_operation_ok
                                                jnz msi_system_call_launch_program_end
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_launch_program_error
                                                call fsm_get_selected_file_header_flags
                                                mov b,a 
                                                ani fsm_header_system_bit
                                                jz msi_system_call_launch_program_next
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_launch_program_next
                                                mvi a,msi_current_program_permissions_error
                                                jmp msi_system_call_launch_program_error
msi_system_call_launch_program_next:            mov a,b 
                                                ani fsm_header_program_bit
                                                jnz msi_system_call_launch_program_next2
                                                mvi a,msi_not_a_program 
                                                jmp msi_system_call_launch_program_error
msi_system_call_launch_program_next2:           lda msi_current_program_flags
                                                ani msi_current_program_loaded
                                                cnz mms_unload_low_memory_program
                                                call fsm_load_selected_program
                                                cpi fsm_operation_ok
                                                jz msi_system_call_launch_program_next3
msi_system_call_launch_program_abort:           mvi a,msi_load_program_error_execution_code 
                                                jmp msi_sheel_startup
msi_system_call_launch_program_next3:           lda msi_current_program_flags
                                                ori msi_current_program_loaded
                                                sta msi_current_program_flags 
                                                call mms_dselect_low_memory_data_segment 
                                                call mms_delete_all_temporary_segments
                                                mvi a,0 
                                                call mms_start_low_memory_loaded_program
                                                mvi a,msi_program_start_error 
                                                jmp msi_sheel_startup
msi_system_call_launch_program_error:           stc 
msi_system_call_launch_program_end:             call msi_selected_segment_restore
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return

;esegue la stessa funzione di msi_system_call_launch_program inviando il messaggio creato precedentemente. Se il messaggio non è stato creato l'applicazione viene lanciata normalmente
;A <- id del segmento da inviare 
;DE -> nome completo del programma 
;A <- errore generato (se si verifica un errore nell'input il programma riprende la sua esecuzione)
;il programma viene eseguito subito dopo il suo caricamento. In caso di errore nel caricamento, viene richiamata la sheel di default con un errore specificato (exit program)

msi_system_call_launch_program_with_message:                call msi_selected_segment_backup
                                                            lhld msi_DE_backup_address
                                                            call msi_string_file_copy_and_load
                                                            cpi msi_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_end
                                                            call fsm_select_file_header
                                                            cpi fsm_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_error
                                                            call fsm_get_selected_file_header_flags
                                                            mov b,a 
                                                            ani fsm_header_system_bit
                                                            jz msi_system_call_launch_program_with_message_next
                                                            lda msi_current_program_flags
                                                            ani msi_current_program_permissions
                                                            jnz msi_system_call_launch_program_with_message_next
                                                            mvi a,msi_current_program_permissions_error
                                                            jmp msi_system_call_launch_program_with_message_error
msi_system_call_launch_program_with_message_next:           mov a,b 
                                                            ani fsm_header_program_bit
                                                            jnz msi_system_call_launch_program_with_message_next2
                                                            mvi a,msi_not_a_program 
                                                            jmp msi_system_call_launch_program_with_message_error
msi_system_call_launch_program_with_message_next2:          lda msi_current_program_flags
                                                            ani msi_current_program_loaded
                                                            cnz mms_unload_low_memory_program
                                                            call fsm_load_selected_program
                                                            cpi fsm_operation_ok
                                                            jz msi_system_call_launch_program_with_message_next3
msi_system_call_launch_program_with_message_abort:          mvi a,msi_load_program_error_execution_code 
                                                            jmp msi_sheel_startup
msi_system_call_launch_program_with_message_next3:          lda msi_current_program_flags
                                                            ori msi_current_program_loaded
                                                            sta msi_current_program_flags 
                                                            
                                                            lda msi_PSW_backup_address+1
                                                            call mms_get_selected_data_segment_flags
                                                            cpi mms_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_share_error 
                                                            ani $ff-mms_low_memory_temporary_segment_mask
                                                            call mms_set_selected_data_segment_flags
                                                            call mms_delete_all_temporary_segments
                                                            call mms_get_selected_data_segment_flags
                                                            cpi mms_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_share_error 
                                                            ori mms_low_memory_temporary_segment_mask
                                                            call mms_set_selected_data_segment_flags
                                                            call mms_dselect_low_memory_data_segment 
                                                            lda msi_PSW_backup_address+1
                                                            call mms_start_low_memory_loaded_program
                                                            mvi a,msi_program_start_error 
                                                            jmp msi_sheel_startup
msi_system_call_launch_program_with_message_share_error:    mvi a,msi_program_message_share_error 
                                                            jmp msi_sheel_startup
msi_system_call_launch_program_with_message_error:          stc 
msi_system_call_launch_program_with_message_end:            call msi_selected_segment_restore
                                                            lhld msi_BC_backup_address
                                                            mov c,l 
                                                            mov b,h 
                                                            lhld msi_DE_backup_address
                                                            xchg 
                                                            lhld msi_HL_backup_address  
                                                            jmp msi_system_calls_return
;msi_system_call_exit_program chiude il programma attualmente in esecuzione e ritorna alla sheel del sistema restituiendo un codice di esecuzione 
;A -> codice di esecuzione 

msi_system_call_exit_program:           call mms_unload_low_memory_program
                                        call mms_delete_all_temporary_segments
                                        lda msi_PSW_backup_address+1 
                                        stc 
                                        cmc 
                                        jmp msi_sheel_startup

;------ Sheel di sistema ------
;La sheel di sistema è la parte interattiva del sistema operativo. è basata su un sistema a linea di comando, dove l'utente può inserire i camoandi che il sistema deve eseguire. 
;L'interfaccia prevede una serie di comandi tra cui:
;-  COPY "sorgente" "destinazione"  -> copia il file desiderato 
;-  DELETE "file" -> elimina il file desiderato
;-  RENAME "file" -> rinomina il file desiderato
;-  ERASE -> elimina tutti i file nella directory 
;-  MEM -> stampa in numero di bytes disponibili nella RAM
;-  LIST -> stampa tutti i file presenti nel disco selezionato
;-  VER -> restituisce la versione del sistema operativo
;-  ECHO "stringa" -> stampa la stringa 
;-  CHANGE -> cambia il disco attualmente selezionato
;-  DEVICES -> stampa la lista dei dispositivi IO disponibili 

msi_sheel_default_disk              .equ    reserved_memory_start+$005f 
msi_sheel_input_buffer_id           .equ    reserved_memory_start+$0060 
msi_sheel_input_buffer_head         .equ    reserved_memory_start+$0061
msi_sheel_console_input_port        .equ    reserved_memory_start+$0062 
msi_sheel_console_output_port       .equ    reserved_memory_start+$0063 

msi_sheel_input_buffer_dimension    .equ 64     ;(max 256)

msi_input_buffer_overflow           .equ msi_execution_code_mark+$20 

msi_sheel_load_program_error_message    .text "Failed to load program"
                                        .b $0d, $0 
msi_sheel_start_program_error_message   .text "Falied to start program"
                                        .b $0d, $0 
msi_sheel_error_code_received_message   .text "Program exited with code: "
                                        .b $0 
msi_sheel_arrow:                        .text ":/> "

msi_sheel_startup:                  push psw 
                                    mvi a,$03 
                                    out 21  
                                    lxi b,$ffff 
                                    push b 
                                    lxi b,$FFFF
                                    push b 
                                    lxi b,$1111 
                                    lxi d,$2222 
                                    lxi h,$3333
                                    call unsigned_convert_hex_bcd_long 
                                    pop h 
                                    pop d 
                                    pop b 
                                    hlt 

                                    xra a  
                                    sta msi_sheel_input_buffer_id
                                    sta msi_sheel_input_buffer_head 
                                    sta msi_sheel_console_input_port
                                    mvi b,$41 
msi_sheel_start_disk_search:        mov a,b 
                                    call fsm_select_disk
                                    cpi fsm_operation_ok
                                    jz msi_sheel_start_disk_search_end 
                                    inr b 
                                    mvi a,$5A 
                                    cmp b 
                                    jnz msi_sheel_start_disk_search
                                    mvi a,0 
                                    sta msi_sheel_default_disk 
msi_sheel_start_disk_search_end:    pop psw
                                    hlt 

;msi_sheel_create_input_buffer crea il buffer che verrà utilizzato per memorizzare temporaneamente l'input da console 
;A <- esito dell'operazione 
msi_sheel_create_input_buffer:      push h 
                                    lxi h,msi_sheel_input_buffer_dimension
                                    mvi a,mms_low_memory_valid_segment_mask+mms_low_memory_temporary_segment_mask
                                    call mms_create_low_memory_data_segment
                                    pop h 
                                    rc 
                                    sta msi_sheel_input_buffer_id
                                    mvi a,msi_operation_ok
                                    ret 

;msi_sheel_send_console_byte invia un byte alla console 
;A -> byte da inviare 
;A <- esito dell'operazione
msi_sheel_send_console_byte:            push psw 
                                        lda msi_sheel_console_output_port
                                        call bios_select_IO_device
                                        cpi bios_operation_ok
                                        jz msi_sheel_send_console_byte_wait 
                                        inx sp 
                                        inx sp 
                                        ret 
msi_sheel_send_console_byte_wait:       call bios_get_selected_device_state
                                        ani bios_IO_device_output_byte_ready
                                        jz msi_sheel_send_console_byte_wait
                                        pop psw 
                                        call bios_write_selected_device_byte
                                        rc 
                                        mvi a,msi_operation_ok
                                        ret 

;msi_sheel_send_string_console stampa la stringa desiderata
;HL -> puntatore alla stringa 
msi_sheel_send_string_console:          push h 
                                        lda msi_sheel_console_output_port
                                        call bios_select_IO_device
                                        cpi bios_operation_ok
                                        jnz msi_sheel_send_string_console_end
msi_sheel_send_string_console_loop:     mov a,m 
                                        inx h 
                                        ora a 
                                        jz msi_sheel_send_string_console_loop_end                            
msi_sheel_send_string_console_loop2:    call bios_get_selected_device_state
                                        ani bios_IO_device_output_byte_ready
                                        jz msi_sheel_send_string_console_loop2                  
                                        mov a,m 
                                        call bios_write_selected_device_byte
                                        jc msi_sheel_send_string_console_end
                                        jmp msi_sheel_send_string_console_loop2
msi_sheel_send_string_console_loop_end: mvi a,msi_operation_ok
msi_sheel_send_string_console_end:      pop h 
                                        ret 

;msi_get_console_input_buffer_byte legge un byte dalla console e lo inserisce nel buffer  
;A <- byte letto (se CY=1 restituisce un errore)
msi_get_console_input_buffer_byte:          push h
                                            lda msi_sheel_console_input_port
                                            call bios_select_IO_device
                                            cpi bios_operation_ok
                                            jnz msi_get_console_input_buffer_byte
                                            lda msi_sheel_input_buffer_id
                                            call mms_select_low_memory_data_segment
                                            cpi mms_operation_ok
                                            jnz msi_get_console_input_buffer_byte
                                            lda msi_sheel_input_buffer_head
                                            lxi h,0 
                                            mov l,a 
msi_get_console_input_buffer_byte_loop:     call bios_get_selected_device_state
                                            ani bios_IO_device_input_byte_ready
                                            jz msi_get_console_input_buffer_byte_loop
                                            call bios_read_selected_device_byte
                                            jc msi_get_console_input_buffer_byte_end
                                            call mms_write_selected_data_segment_byte
                                            jc msi_get_console_input_buffer_byte_end
                                            inx h 
                                            push psw 
                                            mov a,l 
                                            sta msi_sheel_input_buffer_head
                                            pop psw 
                                            stc 
                                            cmc 
                                            pop h 
                                            ret 
msi_get_console_input_buffer_byte_end:      stc 
                                            pop h 
                                            ret 

;msi_read_input_buffer_byte legge un byte dal buffer input 
;A -> posizione nel buffer 
;A <- byte letto (se CY=1 restituisce un errore)
msi_read_input_buffer_byte:             push h 
                                        lxi h,0 
                                        mov l,a 
                                        lda msi_sheel_input_buffer_id
                                        call mms_select_low_memory_data_segment
                                        cpi mms_operation_ok
                                        jz msi_read_input_buffer_byte_next
                                        stc 
                                        jmp msi_read_input_buffer_byte_end
msi_read_input_buffer_byte_next:        lda msi_sheel_input_buffer_head
                                        sub l 
                                        jz msi_read_input_buffer_byte_overflow
                                        jnc msi_read_input_buffer_byte_next2
msi_read_input_buffer_byte_overflow:    mvi a,msi_input_buffer_overflow 
                                        stc 
                                        jmp msi_read_input_buffer_byte_end
msi_read_input_buffer_byte_next2:       call mms_read_selected_data_segment_byte
msi_read_input_buffer_byte_end:         pop h 
                                        ret 

;msi_sheel_ascii_character verifica se il carattere è stampabile 
;A -> carattere da verificare 
;PSW <- se è stampabile CY=0, C=1 altrimenti

msi_sheel_ascii_character:          cpi $20 
                                    rc 
                                    cpi $7e 
                                    cmc 
                                    ret                  




MSI_layer_end:
.print "Space left in MSI layer ->",MSI_dimension-MSI_layer_end+MSI 
.memory "fill", MSI_layer_end, MSI_dimension-MSI_layer_end+MSI,$00

.print "MSI load address ->",MSI 
.print "All functions built successfully"
.print "System calls number -> ",(msi_system_calls_id_table_end-msi_system_calls_id_table)/2