; lab08_2.asm
org 100h

mov cx, 16         ; contador de 16 bits

loop_bin:
rol bx, 1          ; rotaciona BX à esquerda
jnc zero
mov dl, '1'        ; CF = 1 → imprime '1'
jmp imprime

zero:
mov dl, '0'        ; CF = 0 → imprime '0'

imprime:
mov ah, 2
int 21h
loop loop_bin

ret
