MCU=msp430f5510
SUPPORT_FILES=gcc/include/
ELF_PREFIX=gcc/bin/msp430-elf-
GDB_CONSOLE=gcc/bin/gdb_agent_console
MSP430_DAT=gcc/msp430.dat

HEADERS=msp430.nim msp430f5510.nim iomacros.nim
CODEFILES=main.nim ring.nim Makefile

NIMFLAGS=-d:release --os:standalone --opt:size --gc:none --deadCodeElim:on
# avr is the closest cpu for the moment
NIMFLAGS+=--cpu:avr
# running one C compiler lets its errors show
NIMFLAGS+=--parallelBuild:1 --verbosity:2
#location of include files
NIMFLAGS+=--passC:"-mmcu=$(MCU) -I$(SUPPORT_FILES) -g -minrt"
NIMFLAGS+=--passL:"-mmcu=$(MCU) -L$(SUPPORT_FILES) -T $(MCU).ld -Wl,--gc-sections -Wl,-M=output.map -g -gdwarf-2 -minrt"

%: %.nim panicoverride.nim
	nim c $(NIMFLAGS) -o:main.elf $<

main: $(HEADERS) $(CODEFILES)

all: main

listing: main
	echo "----------DISASSEMBLY OF TEXT SECTION---------" > asm.lst
	$(ELF_PREFIX)objdump -d main.elf >> asm.lst
	echo "---------SECTION SUMMARY/SYMBOL TABLE---------" >> asm.lst
	$(ELF_PREFIX)objdump -x main.elf >> asm.lst
	echo "--------------SECTION SIZES-------------------" >> asm.lst
	$(ELF_PREFIX)size main.elf >> asm.lst

debugserver:
	LD_LIBRARY_PATH=./gcc/bin/ $(GDB_CONSOLE) $(MSP430_DAT) &> ./gdb_agent_console.log &
	
debug:
	LD_LIBRARY_PATH=./gcc/bin/ $(ELF_PREFIX)gdb main.elf -ex "target remote :55000"

ezFetToTILib:
	sudo LD_LIBRARY_PATH=./gcc/bin/ ./mspdebug tilib --allow-fw-update
# taken from https://www.pabigot.com/msp430/exp430fr5969-launchpad-first-experiences/

mspdebug:
	sudo LD_LIBRARY_PATH=./gcc/bin/ ./mspdebug tilib

.PHONY: debug debugserver mspdebug ezFetToTILib
