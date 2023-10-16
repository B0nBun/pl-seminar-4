CFLAGS     = -g -O2 -Wall -Werror -std=c17 -Wdiscarded-qualifiers -Wincompatible-pointer-types -Wint-conversion
CC         = gcc
LD         = gcc
ASM        = nasm
ASMFLAGS   =-felf64 -g

# Если есть код на C, то компоновку тоже нужно производить
# с помощью gcc, а не ld
main: file.o print_file.o
	$(LD) -o $@ $^

# target : dependencies
#     do this
file.o: file.c 
	$(CC) -c $(CFLAGS) -o $@ $<

print_file.o: print_file.asm
	$(ASM) $(ASMFLAGS) -o $@ $<

clean: 
	$(RM) main file.o print_file.o

.PHONY: clean

