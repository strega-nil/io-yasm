global _start

%include "io.mac"

section .text

global _start
_start:
    read name, 32

    print hello
    print name
    print nl

    exit 0

section .bss
name resb 32

section .data
hello db "Hello, ", 0
nl db 0xA, 0
