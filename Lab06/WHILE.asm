.model small
.stack 100h
.data
    count db 0
    char db ?

.code
main:
    mov ax, @data
    mov ds, ax

read_loop:
    mov ah, 1          ; Função de leitura de caractere
    int 21h
    mov char, al       ; Armazena caractere lido

    cmp al, 13         ; Verifica se é CR (Enter)
    je print_stars     ; Se for, sai do loop

    inc count          ; Incrementa contador
    jmp read_loop      ; Repete enquanto não for CR

print_stars:
    mov bl, count      ; BL = número de caracteres
    mov cx, bx         ; CX = número de vezes a imprimir

print_loop:
    mov ah, 2
    mov dl, '*'
    int 21h
    loop print_loop

    mov ah, 4Ch
    int 21h
end main
