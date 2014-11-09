%macro puts 1
    strlen %1   ; length of %1 in rax
    mov rdx, rax
    mov rax, 1  ; write syscall
    mov rdi, 1  ; stdout
    mov rsi, %1 ; read from
    syscall
%endmacro

%macro strlen 1
    mov rax, -1
    xor rdx, rdx
    %%count_loop:
    inc rax
    mov dl, [%1+rax]
    test dl, dl
    jnz %%count_loop
%endmacro

%macro putc 1
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, 1
    syscall
%endmacro

; rdi => const char * buf
; rsi => int len (how big buf is)
global gets
gets:
    push rbp
    mov rbp, rsp

    cmp rsi, 0
    jle gets_end

    mov rdx, rsi ; how many maximum to read (len)
    mov rsi, rdi ; where to read to (buf)
    mov rax, 0   ; read syscall
    mov rdi, 0   ; using stdin
    syscall

    ; Zero escaping the sequence

    mov rax, -1  ; buf index
    mov cl, 0xA  ; newline
    mov ch, -1   ; EOF

    gets_loop:
        inc rax
        cmp rax, rdx
        jge gets_end     ; test if we've reached len
        mov dl, [rsi+rax]
        cmp dl, cl
        je gets_end      ; test if it's a newline
        cmp dl, ch
        je gets_end      ; test if it's an EOF
        test dl, dl
        jne gets_loop    ; test if it's a \0

    gets_end:
        mov byte [rsi+rax], 0

        mov rsp, rbp
        pop rbp
        ret

; rdi => const char * format_string
; rsi, rdx, rcx, r8, r9 => rest of the things
; takes up to six arguments. No more may be pushed!
global printf
printf:
    push rbp
    mov rbp, rsp
    push r12     ; Push registers we'll use
    push r13
    push r14
    push r15
    sub rsp, 48  ; save and start the stack frame
                 ; 1 char (+ 7 padding)
                 ; 5 arguments

    mov [rsp+8], rsi  ; save argument registers
    mov [rsp+16], rdx
    mov [rsp+24], rcx
    mov [rsp+32], r8
    mov [rsp+40], r9

    mov r12, 0    ; char array index
    mov r13, rdi  ; char array
    mov r15, 0    ; argument index

    printf_load_argument:
        inc r15
        mov r14, [rsp+8*r15] ; argument

    printf_loop:
        mov cl, [r13+r12]
        test cl, cl
        jz printf_end
        cmp cl, 0x25 ; is cl a %?
        je printf_what_type ; yes
        mov [rsp], cl ; no
        putc rsp
        inc r12
        jmp printf_loop

    printf_what_type:
        inc r12
        mov cl, [r13+r12]
        cmp cl, 0x73 ; s
        je printf_str
        cmp cl, 0x64 ; d
        je printf_int
        cmp cl, 0x25 ; %
        je printf_percent_sign
        jmp printf_loop

    printf_str:
        puts r14
        inc r12
        jmp printf_load_argument

    printf_int:
        mov rdi, r14
        call print_num
        inc r12
        jmp printf_load_argument

    printf_percent_sign:
        mov byte [rsp], 0x25
        putc rsp
        jmp printf_loop

    printf_end:
        add rsp, 48
        pop r15
        pop r14
        pop r13
        pop r12
        mov rsp, rbp
        pop rbp
        ret

; rdi => number to be printed
print_num:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    sub rsp, 24 ; char array of size 24

    mov r12, rdi
    mov r13, 0 ; index of array

    cmp r12, 0
    jge print_num_begin

    print_num_is_negative:
        mov byte [rsp], 0x2D ; set the first character to be '-'
        neg r12
        inc r13

    print_num_begin:
        mov rax, r12

    print_num_length:
        inc r13
        cdq
        mov r9, 10
        div r9
        test rax, rax
        jnz print_num_length

    mov byte [rsp+r13], 0 ; put a 0 on the end of the array

    mov rax, r12
    print_num_fill_array:
        dec r13
        cdq
        mov r9, 10
        div r9
        add rdx, 0x30 ; convert to ascii
        mov [rsp+r13], dl
        test rax, rax
        jnz print_num_fill_array

    puts rsp
        
    print_num_end:
        add rsp, 24
        pop r13
        pop r12
        mov rsp, rbp
        pop rbp
        ret
