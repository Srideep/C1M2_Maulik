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
# Sources for main Make File
#-----------------------------------------------------------------------------

# Common sources needed by BOTH platforms
COMMON_SOURCES = main.c \
                 memory.c

# MSP432-specific sources (startup, interrupts, system config)
MSP432_SOURCES = interrupts_msp432p401r_gcc.c \
                 startup_msp432p401r_gcc.c \
                 system_msp432p401r.c

# Include paths
COMMON_INCLUDES = -I../include/common

MSP432_INCLUDES = -I../include/msp432 \
                  -I../include/CMSIS

#------------------------------------------------------------------------------
# Platform-conditional assignment
#------------------------------------------------------------------------------
ifeq ($(PLATFORM), HOST)
	SOURCES = $(COMMON_SOURCES)
	INCLUDES = $(COMMON_INCLUDES)
else ifeq ($(PLATFORM),MSP432)
    # MSP432 needs BOTH common sources AND platform-specific sources
    SOURCES = $(COMMON_SOURCES) $(MSP432_SOURCES)
    INCLUDES = $(COMMON_INCLUDES) $(MSP432_INCLUDES)
endif
