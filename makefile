CPS=sources/console_processor/CPS.8085.asm
FSM=sources/file_system_manager/FSM.8085.asm
MMS=sources/memory_management/MMS.8085.asm
BIOS=sources/px_mini_bios/BIOS.8085.asm
MAIN=sources/main.8085.asm
ASSEMBLER=retroassembler/retroassembler.dll

TEMP=/tmp/compiled
OUTPUT=bin

target: $(CPS) $(FSM) $(MMS) $(BIOS) $(MAIN)
	@echo compiling main system files...
	dotnet $(ASSEMBLER) $(MAIN) $(OUTPUT)/
	