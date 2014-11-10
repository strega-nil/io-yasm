global _start

section .text

extern asmio_printf
extern asmio_gets

%macro exit 1
    mov rax, 60 ; exit syscall
    mov rdi, %1 ; exit value
    syscall
%endmacro

global _start
_start:
    mov rdi, startup
    call asmio_printf

    mov rdi, name
    mov rsi, 32
    call asmio_gets

    mov rdi, hello
    mov rsi, name
    call asmio_printf

    mov rdi, test_pushed
    mov rsi, test_pushee_a
    mov rdx, test_pushee_b
    mov rcx, test_pushee_c
    mov r8, test_pushee_a
    mov r9, test_pushee_b
    ; because for legacy reasons you must push backwards
    push test_pushee_b
    push test_pushee_a
    push test_pushee_c

    call asmio_printf

    pop rax
    pop rax
    pop rax

    mov rdi, equation
    mov rsi, 42
    call asmio_printf

    exit 0

section .bss
name resb 32

section .data
startup db "What's your name?", 0xA, 0
hello db "Hello, %s", 0xA, 0
equation db "The answer to life is %d", 0xA, 0
test_pushed db "Test of varargs > 5: a%s b%s c%s a%s b%s c%s a%s b%s", 0xA, 0
test_pushee_a db "a", 0
test_pushee_b db "b", 0
test_pushee_c db "c", 0
