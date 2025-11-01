.MODEL small
.STACK 100h

.DATA

.CODE
  mov ax, @data
  mov ds, ax

  ; Parte 1: Exibir 50 asteriscos na mesma linha
  mov cx, 50     ; Inicializa o contador com 50
  mov ah, 02h    ; Servico de exibicao de caractere (INT 21h)
  mov dl, '*'    ; Caractere a ser exibido

  loop_mesma_linha:
    int 21h      ; Exibe o caractere
    dec cx       ; Decrementa o contador
    jnz loop_mesma_linha ; Salta se CX nao for zero

  ; Quebra de linha
  mov ah, 02h
  mov dl, 13     ; Caractere de retorno de carro (CR)
  int 21h
  mov dl, 10     ; Caractere de nova linha (LF)
  int 21h

  ; Parte 2: Exibir 50 asteriscos, um por linha
  mov cx, 50     ; Reinicializa o contador com 50
  mov ah, 02h    ; Servico de exibicao de caractere

  loop_nova_linha:
    mov dl, '*'  ; Coloca o caractere '*' em DL
    int 21h      ; Exibe o asterisco

    ; Quebra de linha
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h

    dec cx       ; Decrementa o contador
    jnz loop_nova_linha ; Salta se CX nao for zero

  ; Finaliza o programa
  mov ah, 4ch
  int 21h

END