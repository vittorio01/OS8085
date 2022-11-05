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
;Come detto precdentemente, la MSI ha il compito di inizializzare correttamente tutti i layers del sistema operativo. In particolare, tutti i layers devono essere inizializzati seguendo quest'ordine:
;-  BIOS 
;-  MMS 
;-  FSM 
;Per fare questo, ogni layer contiene le istruzioni di inizializzazione (il BIOS deve eseguire un cold boot)

;Nel caso in cui si richiama l'interrupt rst0, tutti i layers devono essere inizializzati nuovamente (il BIOS deve eseguire questa volta un warm boot)

;all'avvio, o a un reset, l'MSI lancia un'applicazione di sistema di default (una sheel) direttamente salvata nella memoria di massa (nome ed estenzioni definiti a priori nella programmazione del layer).
;La sheel, dato che è la prima applicazione ad essere avviata, permetterà all'utente di accedere ad un'interfaccia basilare a linea di comando (vedi la programmazione dell'applicazione)

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

;La sheel, ad esempio, utilizza un messaggio per comunicare all'applicazione da avviare gli i suoi argomenti opzionali.
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
.include "execution_codes.8085.asm"

rst0_address                .equ    $0000
rst1_address                .equ    $0008
rst2_address                .equ    $0010 
rst3_address                .equ    $0018
rst4_address                .equ    $0020

msi_HL_backup_address       .equ reserved_memory_start+$0050
msi_DE_backup_address       .equ reserved_memory_start+$0052
msi_BC_backup_address       .equ reserved_memory_start+$0054
msi_PSW_backup_address      .equ reserved_memory_start+$0056
msi_PC_backup_address       .equ reserved_memory_start+$0058
msi_SP_backup_address       .equ reserved_memory_start+$005A

msi_loaded_program_flags    .equ reserved_memory_start+$005C

MSI_functions:                  .org MSI
                                jmp msi_cold_start 

msi_shell_name          .text "sheel"
                        .b 0 
msi_shell_extenson      .text "sys"
                        .b 0


;per rendere più efficace la ricerca della system call desiderata viene utilizzata una tabella in cui ogni record da 2 bytes identifica l'indirizzo dell'handler dedcato (la posizione identifica l'handler)

msi_system_calls_id_table:      .word msi_system_call_exit 
                                ;.word msi_system_call_select_IO_device 
                               
msi_system_calls_id_table_end:  

msi_cold_start:                 lxi sp,stack_memory_start
                                call bios_cold_boot
                                call mms_low_memory_initialize
                                call fsm_init
                                call msi_interrupt_reset      
                                ;da definire 

                                mvi a,$0
                                lxi B,$BBCC 
                                lxi d,$DDEE 
                                lxi h,$1234
                                rst 1
                                hlt 

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
                                    ;da definire
                                    hlt 

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
                                        add a 
                                        mov e,a 
                                        mvi a,0 
                                        ral 
                                        mov d,a 
                                        lxi h,msi_system_calls_id_table
                                        dad d 
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


msi_system_calls_restore_HL_and_return:     lhld msi_SP_backup_address
                                            sphl 
                                            lhld msi_PC_backup_address
                                            push h 
                                            lhld msi_HL_backup_address
                                            ret 

msi_system_calls_return:                    lhld msi_SP_backup_address
                                            sphl 
                                            lhld msi_PC_backup_address
                                            push h 
                                            ret 

;handlers delle funzioni relative ai dispositivi IO     

;msi_IO_write_system_call_handler viene chiamata tramite l'interrupt rst2 e invia un byte al dispositivo IO selezionato precedentemente con rst1 
;A      -> byte da inviare 
;PSW    <- CY viene settato ad 1 se si è vrificato un errore. Tutte le altre flags non vengono modificate
;A      <- se CY = 1 ritorna l'errore generato, altrimenti assume lo stesso valore in ingresso alla funzione
msi_IO_write_system_call_handler:       shld msi_HL_backup_address
                                        pop h 
                                        shld msi_PC_backup_address
                                        lxi h,0 
                                        dad sp 
                                        shld msi_SP_backup_address
                                        push psw 
                                        pop h 
                                        shld msi_PSW_backup_address
                                        lxi sp,stack_memory_start
                                        call bios_write_selected_device_byte
                                        jc msi_IO_write_system_call_handler_error 
                                        lhld msi_PSW_backup_address
                                        push h 
                                        pop psw 
                                        stc 
                                        cmc 
                                        jmp msi_system_calls_restore_HL_and_return

msi_IO_write_system_call_handler_error: xchg 
                                        shld msi_DE_backup_address
                                        mov e,a 
                                        lhld msi_PSW_backup_address
                                        push h 
                                        pop psw  
                                        stc 
                                        mov a,e 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        jmp msi_system_calls_restore_HL_and_return
                                        ret 

;msi_IO_read_system_call_handler viene richiamata tramite l'interrupt rst3 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è vrificato un errore. Tutte le altre flags non vengono modificate
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce il carattere letto dal dispositivo IO

msi_IO_read_system_call_handler:        shld msi_HL_backup_address
                                        pop h 
                                        shld msi_PC_backup_address
                                        lxi h,0 
                                        dad sp 
                                        shld msi_SP_backup_address
                                        push psw 
                                        pop h 
                                        shld msi_PSW_backup_address
                                        lxi sp,stack_memory_start
                                        call bios_read_selected_device_byte
                                        jc msi_IO_read_system_call_handler_error 
                                        lhld msi_PSW_backup_address
                                        xchg 
                                        shld msi_DE_backup_address
                                        mov e,a 
                                        lhld msi_PSW_backup_address
                                        push h 
                                        pop psw  
                                        stc 
                                        cmc 
                                        mov a,e 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        jmp msi_system_calls_restore_HL_and_return

msi_IO_read_system_call_handler_error:  xchg 
                                        shld msi_DE_backup_address
                                        mov e,a 
                                        lhld msi_PSW_backup_address
                                        push h 
                                        pop psw  
                                        stc 
                                        mov a,e 
                                        lhld msi_DE_backup_address
                                        xchg 
                                        jmp msi_system_calls_restore_HL_and_return
                                        ret      

;msi_IO_get_state_system_call_handler viene richiamata tramite l'interrupt rst3 e legge un byte dal dispositivo IO selezionato precedentemente con rst1 
;PSW    <- CY viene settato ad 1 se si è verificato un errore. Tutte le altre flags non vengono modificate
;A      <- se CY = 1 ritorna l'errore generato, altrimenti restituisce lo stato del dispositivo IO

msi_IO_get_state_system_call_handler:       shld msi_HL_backup_address
                                            pop h 
                                            shld msi_PC_backup_address
                                            lxi h,0 
                                            dad sp 
                                            shld msi_SP_backup_address
                                            push psw 
                                            pop h 
                                            shld msi_PSW_backup_address
                                            lxi sp,stack_memory_start
                                            call bios_get_selected_device_state
                                            jc msi_IO_write_system_call_handler_error 
                                            xchg 
                                            shld msi_DE_backup_address
                                            mov e,a 
                                            lhld msi_PSW_backup_address
                                            push h 
                                            pop psw  
                                            stc 
                                            cmc 
                                            mov a,e 
                                            lhld msi_DE_backup_address
                                            xchg  
                                            jmp msi_system_calls_restore_HL_and_return

msi_IO_get_state_system_call_handler_error: xchg 
                                            shld msi_DE_backup_address
                                            mov e,a 
                                            lhld msi_PSW_backup_address
                                            push h 
                                            pop psw  
                                            stc 
                                            mov a,e 
                                            lhld msi_DE_backup_address
                                            xchg 
                                            jmp msi_system_calls_restore_HL_and_return
                                            ret      

;implementazione delle system calls standard rst1 

msi_system_call_exit:   mvi a,$CC 
                        hlt 


MSI_layer_end:
.print "Space left in MSI layer ->",MSI_dimension-MSI_layer_end+MSI 
.memory "fill", MSI_layer_end, MSI_dimension-MSI_layer_end+MSI,$00

.print "MSI load address ->",MSI 
.print "All functions built successfully"