ARMGNU = arm-none-eabi

TARGET = kernel7.bin
SDTARGET = things_to_copy_to_your_sd_card/kernel7.img
DEPS = *.h

COPS = -Wall -O2 -nostdlib -nostartfiles -ffreestanding

all : $(TARGET) 

%.o : %.s
	$(ARMGNU)-as $< -o $@

%.o : %.c $(DEPS)
	$(ARMGNU)-gcc $(COPS) -c $< -o $@

OBJECTS := $(patsubst %.s,%.o,$(wildcard *.s)) $(patsubst %.c,%.o,$(wildcard *.c))

$(TARGET) : kversion $(OBJECTS) memmap
	$(ARMGNU)-ld $(OBJECTS) io.o u_syscalls.o trap_handlers.o -T memmap -o kernel7.elf
	$(ARMGNU)-objdump -D kernel7.elf > kernel7.list
	$(ARMGNU)-objcopy kernel7.elf -O binary $(TARGET)
	cp $(TARGET) $(SDTARGET)

kversion :
	echo char kversion\[\] = \"Kernel version: \[`basename \`pwd\``\, `date`\]\"\; > kversion.c

clean :
	rm -f $(OBJECTS)
	rm -f *.bin
	rm -f *.elf
	rm -f *.list
	rm -f *.auto
	rm -f **/*.img

