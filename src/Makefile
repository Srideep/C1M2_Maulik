#******************************************************************************
# Copyright (C) 2017 by Alex Fosdick - University of Colorado
#
# Redistribution, modification or use of this software in source or binary
# forms is permitted as long as the files maintain this copyright. Users are 
# permitted to modify this and use it to learn about the field of embedded
# software. Alex Fosdick and the University of Colorado are not liable for any
# misuse of this material. 
#
#*****************************************************************************

#------------------------------------------------------------------------------
# Multi-platform build system for HOST (native) and MSP432 (ARM Cortex-M4)
#
# Use: make [TARGET] PLATFORM=[HOST|MSP432]
#
# Build Targets:
#      build        - Compile all sources and link into c1m2.out
#      compile-all  - Compile all sources to object files (no linking)
#      clean        - Remove all generated files
#      %.i          - Generate preprocessed output for a source file
#      %.asm        - Generate assembly output for a source file
#      %.o          - Generate object file for a source file
#
#------------------------------------------------------------------------------


###############################################################################
# c1m2 – Multi-platform Makefile (HOST & MSP432)
###############################################################################

# ---------------------- Platform selection -----------------------------------

# Must be HOST or MSP432 (pass on command line: PLATFORM=HOST or PLATFORM=MSP432)
PLATFORM ?= HOST

# Bring in SOURCES and INCLUDES for this platform
include sources.mk

# ---------------------- Output names -----------------------------------------

TARGET  := c1m2.out
MAPFILE := c1m2.map

OBJECTS := $(SOURCES:.c=.o)
DEPS    := $(SOURCES:.c=.d)

# ---------------------- Toolchain commands -----------------------------------

CC      :=
LD      :=
SIZE    :=
OBJDUMP :=

# ---------------------- Common flags (both platforms) ------------------------

CFLAGS     := -Wall -Werror -g -O0 -std=c99
CPPFLAGS   := $(INCLUDES) -D$(PLATFORM)
LDFLAGS    :=
ARCH_FLAGS :=

# Architecture-related variables (for ARM)
LINKER_FILE := msp432p401r.lds
CPU         := cortex-m4
ARCH        := armv7e-m
SPECS       := nosys.specs

# ---------------------- Platform-specific setup ------------------------------

ifeq ($(PLATFORM),HOST)

CC      := gcc
LD      := gcc
SIZE    := size
OBJDUMP := objdump

# Host build: no special arch flags
ARCH_FLAGS :=

# Still generate a map file
LDFLAGS += -Wl,-Map=$(MAPFILE)

else ifeq ($(PLATFORM),MSP432)

CC      := arm-none-eabi-gcc
LD      := arm-none-eabi-gcc
SIZE    := arm-none-eabi-size
OBJDUMP := arm-none-eabi-objdump

ARCH_FLAGS := \
  -mcpu=$(CPU)        \
  -mthumb             \
  -march=$(ARCH)      \
  -mfloat-abi=hard    \
  -mfpu=fpv4-sp-d16   \
  --specs=$(SPECS)
  -Wno-error=attributes

# MSP432: use linker script + map file
LDFLAGS += $(ARCH_FLAGS) -T $(LINKER_FILE) -Wl,-Map=$(MAPFILE)

else
  $(error Unsupported PLATFORM "$(PLATFORM)". Use PLATFORM=HOST or PLATFORM=MSP432)
endif

# Add arch flags and dependency generation to compile flags
CFLAGS += $(ARCH_FLAGS) -MMD -MP

# ---------------------- Phony targets ----------------------------------------

.PHONY: all build compile-all clean asm preproc

# Default target
all: build

# Build = compile everything and link executable
build: $(TARGET)

# Compile all object files, but DO NOT link
compile-all: $(OBJECTS)

# Generate all preprocessed .i files
preproc: $(SOURCES:.c=.i)

# Generate assembly for each C file AND disasm of final executable
asm: $(SOURCES:.c=.asm) $(TARGET:.out=.asm)

# ---------------------- Pattern rules ----------------------------------------

# Object files
%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

# Preprocessed output (.i)
%.i: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -E $< -o $@

# Assembly from C (.asm)
%.asm: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) -S $< -o $@

# Disassembly of final executable → c1m2.asm
$(TARGET:.out=.asm): $(TARGET)
	$(OBJDUMP) -D $< > $@

# ---------------------- Link rule + size report ------------------------------

$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	$(SIZE) $@

# ---------------------- Clean ------------------------------------------------

clean:
	rm -f $(OBJECTS) $(DEPS) $(TARGET) $(MAPFILE) \
	      $(SOURCES:.c=.i) $(SOURCES:.c=.asm) $(TARGET:.out=.asm)

# ---------------------- Auto-dependencies ------------------------------------

-include $(DEPS)
