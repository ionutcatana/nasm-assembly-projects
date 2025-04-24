FILES = ./build/kernel_asm.o ./build/kernel.o
INCLUDES = -I./src/kernel
FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer -finline-functions -Wno-unused-function -fno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib -nostartfiles -nodefaultlibs -Wall -O0 -Iinc

all: ./bin/bootloader.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/bootloader.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/bootloader.bin: ./src/boot/bootloader.S
	nasm -f bin ./src/boot/bootloader.S -o ./bin/bootloader.bin

./build/kernel_asm.o: ./src/kernel/kernel.S
	nasm -f elf -g ./src/kernel/kernel.S -o ./build/kernel_asm.o

./build/kernel.o: ./src/kernel/kernel.c
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel/kernel.c -o ./build/kernel.o

qemu: all
	qemu-system-x86_64 -hda ./bin/os.bin

clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o ./build/*.so ./build/*.a