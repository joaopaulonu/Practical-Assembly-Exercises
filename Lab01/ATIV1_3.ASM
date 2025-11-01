TITLE ATIV1_3_JP

.MODEL SMALL
.STACK 100h

.DATA
  MSG_PEDIR_CARACTERE DB "Digite um caractere: $"
  MSG_CARACTERE_DIGITADO DB 10,13,"O caractere digitado foi: $"
  CARACTERE_LIDO DB ?

.CODE
MAIN PROC
  MOV AX, @DATA
  MOV DS, AX

  ; Exibe mensagem para o usuário
  MOV AH, 9
  LEA DX, MSG_PEDIR_CARACTERE
  INT 21h

  ; Lê um caractere do teclado
  MOV AH, 1
  INT 21h
  MOV CARACTERE_LIDO, AL

  ; Exibe a mensagem de confirmação
  MOV AH, 9
  LEA DX, MSG_CARACTERE_DIGITADO
  INT 21h

  ; Exibe o caractere digitado
  MOV AH, 2
  MOV DL, CARACTERE_LIDO
  INT 21h

  ; Finaliza o programa
  MOV AH, 4Ch
  INT 21h

MAIN ENDP

END MAIN