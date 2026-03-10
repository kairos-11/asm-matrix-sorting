all:
	mkdir -p build
	nasm -f elf64 main.asm -o build/main.o
	ld build/main.o -o build/main
test:
	objdump -s main.o
	#perf stat -r 10 ./main
	#perf stat -e L1-dcache-load-misses ./main
clean:
	rm -rf build/
