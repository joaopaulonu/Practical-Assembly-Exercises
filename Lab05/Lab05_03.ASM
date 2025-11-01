.MODEL small
.STACK 100h

.DATA

.CODE
  mov ax, @data
  mov ds, ax

  ; Exibir letras maiusculas (A-Z)
  mov cx, 26       ; Ha 26 letras maiusculas
  mov ah, 02h      ; Servico de exibicao de caractere
  mov dl, 'A'      ; Inicia com a letra 'A'

  loop_maiusculas:
    int 21h        ; Exibe o caractere
    inc dl         ; Incrementa o codigo ASCII para a proxima letra
    loop loop_maiusculas ; Decrementa CX e salta

  ; Quebra de linha entre as sequencias
  mov ah, 02h
  mov dl, 13
  int 21h
  mov dl, 10
  int 21h

  ; Exibir letras minusculas (a-z)
  mov cx, 26       ; Ha 26 letras minusculas
  mov ah, 02h      ; Servico de exibicao de caractere
  mov dl, 'a'      ; Inicia com a letra 'a'

  loop_minusculas:
    int 21h        ; Exibe o caractere
    inc dl         ; Incrementa o codigo ASCII para a proxima letra
    loop loop_minusculas ; Decrementa CX e salta

  ; Finaliza o programa
  mov ah, 4ch
  int 21h

END