CPS=sources/console_processor/CPS.8085.asm
FSM=sources/file_system_manager/FSM.8085.asm
MMS=sources/memory_management/MMS.8085.asm
BIOS=sources/bios/BIOS_MINIMAL.8085.asm
MAIN=sources/main.8085.asm
ASSEMBLER=retroassembler/retroassembler.dll

TEMP=/tmp/compiled
OUTPUT=bin

target: $(CPS) $(FSM) $(MMS) $(BIOS) $(MAIN)
	@echo selected bios: $(BIOS)
	@echo selected CPS:	$(CPS)
	@echo selected FSM: $(FSM)
	@echo selected MMS: $(MMS)
	@echo compiling main system files...
	dotnet $(ASSEMBLER) $(MAIN) $(OUTPUT)/
	@echo -------------------------------- 
	@echo files generated: 
	@ls bin
	