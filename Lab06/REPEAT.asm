.model small
.stack 100h
.data
    count db 0
    char db ?

.code
main:
    mov ax, @data
    mov ds, ax

repeat_loop:
    mov ah, 1
    int 21h
    mov char, al

    cmp al, 13
    je print_stars

    inc count
    jmp repeat_loop

print_stars:
    mov bl, count
    mov cx, bx

print_loop:
    mov ah, 2
    mov dl, '*'
    int 21h
    loop print_loop

    mov ah, 4Ch
    int 21h
end main
