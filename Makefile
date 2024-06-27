# Compiler and tools
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
CP = arm-none-eabi-objcopy
SZ = arm-none-eabi-size

# Project name
TARGET = stm32f411ret6

# Directories
SRCDIR = Core/Src
INCDIR = Core/Inc
STARTUP_DIR = Core/Startup
DRVDIR = Drivers

# Source files
SRCS = $(wildcard $(SRCDIR)/*.c) \
       $(wildcard $(DRVDIR)/STM32F4xx_HAL_Driver/Src/*.c) \
       $(wildcard $(DRVDIR)/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/*.c) \
       $(wildcard $(STARTUP_DIR)/*.s)

# Object files
OBJS = $(SRCS:.c=.o)

# Includes
INCLUDES = -I$(INCDIR) \
           -I$(DRVDIR)/STM32F4xx_HAL_Driver/Inc \
           -I$(DRVDIR)/CMSIS/Include \
           -I$(DRVDIR)/CMSIS/Device/ST/STM32F4xx/Include \
           -I$(STARTUP_DIR)

# Compiler flags
CFLAGS = -mcpu=cortex-m4 -mthumb -std=gnu11 -Wall -fdata-sections -ffunction-sections
CFLAGS += -Os -g -DSTM32F411xE -DUSE_HAL_DRIVER
CFLAGS += $(INCLUDES)

# Linker script
LDSCRIPT = STM32F411RETX_FLASH.ld

# Linker flags
LDFLAGS = -T$(LDSCRIPT) -Wl,--gc-sections -static -Wl,-Map=$(TARGET).map

# Rules
all: $(TARGET).bin

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LDFLAGS) -o $@
	$(SZ) $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.s
	$(AS) $(CFLAGS) -c $< -o $@

$(TARGET).bin: $(TARGET).elf
	$(CP) -O binary $< $@

clean:
	rm -f $(SRCDIR)/*.o
	rm -f $(DRVDIR)/STM32F4xx_HAL_Driver/Src/*.o
	rm -f $(DRVDIR)/CMSIS/Device/ST/STM32F4xx/Source/Templates/gcc/*.o
	rm -f $(STARTUP_DIR)/*.o
	rm -f $(TARGET).elf $(TARGET).bin $(TARGET).map

flash: $(TARGET).bin
	st-flash write $(TARGET).bin 0x8000000

.PHONY: all clean flash
