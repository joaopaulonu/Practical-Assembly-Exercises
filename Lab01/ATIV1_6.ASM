TITLE ATIV1_6_JP_SOMA_MAIOR_QUE_9

.MODEL SMALL
.STACK 100h

.DATA
    CR                  EQU 13
    LF                  EQU 10
    MIN_SUM             EQU 9

    MSG_PROMPT1         DB 'Digite o primeiro numero (0-9): $'
    MSG_PROMPT2         DB LF, CR, 'Digite o segundo numero (0-9): $'
    MSG_RESULT_PREFIX   DB LF, CR, 'A soma e: '
    MSG_SUM_VALID       DB LF, CR, 'A soma e maior ou igual a 9. Correto!$'
    MSG_SUM_INVALID     DB LF, CR, 'A soma e menor que 9. Incorreto!$'
    
    NUM1                DB ?
    NUM2                DB ?
    SUM_ASCII           DB '  $' ; Buffer para a soma em formato ASCII (até 2 dígitos)


.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; --- Pede e lê o primeiro número ---
    MOV AH, 9
    LEA DX, MSG_PROMPT1
    INT 21h

    MOV AH, 1       ; Lê um caractere do teclado (ecoado)
    INT 21h
    SUB AL, '0'     ; Converte de ASCII para binário (ex: '5' -> 5)
    MOV NUM1, AL    ; Salva o primeiro número

    ; --- Pede e lê o segundo número ---
    MOV AH, 9
    LEA DX, MSG_PROMPT2
    INT 21h

    MOV AH, 1       ; Lê um caractere
    INT 21h
    SUB AL, '0'     ; Converte de ASCII para binário
    MOV NUM2, AL    ; Salva o segundo número

    ; --- Calcula a soma ---
    MOV AL, NUM1
    ADD AL, NUM2    ; AL = NUM1 + NUM2

    ; --- Exibe a soma calculada ---
    MOV AH, 9
    LEA DX, MSG_RESULT_PREFIX
    INT 21h

    ; Converte a soma (em AL) para ASCII para exibição (suporta até 2 dígitos)
    MOV AH, 0       ; Limpa AH para a divisão de 16 bits (AX)
    MOV BL, 10
    DIV BL          ; AX / 10 -> AL = quociente (dezena), AH = resto (unidade)
    
    ADD AL, '0'     ; Converte quociente (dezena) para ASCII
    ADD AH, '0'     ; Converte resto (unidade) para ASCII

    MOV SUM_ASCII, AL
    MOV SUM_ASCII+1, AH

    ; Se a soma for < 10, a dezena será '0'. Substitui por um espaço para não imprimir "08".
    CMP SUM_ASCII, '0'
    JNE EXIBE_SOMA
    MOV SUM_ASCII, ' '

EXIBE_SOMA:
    MOV AH, 9
    LEA DX, SUM_ASCII
    INT 21h

    ; --- Compara a soma com o valor mínimo e exibe o resultado ---
    MOV AL, NUM1
    ADD AL, NUM2    ; Recalcula a soma em AL
    CMP AL, MIN_SUM
    JL SOMA_INVALIDA ; Se for menor (Jump if Less), a condição não foi atendida

SOMA_VALIDA:
    ; Se a soma for >= 9
    MOV AH, 9
    LEA DX, MSG_SUM_VALID
    INT 21h
    JMP FIM_PROGRAMA

SOMA_INVALIDA:
    ; Se a soma for < 9
    MOV AH, 9
    LEA DX, MSG_SUM_INVALID
    INT 21h

FIM_PROGRAMA:
    MOV AH, 4Ch
    INT 21h

MAIN ENDP
END MAIN