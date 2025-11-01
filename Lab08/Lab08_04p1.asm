; lab08_4.asm
org 100h

mov cx, 4          ; 4 dígitos hexa

loop_hex:
mov dl, bh         ; copia parte alta de BX
shr dl, 4          ; pega 4 bits mais altos

cmp dl, 9
jbe digito
add dl, 7          ; ajusta letras A-F

digito:
add dl, '0'        ; converte para caractere ASCII
mov ah, 2
int 21h

rol bx, 4          ; rotaciona BX 4 bits à esquerda
loop loop_hex

ret
