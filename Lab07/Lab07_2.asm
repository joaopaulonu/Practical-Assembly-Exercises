; Lab07_2.asm - Multiplicação por somas sucessivas
section .data
    msg1 db "Digite o multiplicando: ", 0
    msg2 db "Digite o multiplicador: ", 0
    msg3 db "Produto: ", 0
    newline db 10, 0

section .bss
    a resb 2
    b resb 2
    produto resb 2

section .text
    global _start

_start:
    ; Entrada do multiplicando
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 25
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, a
    mov edx, 2
    int 0x80

    ; Entrada do multiplicador
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, 25
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, b
    mov edx, 2
    int 0x80

    ; Conversão ASCII
    mov eax, [a]
    sub eax, '0'
    mov esi, eax ; multiplicando

    mov eax, [b]
    sub eax, '0'
    mov edi, eax ; multiplicador

    xor ecx, ecx ; produto = 0

mul_loop:
    cmp edi, 0
    je fim_mul
    add ecx, esi
    dec edi
    jmp mul_loop

fim_mul:
    ; Mostrar produto
    mov eax, 4
    mov ebx, 1
    mov ecx, msg3
    mov edx, 10
    int 0x80

    mov eax, ecx
    add eax, '0'
    mov [produto], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, produto
    mov edx, 1
    int 0x80

    ; Encerrar
    mov eax, 1
    xor ebx, ebx
    int 0x80
