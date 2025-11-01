; Lab07_1.asm - Divisão por subtrações sucessivas
section .data
    msg1 db "Digite o dividendo: ", 0
    msg2 db "Digite o divisor: ", 0
    msg3 db "Quociente: ", 0
    msg4 db "Resto: ", 0
    newline db 10, 0

section .bss
    dividendo resb 2
    divisor resb 2
    quociente resb 2
    resto resb 2

section .text
    global _start

_start:
    ; Entrada do dividendo
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, 20
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, dividendo
    mov edx, 2
    int 0x80

    ; Entrada do divisor
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, 20
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, divisor
    mov edx, 2
    int 0x80

    ; Conversão ASCII para número
    mov eax, [dividendo]
    sub eax, '0'
    mov esi, eax ; dividendo

    mov eax, [divisor]
    sub eax, '0'
    mov edi, eax ; divisor

    xor ecx, ecx ; quociente = 0

div_loop:
    cmp esi, edi
    jl fim_div
    sub esi, edi
    inc ecx
    jmp div_loop

fim_div:
    ; Mostrar quociente
    mov eax, 4
    mov ebx, 1
    mov ecx, msg3
    mov edx, 12
    int 0x80

    mov eax, ecx
    add eax, '0'
    mov [quociente], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, quociente
    mov edx, 1
    int 0x80

    ; Mostrar resto
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg4
    mov edx, 10
    int 0x80

    mov eax, esi
    add eax, '0'
    mov [resto], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, resto
    mov edx, 1
    int 0x80

    ; Encerrar
    mov eax, 1
    xor ebx, ebx
    int 0x80
