.MODEL SMALL
.STACK 100H

; -------------------- CONSTANTES E VARIÁVEIS --------------------
.DATA
    N EQU 3                   ; Constante: tamanho da matriz (N x N)
    
    ; Matrizes na memória
    matriz1 DW 9 DUP(?)       ; Primeira matriz (N*N elementos word)
    matriz2 DW 9 DUP(?)       ; Segunda matriz (N*N elementos word)  
    matriz_soma DW 9 DUP(?)   ; Matriz soma (N*N elementos word)
    
    ; Mensagens
    msg_matriz1 DB 'Digite os elementos da matriz 1:', 13, 10, '$'
    msg_matriz2 DB 13, 10, 'Digite os elementos da matriz 2:', 13, 10, '$'
    msg_soma DB 13, 10, 'Matriz Soma:', 13, 10, '$'
    msg_erro DB 13, 10, 'Erro: Numero deve ser menor que 10!', 13, 10, '$'
    
    ; Auxiliares
    nova_linha DB 13, 10, '$'
    espaco DB ' $'
    buffer DB 7 DUP('$')      ; Buffer para leitura

; -------------------- CÓDIGO PRINCIPAL --------------------
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Ler primeira matriz
    LEA DX, msg_matriz1
    MOV AH, 09H
    INT 21H
    LEA SI, matriz1          ; SI aponta para matriz1
    CALL LER_MATRIZ
    
    ; Ler segunda matriz  
    LEA DX, msg_matriz2
    MOV AH, 09H
    INT 21H
    LEA SI, matriz2          ; SI aponta para matriz2
    CALL LER_MATRIZ
    
    ; Calcular matriz soma
    CALL CALCULAR_SOMA
    
    ; Imprimir matriz soma
    LEA DX, msg_soma
    MOV AH, 09H
    INT 21H
    LEA SI, matriz_soma      ; SI aponta para matriz_soma
    CALL IMPRIMIR_MATRIZ
    
    ; Finalizar programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -------------------- PROCEDIMENTOS --------------------

; Lê N*N números inteiros (<10) do teclado
LER_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV CX, N                ; Contador linhas
    
ler_linha:
    PUSH CX                  ; Salvar contador de linhas
    MOV CX, N                ; Contador colunas
    
ler_coluna:
    CALL LER_NUMERO          ; Ler número (retorna em AX)
    
    ; Verificar se número é menor que 10
    CMP AX, 10
    JL armazenar_numero
    
    ; Se número >= 10, mostrar erro e ler novamente
    LEA DX, msg_erro
    MOV AH, 09H
    INT 21H
    JMP ler_coluna           ; Tentar novamente
    
armazenar_numero:
    MOV [SI], AX             ; Armazenar número na matriz
    ADD SI, 2                ; Próxima posição (word = 2 bytes)
    
    LOOP ler_coluna
    
    CALL PULAR_LINHA         ; Nova linha após cada linha da matriz
    POP CX                   ; Restaurar contador de linhas
    LOOP ler_linha
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LER_MATRIZ ENDP

; Calcula matriz_soma[i][j] = matriz1[i][j] + matriz2[i][j]
CALCULAR_SOMA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    MOV CX, N * N            ; Total de elementos (N*N)
    MOV SI, 0                ; Índice para matriz1 e matriz2
    
calcular_elemento:
    ; Carregar elemento da matriz1
    MOV AX, matriz1[SI]
    
    ; Somar com elemento da matriz2
    ADD AX, matriz2[SI]
    
    ; Armazenar na matriz_soma
    MOV matriz_soma[SI], AX
    
    ; Próximo elemento
    ADD SI, 2
    LOOP calcular_elemento
    
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
CALCULAR_SOMA ENDP

;  Imprime a matriz formatada com quebras de linha
IMPRIMIR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV CX, N                ; Contador linhas
    
imprimir_linha:
    PUSH CX                  ; Salvar contador de linhas
    MOV CX, N                ; Contador colunas
    
imprimir_coluna:
    ; Imprimir elemento da matriz
    MOV AX, [SI]
    CALL IMPRIMIR_NUMERO
    
    ; Imprimir espaço entre elementos
    LEA DX, espaco
    MOV AH, 09H
    INT 21H
    
    ADD SI, 2                ; Próxima posição
    LOOP imprimir_coluna
    
    CALL PULAR_LINHA         ; Nova linha após cada linha
    POP CX                   ; Restaurar contador de linhas
    LOOP imprimir_linha
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_MATRIZ ENDP

; -------------------- PROCEDIMENTOS AUXILIARES --------------------

;  Lê um número inteiro do teclado (apenas 0-9)
LER_NUMERO PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
ler_novamente:
    ; Limpar buffer
    MOV SI, 0
limpar_buffer:
    MOV buffer[SI], '$'
    INC SI
    CMP SI, 6
    JL limpar_buffer
    
    ; Ler string do teclado
    LEA DX, buffer
    MOV AH, 0AH
    INT 21H
    
    ; Converter string para número
    CALL STR_TO_INT
    
    ; Verificar se número é válido (0-9)
    CMP AX, 0
    JL numero_invalido
    CMP AX, 9
    JG numero_invalido
    JMP fim_ler_numero
    
numero_invalido:
    ; Mostrar mensagem de erro
    LEA DX, msg_erro
    MOV AH, 09H
    INT 21H
    JMP ler_novamente        ; Tentar novamente
    
fim_ler_numero:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
LER_NUMERO ENDP

;  Converte string ASCII para inteiro
STR_TO_INT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV SI, 0
    MOV AX, 0              ; Acumulador
    MOV BX, 10             ; Base decimal
    
    ; Verificar se string está vazia
    CMP buffer[1], 0
    JE fim_conversao
    
converter_digitos:
    MOV DL, buffer[SI+2]   ; Caractere atual
    CMP DL, 13             ; Verificar fim (Enter)
    JE fim_conversao
    CMP DL, '0'
    JL fim_conversao
    CMP DL, '9'
    JG fim_conversao
    
    ; Converter dígito ASCII para número
    SUB DL, '0'
    MOV DH, 0
    
    ; AX = AX * 10 + DX
    MUL BX
    ADD AX, DX
    
    INC SI
    CMP SI, 6              ; Limitar a 6 dígitos
    JL converter_digitos
    
fim_conversao:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
STR_TO_INT ENDP

;  Imprime número inteiro na tela (apenas 1 dígito)
IMPRIMIR_NUMERO PROC
    PUSH AX
    PUSH DX
    
    ; Como números são menores que 10, podemos imprimir diretamente
    ADD AL, '0'            ; Converter para ASCII
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    POP DX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP

;  Imprime quebra de linha
PULAR_LINHA PROC
    PUSH AX
    PUSH DX
    
    LEA DX, nova_linha
    MOV AH, 09H
    INT 21H
    
    POP DX
    POP AX
    RET
PULAR_LINHA ENDP

END MAIN