all: _io _libio
	ld -o io obj/io.o obj/libio.o

_io:
	yasm -f elf64 -g dwarf2 -o obj/io.o src/io.s

_libio:
	yasm -f elf64 -g dwarf2 -o obj/libio.o src/libio.s
