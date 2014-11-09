global _start

%include "io.mac"

section .text

global _start
_start:
    ;read name, 32

    mov rdi, hello
    mov rsi, name
    call printf

    exit 0

section .bss
;name resb 32

section .data
hello db "Hello, %s. This is a test!", 0xA, 0
name db "Nicholas", 0
