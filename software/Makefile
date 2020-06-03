# Makefile for RISCV gcc cross-compile
# this requires $RISCV/bin to be on the $PATH
CC      = riscv32-unknown-elf-gcc
LD 		= riscv32-unknown-elf-ld
OBJDUMP = riscv32-unknown-elf-objdump
OBJCOPY = riscv32-unknown-elf-objcopy
ELF2HEX = riscv32-unknown-elf-elf2hex
READELF = riscv32-unknown-elf-readelf
# Custom C Runtime
CRT = crt0.s
# flags
CFLAGS 	= -O0 -march=rv32i -mabi=ilp32 
CXXFLAGS = -ffreestanding -Wl,-T,riscv32-fpga.ld -nostartfiles -nostdlib -nodefaultlibs 
# --gc-sections,

LDFLAGS = 

# -d, or use -D to see non-executable sections such as .ro_data
DFLAGS 	= -D
OBJCOPYELFFLAGS = -O elf32-littleriscv
OBJCOPYVHEXFLAGS 	= -O verilog
# for generating intermediate ELFs
RAMSECTIONS = --only-section .data* --only-section .sdata*
ROMSECTIONS = --remove-section .data* --remove-section .sdata*
HFLAGS 	= --bit-width 32 
READELFFLAGS = -p 
# directories
ELF = 
SRC = src/
BUILD = build/
# suffixes, vhex is used for verilog memory format
.SUFFIXES: .hex .elf .vhex .asm .all .elfrom .elfram
	
clean:
	-rm -rf build/*


test: hello.elf
	
# make everything (VHEX, HEX, ASM) from a .c

test3: hello3.asm


test_asm: hello3.elf
	$(OBJDUMP) $(DFLAGS) $< > $@

# maybe remove .all from suffixes?

# todo: we need a way of Make'ing any C file, and/or using a list of dependencies as objects

all: hello5.asm hello5.vhex hello5.hex


	
# Make Help:
# $@ is the name of the file to be made (target file)
# $? is the names of the changed dependents
# $< is the name of the related file that caused the action (source file)
# $* is the prefix shared by the target and dependent files


# make elf files from C files
.c.elf:
	$(CC) $(CFLAGS) $(CXXFLAGS) $< $(CRT) -o $(ELF)$@

# Generate output products from ELF files
.elf.asm: 
	$(OBJDUMP) $(DFLAGS) $(ELF)$< > $(BUILD)$@
	$(READELF) $(READELFFLAGS) .comment $(ELF)$< > $(BUILD)$*_comments.txt
	$(READELF) $(READELFFLAGS) .riscv.attributes $(ELF)$< > $(BUILD)$*_riscv_attributes.txt
	$(READELF) --headers $(ELF)$< > $(BUILD)$*_elf_info.txt

.elf.hex:
	@echo creating temp ELF files with just ROM/RAM contents
	$(OBJCOPY) $(OBJCOPYELFFLAGS) $(ROMSECTIONS) $(ELF)$< $(ELF)$*_rom.elf
	$(OBJCOPY) $(OBJCOPYELFFLAGS) $(RAMSECTIONS) $(ELF)$< $(ELF)$*_ram.elf
	
	@echo creating HEX files for each of these
	$(ELF2HEX) $(HFLAGS) --input $(ELF)$*_rom.elf --output $(BUILD)$*_rom.hex 
	$(ELF2HEX) $(HFLAGS) --input $(ELF)$*_ram.elf --output $(BUILD)$*_ram.hex 
	
	@echo Creating overall HEX file
	$(ELF2HEX) $(HFLAGS) --input $(ELF)$< --output $(BUILD)$@ 

.elf.vhex:
	$(OBJCOPY) $(OBJCOPYVHEXFLAGS) $(ELF)$< $(BUILD)$*.vhex

	
	