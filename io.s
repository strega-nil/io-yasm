global _start

%include "io.mac"

section .text

global _start
_start:
    mov rdi, startup
    call printf

    read name, 32

    mov rdi, hello
    mov rsi, name
    call printf

    mov rdi, equation
    mov rsi, 42
    call printf

    exit 0

section .bss
name resb 32

section .data
startup db "What's your name?", 0xA, 0
hello db "Hello, %s", 0xA, 0
equation db "The answer to life is %d", 0xA, 0
