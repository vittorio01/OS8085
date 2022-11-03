MSI=sources/main_system_interface/MSI.8085.asm
FSM=sources/file_system_manager/FSM.8085.asm
MMS=sources/memory_management/MMS.8085.asm
BIOS=sources/bios/BIOS_MINIMAL.8085.asm
LIBRARIES_DIR=sources/libraries
LIBRARIES=$(LIBRARIES_DIR)/libraries.8085.asm

SYSTEM_CALLS_DIR=sources/constraints/
ASSEMBLER=retroassembler/retroassembler.dll

TEMP=/tmp/8085compiler
OUTPUT=bin

target: $(MSI) $(FSM) $(MMS) $(BIOS) $(MAIN)
	rm -rf $(TEMP)
	mkdir $(TEMP)
	mkdir $(TEMP)/bin
	cp $(MSI) $(TEMP)/MSI.8085.asm
	cp $(FSM) $(TEMP)/fsm.8085.asm
	cp $(MMS) $(TEMP)/mms.8085.asm
	cp $(BIOS) $(TEMP)/BIOS.8085.asm
	cp -r $(LIBRARIES_DIR)/* $(TEMP)
	cp -r $(SYSTEM_CALLS_DIR)/* $(TEMP)
	cp $(LIBRARIES) $(TEMP)
	@echo selected BIOS: $(BIOS)
	@echo selected MSI:	$(MSI)
	@echo selected FSM: $(FSM)
	@echo selected MMS: $(MMS)
	@echo compiling main system files...
	dotnet $(ASSEMBLER) $(TEMP)/libraries.8085.asm $(TEMP)/bin/libraries_layer.bin
	dotnet $(ASSEMBLER) $(TEMP)/BIOS.8085.asm $(TEMP)/bin/bios_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/mms.8085.asm $(TEMP)/bin/mms_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/fsm.8085.asm $(TEMP)/bin/fsm_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/MSI.8085.asm $(TEMP)/bin/MSI_layer.bin 
	@echo All system files compiled succeffully 
	@echo Merging files generated...
	cat $(TEMP)/bin/MSI_layer.bin $(TEMP)/bin/fsm_layer.bin $(TEMP)/bin/mms_layer.bin $(TEMP)/bin/bios_layer.bin $(TEMP)/bin/libraries_layer.bin > $(TEMP)/bin/system.bin
	@echo system built succeffully 
	@echo copying generated files...
	rm -rf bin/*
	cp $(TEMP)/bin/* bin/
	rm -rf $(TEMP)
	@echo -------------------------------- 
	@echo Done. Files generated: 
	@ls bin
	