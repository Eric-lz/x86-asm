hello: hello.asm
	nasm -f elf64 $<
	ld $@.o -o $@

stars: stars.asm
	nasm -f elf64 $<
	ld $@.o -o $@

input: input.asm
	nasm -f elf64 $<
	ld $@.o -o $@

add: add.asm
	nasm -f elf64 $<
	ld $@.o -o $@

loop: loop.asm
	nasm -f elf64 $<
	ld $@.o -o $@

clean:
	rm -f *.o hello stars input add loop