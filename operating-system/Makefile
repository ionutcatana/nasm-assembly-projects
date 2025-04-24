FILES = ./build/kernel.o

all: ./bin/bootloader.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/bootloader.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin

./bin/kernel.bin: $(FILES)
	i686-elf-ld -g -relocatable $(FILES) -o ./build/kernelfull.o
	i686-elf-gcc -T ./src/linker.ld -o ./bin/kernel.bin -ffreestanding -O0 -nostdlib ./build/kernelfull.o

./bin/bootloader.bin: ./src/boot/bootloader.S
	nasm -f bin ./src/boot/bootloader.S -o ./bin/bootloader.bin

./build/kernel.o: ./src/kernel/kernel.S
	nasm -f elf -g ./src/kernel/kernel.S -o ./build/kernel.o

qemu: all
	qemu-system-x86_64 -hda ./bin/os.bin

clean:
	rm -rf ./bin/*.bin
	rm -rf ./build/*.o ./build/*.so ./build/*.a