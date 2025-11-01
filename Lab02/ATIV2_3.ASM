TITLE SOMA_NUMEROS

.MODEL SMALL

.DATA
    MSG_INPUT DB "Digite o primeiro numero: ", "$"
    MSG_INPUT2 DB "Digite o segundo numero: ", "$"
    MSG_OUTPUT DB "O resultado final e: ", "$"

.CODE
    MAIN PROC
        ; Pega as variáveis de DATA
        MOV AX,@DATA
        MOV DS,AX

        ; Lê o primeiro caractere
        MOV AH,9
        LEA DX,MSG_INPUT
        INT 21h
        MOV AH,1
        INT 21h

        ; Transforma o caractere em número
        SUB AL, 30h

        ; Move o número para BL
        MOV BL, AL

        ; Printa uma nova linha
        MOV AH,2
        MOV DL,10 
        INT 21h

        ; Lê o segundo caractere
        MOV AH,9
        LEA DX,MSG_INPUT2
        INT 21h
        MOV AH,1
        INT 21h

        ; Transforma o caractere em número
        SUB AL, 30h

        ; Adiciona AL em DL (soma de num1 + num2)
        ADD BL, AL

        ; Transforma em cactere de novo para printar
        ADD BL, 30h

        ; Printa duas novas linha
        MOV AH,2
        MOV DL,10 
        INT 21h

        MOV AH,2
        MOV DL,10 
        INT 21h
        
        ; Printa o resultado final
        MOV AH, 9h
        MOV DX, OFFSET MSG_OUTPUT
        INT 21h
        MOV AH,02
        MOV DL, BL
        INT 21h

        ; Finaliza o programa
        MOV AH,4Ch
        INT 21h
    MAIN ENDP
END MAIN