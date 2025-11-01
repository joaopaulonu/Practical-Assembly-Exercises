.MODEL small
.STACK 100h

.DATA

.CODE
  mov ax, @data
  mov ds, ax

  ; Parte 1: Exibir 50 asteriscos na mesma linha
  mov cx, 50     ; Contador
  mov ah, 02h    ; Servico de exibicao de caractere
  mov dl, '*'    ; Caractere a ser exibido

  loop_mesma_linha_2:
    int 21h      ; Exibe
    loop loop_mesma_linha_2 ; Decrementa CX e salta

  ; Quebra de linha
  mov ah, 02h
  mov dl, 13
  int 21h
  mov dl, 10
  int 21h

  ; Parte 2: Exibir 50 asteriscos, um por linha
  mov cx, 50     ; Reinicializa o contador
  mov ah, 02h    ; Servico de exibicao de caractere

  loop_nova_linha_2:
    mov dl, '*'  ; Caractere a ser exibido
    int 21h      ; Exibe

    ; Quebra de linha
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    loop loop_nova_linha_2 ; Decrementa CX e salta

  ; Finaliza o programa
  mov ah, 4ch
  int 21h

END