; lab08_1.asm
org 100h

mov bx, 0          ; limpa BX

next_char:
mov ah, 1          ; função de leitura de caractere
int 21h
cmp al, 13         ; verifica se é CR
je fim

sub al, '0'        ; converte '0' ou '1' para 0 ou 1
shl bx, 1          ; desloca BX 1 bit à esquerda
or bx, ax          ; insere bit lido no LSB de BX
jmp next_char

fim:
ret
