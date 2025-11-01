; Lab07_4.asm - Verifica maior e menor
section .data
    msg1 db "Entre com um numero: ", 0
    msg_maior db " eh o numero maior", 10, 0
    msg_menor db " eh o numero menor", 10, 0

section .bss
    num1 resb 2
    num2 resb 2

section .text
    global _start

_start:
    ; Entrada num1
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 23
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num1
    mov edx, 2
    int 0x80

    ; Entrada num2
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 23
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, num2
    mov edx, 2
    int 0x80

    ; Conversão
    mov eax, [num1]
    sub eax, '0'
    mov esi, eax

    mov eax, [num2]
    sub eax, '0'
    mov edi, eax

    ; Comparação
    cmp esi, edi
    jg num1_maior