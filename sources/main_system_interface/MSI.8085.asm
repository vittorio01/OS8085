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

;una volta avviato, il sistema lancia automaticamente la shell integrata nella MSI, che permetterà all'utente di accedere ad un'interfaccia basilare a linea di comando

;----- sistema a passaggio di messaggi -----
;Ogni applicazione al suo avvio ha i registri azzerati e lo stack pointer preimostato alla fine del program space (vedi mms). 

;Prima dell'avvio dell'applicazione il segmento utilizzato per lo scambio dei messaggi viene automaticamente selezionato dalla mms. Di conseguenza, un'applicazione, per leggere 
;il messaggio, può utilizzare le system calls dedicate alla gestione dei segmenti della memoria. 

;Se un'applicazione viene avviata dalla shell di sistema riceve  un messaggio contenente il comando intero in caratteri ASCII.

;Quando la shell termina a sua esecuzione, il sistema attende lo spegnimento stampando in output il messaggio di chiusura del sistema.

;una volta chiusa l'applicazione destinataria, il messaggio viene automaticamente cancellato.

;Un'applicazione può creare solamente un messaggio e lo può inviare tramite le system calls quando richiede l'avvio di un applicazione.

;----- permessi dell'applicazione -----
;LA MSI si occupa di avviare correttamente le applicazioni. In particolare, a seconda del loro tipo, le applicazioni possono essere di sistema o utente (l'unica cosa che varia sono i permessi di accesso alle system calls):
;-  un'applicazione di sistema può accedere a tutte le system calls e avviare applicaioni di qualsiasi tipo 
;-  un'applicazione non di sistema può accedere solo a un numero ristretto di system calls e avviare applicazioni di tipo utente 
; Viene utilizzata quindi una flag salvata in memoria per tenere traccia del tipo di applicazione in esecuzione.

;----- errori nelle system calls -----
;Quando alla chiamata di una system call si verifica un errore, la MSI restituisce un esito negativo all'applicazione che ha rischiesto la system call con la flag CY settata a 1

;----- gestione dei diespositivi I/O -----
;I dispositivi I/O non possono essere gestiti in modo efficace tramite un sistema di drivers a causa delle limitate funzionalità del processore. Tuttavia, possono essere utilizzate le system calls 
;Per richiedere l'accesso ai dispositivi I/O registrati nel BIOS come l'input o l'output da console o altro:
;- Un'applicazione normale può accedere alle funzioni della console e ai dispositivi secondari registrati nel BIOS 
;- Un'applicazione di sistema può accedere alle funzioni di tutti i dispositivi, comprese quelle delle memorie di massa (questo per eseguire alcune applicazioni di ottimizzazione del filesystem come deframmentazione o pulizia)

;I dispositivi I/O vengono selezionati tramite un identificativo attraverso una system call rst1. Per leggere o scrivere sul dispositivo vengono utilizzate 
;le system calls  separate rst2 (per l'input), rst3 (per l'output), rst4 (ricevere il byte di status), rst5 (inviare un byte di impostazioni). 
;Tramite le system calls rst1 è possibile ricevere l'identificativo di un dispositivo (4 bytes ASCII) o selezionarlo per predisporlo all'utilizzo degli interrupts dedicati.

;----- interrupts hardware -----
;Tutti gli interrupts hardware vengono direzionati direttamente al BIOS, che avrà il compito di gestirli. 
;Nel caso di un processore intel 8085, tutti i tipi di interrupt fanno capo allo stesso handler, mentre nel caso di un processore Z80 viene gestito unicamente l'interrupt MODE1 di default. 

.include "os_constraints.8085.asm"
.include "bios_system_calls.8085.asm"
.include "mms_system_calls.8085.asm"
.include "fsm_system_calls.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "environment_variables.8085.asm"

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

MSI_rst0_interrupt:             .org rst0_address 
                                jmp msi_system_start
MSI_rst1_interrupt:             .org rst1_address
                                jmp msi_main_system_calls_handler
MSI_rst2_interrupt:             .org rst2_address
                                jmp msi_IO_write_system_call_handler
MSI_rst3_interrupt:             .org rst3_address
                                jmp msi_IO_read_system_call_handler
MSI_rst4_interrupt:             .org rst4_address
                                jmp msi_IO_get_state_system_call_handler
MSI_trap_interrupt:             .org I8085_trap_address
                                jmp bios_hardware_interrupt_handler             
MSI_rst5_interrupt:             .org rst5_address
                                jmp bios_hardware_interrupt_handler
MSI_rst6_interrupt:             .org rst6_address
                                jmp bios_hardware_interrupt_handler 
MSI_rst65_interrupt:            .org I8085_rst65_address 
                                jmp bios_hardware_interrupt_handler
MSI_int_interrupt:              .org Z80_int_address
                                jmp bios_hardware_interrupt_handler
MSI_rst75_address:              .org I8085_rst75_address 
                                jmp bios_hardware_interrupt_handler 
;per rendere più efficace la ricerca della system call desiderata viene utilizzata una tabella in cui ogni record da 2 bytes identifica l'indirizzo dell'handler dedcato (la posizione identifica l'handler)

msi_system_calls_id_table:      .org MSI
                                .word msi_system_call_select_IO_device 
                                .word msi_system_call_get_IO_device_informations 
                                .word msi_system_call_disk_device_select_sector 
                                .word msi_system_call_disk_device_select_track 
                                .word msi_system_call_disk_device_select_head 
                                .word msi_system_call_disk_device_status 
                                .word msi_system_call_disk_device_get_bps 
                                .word msi_system_call_disk_device_get_spt 
                                .word msi_system_call_disk_device_get_tph 
                                .word msi_system_call_disk_device_get_head_number 
                                .word msi_system_call_disk_device_write_sector 
                                .word msi_system_call_disk_device_read_sector 
                                .word msi_system_call_disk_device_format
                                .word msi_system_call_disk_device_set_motor

                                .word msi_system_call_get_free_ram_bytes  
                                .word msi_system_call_create_temporary_memory_segment
                                .word msi_system_call_delete_temporary_memory_segment 
                                .word msi_system_call_select_temporary_memory_segment 
                                .word msi_system_call_read_temporary_segment_byte 
                                .word msi_system_call_write_temporary_segment_byte 
                                .word msi_system_call_read_temporary_segment_dimension 
                                .word msi_system_call_get_current_program_dimension 
                                .word msi_system_call_get_selected_data_segment_dimension

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
                                .word msi_system_call_rename_file

                                .word msi_system_call_get_file_name 
                                .word msi_system_call_get_file_dimension 
                                .word msi_system_call_get_file_system_flag_state
                                .word msi_system_call_get_file_readonly_flag_state
                                .word msi_system_call_get_file_hidden_flag_state
                                .word msi_system_call_set_file_system_flag
                                .word msi_system_call_set_file_readonly_flag 
                                .word msi_system_call_set_file_hidden_flag     

                                .word msi_system_call_change_file_dimension 
                                .word msi_system_call_set_data_pointer 
                                .word msi_system_call_read_file_bytes 
                                .word msi_system_call_write_file_bytes 
                                
                                .word msi_system_call_launch_program
                                .word msi_system_call_launch_program_with_message 
                                .word msi_system_call_exit_program

                                .word msi_system_call_get_os_version 
                            

msi_system_calls_id_table_end:  

msi_shell_program_extension                 .text ".run"
msi_shell_program_extension_dimension       .equ 4 

;msi_system_start si occupa di eseguire il warm reset
msi_system_start:                   lxi sp,stack_memory_start
                                    
                                    call bios_system_start 
                                    call mms_high_memory_initialize 
                                    call fsm_init 
                                    mvi a,0 
                                    sta msi_current_program_flags
                                    
                                    jmp msi_shell_startup 
                                     

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
                                        call msi_selected_segment_backup
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

msi_system_calls_return:                    call msi_selected_segment_restore
                                            shld msi_HL_backup_address
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
                                        call mms_select_high_memory_data_segment
                                        pop psw 
                                        ret 
msi_selected_segment_restore_deselect:  call mms_dselect_high_memory_data_segment
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
;PSW    <- CY viene settato ad 1 se si è verificato un errore.
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

;msi_IO_get_state_system_call_handler viene richiamata tramite l'interrupt rst4 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è verificato un errore.
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce lo stato del dispositivo IO

msi_IO_set_state_system_call_handler:       shld msi_HL_backup_address
                                            pop h 
                                            shld msi_PC_backup_address
                                            lxi h,0 
                                            dad sp 
                                            shld msi_SP_backup_address
                                            lxi sp,stack_memory_start
                                            call bios_set_selected_device_state
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return 

;msi_IO_get_state_system_call_handler viene richiamata tramite l'interrupt rst5 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è verificato un errore.
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce lo stato del dispositivo IO

msi_IO_initialize_system_call_handler:      shld msi_HL_backup_address
                                            pop h 
                                            shld msi_PC_backup_address
                                            lxi h,0 
                                            dad sp 
                                            shld msi_SP_backup_address
                                            lxi sp,stack_memory_start
                                            call bios_initialize_selected_device 
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
;A <- se CY = 1 restituisce l'errore generato
;SP <- se CY = 0 restituisce i 4 bytes dell'identificativo
msi_system_call_get_IO_device_informations:         lda msi_PSW_backup_address+1
                                                    call bios_get_IO_device_informations
                                                    jc msi_system_call_get_IO_device_informations_end
                                                    mvi b,4
                                                    lhld msi_SP_backup_address
                                                    mov a,l 
                                                    sub b 
                                                    mov l,a 
                                                    mov a,h 
                                                    sbi 0 
                                                    mov h,a 
                                                    shld msi_SP_backup_address
                                                    xchg 
                                                    lxi h,0 
                                                    dad sp 
msi_system_call_get_IO_device_informations_copy:    mov a,m 
                                                    stax d  
                                                    inx d 
                                                    inx h 
                                                    dcr b 
                                                    jnz msi_system_call_get_IO_device_informations_copy
                                                    mvi a,bios_operation_ok
                                                    stc 
                                                    cmc 
msi_system_call_get_IO_device_informations_end:     lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_select_sector permette di selezonare un settore nella memoria di massa selezionata
; A -> numero di settore 
; A <- esito dell'operazione 
; PSW <- se si è verificato un errore CY viene settato ad 1 

msi_system_call_disk_device_select_sector:          lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_select_sector_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_select_sector_end
msi_system_call_disk_device_select_sector_next:     lda msi_PSW_backup_address+1
                                                    call bios_disk_device_select_sector
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_disk_device_select_sector_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_disk_device_select_sector_end:      lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_select_head permette di selezonare la testina nella memoria di massa selezionata
; A -> numero di testina
; A <- esito dell'operazione 
; PSW <- se si è verificato un errore CY viene settato ad 1 

msi_system_call_disk_device_select_head:            lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_select_head_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_select_head_end
msi_system_call_disk_device_select_head_next:       lda msi_PSW_backup_address+1
                                                    call bios_disk_device_select_head
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_disk_device_select_head_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_disk_device_select_head_end:        lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_select_track permette di selezionare la traccia nella memoria di massa selezionata 
;HL -> numero di traccia 
;A <- esito dell'operazione 
;PSW <- Csi si è verificato un errore CY viene settato ad 1 

msi_system_call_disk_device_select_track:           lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_select_track_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_select_track_end
msi_system_call_disk_device_select_track_next:      lhld msi_HL_backup_address
                                                    call bios_disk_device_select_track 
                                                    cpi bios_operation_ok
                                                    stc 
                                                    jnz msi_system_call_disk_device_select_track_end
                                                    cmc 
                                                    mvi a,msi_operation_ok
msi_system_call_disk_device_select_track_end:       lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_status restituisce lo stato corrente della memoria di massa selezionata 
;PSW <- CY viene settata ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce lo stato corrente del dispositivo 

msi_system_call_disk_device_status:                 lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_status_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_status_end
msi_system_call_disk_device_status_next:            call bios_disk_device_status
msi_system_call_disk_device_status_end:             lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_get_bps restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di bytes per settore in multipli di 128b 

msi_system_call_disk_device_get_bps:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_get_bps_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_get_bps_end
msi_system_call_disk_device_get_bps_next:           call bios_disk_device_get_bps
msi_system_call_disk_device_get_bps_end:            lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_get_spt restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituiscel'errore generato, altrimenti restituisce il numero di settori per traccia

msi_system_call_disk_device_get_spt:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_get_spt_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_get_spt_end
msi_system_call_disk_device_get_spt_next:           call bios_disk_device_get_spt 
msi_system_call_disk_device_get_spt_end:            lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_get_spt restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di tracce per settori in multipli di 128b 
;HL <- assume 0 se CY=1, altrimenti restituisce il numero di tracce per testina 

msi_system_call_disk_device_get_tph:                lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_get_tph_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    lxi h,0
                                                    jmp msi_system_call_disk_device_get_tph_end
msi_system_call_disk_device_get_tph_next:           call bios_disk_device_get_tph
msi_system_call_disk_device_get_tph_end:            xchg 
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_get_head_number restituisce il numero di settori per traccia della memoria di massa selezionata 
;PSW <- CY viene settato ad 1 se si è verificato un errore 
;A <- se CY=1 restituisce l'errore generato, altrimenti restituisce il numero di testine del dispositivo

msi_system_call_disk_device_get_head_number:        lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_get_head_number_next
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_get_head_number_end
msi_system_call_disk_device_get_head_number_next:   call bios_disk_device_get_head_number
msi_system_call_disk_device_get_head_number_end:    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return 

;msi_system_call_disk_device_write_sector scrive nel settore della memoria di massa i dati precedenti nel segmento di memoria selezionato 
;HL -> offset nel segmento 
;A <- esito dell'operazione 
;PSW <- CY viene settata ad 1 se si è verificato un errore
;HL <- offset nel segmento dopo l'operazione 

msi_system_call_disk_device_write_sector:           lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_write_sector_next 
msi_system_call_disk_device_write_sector_perm_err:  lhld msi_HL_backup_address
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_write_sector_end 
msi_system_call_disk_device_write_sector_next:      call mms_get_selected_segment_ID
                                                    jnz msi_system_call_disk_device_write_sector_perm_err
                                                    lhld msi_HL_backup_address
                                                    call mms_disk_device_write_sector
                                                    cpi mms_operation_ok
                                                    jnz msi_system_call_disk_device_write_sector_error 
                                                    stc 
                                                    cmc 
                                                    mvi a,msi_operation_ok
                                                    jmp msi_system_call_disk_device_write_sector_end 
msi_system_call_disk_device_write_sector_error:     stc 
                                                    lhld msi_HL_backup_address
msi_system_call_disk_device_write_sector_end:       xchg 
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    jmp msi_system_calls_return

;msi_system_call_disk_device_read_sector legge dal settore della memoria di massa i dati e li salva nel segmento di memoria selezionato 
;HL -> offset nel segmento 
;A <- esito dell'operazione 
;PSW <- CY viene settata ad 1 se si è verificato un errore
;HL <- offset nel segmento dopo l'operazione  
msi_system_call_disk_device_read_sector:            lda msi_current_program_flags
                                                    ani msi_current_program_permissions
                                                    jnz msi_system_call_disk_device_read_sector_next 
msi_system_call_disk_device_read_sector_perm_err:   lhld msi_HL_backup_address
                                                    xchg 
                                                    mvi a,msi_current_program_permissions_error 
                                                    stc 
                                                    jmp msi_system_call_disk_device_read_sector_end 
msi_system_call_disk_device_read_sector_next:       call mms_get_selected_segment_ID
                                                    
                                                    jnz msi_system_call_disk_device_read_sector_perm_err
                                                    lhld msi_DE_backup_address
                                                    call mms_disk_device_read_sector
                                                    cpi mms_operation_ok
                                                    jnz msi_system_call_disk_device_read_sector_error 
                                                    stc 
                                                    cmc 
                                                    mvi a,msi_operation_ok
                                                    jmp msi_system_call_disk_device_read_sector_end 
msi_system_call_disk_device_read_sector_error:      stc 
                                                    lhld msi_HL_backup_address
msi_system_call_disk_device_read_sector_end:        xchg 
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    jmp msi_system_calls_return

;msi_system_call_disk_device_format esegue la formattazione hardware al disco selezionato 
;A <- esito dell'operazione 
;PSW <- se si è verificato un errore CY viene settato a 1 
msi_system_call_disk_device_format:         lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_disk_device_format_next 
                                            mvi a,msi_current_program_permissions_error
                                            stc 
                                            jmp msi_system_call_disk_device_format_end
msi_system_call_disk_device_format_next:    call fsm_deselect_disk 
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_disk_device_format_error
                                            call bios_disk_device_format_drive 
                                            cpi bios_operation_ok
                                            jnz msi_system_call_disk_device_format_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_disk_device_format_end
msi_system_call_disk_device_format_error:   stc 
msi_system_call_disk_device_format_end:     lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return 

;msi_system_call_disk_device_set_motor modifica lo stato del motore della memoria di massa 
;A -> $00 per disabilitare il motore, altro per abilitarlo 
;A <- esito dell'operazione 
msi_system_call_disk_device_set_motor:      lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_disk_device_set_motor_next 
                                            mvi a,msi_current_program_permissions_error 
                                            jmp msi_system_call_disk_device_set_motor_end
msi_system_call_disk_device_set_motor_next: call bios_disk_device_set_motor 
msi_system_call_disk_device_set_motor_end:  lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return 

;msi_system_call_get_free_ram_bytes restituisce il numero di bytes disponibili nella RAM 
;HL <- bytes disponibili 
msi_system_call_get_free_ram_bytes:             call mms_free_high_ram_bytes
                                                xchg 
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_PSW_backup_address
                                                push h 
                                                pop psw 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                jmp msi_system_calls_return

;msi_system_call_get_current_program_dimension restituisce la dimensione del programma caricato attualmente in memoria 
;DE <- bytes occupati dal programma attualmente in esecuzione (restituisce 0 se non è stato caricato un programma)
msi_system_call_get_current_program_dimension:  call mms_get_high_memory_program_dimension
                                                xchg 
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_PSW_backup_address
                                                push h 
                                                pop psw 
                                                lhld msi_HL_backup_address
                                                jmp msi_system_calls_return

;msi_system_call_get_selected_data_segment_dimension restituisce la dimensione del segmento di memoria attualmente selezionato
;DE <- bytes occupati dal programma attualmente in esecuzione (restituisce 0 se il segmento non è stato selezionato)

msi_system_call_get_selected_data_segment_dimension:    call mms_get_selected_data_segment_dimension
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
;HL -> dimensione del segmento da creare 
msi_system_call_create_temporary_memory_segment:        lhld msi_HL_backup_address
                                                        call mms_create_high_memory_data_segment
                                                        jc msi_system_call_create_temporary_memory_segment_end 
                                                        call mms_set_selected_data_segment_temporary_flag
                                                        cpi mms_operation_ok
                                                        jnz msi_system_call_create_temporary_memory_segment_end
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
msi_system_call_delete_temporary_memory_segment:        call mms_get_selected_data_segment_type_flag_status
                                                        jc msi_system_call_delete_temporary_memory_segment_end
                                                        ora a 
                                                        jz msi_system_call_delete_temporary_memory_segment_next
                                                        mvi a,msi_current_program_permissions_error
                                                        stc 
                                                        jmp msi_system_call_delete_temporary_memory_segment_end 
msi_system_call_delete_temporary_memory_segment_next:   call mms_delete_selected_high_memory_data_segment
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
                                                        call mms_select_high_memory_data_segment
                                                        cpi mms_operation_ok
                                                        jnz msi_system_call_select_temporary_memory_segment_error 
                                                        call mms_get_selected_data_segment_type_flag_status
                                                        ora a
                                                        jz msi_system_call_select_temporary_memory_segment_next
                                                        mvi a,msi_current_program_permissions_error
                                                        stc 
                                                        jmp msi_system_call_select_temporary_memory_segment_end
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
                                                        shld msi_HL_backup_address
                                                        lhld msi_SP_backup_address
                                                        sphl 
                                                        lhld msi_PC_backup_address
                                                        push h 
                                                        lhld msi_HL_backup_address
                                                        ret 

;msi_system_call_read_temporary_segment_dimension restituisce la dimensione del segmento di memoria selezionato 
;DE <- dimensione del segmento (ritorna 0 se non è stato selezionato nessun segmento)
;A <- esito dell'operazione
;PSW <- CY viene settato ad 1 se si è verificato un errore 
msi_system_call_read_temporary_segment_dimension:       call mms_get_selected_data_segment_type_flag_status
                                                        jc msi_system_call_read_temporary_segment_dimension_end
                                                        ora a 
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
;HL -> offset nel segmento 
;A <- byte letto (se CY viene settato a 1 restituisce l'errore generato)
;PSW <- se si è verificato un errore nella lettura CY viene settato a 1

msi_system_call_read_temporary_segment_byte:        lhld msi_HL_backup_address 
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
;HL -> offset nel segmento 
;A <- se CY viene settato a 1 viene restituito l'errore generato (altrimenti rimane invariato)
;PSW <- se si è verificato un errore nella lettura CY viene settato a 1

msi_system_call_write_temporary_segment_byte:       lda msi_PSW_backup_address+1
                                                    lhld msi_HL_backup_address 
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
      
msi_system_call_select_disk:        lda msi_PSW_backup_address+1 
                                    call fsm_select_disk
                                    cpi fsm_operation_ok    
                                    jnz msi_system_call_select_disk_error
                                    stc 
                                    cmc 
                                    mvi a,fsm_operation_ok
                                    jmp msi_system_call_select_disk_end
msi_system_call_select_disk_error:  stc 
msi_system_call_select_disk_end:    lhld msi_BC_backup_address
                                    mov c,l 
                                    mov b,h 
                                    lhld msi_DE_backup_address
                                    xchg 
                                    lhld msi_HL_backup_address  
                                    jmp msi_system_calls_return

;msi_system_call_get_disk_format_type restituisce il tipo di formattazione del disco 
;A <- codice di formattazione 
;PSW <- se si è verificato un errore CY viene settato a 1 
msi_system_call_get_disk_format_type:   call fsm_get_disk_format_type 
                                        
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
msi_system_call_wipe_disk:          lda msi_PSW_backup_address+1 
                                    call fsm_wipe_disk
                                    cpi fsm_operation_ok
                                    jnz msi_system_call_wipe_disk_error
                                    stc 
                                    cmc 
                                    mvi a,fsm_operation_ok
                                    jmp msi_system_call_wipe_disk_end
msi_system_call_wipe_disk_error:    stc 
msi_system_call_wipe_disk_end:      lhld msi_BC_backup_address
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


msi_system_call_set_disk_name:                          lhld msi_DE_backup_address
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
msi_system_call_set_disk_name_end:                      lhld msi_BC_backup_address
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

msi_system_call_get_disk_name:          call fsm_disk_get_name 
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
msi_system_call_get_disk_name_end:      lhld msi_BC_backup_address
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
msi_system_call_get_disk_free_space:        call fsm_disk_get_free_space
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_disk_free_space_error
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return
msi_system_call_get_disk_free_space_error:  stc 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_search_file verifica se il file esiste all'interno del disco selezionato 
;DE -> puntatore nome completo del file. Il nome completo è una stringa di caratteri ASCII terminata dal carattere $00 in cui nome ed estensione sono separati da un punto . (l'estensione è facoltativa)

;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore nell'esecuzione

msi_system_call_search_file:                lhld msi_DE_backup_address
                                            mov c,l 
                                            mov b,h 
                                            call fsm_search_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_search_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_search_file_end
msi_system_call_search_file_error:          stc  
msi_system_call_search_file_end:            lhld msi_BC_backup_address
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
msi_system_call_select_file:                lhld msi_DE_backup_address
                                            mov c,l 
                                            mov b,h 
                                            call fsm_select_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_select_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_select_file_end
msi_system_call_select_file_error:          stc  
msi_system_call_select_file_end:            lhld msi_BC_backup_address
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
msi_system_call_create_file:                lhld msi_DE_backup_address
                                            mov c,l 
                                            mov b,h 
                                            call fsm_create_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_create_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_create_file_end
msi_system_call_create_file_error:          stc  
msi_system_call_create_file_end:            lhld msi_BC_backup_address
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
msi_system_call_get_file_name:              call fsm_get_selected_file_header_name 
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_file_name_end
                                            lxi h,0 
                                            dad sp
                                            mvi b,0  
msi_system_call_get_file_name_count:        inr b
                                            mov a,m 
                                            inx h 
                                            ora a 
                                            jnz msi_system_call_get_file_name_count
                                            lxi h,0 
                                            dad sp 
                                            xchg 
                                            lhld msi_SP_backup_address
                                            mov a,l 
                                            sub b 
                                            mov l,a 
                                            mov a,h 
                                            sbi 0 
                                            mov h,a 
                                            shld msi_SP_backup_address
msi_system_call_get_file_name_copy:         ldax d 
                                            mov m,a 
                                            inx d 
                                            inx h 
                                            dcr b 
                                            jnz msi_system_call_get_file_name_copy
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
msi_system_call_get_file_name_end:          lhld msi_BC_backup_address
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
msi_system_call_get_file_dimension:         call fsm_get_selected_file_header_dimension
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_get_file_dimension_error
                                            stc 
                                            cmc 
                                            mvi a,msi_operation_ok
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return
msi_system_call_get_file_dimension_error:   stc 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_get_file_system_flag_state verifica se il file è di sistema 
;A <- $ff se è di sistema $00 altrimenti 
;     se CY=1 restituisce un errore 
msi_system_call_get_file_system_flag_state:         call fsm_get_selected_file_header_system_flag_status 
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_get_file_readonly_flag_state verifica se il file è di sola lettura
;A <- $ff se è di sola lettura $00 altrimenti 
;     se CY=1 restituisce un errore
msi_system_call_get_file_readonly_flag_state:       call fsm_get_selected_file_header_readonly_flag_status
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_get_file_hidden_flag_state verifica se il file è nascosto
;A <- $ff se è nascosto $00 altrimenti 
;     se CY=1 restituisce un errore
msi_system_call_get_file_hidden_flag_state:         call fsm_get_selected_file_header_hidden_flag_status
                                                    lhld msi_BC_backup_address
                                                    mov c,l 
                                                    mov b,h 
                                                    lhld msi_DE_backup_address
                                                    xchg 
                                                    lhld msi_HL_backup_address  
                                                    jmp msi_system_calls_return

;msi_system_call_set_file_system_flag modifica la flag "sistema" del file
;A -> $00 se il file non deve essere di sistema, $ff altrimenti 
;A <- esito dell'operazione. Se CY=1 restituisce un errore 
msi_system_call_set_file_system_flag:       lda msi_current_program_flags
                                            ani msi_current_program_permissions
                                            jnz msi_system_call_set_file_system_flag_next
                                            mvi a,msi_current_program_permissions_error
                                            stc 
                                            jmp msi_system_call_set_file_system_flag_end
msi_system_call_set_file_system_flag_next:  lda msi_PSW_backup_address+1 
                                            call fsm_set_selected_file_header_system_flag
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_set_file_system_flag_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            call msi_system_call_set_file_system_flag_end
msi_system_call_set_file_system_flag_error: stc 
msi_system_call_set_file_system_flag_end:   lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_set_file_system_flag modifica la flag "sola lettura" del file
;A -> $00 se il file non deve essere di sola lettura, $ff altrimenti 
;A <- esito dell'operazione. Se CY=1 restituisce un errore 
msi_system_call_set_file_readonly_flag:         call fsm_get_selected_file_header_system_flag_status
                                                jc msi_system_call_set_file_readonly_flag_end
                                                ora a 
                                                jz msi_system_call_set_file_readonly_flag_next
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_set_file_readonly_flag_next
                                                mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_set_file_readonly_flag_end
msi_system_call_set_file_readonly_flag_next:    lda msi_PSW_backup_address+1 
                                                call fsm_set_selected_file_header_readonly_flag
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_set_file_readonly_flag_error
                                                mvi a,msi_operation_ok
                                                stc 
                                                cmc 
                                                call msi_system_call_set_file_readonly_flag_end
msi_system_call_set_file_readonly_flag_error:   stc 
msi_system_call_set_file_readonly_flag_end:     lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return

;msi_system_call_set_file_system_flag modifica la flag "nascosto" del file
;A -> $00 se il file non deve essere nascosto, $ff altrimenti 
;A <- esito dell'operazione. Se CY=1 restituisce un errore 
msi_system_call_set_file_hidden_flag:           call fsm_get_selected_file_header_system_flag_status
                                                jc msi_system_call_set_file_hidden_flag_end
                                                ora a 
                                                jz msi_system_call_set_file_hidden_flag_next
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_set_file_hidden_flag_next
                                                mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_set_file_hidden_flag_end
msi_system_call_set_file_hidden_flag_next:      lda msi_PSW_backup_address+1 
                                                call fsm_set_selected_file_header_hidden_flag
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_set_file_hidden_flag_error
                                                mvi a,msi_operation_ok
                                                stc 
                                                cmc 
                                                call msi_system_call_set_file_hidden_flag_end
msi_system_call_set_file_hidden_flag_error:     stc 
msi_system_call_set_file_hidden_flag_end:       lhld msi_BC_backup_address
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
msi_system_call_rename_file:                call fsm_get_selected_file_header_system_flag_status
                                            jc msi_system_call_rename_file_end
                                            ora a 
                                            jz msi_system_call_rename_file_next 
                                            lda msi_current_program_flags
                                            ani msi_current_program_permissions_error
                                            jnz msi_system_call_rename_file_next
                                            mvi a,msi_current_program_permissions_error
                                            stc 
                                            jmp msi_system_call_rename_file_end
msi_system_call_rename_file_next:           lhld msi_DE_backup_address
                                            mov c,l 
                                            mov b,h 
                                            call fsm_set_selected_file_header_name
                                            cpi fsm_operation_ok
                                            jnz msi_system_call_rename_file_error
                                            mvi a,msi_operation_ok
                                            stc 
                                            cmc 
                                            jmp msi_system_call_rename_file_end
msi_system_call_rename_file_error:          stc 
msi_system_call_rename_file_end:            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return


;msi_system_call_delete_file elimina il file attualmente selezionato 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 in caso di errore 
msi_system_call_delete_file:                call fsm_get_selected_file_header_system_flag_status
                                            jc msi_system_call_delete_file_end
                                            ora a 
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
msi_system_call_delete_file_end:            lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_reset_file_scan_pointer reimposta il flne scan spointer alla posizione iniziale 
;A <- esito dell'operazione
;PSW <- CY viene settato a 1 in caso di errore 

msi_system_call_reset_file_scan_pointer:        call fsm_reset_file_header_scan_pointer
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_reset_file_scan_pointer_ok
                                                stc
                                                cmc 
                                                jmp msi_system_call_reset_file_scan_pointer_end
msi_system_call_reset_file_scan_pointer_ok:     mvi a,msi_operation_ok
                                                stc 
msi_system_call_reset_file_scan_pointer_end:    lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return

;msi_system_call_increment_file_scan_pointer incrementa il file scan pointer 
;A <- esito dell'operazione 
;PSW <- CY viene settato a 1 se si è verificato un errore 
msi_system_call_increment_file_scan_pointer:        call fsm_increment_file_header_scan_pointer
                                                    cpi fsm_operation_ok
                                                    jnz msi_system_call_increment_file_scan_pointer_error
                                                    mvi a,msi_operation_ok
                                                    stc 
                                                    cmc 
                                                    jmp msi_system_call_increment_file_scan_pointer_end
msi_system_call_increment_file_scan_pointer_error:  stc 
msi_system_call_increment_file_scan_pointer_end:    lhld msi_BC_backup_address
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

msi_system_call_change_file_dimension:              call fsm_get_selected_file_header_system_flag_status
                                                    jc msi_system_call_change_file_dimension_end
                                                    ora a 
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
msi_system_call_change_file_dimension_end:          lhld msi_BC_backup_address
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

msi_system_call_read_file_bytes:                call fsm_get_selected_file_header_system_flag_status
                                                jc msi_system_call_read_file_bytes_end
                                                ora a 
                                                jz msi_system_call_read_file_bytes_next 
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_read_file_bytes_next
msi_system_call_read_file_bytes_permerr:        mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_read_file_bytes_end
msi_system_call_read_file_bytes_next:           lda msi_PSW_backup_address+1
                                                call mms_select_high_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_system_call_read_file_bytes_error
                                                call mms_get_selected_data_segment_type_flag_status
                                                jc msi_system_call_read_file_bytes_end
                                                ora a 
                                                jnz msi_system_call_read_file_bytes_permerr
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
msi_system_call_read_file_bytes_end:            lhld msi_BC_backup_address
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

msi_system_call_write_file_bytes:               call fsm_get_selected_file_header_system_flag_status
                                                jc msi_system_call_write_file_bytes_end
                                                ora a 
                                                jz msi_system_call_write_file_bytes_next 
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_write_file_bytes_next
msi_system_call_write_file_bytes_permerr:       mvi a,msi_current_program_permissions_error
                                                stc 
                                                jmp msi_system_call_write_file_bytes_end
msi_system_call_write_file_bytes_next:          lda msi_PSW_backup_address+1
                                                call mms_select_high_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_system_call_write_file_bytes_error
                                                call mms_get_selected_data_segment_type_flag_status
                                                jc msi_system_call_write_file_bytes_end
                                                ora a 
                                                jnz msi_system_call_write_file_bytes_permerr
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
msi_system_call_write_file_bytes_end:           lhld msi_BC_backup_address
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
msi_system_call_set_data_pointer:           call fsm_get_selected_file_header_system_flag_status
                                            jc msi_system_call_set_data_pointer_end
                                            ora a 
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
msi_system_call_set_data_pointer_end:       lhld msi_BC_backup_address
                                            mov c,l 
                                            mov b,h 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            lhld msi_HL_backup_address  
                                            jmp msi_system_calls_return

;msi_system_call_launch_program sostituisce il programma attualmente caricato con quello selezionato precedentemente. 

;A <- errore generato (se si verifica un errore nell'input il programma riprende la sua esecuzione)
;il programma viene eseguito subito dopo il suo caricamento. In caso di errore nel caricamento, viene richiamata la shell di default con un errore specificato (exit program)

msi_system_call_launch_program:                 call fsm_get_selected_file_header_system_flag_status
                                                cpi $ff 
                                                jnz msi_system_call_launch_program_next
                                                lda msi_current_program_flags
                                                ani msi_current_program_permissions
                                                jnz msi_system_call_launch_program_next
                                                mvi a,msi_current_program_permissions_error
msi_system_call_launch_program_end:             stc 
                                                lhld msi_BC_backup_address
                                                mov c,l 
                                                mov b,h 
                                                lhld msi_DE_backup_address
                                                xchg 
                                                lhld msi_HL_backup_address  
                                                jmp msi_system_calls_return
msi_system_call_launch_program_next:            call fsm_get_selected_file_header_name
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_launch_program_end
                                                lxi h,0 
                                                dad sp 
                                                lxi d,msi_shell_program_extension 
                                                mvi b,msi_shell_program_extension_dimension
msi_system_call_launch_program_verify_loop:     mov a,m 
                                                ora a 
                                                jz msi_system_call_launch_program_verify_error
                                                cpi $2e 
                                                jz msi_system_call_launch_program_verify_next
                                                inx h 
                                                jmp msi_system_call_launch_program_verify_loop
msi_system_call_launch_program_verify_error:    mvi a,msi_not_a_program 
                                                stc 
                                                jmp msi_system_call_launch_program_end
msi_system_call_launch_program_verify_next:     ldax d 
                                                cmp m 
                                                jnz msi_system_call_launch_program_verify_error
                                                inx h 
                                                inx d 
                                                dcr b 
                                                jnz msi_system_call_launch_program_verify_next
                                                call mms_delete_all_temporary_segments
                                                call mms_unload_high_memory_program
                                                call fsm_load_selected_program
                                                cpi fsm_operation_ok
                                                jnz msi_system_call_launch_program_load_error
                                                call mms_start_high_memory_loaded_program
                                                mvi a,msi_shell_start_program_error
                                                jmp msi_shell_startup 
msi_system_call_launch_program_load_error:      mvi a,msi_shell_load_program_error
                                                jmp msi_shell_startup

;esegue la stessa funzione di msi_system_call_launch_program inviando il messaggio creato precedentemente. Se il messaggio non è stato creato l'applicazione viene lanciata normalmente
;A <- id del segmento da inviare 
;DE -> nome completo del programma 
;A <- errore generato (se si verifica un errore nell'input il programma riprende la sua esecuzione)
;il programma viene eseguito subito dopo il suo caricamento. In caso di errore nel caricamento, viene richiamata la shell di default con un errore specificato (exit program)

msi_system_call_launch_program_with_message:                call fsm_get_selected_file_header_system_flag_status
                                                            cpi $ff 
                                                            jnz msi_system_call_launch_program_with_message_next
                                                            lda msi_current_program_flags
                                                            ani msi_current_program_permissions
                                                            jnz msi_system_call_launch_program_with_message_next
                                                            mvi a,msi_current_program_permissions_error
msi_system_call_launch_program_with_message_end:            stc 
                                                            lhld msi_BC_backup_address
                                                            mov c,l 
                                                            mov b,h 
                                                            lhld msi_DE_backup_address
                                                            xchg 
                                                            lhld msi_HL_backup_address  
                                                            jmp msi_system_calls_return
msi_system_call_launch_program_with_message_next:           call fsm_get_selected_file_header_name
                                                            cpi fsm_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_end
                                                            lxi h,0 
                                                            dad sp 
                                                            lxi d,msi_shell_program_extension 
                                                            mvi b,msi_shell_program_extension_dimension
msi_system_call_launch_program_with_message_verify_loop:    mov a,m 
                                                            ora a 
                                                            jz msi_system_call_launch_program_with_message_verify_error
                                                            cpi $2e 
                                                            jz msi_system_call_launch_program_with_message_verify_next
                                                            inx h 
                                                            jmp msi_system_call_launch_program_with_message_verify_loop
msi_system_call_launch_program_with_message_verify_error:   mvi a,msi_not_a_program 
                                                            stc 
                                                            jmp msi_system_call_launch_program_with_message_end
msi_system_call_launch_program_with_message_verify_next:    ldax d 
                                                            cmp m 
                                                            jnz msi_system_call_launch_program_with_message_verify_error
                                                            inx h 
                                                            inx d 
                                                            dcr b 
                                                            jnz msi_system_call_launch_program_with_message_verify_next
                                                            lda msi_PSW_backup_address+1 
                                                            call mms_select_high_memory_data_segment
                                                            cpi mms_operation_ok
                                                            jz msi_system_call_launch_program_with_message_next2
msi_system_call_launch_program_with_message_passing_error:  call mms_dselect_high_memory_data_segment
                                                            jmp msi_system_call_launch_program_with_message_next3
msi_system_call_launch_program_with_message_next2:          call mms_get_selected_data_segment_type_flag_status
                                                            jc msi_system_call_launch_program_with_message_passing_error
                                                            ora a 
                                                            jnz msi_system_call_launch_program_with_message_passing_error 
                                                            xra a 
                                                            call mms_set_selected_data_segment_temporary_flag
                                                            jc msi_system_call_launch_program_with_message_passing_error
msi_system_call_launch_program_with_message_next3:          call mms_delete_all_temporary_segments
                                                            lda msi_PSW_backup_address+1 
                                                            call mms_select_high_memory_data_segment
                                                            cpi mms_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_next4
                                                            mvi a,$ff 
                                                            call mms_set_selected_data_segment_temporary_flag
msi_system_call_launch_program_with_message_next4:          call mms_unload_high_memory_program
                                                            call fsm_load_selected_program
                                                            cpi fsm_operation_ok
                                                            jnz msi_system_call_launch_program_with_message_load_error
                                                            call mms_start_high_memory_loaded_program
                                                            mvi a,msi_shell_start_program_error
                                                            jmp msi_shell_startup 
msi_system_call_launch_program_with_message_load_error:     mvi a,msi_shell_load_program_error
                                                            jmp msi_shell_startup      


;msi_system_call_exit_program chiude il programma attualmente in esecuzione e ritorna alla shell del sistema restituiendo un codice di esecuzione 
;A -> codice di esecuzione 

msi_system_call_exit_program:           call mms_unload_high_memory_program
                                        call mms_delete_all_temporary_segments
                                        lda msi_PSW_backup_address+1 
                                        jmp msi_shell_startup

;msi_system_call_get_os_version restituisce la versione corrente del sistema operativo 
;A <- versione del sistema codificata 
msi_system_call_get_os_version:     mvi a,current_system_version
                                    stc 
                                    cmc 
                                    lhld msi_BC_backup_address
                                    mov c,l 
                                    mov b,h 
                                    lhld msi_DE_backup_address
                                    xchg 
                                    lhld msi_HL_backup_address  
                                    jmp msi_system_calls_return

;------ shell di sistema ------
;La shell di sistema è la parte interattiva del sistema operativo. è basata su un sistema a linea di comando, dove l'utente può inserire i camoandi che il sistema deve eseguire. 
;L'interfaccia prevede una serie di comandi tra cui:
;-  CP "sorgente" "destinazione"  -> copia il file desiderato 
;-  DEL "file" -> elimina il file desiderato
;-  RM "file" -> rinomina il file desiderato
;-  MEM -> stampa le informazioni della RAM
;-  LS "file" -> stampa le caratteristiche del file oppure tutti i file presenti nella directory
;-  DISK "disco" -> stampa le informazioni sul disco
;-  VER -> restituisce la versione del sistema operativo
;-  ECHO "stringa" -> stampa la stringa 
;-  CD -> cambia il disco attualmente selezionato
;-  DEV -> stampa la lista dei dispositivi IO disponibili 
;-  CON -> cambia il dispositivo IO della console 
msi_shell_start_address:


msi_shell_default_disk              .equ    reserved_memory_start+$005f 
msi_shell_input_buffer_id           .equ    reserved_memory_start+$0060 
msi_shell_input_buffer_head         .equ    reserved_memory_start+$0061
msi_shell_console_ID                .equ    reserved_memory_start+$0062 

msi_shell_input_buffer_full         .equ    msi_execution_code_mark+20
msi_shell_input_buffer_dimension    .equ    64     ;(max 256)

msi_shell_unknown_disk_character    .equ $3F
msi_shell_first_disk_id             .equ $41 
msi_shell_last_disk_id              .equ $5b 
msi_shell_new_line_character        .equ $0a 
msi_shell_carriage_return_character .equ $0d 
msi_shell_backspace_character       .equ $08
msi_shell_space_character           .equ $20 

msi_input_buffer_overflow                   .equ msi_execution_code_mark+$20 

msi_shell_startup_message:                  .text "EDOS v1.0 by V.P."
                                            .b msi_shell_new_line_character, msi_shell_carriage_return_character, 0
                                            
msi_shell_load_program_error_message        .text "Failed to load program: "
                                            .b 0
msi_shell_program_load_dimension_message    .text "Not enough ram"
                                            .b msi_shell_new_line_character, msi_shell_carriage_return_character, 0

msi_shell_error_code_received_message       .text "Program exited with abnormal code: "
                                            .b 0
msi_shell_arrow:                            .text ":/> "
                                            .b 0
msi_shell_command_not_found_message         .text "Command not found"
                                            .b msi_shell_new_line_character, msi_shell_carriage_return_character, 0

msi_shell_basic_console_IO_type             .text "BTTY"



msi_shell_command_list_start    .text "COPY"
                                .b 0
                                .word   msi_shell_cp_command 
                                .text "DEL"
                                .b 0 
                                .word   msi_shell_del_command
                                .text "MOVE"
                                .b 0 
                                .word   msi_shell_mv_command
                                .text "MEM"
                                .b 0 
                                .word   msi_shell_mem_command
                                .text "FILE"
                                .b 0 
                                .word   msi_shell_ls_command
                                .text "DISK"
                                .b 0 
                                .text "VER"
                                .b 0
                                .word   msi_shell_ver_command
                                .text "ECHO"
                                .b 0 
                                .word   msi_shell_echo_command
                                .text "CD"
                                .b 0 
                                .word   msi_shell_cd_command
                                .text "DEV"
                                .b 0 
                                .word   msi_shell_dev_command
msi_shell_command_list_end:

msi_shell_startup:                                      push psw 
                                                    
                                                        call msi_shell_initialize_all_console_devices
msi_shell_startup_device_wait:                          call msi_shell_bind_console_device
                                                        cpi msi_operation_ok
                                                        jnz msi_shell_startup_device_wait
                                                        lxi h,msi_shell_startup_message 
                                                        call msi_shell_send_string_console
                                                        pop psw 
                                                        ora a 
                                                        jz msi_shell_disk_device_search
                                                        cpi msi_shell_load_program_error
                                                        jnz msi_shell_abnormal_code
                                                        lxi h,msi_shell_load_program_error_message
                                                        call msi_shell_send_string_console
                                                        jmp msi_shell_disk_device_search
msi_shell_abnormal_code:                                cpi msi_shell_start_program_error
                                                        jnz msi_shell_abnormal_code_unknown_error
                                                        mov b,a
                                                        lxi h,msi_shell_load_program_error_message
                                                        call msi_shell_send_string_console
                                                        mov a,b 
                                                        call msi_shell_send_console_byte_number 
                                                        jmp msi_shell_disk_device_search
msi_shell_abnormal_code_unknown_error:                  mov b,a 
                                                        lxi h,msi_shell_error_code_received_message
                                                        call msi_shell_send_string_console
                                                        mov a,b 
                                                        call msi_shell_send_console_byte_number 
msi_shell_disk_device_search:                           mvi a,msi_shell_new_line_character 
                                                        call msi_shell_send_console_byte
                                                        mvi a,msi_shell_carriage_return_character 
                                                        call msi_shell_send_console_byte
                                                        call msi_shell_create_input_buffer
                                                        mvi b,msi_shell_first_disk_id
msi_shell_disk_device_search_loop:                      mov a,b 
                                                        call fsm_select_disk
                                                        cpi fsm_operation_ok
                                                        jz msi_shell_disk_device_search_loop_end 
                                                        cpi fsm_device_not_found
                                                        jz msi_shell_disk_device_not_found             
msi_shell_disk_device_search_loop2:                     inr b 
                                                        mov a,b 
                                                        cpi msi_shell_last_disk_id
                                                        jc msi_shell_disk_device_search_loop
msi_shell_disk_device_not_found:                        mvi b,0 
msi_shell_disk_device_search_loop_end:                  mov a,b 
                                                        sta msi_shell_default_disk 
msi_shell_command_prompt_initialize:                    lxi sp,stack_memory_start 
                                                        xra a 
                                                        sta msi_current_program_flags 
                                                        call mms_delete_all_temporary_segments
                                                        lda msi_shell_default_disk 
                                                        mov b,a 
                                                        ora a 
                                                        jz msi_shell_command_prompt_default_disk_not_selected
msi_shell_command_prompt_reselect_default_disk:         call fsm_select_disk 
                                                        cpi fsm_operation_ok
                                                        jz msi_shell_command_prompt_print_arrow
msi_shell_command_prompt_default_disk_not_selected:     call fsm_deselect_disk 
                                                        mvi b,msi_shell_unknown_disk_character
msi_shell_command_prompt_print_arrow:                   call msi_shell_select_console_IO_device
                                                        call msi_shell_select_input_buffer 
                                                        mov a,b 
                                                        call msi_shell_send_console_byte
                                                        lxi h, msi_shell_arrow
                                                        call msi_shell_send_string_console
                                                        call msi_shell_clear_input_buffer
msi_shell_command_prompt_get_command:                   call msi_shell_read_console_byte
                                                        call msi_shell_ascii_character
                                                        jc msi_shell_command_prompt_character_not_printable
                                                        mov b,a 
                                                        call msi_shell_push_input_buffer_byte
                                                        cpi msi_operation_ok
                                                        jnz msi_shell_command_prompt_get_command
                                                        mov a,b 
                                                        call msi_shell_send_console_byte
                                                        jmp msi_shell_command_prompt_get_command
msi_shell_command_prompt_character_not_printable:       cpi msi_shell_carriage_return_character
                                                        jz msi_shell_process_command
                                                        cpi msi_shell_backspace_character 
                                                        jnz msi_shell_command_prompt_get_command
                                                        call msi_shell_remove_input_buffer_byte
                                                        cpi msi_input_buffer_overflow
                                                        jz msi_shell_command_prompt_get_command
                                                        mvi a,msi_shell_backspace_character 
                                                        call msi_shell_send_console_byte
                                                        jmp msi_shell_command_prompt_get_command
msi_shell_process_command:                              call msi_shell_send_console_byte
                                                        lxi d,msi_shell_command_list_start 
                                                        lxi b,msi_shell_command_list_end 
msi_shell_process_command_verify_loop:                  lxi h,0 
                                                        mov a,e 
                                                        sub c 
                                                        mov a,d 
                                                        sbb b 
                                                        jnc msi_shell_process_command_not_found 
msi_shell_process_command_verify_loop2:                 ldax d 
                                                        ora a 
                                                        jnz msi_shell_process_command_verify_loop3
                                                        call mms_read_selected_data_segment_byte
                                                        cpi msi_shell_space_character 
                                                        jz msi_shell_process_command_verify_loop4
                                                        ora a 
                                                        jnz msi_shell_process_command_verify_jump
msi_shell_process_command_verify_loop4:                 xchg 
                                                        inx h 
                                                        mov e,m  
                                                        inx h 
                                                        mov d,m 
                                                        xchg 
                                                        pchl  
msi_shell_process_command_verify_loop3:                 call mms_read_selected_data_segment_byte
                                                        call msi_shell_ascii_upper_case
                                                        xchg 
                                                        cmp m 
                                                        xchg 
                                                        jnz msi_shell_process_command_verify_jump
                                                        inx h 
                                                        inx d 
                                                        jmp msi_shell_process_command_verify_loop2
msi_shell_process_command_verify_jump:                  ldax d 
                                                        inx d 
                                                        ora a 
                                                        jnz msi_shell_process_command_verify_jump    
                                                        inx d 
                                                        inx d 
                                                        jmp msi_shell_process_command_verify_loop
msi_shell_process_command_not_found:                    lxi h,0 
                                                        mvi b,0 
msi_shell_process_command_stack_count:                  inr b 
                                                        call mms_read_selected_data_segment_byte
                                                        inx h 
                                                        jc msi_shell_process_command_stack_count_end
                                                        cpi $2E
                                                        jz msi_shell_process_command_stack_count_end
                                                        ora a 
                                                        jnz msi_shell_process_command_stack_count                                            
msi_shell_process_command_stack_count_end:              mov a,b 
                                                        adi msi_shell_program_extension_dimension 
                                                        mov c,a 
msi_shell_process_command_stack_count_end2:             lxi h,0 
                                                        dad sp 
                                                        mov a,l 
                                                        sub c 
                                                        mov l,a 
                                                        mov a,h 
                                                        sbi 0 
                                                        mov h,a 
                                                        sphl 
                                                        xchg 
                                                        lxi h,0 
msi_shell_process_command_stack_copy:                   call mms_read_selected_data_segment_byte
                                                        dcr b 
                                                        jz msi_shell_process_command_stack_copy2
                                                        stax d 
                                                        inx d 
                                                        inx h 
                                                        jmp msi_shell_process_command_stack_copy   
msi_shell_process_command_stack_copy2:                  mvi b,msi_shell_program_extension_dimension
                                                        lxi h,msi_shell_program_extension
msi_shell_process_command_stack_copy3:                  mov a,m 
                                                        stax d 
                                                        inx d 
                                                        inx h 
                                                        dcr b 
                                                        jnz msi_shell_process_command_stack_copy3                                                
msi_shell_process_command_stack_copy_end:               xra a
                                                        stax d  
                                                        lxi h,0 
                                                        dad sp 
                                                        mov c,l 
                                                        mov b,h 
                                                        lda msi_shell_default_disk   
                                                        ora a 
                                                        jz msi_shell_process_command_program_not_found
                                                        call fsm_select_disk
                                                        cpi fsm_operation_ok
                                                        jnz msi_shell_process_command_program_not_found
                                                        call fsm_select_file_header
                                                        cpi fsm_operation_ok
                                                        jnz msi_shell_process_command_program_not_found  
                                                        call fsm_load_selected_program
                                                        cpi fsm_operation_ok
                                                        jnz msi_shell_process_command_program_load_error
                                                        call fsm_get_selected_file_header_system_flag_status
                                                        jc msi_shell_process_command_program_load_error2
                                                        ani msi_current_program_permissions
                                                        ori msi_current_program_loaded
                                                        sta msi_current_program_flags
                                                        call msi_shell_select_input_buffer
                                                        cpi mms_operation_ok
                                                        jnz msi_shell_process_command_program_load_error2
                                                        call mms_start_high_memory_loaded_program
                                                        mvi a,msi_shell_start_program_error
                                                        jmp msi_shell_startup
msi_shell_process_command_program_load_error:           cpi fsm_program_too_big
                                                        jnz msi_shell_process_command_program_load_error2
                                                        lxi h,msi_shell_load_program_error_message
                                                        call msi_shell_send_string_console
                                                        lxi h,msi_shell_program_load_dimension_message
                                                        call msi_shell_send_string_console
                                                        jmp msi_shell_command_prompt_initialize
msi_shell_process_command_program_load_error2:          mov b,a 
                                                        lxi h,msi_shell_load_program_error_message 
                                                        call msi_shell_send_string_console
                                                        mov a,b 
                                                        call msi_shell_send_console_byte_number
                                                        mvi a,msi_shell_carriage_return_character 
                                                        call msi_shell_send_console_byte
                                                        mvi a,msi_shell_new_line_character 
                                                        call msi_shell_send_console_byte 
                                                        jmp msi_shell_command_prompt_initialize
msi_shell_process_command_program_not_found:            lxi h,msi_shell_command_not_found_message 
                                                        call msi_shell_send_string_console 
                                                        jmp msi_shell_command_prompt_initialize

;msi_shell_bind_console_device identifica automaticamente il dispositivo IO da utilizzare per la gestione della console. 
;Se il dispositivo è connesso viene selezionato automaticamente
;A -> esito dell'operazione

msi_shell_bind_console_device:                  push b 
                                                mvi b,0 
msi_shell_bind_console_device_loop:             mov a,b 
                                                call bios_get_IO_device_informations
                                                cpi bios_IO_device_not_found
                                                jz msi_shell_bind_console_device_loop_not_found
                                                lxi h,0 
                                                dad sp 
                                                lxi d,msi_shell_basic_console_IO_type
                                                mvi c,4 
msi_shell_bind_console_device_loop_verify:      ldax d 
                                                cmp m 
                                                jnz msi_shell_bind_console_device_loop_next
                                                inx d 
                                                inx h 
                                                dcr c 
                                                jnz msi_shell_bind_console_device_loop_verify
                                                pop psw 
                                                pop psw 
                                                jmp msi_shell_bind_console_device_loop_end
msi_shell_bind_console_device_loop_next:        pop psw 
                                                pop psw 
msi_shell_bind_console_device_loop_next2:       inr b 
                                                mov a,b 
                                                ora a 
                                                jnz msi_shell_bind_console_device_loop
msi_shell_bind_console_device_loop_not_found:   mvi a,msi_shell_IO_console_device_not_found 
                                                jmp msi_shell_bind_console_device_end
msi_shell_bind_console_device_loop_end:         mov a,b 
                                                call bios_select_IO_device
                                                call bios_get_selected_device_state
                                                ani bios_IO_console_connected_mask
                                                jz msi_shell_bind_console_device_loop_next2
                                                mov a,b 
                                                sta msi_shell_console_ID
                                                mvi a,msi_operation_ok
msi_shell_bind_console_device_end:              pop b 
                                                ret 

;msi_shell_initialize_all_console_devices inizializza tutti i dispositivi della console 

msi_shell_initialize_all_console_devices:                   push b 
                                                            mvi b,0 
msi_shell_initialize_all_console_devices_loop:              mov a,b 
                                                            call bios_get_IO_device_informations
                                                            cpi bios_IO_device_not_found
                                                            jz msi_shell_initialize_all_console_devices_end
                                                            lxi h,0 
                                                            dad sp 
                                                            lxi d,msi_shell_basic_console_IO_type
                                                            mvi c,4 
msi_shell_initialize_all_console_devices_loop_verify:       ldax d 
                                                            cmp m 
                                                            jnz msi_shell_initialize_all_console_devices_loop_next
                                                            inx d 
                                                            inx h 
                                                            dcr c 
                                                            jnz msi_shell_initialize_all_console_devices_loop_verify
msi_shell_initialize_all_console_devices_init:              mov a,b 
                                                            call bios_select_IO_device
                                                            call bios_initialize_selected_device
msi_shell_initialize_all_console_devices_loop_next:         pop psw 
                                                            pop psw 
msi_shell_initialize_all_console_devices_loop_next2:        inr b 
                                                            mov a,b 
                                                            ora a 
                                                            jnz msi_shell_initialize_all_console_devices_loop
msi_shell_initialize_all_console_devices_end:               pop b 
                                                            ret 

;msi_shell_create_input_buffer crea il buffer che verrà utilizzato per memorizzare temporaneamente l'input da console 
;A <- esito dell'operazione 
msi_shell_create_input_buffer:          push h 
                                        lxi h,msi_shell_input_buffer_dimension
                                        call mms_create_high_memory_data_segment
                                        pop h 
                                        rc 
                                        sta msi_shell_input_buffer_id
                                        mvi a,$ff 
                                        call mms_set_selected_data_segment_temporary_flag
                                        mvi a,msi_operation_ok
                                        ret 

;msi_shell_select_input_buffer seleziona il puffer di input 
;A <- esito dell'operazione 
msi_shell_select_input_buffer:      lda msi_shell_input_buffer_id 
                                    call mms_select_high_memory_data_segment
                                    ret 

;msi_shell_select_console_IO_device seleziona il dispositivo IO utilizzato dalla console 
;A <- esito dell'operazione 
msi_shell_select_console_IO_device:     lda msi_shell_console_ID
                                        call bios_select_IO_device
                                        cpi bios_operation_ok
                                        rnz 
                                        mvi a,msi_operation_ok
                                        ret 
                                        
;msi_shell_send_console_byte invia un byte alla console 
;A -> byte da inviare 
;A <- esito dell'operazione
msi_shell_send_console_byte:                    push psw 
msi_shell_send_console_byte_connection_verify:  call bios_get_selected_device_state
                                                ani bios_IO_console_connected_mask
                                                jnz msi_shell_send_console_byte_wait
msi_shell_send_console_byte_reconnect:          call msi_shell_bind_console_device
                                                cpi msi_operation_ok
                                                jnz msi_shell_send_console_byte_reconnect
msi_shell_send_console_byte_wait:               call bios_get_selected_device_state
                                                ani bios_IO_console_output_byte_ready
                                                jz msi_shell_send_console_byte_wait
                                                pop psw 
                                                call bios_write_selected_device_byte
                                                rc 
                                                mvi a,msi_operation_ok
                                                ret 

;msi_shell_send_console_byte_number converte il byte in BCD e lo invia alla console 
;A -> numero da inviare
;A <- esito dell'operazione 
msi_shell_send_console_byte_number:         push b 
                                            call unsigned_convert_hex_bcd_byte
                                            mov a,b 
                                            ani $0f 
                                            jz msi_shell_send_console_byte_number_next 
                                            adi $30 
                                            call msi_shell_send_console_byte
                                            cpi msi_operation_ok 
                                            jnz msi_shell_send_console_byte_number_end
msi_shell_send_console_byte_number_next:    mov a,c
                                            rar 
                                            rar 
                                            rar 
                                            rar 
                                            ani $0f 
                                            adi $30 
                                            call msi_shell_send_console_byte
                                            cpi msi_operation_ok 
                                            jnz msi_shell_send_console_byte_number_end
msi_shell_send_console_byte_number_next2:   mov a,c 
                                            ani $0f 
                                            adi $30 
                                            call msi_shell_send_console_byte
                                            cpi msi_operation_ok 
                                            jnz msi_shell_send_console_byte_number_end
msi_shell_send_console_byte_number_end:     pop b 
                                            ret 

;msi_shell_send_console_byte_number converte il byte in BCD e lo invia alla console 
;BC -> indirizzo da convertire
;A <- esito dell'operazione 

msi_shell_send_console_address_number:          push b 
                                                push d 
                                                push h
                                                call unsigned_convert_hex_bcd_word
                                                lxi h,2
                                                dad sp 
                                                mvi e,3 
                                                mvi d,0
msi_shell_send_console_address_number_print:    mov a,m 
                                                rar 
                                                rar 
                                                rar 
                                                rar 
                                                ani $0f 
                                                jnz msi_shell_send_console_address_number_print4
                                                mov b,a 
                                                mov a,d 
                                                ora a 
                                                jz msi_shell_send_console_address_number_print2
                                                mov a,b 
msi_shell_send_console_address_number_print4:   mvi d,$ff
                                                adi $30 
                                                call msi_shell_send_console_byte
                                                cpi msi_operation_ok 
                                                jnz msi_shell_send_console_address_number_end
msi_shell_send_console_address_number_print2:   mov a,m 
                                                ani $0f 
                                                jnz msi_shell_send_console_address_number_print5
                                                mov b,a 
                                                mov a,e 
                                                ora a 
                                                jz msi_shell_send_console_address_number_print6
                                                mov a,d 
                                                ora a 
                                                jz msi_shell_send_console_address_number_print3
msi_shell_send_console_address_number_print6:   mov a,b
msi_shell_send_console_address_number_print5:   mvi d,$ff
                                                adi $30 
                                                call msi_shell_send_console_byte
                                                cpi msi_operation_ok 
                                                jnz msi_shell_send_console_address_number_end
msi_shell_send_console_address_number_print3:   dcx h 
                                                dcr e
                                                jnz msi_shell_send_console_address_number_print
                                                mvi a,msi_operation_ok
msi_shell_send_console_address_number_end:      inx sp 
                                                inx sp 
                                                inx sp 
                                                pop h 
                                                pop d 
                                                pop b 
                                                ret 

;msi_shell_send_console_byte_number converte il numero a 32bit in BCD e lo invia alla console 
;BCDE -> indirizzo da convertire
;A <- esito dell'operazione 
msi_shell_send_console_long_number:             push h 
                                                push d  
                                                push b 

                                                push b 
                                                push d 
                                                call unsigned_convert_hex_bcd_long 
                                                lxi h,5
                                                dad sp 
                                                mvi e,6
                                                mvi d,0
msi_shell_send_console_long_number_print:       mov a,m 
                                                rar 
                                                rar 
                                                rar 
                                                rar 
                                                ani $0f 
                                                jnz msi_shell_send_console_long_number_print4
                                                mov b,a 
                                                mov a,d 
                                                ora a 
                                                jz msi_shell_send_console_long_number_print2
                                                mov a,b 
msi_shell_send_console_long_number_print4:      mvi d,$ff
                                                adi $30 
                                                call msi_shell_send_console_byte
                                                cpi msi_operation_ok 
                                                jnz msi_shell_send_console_long_number_end
msi_shell_send_console_long_number_print2:      mov a,m 
                                                ani $0f 
                                                jnz msi_shell_send_console_long_number_print5
                                                mov b,a 
                                                mov a,e 
                                                cpi 1 
                                                jz msi_shell_send_console_long_number_print6
                                                mov a,d 
                                                ora a 
                                                jz msi_shell_send_console_long_number_print3
msi_shell_send_console_long_number_print6:      mov a,b
msi_shell_send_console_long_number_print5:      mvi d,$ff
                                                adi $30 
                                                call msi_shell_send_console_byte
                                                cpi msi_operation_ok 
                                                jnz msi_shell_send_console_long_number_end
msi_shell_send_console_long_number_print3:      dcx h 
                                                dcr e
                                                jnz msi_shell_send_console_long_number_print
                                                mvi a,msi_operation_ok
msi_shell_send_console_long_number_end:         lxi h,6 
                                                dad sp 
                                                sphl 
                                                pop b 
                                                pop d 
                                                pop h 
                                                ret 


;msi_shell_send_string_console stampa la stringa desiderata
;HL -> puntatore alla stringa 
msi_shell_send_string_console:          push h 
msi_shell_send_string_console_loop:     mov a,m
                                        inx h 
                                        ora a 
                                        jz msi_shell_send_string_console_loop_end                            
                                        call msi_shell_send_console_byte 
                                        cpi msi_operation_ok
                                        jnz msi_shell_send_string_console_end
                                        jmp msi_shell_send_string_console_loop
msi_shell_send_string_console_loop_end: mvi a,msi_operation_ok
msi_shell_send_string_console_end:      pop h 
                                        ret 

;msi_shell_read_console_byte legge un byte dalla console 
;A <- byte letto (se CY=1 restituisce un errore)
msi_shell_read_console_byte:            call bios_get_selected_device_state
                                        ani bios_IO_console_connected_mask
                                        jnz msi_shell_read_console_byte_wait
msi_shell_read_console_byte_reconnect:  call msi_shell_bind_console_device
                                        cpi msi_operation_ok
                                        jnz msi_shell_read_console_byte_reconnect
msi_shell_read_console_byte_wait:       call bios_get_selected_device_state 
                                        ani bios_IO_console_input_byte_ready
                                        jz msi_shell_read_console_byte_wait 
                                        call bios_read_selected_device_byte
                                        ret 

;msi_push_input_buffer_byte inserisce in testa il carattere 
;A -> carattere da inserire 
;A <- esito dell'operazione
msi_shell_push_input_buffer_byte:           push h 
                                            push psw 
                                            lda msi_shell_input_buffer_head
                                            cpi msi_shell_input_buffer_dimension
                                            jc msi_shell_input_buffer_byte_next
                                            inx sp 
                                            inx sp 
                                            mvi a,msi_shell_input_buffer_full
                                            jmp msi_shell_push_input_buffer_byte_end
msi_shell_input_buffer_byte_next:           mov l,a 
                                            mvi h,0 
                                            pop psw 
                                            call mms_write_selected_data_segment_byte
                                            inx h 
                                            mov a,l 
                                            sta msi_shell_input_buffer_head
                                            mvi a,msi_operation_ok
msi_shell_push_input_buffer_byte_end:       pop h 
                                            ret 

;msi_shell_remove_input_buffer_byte rimuove un byte dalla testa del buffer
msi_shell_remove_input_buffer_byte:         push h 
                                            lda msi_shell_input_buffer_head 
                                            dcr a 
                                            cpi $ff 
                                            jnz msi_shell_remove_input_buffer_byte_next
                                            mvi a,msi_input_buffer_overflow
                                            jmp msi_shell_remove_input_buffer_byte_end
msi_shell_remove_input_buffer_byte_next:    sta msi_shell_input_buffer_head
                                            mov l,a 
                                            mvi h,0 
                                            xra a 
                                            call mms_write_selected_data_segment_byte
                                            mvi a,msi_operation_ok
msi_shell_remove_input_buffer_byte_end:     pop h 
                                            ret 

;msi_shell_clear_input_buffer pulisce il buffer in ingresso 
;A <- esito dell'operazione 
msi_shell_clear_input_buffer:               push h 
                                            lxi h,0 
msi_shell_clear_buffer_loop:                xra a 
                                            call mms_write_selected_data_segment_byte
                                            inx h 
                                            jnc msi_shell_clear_buffer_loop
                                            xra a 
                                            sta msi_shell_input_buffer_head
                                            mvi a,msi_operation_ok
msi_shell_clear_input_buffer_end:           pop h 
                                            ret 

;msi_shell_ascii_character verifica se il carattere è stampabile 
;A -> carattere da verificare 
;PSW <- se è stampabile CY=0, C=1 altrimenti

msi_shell_ascii_character:          cpi $20 
                                    rc 
                                    cpi $7e 
                                    cmc 
                                    ret                  

;msi_shell_ascii_upper_case converte le lettere da minuscolo a maiuscolo 
;A -> carattere ascii 
;A <- carattere convertito 
msi_shell_ascii_upper_case:         cpi $61 
                                    rc 
                                    cpi $7b 
                                    rnc 
                                    ani %11011111
                                    ret 

;msi_shell_point_argument restituisce l'indirizzo relativo al buffer della console che indica l'argomento desiderato a partire
;A -> numero di argomento (parte da sinistra e arriva verso destra)
;A <- $ff se l'argomento esiste, $00 altrimenti
;HL <- indirizzo dell'argomento nel buffer

msi_shell_point_argument:                       push b 
                                                push d 
                                                lxi h,0 
                                                ora a 
                                                jz msi_shell_point_argument
                                                mov b,a 
msi_shell_point_argument_skip_argument:         call mms_read_selected_data_segment_byte
                                                jc msi_shell_point_argument_not_found
                                                inx h 
                                                ora a 
                                                jz msi_shell_point_argument_not_found
                                                cpi $20 
                                                jnz msi_shell_point_argument_skip_argument
msi_shell_point_argument_align:                 call mms_read_selected_data_segment_byte
                                                ora a 
                                                jz msi_shell_point_argument_not_found
                                                cpi $20 
                                                jnz msi_shell_point_argument_verify_number
                                                inx h 
                                                jmp msi_shell_point_argument_align
msi_shell_point_argument_verify_number:         dcr b 
                                                jnz msi_shell_point_argument_skip_argument
                                                jmp msi_shell_point_argument_ok
msi_shell_point_argument_not_found:             xra a 
                                                jmp msi_shell_point_argument_end
msi_shell_point_argument_null:                  lxi h,0
msi_shell_point_argument_ok:                    mvi a,$ff
msi_shell_point_argument_end:                   pop d 
                                                pop b 
                                                ret 

;----- shell commands -----
;A -> se $00 il comando non ha nessun argomento 
;     se $20 il comando ha almeno un argomento

msi_system_version_message                  .text "EDOS VER "
                                            .b 0 

msi_shell_dev_header_string                 .text "PORT     DEVICE"
                                            .b msi_shell_new_line_character, msi_shell_carriage_return_character, 0 

msi_shell_dev_tab_space                     .text "      "
                                            .b 0

msi_shell_dev_argument_error                .text "Argument format error"
                                            .b 0

msi_shell_mem_installed_string:             .text "RAM installed: "
                                            .b 0

msi_shell_mem_available_string:             .text "Space available: "
                                            .b 0

msi_shell_mem_system_string:                .text "Space reserved: "
                                            .b 0




msi_shell_del_command_wipe_disk_string:        .text "This command will clear all data saved."
                                                .b msi_shell_new_line_character,msi_shell_carriage_return_character
                                                .text "Are you sure? (y/n) "
                                                .b msi_shell_new_line_character,msi_shell_carriage_return_character, 0

msi_shell_del_command_not_found:                .text "File not found"
                                                .b msi_shell_carriage_return_character, msi_shell_new_line_character, 0
msi_shell_del_command_read_only_string:         .text "Read only file"
                                                .b msi_shell_carriage_return_character, msi_shell_new_line_character, 0

msi_shell_abnormal_error:                       .text "Error during command execution: "
                                                .b 0

msi_shell_ls_command_not_formatted_string:      .text "not formatted"
                                                .b 0

msi_shell_ls_specific_name_string               .text "Disk name: "
                                                .b 0

msi_shell_ls_specific_space_left                .text "Free space: "
                                                .b 0
msi_shell_ls_specific_bytes_string              .text " bytes"
                                                .b 0

msi_shell_ls_specific_dimension_string          .text "File dimension: "
                                                .b 0
msi_shell_ls_specific_read_only_string          .text "Read only: "
                                                .b 0
msi_shell_ls_specific_system_string             .text "System:  "
                                                .b 0

msi_shell_ls_specific_hidden_string             .text "Hidden:  "
                                                .b 0

msi_shell_ls_specific_yes_string                .text "yes"
                                                .b 0

msi_shell_ls_specific_no_string                 .text "no"
                                                .b 0

msi_shell_ls_command_pause_string               .text "Press any key to continue..."
                                                .b msi_shell_carriage_return_character, msi_shell_new_line_character, msi_shell_carriage_return_character, msi_shell_new_line_character,0

msi_shell_cd_command_path_not_valid_string      .text "Path not valid"
                                                .b msi_shell_carriage_return_character, msi_shell_new_line_character,0

msi_shell_cd_command_not_valid_string           .text "Path not found"
                                                .b msi_shell_carriage_return_character, msi_shell_new_line_character,0

msi_shell_mv_cp_command_source_not_valid_string         .text "Source path not valid"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_command_destination_not_valid_string    .text "Destination path not valid"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_command_file_exists_string              .text "Destination file exists"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_command_source_not_found_string         .text "Source file not found"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_command_dest_not_found_string           .text "Destination disk not found"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_ram_error_string                        .text "Not enough ram available"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_command_space_disk_string               .text "Not enough space on destination disk"
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character,0
msi_shell_mv_cp_abnormal_error_string                   .text "Error during data transfer."
                                                        .b msi_shell_carriage_return_character, msi_shell_new_line_character
                                                        .text "Attempting to remove destination file: "
                                                        .b 0
msi_shell_del_command:                      mvi a,1
                                            call msi_shell_point_argument
                                            ora a 
                                            jz msi_shell_del_command_not_specified
                                            call mms_read_selected_data_segment_byte
                                            jc msi_shell_del_command_not_specified
                                            cpi "*"
                                            jnz msi_shell_del_command_file
                                            inx h 
                                            call mms_read_selected_data_segment_byte
                                            dcx h
                                            jc msi_shell_del_command_confirm
                                            cpi msi_shell_space_character 
                                            ora a 
                                            jz msi_shell_del_command_confirm
                                            cpi msi_shell_space_character
                                            jnz msi_shell_del_command_file
msi_shell_del_command_confirm:              lxi h,msi_shell_del_command_wipe_disk_string
                                            call msi_shell_send_string_console
                                            call msi_shell_read_console_byte
                                            cpi "Y"
                                            jz msi_shell_del_command_wipe
                                            cpi "y"
                                            jz msi_shell_del_command_wipe 
                                            jmp msi_shell_del_command_end
msi_shell_del_command_wipe:                 call fsm_wipe_disk
                                            cpi fsm_operation_ok
                                            jz msi_shell_del_command_end
                                            mov b,a 
                                            lxi h,msi_shell_abnormal_error
                                            call msi_shell_send_string_console
                                            mov a,b 
                                            call msi_shell_send_console_byte_number
                                            mvi a,msi_shell_carriage_return_character
                                            call msi_shell_send_console_byte
                                            mvi a,msi_shell_carriage_return_character
                                            call msi_shell_send_console_byte
                                            jmp msi_shell_del_command_end

msi_shell_del_command_file:                 xchg 
                                            call fsm_file_name_max_dimension
                                            lxi h,$ffff 
                                            mov b,a 
                                            inr b 
                                            mov a,l 
                                            sub b 
                                            mov l,a 
                                            mov a,h 
                                            sbi 0
                                            mov h,a
                                            pop b  
                                            dad sp 
                                            sphl 
                                            xchg 
msi_shell_del_command_copy_loop:            call mms_read_selected_data_segment_byte
                                            jc msi_shell_del_command_copy_loop_end
                                            cpi msi_shell_space_character
                                            jz msi_shell_del_command_copy_loop_end
                                            ora a 
                                            jz msi_shell_del_command_copy_loop_end
                                            stax d
                                            inx d
                                            inx h 
                                            jmp msi_shell_del_command_copy_loop
msi_shell_del_command_copy_loop_end:        xchg 
                                            mvi m,$00 
                                            lxi h,0 
                                            dad sp 
                                            mov c,l 
                                            mov b,h 
                                            call fsm_select_file_header
                                            cpi fsm_operation_ok
                                            jz msi_shell_del_command_delete
                                            cpi fsm_header_not_found
                                            jnz msi_shell_return_abnormal_error
                                            lxi h,msi_shell_del_command_not_found
                                            jmp msi_shell_print_error_message
msi_shell_del_command_delete:               call fsm_delete_selected_file_header
                                            cpi fsm_operation_ok
                                            jnz msi_shell_return_abnormal_error
                                            mvi a,msi_shell_carriage_return_character
                                            call msi_shell_send_console_byte
                                            mvi a,msi_shell_new_line_character
                                            call msi_shell_send_console_byte        
msi_shell_del_command_end:                  jmp msi_shell_command_prompt_initialize                      

msi_shell_del_command_read_only:            lxi h,msi_shell_del_command_read_only_string 
                                            call msi_shell_send_string_console
                                            jmp msi_shell_command_prompt_initialize

msi_shell_del_command_not_specified:        lxi h, msi_shell_del_command_not_found
                                            call msi_shell_send_string_console
                                            jmp msi_shell_command_prompt_initialize


msi_shell_mv_command:                       mvi a,$ff 
                                            jmp msi_shell_mv_cp_command
msi_shell_cp_command:                       mvi a,0
                                            jmp msi_shell_mv_cp_command

msi_shell_mv_cp_ram_buffer_min_dimension        .equ 128

msi_shell_mv_cp_command:                        push psw                                    
                                                mvi a,1 
                                                call msi_shell_point_argument
                                                ora a 
                                                jz msi_shell_mv_cp_command_source_not_valid
                                                xchg 
                                                lxi h,$ffff 
                                                call fsm_file_name_max_dimension
                                                ;inr a 
                                                mov b,a 
                                                mov a,l 
                                                sub b 
                                                mov l,a 
                                                mov a,h 
                                                sbi 0
                                                mov h,a
                                                dad sp 
                                                sphl    
                                                dcr b
                                                xchg 
msi_shell_mv_cp_command_copy_source:            call mms_read_selected_data_segment_byte
                                                jc msi_shell_mv_cp_command_copy_source_end
                                                cpi msi_shell_space_character
                                                jz msi_shell_mv_cp_command_copy_source_end
                                                ora a 
                                                jz msi_shell_mv_cp_command_copy_source_end
                                                stax d 
                                                inx h 
                                                inx d 
                                                dcr b
                                                jnz msi_shell_mv_cp_command_copy_source
msi_shell_mv_cp_command_copy_source_end:        xchg 
                                                mvi m,0
msi_shell_mv_cp_command_verify_destination:     mvi a,2 
                                                call msi_shell_point_argument
                                                ora a 
                                                jz msi_shell_mv_cp_command_destination_not_valid
                                                xchg 
                                                lxi h,$ffff
                                                call fsm_file_name_max_dimension
                                                mov b,a 
                                                mov a,l 
                                                sub b 
                                                mov l,a 
                                                mov a,h 
                                                sbi 0
                                                mov h,a
                                                dad sp 
                                                sphl    
                                                dcr b
                                                xchg 
                                                inx h 
                                                call mms_read_selected_data_segment_byte
                                                jc msi_shell_mv_cp_command_destination_not_valid
                                                dcx h 
                                                cpi ":"
                                                jnz msi_shell_mv_cp_command_copy_dest_current_dsk
                                                inx h 
                                                inx h 
                                                call mms_read_selected_data_segment_byte
                                                jc msi_shell_mv_cp_command_destination_not_valid
                                                dcx h 
                                                dcx h 
                                                cpi msi_shell_space_character
                                                jz msi_shell_mv_cp_command_destination_not_valid
                                                ora a 
                                                jz msi_shell_mv_cp_command_destination_not_valid
                                                cpi "/"
                                                jnz msi_shell_mv_cp_command_copy_dest_current_dsk
                                                call mms_read_selected_data_segment_byte
                                                jc msi_shell_mv_cp_command_destination_not_valid
                                                cpi $41 
                                                jc msi_shell_mv_cp_command_destination_not_valid
                                                cpi $5B 
                                                jnc msi_shell_mv_cp_command_destination_not_valid
                                                mov c,a 
                                                jmp msi_shell_mv_cp_command_copy_destination
msi_shell_mv_cp_command_copy_dest_current_dsk:  lda msi_shell_default_disk
                                                mov c,a 
msi_shell_mv_cp_command_copy_destination:       call mms_read_selected_data_segment_byte
                                                jc msi_shell_mv_cp_command_copy_destination_end
                                                cpi msi_shell_space_character
                                                jz msi_shell_mv_cp_command_copy_destination_end
                                                ora a 
                                                jz msi_shell_mv_cp_command_copy_destination_end
                                                stax d 
                                                inx h 
                                                inx d 
                                                dcr b
                                                jnz msi_shell_mv_cp_command_copy_destination
msi_shell_mv_cp_command_copy_destination_end:   xchg 
                                                mvi m,0 
                                                lxi h,0 
                                                dad sp 
                                                xchg 
                                                call fsm_file_name_max_dimension
                                                inr a 
                                                mov l,a                         
                                                mvi h,0                         ;B -> source file disk
                                                dad d                           ;C -> destination disk 
                                                xchg 
                                                lda msi_shell_default_disk      ;DE -> source file pointer
                                                mov b,a                         ;HL -> destination file pointer 
msi_shell_mv_cp_source_verify:                  push b 
                                                push d 
                                                push h                          
                                                mov a,b 
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                mov b,d 
                                                mov d,c 
                                                mov c,e 
                                                call fsm_search_file_header
                                                cpi fsm_operation_ok
                                                jz msi_shell_mv_cp_destination_verify
                                                cpi fsm_header_not_found
                                                jz msi_shell_mv_cp_command_source_not_found
                                                jmp msi_shell_return_abnormal_error
msi_shell_mv_cp_destination_verify:             mov a,d 
                                                call fsm_select_disk 
                                                cpi fsm_operation_ok
                                                jz msi_shell_mv_cp_destination_verify2
                                                cpi fsm_device_not_found
                                                jz msi_shell_mv_cp_command_dest_not_found
                                                jmp msi_shell_return_abnormal_error
msi_shell_mv_cp_destination_verify2:            mov c,l 
                                                mov b,h 
                                                call fsm_search_file_header
                                                cpi fsm_operation_ok
                                                jz msi_shell_mv_cp_command_file_exists
                                                cpi fsm_header_not_found
                                                jnz msi_shell_return_abnormal_error
msi_shell_mv_cp_destination_mv_verify:          lxi h,6+2
                                                call fsm_file_name_max_dimension
                                                add l 
                                                mov l,a 
                                                mov a,h 
                                                aci 0 
                                                mov h,a 
                                                call fsm_file_name_max_dimension
                                                add l 
                                                mov l,a 
                                                mov a,h 
                                                aci 0 
                                                mov h,a 
                                                dad sp 
                                                inx h 
                                                mov c,m
                                                lxi h,0                              
                                                dad sp 
                                                push b 
                                                lxi h,0             ;SP -> [current file pointer (4)][file dimension (4)][segment,command][dest pointer][source pointer][disk numbers][header 2][header 1]
                                                push h 
                                                push h 
                                                push h 
                                                push h 
                                                call msi_shell_mv_cp_command_type_load
                                                ora a 
                                                jz msi_shell_mv_cp_destination_create
                                                call msi_shell_mv_cp_disk_numbers_load
                                                mov a,c 
                                                cmp b 
                                                jnz msi_shell_mv_cp_destination_create
                                                call msi_shell_mv_cp_pointers_load
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d 
                                                call fsm_set_selected_file_header_name
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                jmp msi_shell_command_prompt_initialize
msi_shell_mv_cp_destination_create:             call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d
                                                call fsm_create_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_disk_numbers_load
                                                mov a,b 
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_pointers_load
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call fsm_get_selected_file_header_dimension
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                lxi h,4 
                                                dad sp 
                                                mov m,e 
                                                inx h 
                                                mov m,d 
                                                inx h 
                                                mov m,c 
                                                inx h 
                                                mov m,b 
                                                call msi_shell_mv_cp_disk_numbers_load 
                                                mov a,c
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d 
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete 

                                                call msi_shell_mv_cp_file_dimension_load
                                                call fsm_selected_file_append_data_bytes
                                                cpi fsm_operation_ok
                                                jz msi_shell_mv_cp_command_destination_space_ok
                                                cpi fsm_not_enough_spage_left
                                                jnz msi_shell_mv_cp_command_file_delete
                                                lxi h,msi_shell_mv_cp_command_space_disk_string 
                                                call msi_shell_send_string_console
                                                jmp msi_shell_command_prompt_initialize
msi_shell_mv_cp_command_destination_space_ok:   call mms_free_high_ram_bytes
                                                lxi d,msi_shell_mv_cp_ram_buffer_min_dimension
                                                mov a,e 
                                                sub l 
                                                mov a,d 
                                                sbb h 
                                                jnc msi_shell_mv_cp_ram_error 
                                                call mms_create_high_memory_data_segment
                                                jc msi_shell_mv_cp_command_file_delete
                                                mvi a,$ff 
                                                call mms_set_selected_data_segment_temporary_flag
                                                cpi mms_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                lxi h,9
                                                dad sp 
                                                mov m,a 

msi_shell_mv_cp_command_data_transfer_loop:     call msi_shell_mv_cp_disk_numbers_load
                                                mov a,b 
                                                call fsm_select_disk
                                                call msi_shell_mv_cp_pointers_load
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
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
                                                call fsm_selected_file_set_data_pointer
                                                cpi fsm_file_pointer_overflow
                                                jz msi_shell_mv_cp_command_data_transfer_loop_end
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_file_dimension_load
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
                                                call msi_shell_mv_cp_segment_load
                                                call mms_select_high_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call mms_get_selected_data_segment_dimension
                                                mov a,e 
                                                sub l 
                                                mov l,a 
                                                mov a,d 
                                                sbb h 
                                                mov h,a 
                                                mov a,c 
                                                sbi 0 
                                                mov a,b 
                                                sbi 0 
                                                jnc msi_shell_mv_cp_command_data_transfer_loop2
                                                mov l,e
                                                mov h,d 
                                                jmp msi_shell_mv_cp_command_data_transfer_loop3
msi_shell_mv_cp_command_data_transfer_loop2:    call mms_get_selected_data_segment_dimension
msi_shell_mv_cp_command_data_transfer_loop3:    xchg
                                                lxi h,0 
                                                call msi_shell_mv_cp_segment_load
                                                mov c,e 
                                                mov b,d
                                                call fsm_selected_file_read_bytes
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_disk_numbers_load
                                                mov a,c 
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                xchg 
                                                call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d 
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
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
                                                call fsm_selected_file_set_data_pointer
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                xchg 
                                                mov c,e
                                                mov b,d
                                                lxi h,0
                                                call msi_shell_mv_cp_segment_load
                                                call fsm_selected_file_write_bytes
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                xthl 
                                                mov a,l 
                                                add e 
                                                mov l,a 
                                                mov a,h 
                                                adc d 
                                                mov h,a 
                                                xthl 
                                                inx sp 
                                                inx sp 
                                                xthl 
                                                mov a,l 
                                                aci 0
                                                mov l,a 
                                                mov a,h 
                                                aci 0
                                                mov h,a 
                                                xthl 
                                                dcx sp 
                                                dcx sp 
                                                jmp msi_shell_mv_cp_command_data_transfer_loop
msi_shell_mv_cp_command_data_transfer_loop_end: call msi_shell_mv_cp_disk_numbers_load
                                                mov a,b 
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                call msi_shell_mv_cp_pointers_load
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_mv_cp_command_file_delete
                                                mvi d,0 
                                                call fsm_get_selected_file_header_system_flag_status
                                                jc msi_shell_mv_cp_command_file_delete
                                                ani %10000000
                                                ora d 
                                                mov d,a 
                                                call fsm_get_selected_file_header_readonly_flag_status
                                                jc msi_shell_mv_cp_command_file_delete
                                                ani %01000000
                                                ora d 
                                                mov d,a 
                                                call fsm_get_selected_file_header_hidden_flag_status
                                                jc msi_shell_mv_cp_command_file_delete
                                                ani %00100000
                                                ora d 
                                                mov d,a 
                                                call msi_shell_mv_cp_command_type_load
                                                ora a 
                                                jz msi_shell_mv_cp_skip_delete_source
                                                mov a,d 
                                                ani %01000000
                                                jz msi_shell_mv_cp_delete_source
                                                xra a 
                                                call fsm_set_selected_file_header_readonly_flag
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
msi_shell_mv_cp_delete_source:                  call fsm_delete_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
msi_shell_mv_cp_skip_delete_source:             call msi_shell_mv_cp_disk_numbers_load
                                                mov a,c 
                                                call fsm_select_disk
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                mov h,d 
                                                call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d 
                                                mov d,h
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                mov a,d 
                                                ani %10000000
                                                jz msi_shell_mv_cp_skip_system_flag
                                                mvi a,$ff 
                                                call fsm_set_selected_file_header_system_flag
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
msi_shell_mv_cp_skip_system_flag:               mov a,d 
                                                ani %01000000
                                                jz msi_shell_mv_cp_skip_read_only_flag
                                                mvi a,$ff 
                                                call fsm_set_selected_file_header_readonly_flag
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                jmp msi_shell_command_prompt_initialize
msi_shell_mv_cp_skip_read_only_flag:            mov a,d 
                                                ani %00100000
                                                jz msi_shell_command_prompt_initialize
                                                mvi a,$ff 
                                                call fsm_set_selected_file_header_hidden_flag
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                call msi_shell_mv_cp_segment_load
                                                ora a 
                                                jz msi_shell_return_abnormal_error
                                                call mms_select_high_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                call mms_delete_selected_high_memory_data_segment
                                                cpi mms_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                jmp msi_shell_command_prompt_initialize

msi_shell_mv_cp_command_file_delete:            mov b,a 
                                                lxi h,msi_shell_mv_cp_abnormal_error_string 
                                                call msi_shell_send_string_console
                                                mov a,b 
                                                call msi_shell_send_console_byte_number
                                                mvi a,msi_shell_carriage_return_character
                                                call msi_shell_send_console_byte
                                                mvi a,msi_shell_new_line_character
                                                call msi_shell_send_console_byte
                                    
                                                call msi_shell_mv_cp_disk_numbers_load
                                                mov a,c 
                                                call fsm_Select_disk 
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                call msi_shell_mv_cp_pointers_load
                                                mov c,e 
                                                mov b,d 
                                                call fsm_select_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                call fsm_delete_selected_file_header
                                                cpi fsm_operation_ok
                                                jnz msi_shell_return_abnormal_error
                                                jmp msi_shell_command_prompt_initialize

msi_shell_mv_cp_command_type_load:              push h
                                                lxi h,12
                                                dad sp 
                                                mov a,m
                                                pop h 
                                                ret 

msi_shell_mv_cp_segment_load:                   push h 
                                                lxi h,13
                                                dad sp 
                                                mov a,m
                                                pop h 
                                                ret 

msi_shell_mv_cp_pointers_load:                  push h 
                                                lxi h,14
                                                dad sp 
                                                mov e,m             ;DE -> destination
                                                inx h               ;BC -> source
                                                mov d,m 
                                                inx h  
                                                mov c,m 
                                                inx h 
                                                mov b,m
                                                pop h 
                                                ret 

msi_shell_mv_cp_disk_numbers_load:              push h 
                                                lxi h,18
                                                dad sp 
                                                mov c,m 
                                                inx h 
                                                mov b,m 
                                                pop h 
                                                ret 

msi_shell_mv_cp_file_dimension_load:            push h 
                                                lxi h,8 
                                                dad sp 
                                                mov e,m 
                                                inx h 
                                                mov d,m 
                                                inx h 
                                                mov c,m 
                                                inx h 
                                                mov b,m 
                                                pop h 
                                                ret 

msi_shell_mv_cp_ram_error:                      lxi h,msi_shell_mv_cp_ram_error_string 
                                                jmp msi_shell_print_error_message
msi_shell_mv_cp_command_source_not_found:       lxi h,msi_shell_mv_cp_command_source_not_found_string 
                                                jmp msi_shell_print_error_message
msi_shell_mv_cp_command_dest_not_found:         lxi h,msi_shell_mv_cp_command_dest_not_found_string
                                                jmp msi_shell_print_error_message
msi_shell_mv_cp_command_source_not_valid:       lxi h,msi_shell_mv_cp_command_source_not_valid_string 
                                                jmp msi_shell_print_error_message
msi_shell_mv_cp_command_destination_not_valid:  lxi h,msi_shell_mv_cp_command_destination_not_valid_string
                                                jmp msi_shell_print_error_message
msi_shell_mv_cp_command_file_exists:            lxi h,msi_shell_mv_cp_command_file_exists_string
                                                jmp msi_shell_print_error_message     

msi_shell_ls_command_pause_line_number              .equ 8

msi_shell_ls_command:                               mvi c,0 
                                                    mvi b,1 
                                                    mvi d,0
msi_shell_ls_command_read_options_loop:             mov a,b 
                                                    call msi_shell_point_argument
                                                    ora a 
                                                    jz msi_shell_ls_command_read_options_loop_end
                                                    call mms_read_selected_data_segment_byte
                                                    jc msi_shell_ls_command_read_options_loop_end
                                                    cpi "-"
                                                    jnz msi_shell_ls_command_read_options_loop_2
                                                    inx h 
                                                    call mms_read_selected_data_segment_byte
                                                    jc msi_shell_ls_command_read_options_loop_end
                                                    cpi "h"
                                                    jnz msi_shell_ls_command_read_options_loop_1
                                                    mov a,c 
                                                    ori %10000000
                                                    mov c,a 
                                                    inr b 
                                                    jmp msi_shell_ls_command_read_options_loop
msi_shell_ls_command_read_options_loop_1:           cpi "p"
                                                    jnz msi_shell_ls_command_read_options_loop_not_valid
                                                    mov a,c 
                                                    ori %01000000
                                                    mov c,a 
                                                    inr b 
                                                    jmp msi_shell_ls_command_read_options_loop
msi_shell_ls_command_read_options_loop_not_valid:   lxi h,msi_shell_dev_argument_error
                                                    call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte 
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte 
                                                    jmp msi_shell_ls_command_end 
msi_shell_ls_command_read_options_loop_2:           mov a,c 
                                                    ani %00100000
                                                    jnz msi_shell_ls_command_read_options_loop_not_valid
                                                    mov a,c 
                                                    ori %00100000
                                                    mov c,a 
                                                    mov d,b 
                                                    inr b 
                                                    jmp msi_shell_ls_command_read_options_loop
msi_shell_ls_command_read_options_loop_end:         mov a,c 
                                                    ani %00100000
                                                    jnz msi_shell_ls_command_specific
msi_shell_ls_command_list_next:                     lxi h,msi_shell_ls_specific_name_string 
                                                    call msi_shell_send_string_console
                                                    call fsm_disk_get_name
                                                    cpi fsm_operation_ok
                                                    jnz msi_shell_return_abnormal_error
                                                    lxi h,0 
                                                    dad sp 
                                                    call msi_shell_send_string_console
msi_shell_ls_command_list_fetch_loop:               inx h
                                                    mov a,m 
                                                    ora a 
                                                    jnz msi_shell_ls_command_list_fetch_loop
                                                    inx h 
                                                    sphl 
                                                    push b
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte
msi_shell_ls_command_list_space_left:               lxi h,msi_shell_ls_specific_space_left
                                                    call msi_shell_send_string_console
                                                    call fsm_disk_get_free_space
                                                    cpi fsm_operation_ok
                                                    jnz msi_shell_return_abnormal_error
                                                    call msi_shell_send_console_long_number 
                                                    lxi h,msi_shell_ls_specific_bytes_string
                                                    call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte
                                                    call fsm_reset_file_header_scan_pointer
                                                    cpi fsm_operation_ok
                                                    jz msi_shell_ls_command_list_loop
                                                    cpi fsm_end_of_list
                                                    jz msi_shell_ls_command_list_loop_end
                                                    jmp msi_shell_return_abnormal_error
                                                    xthl 
                                                    mvi h,0 
                                                    xthl
msi_shell_ls_command_list_loop:                     xthl 
                                                    mov a,l 
                                                    xthl  
                                                    ani %10000000
                                                    jnz msi_shell_ls_command_list_loop_name_print
                                                    call fsm_get_selected_file_header_hidden_flag_status
                                                    jc msi_shell_return_abnormal_error
                                                    cpi $ff 
                                                    jz msi_shell_ls_command_list_loop_increment
msi_shell_ls_command_list_loop_name_print:          xthl 
                                                    mov a,l 
                                                    xthl  
                                                    ani %01000000
                                                    jz msi_shell_ls_command_list_loop_name_print2
                                                    xthl 
                                                    inr h 
                                                    mov a,h
                                                    xthl  
                                                    cpi msi_shell_ls_command_pause_line_number
                                                    jc msi_shell_ls_command_list_loop_name_print2
                                                    xthl 
                                                    mvi h,0 
                                                    xthl
                                                    lxi h,msi_shell_ls_command_pause_string 
                                                    call msi_shell_send_string_console
                                                    call msi_shell_read_console_byte
msi_shell_ls_command_list_loop_name_print2:         call fsm_get_selected_file_header_name
                                                    cpi fsm_operation_ok
                                                    jnz msi_shell_return_abnormal_error
                                                    lxi h,0 
                                                    dad sp 
                                                    call msi_shell_send_string_console
                                                    mvi b,0 
msi_shell_ls_command_list_name_loop:                inx h
                                                    inr b 
                                                    mov a,m 
                                                    ora a 
                                                    jnz msi_shell_ls_command_list_name_loop
                                                    inx h 
                                                    sphl 
msi_shell_ls_command_list_name_tab:                 call fsm_file_name_max_dimension 
                                                    cmp b 
                                                    jc msi_shell_ls_command_list_name_tab_end
                                                    inr b 
                                                    mvi a,msi_shell_space_character
                                                    call msi_shell_send_console_byte
                                                    jmp msi_shell_ls_command_list_name_tab
msi_shell_ls_command_list_name_tab_end:             mvi a,msi_shell_space_character
                                                    call msi_shell_send_console_byte
                                                    call fsm_get_selected_file_header_dimension 
                                                    cpi fsm_operation_ok
                                                    jnz msi_shell_return_abnormal_error
                                                    call msi_shell_send_console_long_number 
                                                    lxi h,msi_shell_ls_specific_bytes_string
                                                    call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte
msi_shell_ls_command_list_loop_increment:           call fsm_increment_file_header_scan_pointer
                                                    cpi fsm_operation_ok
                                                    jz msi_shell_ls_command_list_loop
                                                    cpi fsm_end_of_list
                                                    jnz msi_shell_return_abnormal_error
msi_shell_ls_command_list_loop_end:                 mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte
                                                    jmp msi_shell_ls_command_end

msi_shell_ls_command_specific:                      mov a,d 
                                                    call msi_shell_point_argument
                                                    xchg 
                                                    push b 
                                                    call fsm_file_name_max_dimension
                                                    lxi h,$ffff 
                                                    mov b,a 
                                                    inr b 
                                                    mov a,l 
                                                    sub b 
                                                    mov l,a 
                                                    mov a,h 
                                                    sbi 0
                                                    mov h,a
                                                    pop b  
                                                    dad sp 
                                                    sphl 
                                                    xchg 
msi_shell_ls_command_specific_copy_loop:            call mms_read_selected_data_segment_byte
                                                    jc msi_shell_ls_command_specific_copy_loop_end
                                                    cpi msi_shell_space_character
                                                    jz msi_shell_ls_command_specific_copy_loop_end
                                                    ora a 
                                                    jz msi_shell_ls_command_specific_copy_loop_end
                                                    stax d
                                                    inx d
                                                    inx h 
                                                    jmp msi_shell_ls_command_specific_copy_loop
msi_shell_ls_command_specific_copy_loop_end:        xchg 
                                                    mvi m,$00 
                                                    lxi h,0 
                                                    dad sp 
                                                    mov e,c 
                                                    mov c,l 
                                                    mov b,h 
                                                    call fsm_select_file_header
                                                    cpi fsm_operation_ok
                                                    jz msi_shell_ls_command_specific_print
                                                    cpi fsm_header_not_found
                                                    jnz msi_shell_return_abnormal_error
msi_shell_ls_command_specific_file_not_found:       lxi h,msi_shell_del_command_not_found
                                                    jmp msi_shell_print_error_message
msi_shell_ls_command_specific_print:                call fsm_get_selected_file_header_hidden_flag_status
                                                    jc msi_shell_return_abnormal_error
                                                    ora a 
                                                    jz msi_shell_ls_command_specific_print2
                                                    mov a,e 
                                                    ani %10000000
                                                    jz msi_shell_ls_command_specific_file_not_found
msi_shell_ls_command_specific_print2:               lxi h, msi_shell_ls_specific_dimension_string
                                                    call msi_shell_send_string_console
                                                    call fsm_get_selected_file_header_dimension
                                                    cpi fsm_operation_ok
                                                    jnz msi_shell_return_abnormal_error
                                                    call msi_shell_send_console_long_number
                                                    mvi a,msi_shell_space_character
                                                    call msi_shell_send_console_byte 
                                                    lxi h,msi_shell_ls_specific_bytes_string
                                                    call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte
                                                    lxi h, msi_shell_ls_specific_system_string
                                                    call msi_shell_send_string_console 
                                                    call fsm_get_selected_file_header_system_flag_status
                                                    jc msi_shell_return_abnormal_error
                                                    ora a 
                                                    jz msi_shell_ls_command_specific_print_normal
                                                    lxi h,msi_shell_ls_specific_yes_string
                                                    jmp msi_shell_ls_command_specific_print_system
msi_shell_ls_command_specific_print_normal:         lxi h,msi_shell_ls_specific_no_string 
msi_shell_ls_command_specific_print_system:         call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte  
                                                    lxi h, msi_shell_ls_specific_read_only_string
                                                    call msi_shell_send_string_console 
                                                    call fsm_get_selected_file_header_readonly_flag_status
                                                    jc msi_shell_return_abnormal_error
                                                    ora a 
                                                    jz msi_shell_ls_command_specific_print_normal2
                                                    lxi h,msi_shell_ls_specific_yes_string
                                                    jmp msi_shell_ls_command_specific_print_readable
msi_shell_ls_command_specific_print_normal2:        lxi h,msi_shell_ls_specific_no_string 
msi_shell_ls_command_specific_print_readable:       call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte  
                                                    lxi h, msi_shell_ls_specific_hidden_string
                                                    call msi_shell_send_string_console 
                                                    call fsm_get_selected_file_header_hidden_flag_status
                                                    jc msi_shell_return_abnormal_error
                                                    ora a 
                                                    jz msi_shell_ls_command_specific_print_normal3
                                                    lxi h,msi_shell_ls_specific_yes_string
                                                    jmp msi_shell_ls_command_specific_print_hidden
msi_shell_ls_command_specific_print_normal3:        lxi h,msi_shell_ls_specific_no_string 
msi_shell_ls_command_specific_print_hidden:         call msi_shell_send_string_console
                                                    mvi a,msi_shell_carriage_return_character
                                                    call msi_shell_send_console_byte
                                                    mvi a,msi_shell_new_line_character
                                                    call msi_shell_send_console_byte  
                                                    jmp msi_shell_ls_command_end            
msi_shell_ls_command_end:                           jmp msi_shell_command_prompt_initialize




msi_shell_mem_command:      lxi h,msi_shell_mem_installed_string
                            call msi_shell_send_string_console
                            call bios_avabile_ram_memory
                            mov c,l 
                            mov b,h 
                            call msi_shell_send_console_address_number
                            mvi a,msi_shell_space_character
                            call msi_shell_send_console_byte 
                            lxi h,msi_shell_ls_specific_bytes_string
                            call msi_shell_send_string_console
                            mvi a,msi_shell_carriage_return_character
                            call msi_shell_send_console_byte
                            mvi a,msi_shell_new_line_character
                            call msi_shell_send_console_byte

                            lxi h,msi_shell_mem_available_string
                            call msi_shell_send_string_console
                            call mms_free_high_ram_bytes
                            mov c,l 
                            mov b,h 
                            call msi_shell_send_console_address_number
                            mvi a,msi_shell_space_character
                            call msi_shell_send_console_byte 
                            lxi h,msi_shell_ls_specific_bytes_string
                            call msi_shell_send_string_console
                            mvi a,msi_shell_carriage_return_character
                            call msi_shell_send_console_byte
                            mvi a,msi_shell_new_line_character
                            call msi_shell_send_console_byte

                            lxi h,msi_shell_mem_system_string
                            call msi_shell_send_string_console
                            lxi b,high_memory_start
                            call msi_shell_send_console_address_number
                            mvi a,msi_shell_space_character
                            call msi_shell_send_console_byte 
                            lxi h,msi_shell_ls_specific_bytes_string
                            call msi_shell_send_string_console
                            mvi a,msi_shell_carriage_return_character
                            call msi_shell_send_console_byte
                            mvi a,msi_shell_new_line_character
                            call msi_shell_send_console_byte

                            jmp msi_shell_command_prompt_initialize
                            
                            


msi_shell_ver_command:      lxi h,msi_system_version_message 
                            call msi_shell_send_string_console
                            mvi a,current_system_version
                            rar 
                            rar 
                            rar 
                            rar 
                            ani $0f 
                            call msi_shell_send_console_byte_number
                            mvi a,$2E 
                            call msi_shell_send_console_byte 
                            mvi a,current_system_version
                            ani $0f 
                            call msi_shell_send_console_byte_number
                            mvi a,msi_shell_carriage_return_character 
                            call msi_shell_send_console_byte
                            mvi a,msi_shell_new_line_character 
                            call msi_shell_send_console_byte
                            jmp msi_shell_command_prompt_initialize
                            

msi_shell_echo_command:         mvi a,1
                                call msi_shell_point_argument
                                ora a 
                                jz msi_shell_echo_command_end
msi_shell_echo_command_print:   call mms_read_selected_data_segment_byte
                                jc msi_shell_echo_command_end
                                ora a 
                                jz msi_shell_echo_command_end
                                call msi_shell_send_console_byte
                                inx h 
                                jmp msi_shell_echo_command_print
msi_shell_echo_command_end:     mvi a,msi_shell_carriage_return_character 
                                call msi_shell_send_console_byte
                                mvi a,msi_shell_new_line_character 
                                call msi_shell_send_console_byte 
                                jmp msi_shell_command_prompt_initialize

msi_shell_cd_command:               mvi a,1 
                                    call msi_shell_point_argument
                                    ora a 
                                    jz msi_shell_cd_command_not_found
                                    call mms_read_selected_data_segment_byte
                                    jc msi_shell_cd_command_not_valid
                                    cpi $41
                                    jc msi_shell_cd_command_not_valid
                                    cpi $5B
                                    jnc msi_shell_cd_command_not_valid
                                    mov b,a 
                                    inx h 
                                    call mms_read_selected_data_segment_byte
                                    jc msi_shell_command_cd_select_disk
                                    ora a 
                                    jz msi_shell_command_cd_select_disk
                                    cpi msi_shell_space_character
                                    jz msi_shell_command_cd_select_disk
                                    cpi ":"
                                    jnz msi_shell_cd_command_not_valid
                                    inx h 
                                    call mms_read_selected_data_segment_byte
                                    jc msi_shell_command_cd_select_disk
                                    cpi msi_shell_space_character
                                    jz msi_shell_command_cd_select_disk
                                    ora a 
                                    jz msi_shell_command_cd_select_disk
                                    cpi "/"
                                    jnz msi_shell_cd_command_not_valid
                                    inx h 
                                    call mms_read_selected_data_segment_byte
                                    jc msi_shell_command_cd_select_disk
                                    ora a 
                                    jz msi_shell_command_cd_select_disk
                                    cpi msi_shell_space_character
                                    jnz msi_shell_cd_command_not_valid
msi_shell_command_cd_select_disk:   mov a,b 
                                    call fsm_select_disk
                                    cpi fsm_operation_ok
                                    jz msi_shell_cd_command_save
                                    cpi fsm_device_not_found
                                    jz msi_shell_cd_command_not_found
                                    jmp msi_shell_return_abnormal_error
msi_shell_cd_command_save:          mov a,b 
                                    sta msi_shell_cd_command_save
                                    jmp msi_shell_cd_command_end 
msi_shell_cd_command_not_valid:     lxi h,msi_shell_cd_command_path_not_valid_string
                                    jmp msi_shell_print_error_message
msi_shell_cd_command_not_found:     lxi h,msi_shell_cd_command_not_valid_string 
                                    jmp msi_shell_print_error_message
msi_shell_cd_command_end:           jmp msi_shell_command_prompt_initialize

msi_shell_dev_command:              ora a 
                                    ;jnz msi_shell_dev_command_specific
                                    lxi h,msi_shell_dev_header_string
                                    call msi_shell_send_string_console
                                    mvi b,0 
msi_shell_dev_command_loop:         mov a,b 
                                    call bios_get_IO_device_informations
                                    cpi bios_IO_device_not_found
                                    jz msi_shell_dev_command_end
                                    lxi h,0 
                                    dad sp 
                                    mvi c,4 
msi_shell_dev_command_println:      mov a,b 
                                    call msi_shell_send_console_byte_number
                                    mov a,b 
                                    cpi 10
                                    jnc msi_shell_dev_command_println_tab
                                    mvi a,msi_shell_space_character
                                    call msi_shell_send_console_byte 
msi_shell_dev_command_println_tab:  mov a,b 
                                    cpi 100
                                    jnc msi_shell_dev_command_println_tab2
                                    mvi a,msi_shell_space_character
                                    call msi_shell_send_console_byte 
msi_shell_dev_command_println_tab2: push h 
                                    lxi h,msi_shell_dev_tab_space
                                    call msi_shell_send_string_console
                                    pop h 
msi_shell_dev_command_println2:     mov a,m 
                                    call msi_shell_send_console_byte
                                    inx h 
                                    dcr c 
                                    jnz msi_shell_dev_command_println2
                                    mvi a,msi_shell_carriage_return_character 
                                    call msi_shell_send_console_byte
                                    mvi a,msi_shell_new_line_character
                                    call msi_shell_send_console_byte 
                                    inr b 
                                    jmp msi_shell_dev_command_loop 
msi_shell_dev_command_end:          mvi a,msi_shell_carriage_return_character 
                                    call msi_shell_send_console_byte
                                    mvi a,msi_shell_new_line_character
                                    call msi_shell_send_console_byte 
                                    jmp msi_shell_command_prompt_initialize

msi_shell_return_abnormal_error:    mov b,a
                                    mvi a,msi_shell_carriage_return_character
                                    call msi_shell_send_console_byte
                                    mvi a,msi_shell_new_line_character
                                    call msi_shell_send_console_byte
                                    lxi h,msi_shell_abnormal_error
                                    call msi_shell_send_string_console
                                    mov a,b 
                                    call msi_shell_send_console_byte_number
                                    mvi a,msi_shell_carriage_return_character
                                    call msi_shell_send_console_byte
                                    mvi a,msi_shell_new_line_character
                                    call msi_shell_send_console_byte    
                                    jmp msi_shell_command_prompt_initialize    

msi_shell_print_error_message:      call msi_shell_send_string_console
                                    jmp msi_shell_command_prompt_initialize 

MSI_layer_end:
.print "Space left in MSI layer ->",MSI_dimension-MSI_layer_end+MSI 
.memory "fill", MSI_layer_end, MSI_dimension-MSI_layer_end+MSI,$00

.print "MSI load address ->",MSI 
.print "All functions built successfully"
.print "System calls number -> ",(msi_system_calls_id_table_end-msi_system_calls_id_table)/2
.print "System end ram address ->", SYSTEM_memory_end
.print "Space used by shell -> ",MSI_layer_end-msi_shell_start_address
