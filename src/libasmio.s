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

; uses the last pushed arg
%macro putc 0
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
%endmacro

; rdi => const char * buf
; rsi => int len (how big buf is)
global asmio_gets
asmio_gets:
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
global asmio_printf
asmio_printf:
    push rbp
    mov rbp, rsp
    push rbx     ; Push registers we'll use
    push r12
    push r13
    push r14
    push r15     ; save and start the stack frame

    mov r12, 0    ; char array index
    mov r13, rdi  ; char array
    mov r14, 0   ; amount of fp arguments
    mov r15, 0   ; amount of general arguments
    mov r11, 2    ; amount of pushed arguments + 2 (rbp+16 is the first pushed
                  ; argument

    printf_count_varargs:
        mov bl, [r13+r12]
        cmp bl, 0x25 ; is bl a %?
        jne printf_count_varargs_continue ; no
        inc r12
        mov bl, [r13+r12]
        cmp bl, 0x25 ; is it a %%?
        je printf_count_varargs_continue ; yes

        cmp bl, 0x66 ; is it a %f?
        je printf_count_varargs_float ; yes
        
    printf_count_varargs_gen:
        cmp r15, 4  ; 0-4
        jg printf_count_varargs_pushed
        inc r15

        mov rax, r15
        dec rax             ; put whichever case into rax
        imul rax, 7
        add rax, printf_va_gen_case_0
        jmp rax             ; jump to the right case

        printf_va_gen_case_0:
            push rsi
            jmp printf_count_varargs_continue
            nop
        printf_va_gen_case_1:
            push rdx
            jmp printf_count_varargs_continue
            nop
        printf_va_gen_case_2:
            push rcx
            jmp printf_count_varargs_continue
            nop
        printf_va_gen_case_3:
            push r8
            jmp printf_count_varargs_continue
        printf_va_gen_case_4:
            push r9
            jmp printf_count_varargs_continue

    printf_count_varargs_float:
        cmp r14, 7
        jg printf_count_varargs_pushed
        inc r14

        mov rax, r14
        dec rax             ; put whichever case into rax
        imul rax, 11
        add rax, printf_va_float_case_0
        jmp rax             ; jump to the right case

        printf_va_float_case_0:
            sub rsp, 8  ; Manual push; you can't actually push an xmm register
            movlpd [rsp], xmm0
            jmp printf_count_varargs_continue
        printf_va_float_case_1:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm1
            jmp printf_count_varargs_continue
        printf_va_float_case_2:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm2
            jmp printf_count_varargs_continue
        printf_va_float_case_3:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm3
            jmp printf_count_varargs_continue
        printf_va_float_case_4:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm4
            jmp printf_count_varargs_continue
        printf_va_float_case_5:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm5
            jmp printf_count_varargs_continue
        printf_va_float_case_6:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm6
            jmp printf_count_varargs_continue
        printf_va_float_case_7:
            sub rsp, 8  ; Manual push
            movlpd [rsp], xmm7
            jmp printf_count_varargs_continue

    printf_count_varargs_pushed:
        mov r10, [rbp+(8*r11)]
        push r10
        inc r11
        
    printf_count_varargs_continue:
        inc r12
        test bl, bl
        jnz printf_count_varargs

    add r15, r11  ; arg index
    add r15, r14
    push r15 ; how many arguments we need to pop
    sub r15, 2
    imul r15, 8

    mov r12, 0    ; char array index
    mov r13, rdi  ; char array
    mov r14, 0    ; float arg index

    printf_load_argument:
        mov rbx, rsp
        add rbx, r15
        mov rbx, [rbx]
        sub r15, 8

    printf_loop:
        mov cl, [r13+r12]
        test cl, cl
        jz printf_end
        cmp cl, 0x25 ; is cl a %?
        je printf_what_type ; yes
        push rcx ; no
        putc
        pop rcx
        inc r12
        jmp printf_loop

    printf_what_type:
        inc r12
        mov cl, [r13+r12]
        cmp cl, 0x73 ; s
        je printf_str
        cmp cl, 0x64 ; d
        je printf_int
        cmp cl, 0x66 ; f
        je printf_float
        cmp cl, 0x25 ; %
        je printf_percent_sign
        jmp printf_loop

    printf_str:
        puts rbx
        inc r12
        jmp printf_load_argument

    printf_int:
        mov rdi, rbx
        call print_int
        inc r12
        jmp printf_load_argument

    printf_float: ; TODO
        inc r12
        jmp printf_load_argument

    printf_percent_sign:
        push 0x25
        putc
        pop rcx
        jmp printf_loop

    printf_end:
        pop r15
        sub r15, 2
        imul r15, 8
        add rsp, r15 ; get rid of the varargs stack

        pop r15
        pop r14
        pop r13
        pop r12
        pop rbx
        mov rsp, rbp
        pop rbp
        ret

; rdi => number to be printed
print_int:
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
