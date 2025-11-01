TITLE ATIV1_4_JP_LOOP

.MODEL SMALL
.STACK 100h

.DATA
  CR EQU 13 ; Carriage Return
  MSG_PEDIR_CARACTERE DB "Digite um caractere: $"
  MSG_CARACTERE_DIGITADO DB 10,13,"O caractere digitado foi: $" ; 10 (LF), 13 (CR)
  CARACTERE_LIDO DB ?

.CODE
MAIN PROC
  MOV AX, @DATA
  MOV DS, AX

LOOP_INICIO:
  ; Exibe mensagem para o usuário
  MOV AH, 9
  LEA DX, MSG_PEDIR_CARACTERE
  INT 21h

  ; Lê um caractere do teclado
  MOV AH, 1 ; Lê o caractere para AL
  INT 21h

  ; Verifica se o caractere digitado é 'Enter' (CR) para sair
  CMP AL, CR
  JE FIM_LOOP

  MOV CARACTERE_LIDO, AL

  ; Exibe a mensagem de confirmação
  MOV AH, 9
  LEA DX, MSG_CARACTERE_DIGITADO
  INT 21h

  ; Exibe o caractere digitado
  MOV AH, 2
  MOV DL, CARACTERE_LIDO
  INT 21h

  JMP LOOP_INICIO ; Volta para o início do loop

FIM_LOOP:
  ; Finaliza o programa
  MOV AH, 4Ch
  INT 21h

MAIN ENDP

END MAIN