;Il BIOS prevede l'implementazione di una serie di funzioni a basso livello che devono adattarsi alle varie specifiche della macchina fisica. 
;Tra le funzioni disponibili troviamo:
;-  funzioni di avvio (bios_cold_boot e bios_warm_boot) che servono per inizializzare le risorse ed eventualmente eseguire test preliminari. In particolare, bios_cold_boot
;   viene invocata dopo l'avvio del computer, mentre bios_warm_boot viene utilizzata invocata quando è necessario un reset interno
;-  funzioni per la gestione della console, che servono per la gestione dei dispositivi base per l'interazione con l'utente (lettura di caratteri e stampa su schermo)
;-  funzioni per la gestione delle memorie di massa, tra cui sono presenti alcune dedicate alla selezione di tracce, settori e testine e altre alla gestione del flusso dei dati, tra cui lettura
;   scrittura di una traccia e formattazione del disco
;-  funzioni per la copia di blocchi di memoria, che vengono utilizzati nel caso di trasferimenti di grandi blocchi di dati da e verso la memoria. 

bios_ram_dimension      .equ 32768


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
                jmp bios_mass_memory_write_enable_status 
                jmp bios_mass_memory_write_sector 
                jmp bios_mass_memory_read_sector  
                jmp bios_mass_memory_format_drive 
                jmp bios_mem_copy
;bios_cold_boot esegue un test e un reset della memoria ram e procede con l'inizializzazione delle risorse hardware. Tra le operazioni che deve eseguire troviamo quindi:
;- inizializzazione e test (facoltativo) della ram 
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa

bios_cold_boot:         lxi h,0 
                        lxi d,bios_ram_dimension 
bios_memory_test_loop:  mvi m,0 
                        inx h 
                        mov a,e 
                        sub l 
                        mov a,d 
                        sbb h 
                        jnz bios_memory_test_loop
                        ret 

;bios_warm_boot esegue delle operazioni simili a bios_warm_boot escludendo il test e l'inizializzazione della ram. Prevede quindi:
;- inzializzazione dei dispositivi per interfacciare la console
;- inzializzazione dei dispositivi per la gestione delle memoria di massa
;tuttavia, è possibile specificare operazioni diverse per la gestione dei dispositivi IO, in caso si desidera ad esempio lasciare invariato il setup dei dispositivi
bios_warm_boot:         ret 

;bios_console_output_write_character e bios_console_output_ready sono due funzioni dedicate alla gestione del lato output della console (monitor). In particolare:
;-  bios_console_output_ready restituisce lo stato dell'output della console (pronto per ricevere dati o no)
;-  bios_console_output_write_character manda in output il carattere ASCII ricevuto

;bios_console_output_write_character
; A -> carattere ASCII da scrivere
bios_console_output_write_character:    ret 

;bios_console_output_ready
; A <- stato della console (lato output)
bios_console_output_ready:  ret 

;bios_console_input_read_character e bios_console_input_ready sono due funzioni dedicate alla gestione del lato input della console (tastiera). In particolare:
;-  bios_console_input_ready restituisce lo stato dell'input della console (dato in attesa di essere letto o no)
;-  bios_console_input_read_character preleva il carattere ASCII in ingresso dalla console

;bios_console_input_ready
; A <- stato della console (lato input)
bios_console_input_ready:   ret 

;bios_console_input_read_character 
; A <- carattere ASCII in ingresso
bios_console_input_read_character:  ret 

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
; A <- bytes per settore codificati in potenza di 2 da 128. Assume $00 se l'operazione non ha avuto successo 
; B <- numero di settori per traccia
; C <- numero di testine
; DE <- numero di tracce

bios_mass_memory_select_drive:  ret 

;bios_mass_memory_select_sector
; A -> settore da selezionare 
; A <- esito dell'operazione
bios_mass_memory_select_sector: ret 

;bios_mass_memory_select_track
; HL -> traccia da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_track: ret 

;bios_mass_memory_select_head
; A -> testina da selezionare
; A <- esito dell'operazione
bios_mass_memory_select_head: ret 

;bios_mass_memory_write_enable_status verifica se la memoria di massa è abilitata alla scrittura.
; A <- esito dell'operazione
bios_mass_memory_write_enable_status: ret 

;Le seguenti funzioni servono per interagire con il lettore selezionato nella memoria di massa.
;-  bios_mass_memory_write_sector scrive i dati nel settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo in memoria dei dati da scrivere
;-  bios_mass_memory_read_sector legge i dati dal settore selezionato e restituisce l'esito dell'operazione. Gli viene passato un indirizzo della ram per indicare dove scrivere i dati ricevuti
;-  bios_mass_memory_format_drive formatta l'intero disco, sovrascrivendo tutti i dati e restituisce l'esito dell'operazione

;bios_mass_memory_write_sector
; HL -> indirizzo in memoria 
; A <- esito dell'operazione
bios_mass_memory_write_sector:  ret 

; bios_mass_memory_read_sector
; HL -> indirizzo in memoria
; A <- esito dell'operazione
bios_mass_memory_read_sector:   ret 

;bios_mass_memory_format_drive
; A <- esito dell'operazione
bios_mass_memory_format_drive:  ret 

;opzionalmente può essere inserito un dispositivo DMA per gestire il flusso dati CPU/IO in modo più efficente. Il dispositivo DMa può essere inizializzato nelle funzioni cold_boot e warm_boot e i trasferimenti
;possono essere avviati e gestiti tramite le funzioni bios_mass_memory_write_sector e bios_mass_memory_read_sector.

;bios_mem_copy viene utilizzata per la copia di grandi quantità di dati all'interno della memoria. Dato che alcuni dispositivi DMA possono gestire il trasferimento mem-to-mem si preferisce mantenere 
;questa funzione nel bios. Nel caso non sia presente un dispositivo DMA o non sia disponibile la funzionalità, è possibile implementare una copoa software dei dati
; DE -> indirizzo sorgente
; HL -> indirizzo destinazione
; A <- esito dell'operazione 
; DE <- indirizzo sorgente dopo l'esecuzione
; HL <- indirizzo destinazione dopo l'esecuzione 

bios_mem_copy:  ret 