TITLE ATIV1_5_JP_CONTADOR

.MODEL SMALL
.STACK 100h

.DATA
    TARGET_COUNT        EQU 5
    CR                  EQU 13
    LF                  EQU 10

    MSG_PROMPT          DB 'Digite ', '0' + TARGET_COUNT, ' caracteres e pressione Enter: $'
    MSG_RESULT_PREFIX   DB LF, CR, 'Voce digitou '
    MSG_RESULT_SUFFIX   DB ' caracteres.$'
    MSG_CORRECT         DB LF, CR, 'A quantidade esta correta!$'
    MSG_INCORRECT       DB LF, CR, 'A quantidade esta incorreta.$'

    ; Buffer para a entrada de string (INT 21h, AH=0Ah)
    ; O primeiro byte define o tamanho máximo do buffer (incluindo o Enter)
    ; O segundo byte será preenchido pelo DOS com a quantidade de caracteres digitados
    INPUT_BUFFER        LABEL BYTE
    MAX_LEN             DB 12          ; Tamanho máximo, um pouco maior que o necessário
    ACTUAL_LEN          DB ?           ; O DOS colocará o tamanho real aqui
    INPUT_CHARS         DB 12 DUP(?)   ; Buffer para os caracteres

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Pede para o usuário digitar os caracteres
    MOV AH, 9
    LEA DX, MSG_PROMPT
    INT 21h

    ; Lê a string do teclado usando a função 0Ah do DOS
    MOV AH, 0Ah
    LEA DX, INPUT_BUFFER
    INT 21h

    ; Exibe a mensagem de quantos caracteres foram digitados
    MOV AH, 9
    LEA DX, MSG_RESULT_PREFIX
    INT 21h

    ; Converte o número de caracteres (que está em binário) para ASCII para exibição
    ; Nota: Isto só funciona para quantidades de 0 a 9.
    MOV DL, ACTUAL_LEN
    ADD DL, '0' ; Adiciona o valor ASCII de '0' para converter

    ; Exibe o número
    MOV AH, 2
    INT 21h

    ; Exibe o resto da mensagem
    MOV AH, 9
    LEA DX, MSG_RESULT_SUFFIX
    INT 21h

    ; Compara a quantidade digitada com a quantidade esperada
    MOV AL, ACTUAL_LEN
    CMP AL, TARGET_COUNT
    JE QTD_CORRETA ; Se for igual (Jump if Equal), vai para a seção correta

    ; Se a quantidade for incorreta
    MOV AH, 9
    LEA DX, MSG_INCORRECT
    INT 21h
    JMP FIM_PROGRAMA ; Pula para o final

QTD_CORRETA:
    ; Se a quantidade for correta
    MOV AH, 9
    LEA DX, MSG_CORRECT
    INT 21h

FIM_PROGRAMA:
    ; Finaliza o programa
    MOV AH, 4Ch
    INT 21h

MAIN ENDP
END MAIN