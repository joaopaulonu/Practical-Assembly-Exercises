TITLE Eco
.MODEL SMALL
.CODE

LF EQU 10 ; Line Feed
CR EQU 13 ; Carriage Return

MAIN PROC

; Exibe o caracter ? na tela
MOV AH,2
MOV DL,'?' 
INT 21h

; Lê um caracter do teclado e salva o caracter lido em AL
MOV AH,1
INT 21h

; Copia o caracter lido para BL
MOV BL,AL

; Exibe o caracter Line Feed (move o cursor para a linha seguinte)
MOV AH,2
MOV DL,LF
INT 21h

; Exibe o caracter Carriage Return (move o cursor para o canto esquerdo da tela)
MOV AH,2
MOV DL,CR
INT 21h

; Exibe o caracter lido (salvo em BL)
MOV AH,2
MOV DL,BL
INT 21h

; Finaliza o programa
MOV AH,4Ch
INT 21h

MAIN ENDP
END MAIN
Cada aluno deve