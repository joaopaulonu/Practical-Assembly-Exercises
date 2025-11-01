; lab08_5.asm
org 100h

start:
mov ah, 1
int 21h            ; lê opção do usuário
cmp al, '1'
je bin_in
cmp al, '2'
je bin_out
cmp al, '3'
je hex_in
cmp al, '4'
je hex_out
jmp start

bin_in:
call leitura_bin
jmp start

bin_out:
call imprime_bin
jmp start

hex_in:
call leitura_hex
jmp start

hex_out:
call imprime_hex
jmp start

; Procedimento 1
leitura_bin:
mov bx, 0
.next:
mov ah, 1
int 21h
cmp al, 13
je .fim
sub al, '0'
shl bx, 1
or bx, ax
jmp .next
.fim:
ret

; Procedimento 2
imprime_bin:
mov cx, 16
.loop:
rol bx, 1
jnc .zero
mov dl, '1'
jmp .print
.zero:
mov dl, '0'
.print:
mov ah, 2
int 21h
loop .loop
ret

; Procedimento 3
leitura_hex:
mov bx, 0
.next:
mov ah, 1
int 21h
cmp al, 13
je .fim
shl bx, 4
cmp al, '9'
jbe .digito
sub al, 7
.digito:
sub al, '0'
or bl, al
jmp .next
.fim:
ret

; Procedimento 4
imprime_hex:
mov cx, 4
.loop:
mov dl, bh
shr dl, 4
cmp dl, 9
jbe .digito
add dl, 7
.digito:
add dl, '0'
mov ah, 2
int 21h
rol bx, 4
loop .loop
ret
