CC = /usr/local/cross/bin/i686-elf-gcc
LD = /usr/local/cross/bin/i686-elf-ld

SRC = $(wildcard kernel/*.c drivers/*.c)
HDR = $(wildcard kernel/*.h drivers/*.h)
OBJ = ${SRC:.c=.o}

system.bin: boot/boot_sector.bin kernel.bin
	cat $^ > system.bin

kernel.bin: boot/kernel_entry.o ${OBJ}
	${LD} -o $@ -Ttext 0x1000 $^ --oformat binary -nostdlib

%.o: %.c ${HDR}
	${CC} -ffreestanding -c $< -o $@

%.o: %.asm
	nasm $< -f elf -o $@

%.bin: %.asm
	nasm $< -f bin -o $@

clean:
	rm -rf *.bin *.o
	rm -rf drivers/*.o kernel/*.o boot/*.bin boot/*.o
