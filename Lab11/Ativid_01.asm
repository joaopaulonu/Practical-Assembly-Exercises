.MODEL SMALL
.STACK 100H

; -------------------- CONSTANTES E VARIÁVEIS --------------------
.DATA
    N EQU 3                   ; Constante: tamanho da matriz (N x N)
    matriz DW 9 DUP(?)        ; Matriz original (N*N elementos word)
    msg_ler DB 'Digite os elementos da matriz:$'
    msg_original DB 'Matriz original:$'
    msg_nova DB 'Matriz apos troca:$'
    nova_linha DB 13, 10, '$' ; Quebra de linha
    espaco DB ' $'            ; Espaço para formatacao
    buffer DB 7 DUP('$')      ; Buffer para leitura de números

; -------------------- CÓDIGO PRINCIPAL --------------------
.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Chamar procedimento para ler matriz
    CALL LER_MATRIZ
    
    ; Mostrar matriz original
    LEA DX, msg_original
    MOV AH, 09H
    INT 21H
    CALL IMPRIMIR_MATRIZ
    
    ; Chamar procedimento para trocar elementos
    CALL TROCAR_DIAGONAIS
    
    ; Mostrar matriz após troca
    LEA DX, msg_nova
    MOV AH, 09H
    INT 21H
    CALL IMPRIMIR_MATRIZ
    
    ; Finalizar programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; -------------------- PROCEDIMENTOS --------------------

; Lê N*N números inteiros do teclado e armazena na matriz
LER_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; Exibir mensagem
    LEA DX, msg_ler
    MOV AH, 09H
    INT 21H
    CALL PULAR_LINHA
    
    ; Inicializar índices
    MOV SI, 0              ; Índice na matriz (offset em words)
    MOV CX, N              ; Contador linhas
    
ler_linha:
    PUSH CX                ; Salvar contador de linhas
    MOV CX, N              ; Contador colunas
    
ler_coluna:
    ; Ler número do teclado
    CALL LER_NUMERO
    MOV matriz[SI], AX     ; Armazenar número na matriz
    ADD SI, 2              ; Próxima posição (word = 2 bytes)
    
    LOOP ler_coluna
    
    CALL PULAR_LINHA       ; Nova linha após cada linha da matriz
    POP CX                 ; Restaurar contador de linhas
    LOOP ler_linha
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
LER_MATRIZ ENDP


; Para cada par (i,j) com i<j, troca matriz[i][j] com matriz[j][i]
TROCAR_DIAGONAIS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    MOV CX, 0              ; i = 0 (linha)
    
loop_i:
    MOV DX, CX             ; j = i + 1
    INC DX
    
    CMP DX, N              ; Verificar se j < N
    JGE proximo_i
    
loop_j:
    ; Calcular endereço de matriz[i][j] = i*N + j
    MOV AX, CX             ; AX = i
    MOV BX, N
    MUL BX                 ; AX = i * N
    ADD AX, DX             ; AX = i*N + j
    MOV BX, 2
    MUL BX                 ; AX = (i*N + j) * 2 (word offset)
    MOV SI, AX             ; SI = offset de matriz[i][j]
    
    ; Calcular endereço de matriz[j][i] = j*N + i
    MOV AX, DX             ; AX = j
    MOV BX, N
    MUL BX                 ; AX = j * N
    ADD AX, CX             ; AX = j*N + i
    MOV BX, 2
    MUL BX                 ; AX = (j*N + i) * 2 (word offset)
    MOV DI, AX             ; DI = offset de matriz[j][i]
    
    ; Trocar os valores
    MOV AX, matriz[SI]     ; AX = matriz[i][j]
    MOV BX, matriz[DI]     ; BX = matriz[j][i]
    MOV matriz[SI], BX     ; matriz[i][j] = BX
    MOV matriz[DI], AX     ; matriz[j][i] = AX
    
    INC DX                 ; j++
    CMP DX, N
    JL loop_j
    
proximo_i:
    INC CX                 ; i++
    CMP CX, N
    JL loop_i
    
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
TROCAR_DIAGONAIS ENDP


; Imprime a matriz formatada com quebras de linha
IMPRIMIR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    CALL PULAR_LINHA
    
    MOV SI, 0              ; Índice na matriz
    MOV CX, N              ; Contador linhas
    
imprimir_linha:
    PUSH CX                ; Salvar contador de linhas
    MOV CX, N              ; Contador colunas
    
imprimir_coluna:
    ; Imprimir elemento matriz[SI]
    MOV AX, matriz[SI]
    CALL IMPRIMIR_NUMERO
    
    ; Imprimir espaço
    LEA DX, espaco
    MOV AH, 09H
    INT 21H
    
    ADD SI, 2              ; Próxima posição
    LOOP imprimir_coluna
    
    CALL PULAR_LINHA       ; Nova linha
    POP CX                 ; Restaurar contador de linhas
    LOOP imprimir_linha
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_MATRIZ ENDP

; -------------------- PROCEDIMENTOS AUXILIARES --------------------


; Lê um número inteiro do teclado
LER_NUMERO PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
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
    
    POP SI
    POP DX
    POP CX
    POP BX
    RET
LER_NUMERO ENDP


; Converte string ASCII para inteiro
STR_TO_INT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV SI, 0
    MOV AX, 0              ; Acumulador
    MOV BX, 10             ; Base decimal
    MOV CX, 0              ; Sinal positivo
    
    ; Verificar sinal negativo
    CMP buffer[2], '-'
    JNE converter_digitos
    MOV CX, 1              ; Marcar como negativo
    INC SI                 ; Pular o '-'
    
converter_digitos:
    MOV DL, buffer[SI+2]   ; Caractere atual
    CMP DL, 13             ; Verificar fim (Enter)
    JE fim_conversao
    
    ; Converter dígito ASCII para número
    SUB DL, '0'
    MOV DH, 0
    
    ; AX = AX * 10 + DX
    MUL BX
    ADD AX, DX
    
    INC SI
    JMP converter_digitos
    
fim_conversao:
    ; Aplicar sinal negativo se necessário
    CMP CX, 0
    JE positivo
    NEG AX
    
positivo:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
STR_TO_INT ENDP


; Imprime número inteiro na tela
IMPRIMIR_NUMERO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CX, 0              ; Contador de dígitos
    MOV BX, 10             ; Divisor
    
    ; Verificar se é negativo
    CMP AX, 0
    JGE preparar_pilha
    PUSH AX
    MOV DL, '-'
    MOV AH, 02H
    INT 21H
    POP AX
    NEG AX
    
preparar_pilha:
    MOV DX, 0
    DIV BX                 ; AX = quociente, DX = resto
    PUSH DX                ; Empilhar dígito
    INC CX
    
    CMP AX, 0
    JNE preparar_pilha
    
imprimir_digitos:
    POP DX
    ADD DL, '0'            ; Converter para ASCII
    MOV AH, 02H
    INT 21H
    LOOP imprimir_digitos
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP


; Imprime quebra de linha
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