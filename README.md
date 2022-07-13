# OS8085
OS8085 è un sistema operativo per microcomputer scritto interamente in assembly per intel 8085. L'obiettivo di questo progetto è sviluppare un OS standalone universale che può girare su computer i8085 / Z80. Vengono postati i listati ASM8085 per tutte le funzionalità e un makefile per compilare automaticamente il progetto, ancora in sviluppo. 

I files sorgenti, contenuti nella cartella sources, vengono compilati tramite il compilatore retroassembler (reperibile in questo indirizzo -> https://enginedesigns.net/retroassembler) e .NET 6. Per funzionare, il makefile richiede come parametro ASSEMBLER il file retroassembler.dll, da assegnare manualmente ogni volta che si deve eseguire il comando make:

makefile ASSEMBLER="path/to/assembler/retroassembler.dll" 

Nel comando deve anche essere specificato il BIOS personalizzato che si vuole compilare nel sistema operativo (nel caso non sia specificato compila automaticamente il bios minimale presente in sources/bios/BIOS_MINIMAL.8085.asm).

makefile ASSEMBLER="path/to/assembler/retroassembler.dll" BIOS="path/to/cbios/BIOS.8085.asm" 

Il comando compila tutti i files sorgenti e restituisce un output main.bin nella cartella bin del progetto, dove è contenuto tutto il sistema operativo compilato e pronto per essere installato nella ROM del computer o nel disco di avvio.
Per maggiori informazioni sulla struttura del SO è disponibile una guida in PDF nella cartella info (non ancora disponibile)
