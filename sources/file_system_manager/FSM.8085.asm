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
;-  un byte per identificare il tipo di file 
;-  18 bytes per memorizzare nome ed estenzione del file, separate da un punto (ad esempio file.exe) 
;-  2 bytes per indicare il numero di blocchi occupati dal file
;-  2 bytes che mantengono l'indirizzo della prima pagina dei dati

;-------------------------------------------------------------------------------------------
;- tipo - nome ed estenzione - dimensione (in pagine) - puntatore alla prima pagina indici -
;-------------------------------------------------------------------------------------------

;L'intestazione di un file è quindi di dimensone fissa prestabilita (32 bytes)

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
;       * numero di pagine disponibii           (2 bytes)
;       * puntatore al primo settore della fat  (2 bytes)
;       * numero di settori dedicate al sistema (4 bytes)
;       Il resto del settore contiene le istruzioni per l'avvio del sistema operativo (se presenti)

;-  Il sistema operativo occupa una certa zona riservata del disco, oltre alla parte rimanente del settore di avvio, e può avere una dimensione massima di 64KB (dato che deve essere caricao in memoria)
;   All'avvio, il computer carica in memoria tutto il codice de sistema operativo ed esegue l'istruzione di salto del settore di avvio
;-  La File Allocation Table contiene la tabella di allocazione, la sua dimensione dipende dal numero di pagine disponibili nel disco 
;-  La zona dati comprende la parte restante del disco e contiene intestazioni e corpo dei files, organizzati come detto precedentemente
;----------------------------------------------------------------------
;- settore di avvio - sistema operativo (opzionale) - FAT - Zona dati -
;----------------------------------------------------------------------

