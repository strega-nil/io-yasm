all: _test_s _test_c _libasmio
	ld -o test_s obj/test_s.o obj/libasmio.o
	clang -o test_c obj/test_c.o obj/libasmio.o

_test_s: _obj_folder
	yasm -f elf64 -g dwarf2 -o obj/test_s.o src/test.s

_test_c: _obj_folder
	clang -c -o obj/test_c.o src/test.c

_libasmio: _obj_folder
	yasm -f elf64 -g dwarf2 -o obj/libasmio.o src/libasmio.s

_obj_folder:
	mkdir -p obj
