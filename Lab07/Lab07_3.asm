; Lab07_3.asm - Verifica par ou ímpar
section .data
    msg1 db "Entre com um numero: ", 0
    msg_par db " eh um numero par", 10, 0
    msg_impar db " eh um numero impar", 10, 0

section .bss
    num resb 2

section .text
    global _start

_start:
    ; Entrada
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 23
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num
    mov edx, 2
    int 0x80

    ; Conversão
    mov eax, [num]
    sub eax, '0'
    mov ebx, 2
    xor edx, edx
    div ebx ; resto em edx

    ; Mostrar número
    mov eax, 4
    mov ebx, 1
    mov ecx, num
    mov edx, 1
    int 0x80

    ; Verifica par ou ímpar
    cmp edx, 0
    je par

    ; Ímpar
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_impar
    mov edx, 20
    int 0x80
    jmp fim

par:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_par
    mov edx, 18
    int 0x80

fim:
    mov eax, 1
    xor ebx, ebx
    int 0x80
