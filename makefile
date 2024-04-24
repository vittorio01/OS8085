BIOS=BIOS_MINIMAL
BIOS_DIR=sources/bios/$(BIOS).8085.asm

MSI=sources/main_system_interface/MSI.8085.asm
FSM=sources/file_system_manager/FSM.8085.asm
MMS=sources/memory_management/MMS.8085.asm
LIBRARIES_DIR=sources/libraries
LIBRARIES=$(LIBRARIES_DIR)/libraries.8085.asm

FIRMWARE=PX1_full

SYSTEM_CALLS_DIR=sources/constraints/
ASSEMBLER=retroassembler/retroassembler.dll

TEMP=tmp
OUTPUT=bin

FIRMWARE_DIR=boards/firmwares/$(FIRMWARE)/
BOOTLOADER_DIR=boards/bootloaders/$(FIRMWARE)/
all: system firmware bootloader

system: $(MSI) $(FSM) $(MMS) $(BIOS_DIR) $(MAIN) 
	rm -rf $(TEMP)
	mkdir $(TEMP)
	mkdir $(TEMP)/bin
	cp $(MSI) $(TEMP)/msi.8085.asm
	cp $(FSM) $(TEMP)/fsm.8085.asm
	cp $(MMS) $(TEMP)/mms.8085.asm
	cp $(BIOS_DIR) $(TEMP)/BIOS.8085.asm
	cp -r $(LIBRARIES_DIR)/* $(TEMP)
	cp -r $(SYSTEM_CALLS_DIR)/* $(TEMP)
	cp $(LIBRARIES) $(TEMP)
	@echo selected BIOS: $(BIOS_DIR)
	@echo selected MSI:	$(MSI)
	@echo selected FSM: $(FSM)
	@echo selected MMS: $(MMS)
	@echo compiling main system files...
	dotnet $(ASSEMBLER) $(TEMP)/libraries.8085.asm $(TEMP)/bin/libraries_layer.bin
	dotnet $(ASSEMBLER) $(TEMP)/BIOS.8085.asm $(TEMP)/bin/bios_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/mms.8085.asm $(TEMP)/bin/mms_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/fsm.8085.asm $(TEMP)/bin/fsm_layer.bin 
	dotnet $(ASSEMBLER) $(TEMP)/msi.8085.asm $(TEMP)/bin/msi_layer.bin 
	@echo All system files compiled succeffully 
	@echo Merging files generated...
	cat $(TEMP)/bin/msi_layer.bin $(TEMP)/bin/fsm_layer.bin $(TEMP)/bin/mms_layer.bin $(TEMP)/bin/bios_layer.bin $(TEMP)/bin/libraries_layer.bin > $(TEMP)/bin/system.bin
	@echo system built succeffully 
	@echo copying generated files...
	rm -rf bin/*
	cp $(TEMP)/bin/* bin/
	rm -rf $(TEMP)
	@echo -------------------------------- 
	@echo Done. Files generated: 
	@ls bin
	@echo --------------------------------
	@echo 


firmware: 
	@echo selected FIRMWARE: $(FIRMWARE)
	rm -rf $(TEMP)
	mkdir $(TEMP)
	cp -r $(FIRMWARE_DIR)/* $(TEMP)
	cp -r $(LIBRARIES_DIR)/* $(TEMP)
	@echo building firmware image...
	dotnet $(ASSEMBLER) $(TEMP)/$(FIRMWARE)_firmware.8085.asm bin/firmware.bin
	rm -rf $(TEMP)
	@echo -------------------------------- 
	@echo Done. Files generated: 
	@ls bin
	@echo --------------------------------
	@echo 
	
bootloader: 
	@echo selected bootloader for FIRMWARE: $(FIRMWARE)
	rm -rf $(TEMP)
	mkdir $(TEMP)
	cp -r $(BOOTLOADER_DIR)/* $(TEMP)
	cp -r $(LIBRARIES_DIR)/* $(TEMP)
	@echo building bootloader...
	dotnet $(ASSEMBLER) $(TEMP)/$(FIRMWARE)_system_bootloader.8085.asm bin/bootloader.bin