;Il BIOS prevede l'implementazione di una serie di funzioni a basso livello che devono adattarsi alle varie specifiche della macchina fisica. 
;Tra le funzioni disponibili troviamo:
;-  funzioni di avvio (bios_cold_boot e bios_warm_boot) che servono per inizializzare le risorse ed eventualmente eseguire test preliminari. In particolare, bios_cold_boot
;   viene invocata dopo l'avvio del computer, mentre bios_warm_boot viene utilizzata invocata quando è necessario un reset interno
;-  funzioni per la gestione della console, che servono per la gestione dei dispositivi base per l'interazione con l'utente (lettura di caratteri e stampa su schermo)
;-  funzioni per la gestione delle memorie di massa, tra cui sono presenti alcune dedicate alla selezione di tracce, settori e testine e altre alla gestione del flusso dei dati, tra cui lettura
;   scrittura di una traccia e formattazione del disco
;-  funzioni per la copia di blocchi di memoria, che vengono utilizzati nel caso di trasferimenti di grandi blocchi di dati da e verso la memoria. 

.include "os_constraints.8085.asm"
.include "libraries_system_calls.8085.asm"
.include "execution_codes.8085.asm"

bios_functions: .org BIOS 
                jmp bios_cold_boot 
                jmp bios_warm_boot 
                jmp bios_console_output_read_character
                jmp bios_console_output_ready 
                jmp bios_console_input_read_character 
                jmp bios_console_input_ready 
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
                
;bios_cold_boot esegue un test e un reset della memoria ram e procede con l'inizializzazione delle risorse hardware. Tra le operazioni che deve eseguire troviamo quindi:
;- inizializzazione e test (facoltativo) della ram 
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa

bios_cold_boot:         ;da implementare
                        ret 

;bios_warm_boot esegue delle operazioni simili a bios_warm_boot escludendo il test e l'inizializzazione della ram. Prevede quindi:
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa
;tuttavia, è possibile specificare operazioni diverse per la gestione dei dispositivi IO, in caso si desidera ad esempio lasciare invariato il setup dei dispositivi
bios_warm_boot:         ;da implementare
                        ret 

;bios_console_output_write_character e bios_console_output_ready sono due funzioni dedicate alla gestione del lato output della console (monitor). In particolare:
;-  bios_console_output_ready restituisce lo stato dell'output della console (pronto per ricevere dati o no)
;-  bios_console_output_write_character manda in output il carattere ASCII ricevuto

;bios_console_output_write_character
; A -> carattere ASCII da scrivere
bios_console_output_write_character:    ;da implementare
                                        ret 

;bios_console_output_ready
; A <- stato della console (lato output)
bios_console_output_ready:  ;da implementare
                            ret 

;bios_console_input_read_character e bios_console_input_ready sono due funzioni dedicate alla gestione del lato input della console (tastiera). In particolare:
;-  bios_console_input_ready restituisce lo stato dell'input della console (dato in attesa di essere letto o no)
;-  bios_console_input_read_character preleva il carattere ASCII in ingresso dalla console

;bios_console_input_ready
; A <- stato della console (lato input)
bios_console_input_ready:   ;da implementare
                            ret 

;bios_console_input_read_character 
; A <- carattere ASCII in ingresso
bios_console_input_read_character:  ;da implementare
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
                            jz bios_memo_copy_end
                            ldax d 
                            mov m,a 
                            dcx b 
                            inx h 
                            inx d 
                            jmp bios_mem_copy
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