FORMAT = elf64
NASM = nasm -f $(FORMAT) $<
LD = ld $@.o -o $@.out

RECIPE = $(NASM) && $(LD)

hello: hello.asm
	$(RECIPE)

stars: stars.asm
	$(RECIPE)

input: input.asm
	$(RECIPE)

add: add.asm
	$(RECIPE)

loop: loop.asm
	$(RECIPE)

loop64: loop64.asm
	$(RECIPE)

input64: input64.asm
	$(RECIPE)

clean:
	rm -f *.o *.out
