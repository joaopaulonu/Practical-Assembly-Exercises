; lab08_3.asm
org 100h

mov bx, 0          ; limpa BX

next_hex:
mov ah, 1
int 21h
cmp al, 13         ; verifica CR
je fim

shl bx, 4          ; desloca BX 4 bits à esquerda

cmp al, '9'
jbe digito
sub al, 7          ; ajusta letras A-F

digito:
sub al, '0'        ; converte caractere para valor
or bl, al          ; insere valor nos 4 bits inferiores
jmp next_hex

fim:
ret
