; Programa para ler um número do teclado e dividir por potência de dois
.MODEL SMALL
.STACK 100H

.DATA
    msg_digite    DB 'Digite um numero: $'
    msg_expoente  DB 13, 10, 'Digite o expoente (0-15): $'
    msg_resultado DB 13, 10, 'Resultado da divisao: $'
    msg_original  DB 13, 10, 'Numero original: $'
    msg_divisor   DB 13, 10, 'Divisor (2^CL): $'
    nova_linha    DB 13, 10, '$'
    buffer        DB 7 DUP('$')      ; Buffer para leitura
    numero        DW ?               ; Armazena o número lido
    expoente      DB ?               ; Armazena o expoente

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Pedir e ler o número
    LEA DX, msg_digite
    MOV AH, 09H
    INT 21H
    CALL LER_NUMERO
    MOV numero, AX      ; Salvar o número lido
    
    ; Pedir e ler o expoente
    LEA DX, msg_expoente
    MOV AH, 09H
    INT 21H
    CALL LER_NUMERO
    MOV expoente, AL    ; Salvar expoente (usamos só AL)
    
    ; Mostrar número original
    LEA DX, msg_original
    MOV AH, 09H
    INT 21H
    MOV AX, numero
    CALL IMPRIMIR_NUMERO
    
    ; Mostrar divisor
    LEA DX, msg_divisor
    MOV AH, 09H
    INT 21H
    MOV AX, 1           ; Calcular 2^CL
    MOV CL, expoente
    SHL AX, CL          ; AX = 2^CL
    CALL IMPRIMIR_NUMERO
    
    ; Realizar a divisão
    LEA DX, msg_resultado
    MOV AH, 09H
    INT 21H
    MOV AX, numero      ; Carregar número original
    MOV CL, expoente    ; Carregar expoente
    CALL DIVIDIR_POTENCIA_DOIS
    CALL IMPRIMIR_NUMERO ; Imprimir resultado
    
    ; Finalizar programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Procedimento: DIVIDIR_POTENCIA_DOIS
; Entrada: AX = número a ser dividido, CL = expoente da potência de dois (2^CL)
; Saída: AX = resultado da divisão (AX / 2^CL)
; Descrição: Divide um número por uma potência de dois usando shift aritmético
DIVIDIR_POTENCIA_DOIS PROC
    PUSH CX
    
    ; Verificar se o expoente é zero
    CMP CL, 0
    JE fim_divisao      ; Se CL=0, retorna AX inalterado
    
    ; Verificar se expoente é válido (0 <= CL <= 15)
    CMP CL, 15
    JLE fazer_divisao
    
    ; Se CL > 15, limitar a 15
    MOV CL, 15
    
fazer_divisao:
    ; Usar SAR (Shift Arithmetic Right) que preserva o sinal
    ; Equivale a divisão por 2^CL para inteiros
    SAR AX, CL
    
fim_divisao:
    POP CX
    RET
DIVIDIR_POTENCIA_DOIS ENDP

;  Lê um número inteiro do teclado (positivo ou negativo)
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

; Converte string ASCII para inteiro (suporta negativos)
STR_TO_INT PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV SI, 0
    MOV AX, 0              ; Acumulador
    MOV BX, 10             ; Base decimal
    MOV CX, 0              ; 0 = positivo, 1 = negativo
    
    ; Verificar sinal negativo
    CMP buffer[2], '-'
    JNE converter_digitos
    MOV CX, 1              ; Marcar como negativo
    INC SI                 ; Pular o '-'
    
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
    
    ; Se for zero, imprimir '0' diretamente
    CMP AX, 0
    JNE nao_zero
    MOV DL, '0'
    MOV AH, 02H
    INT 21H
    JMP fim_imprimir
    
nao_zero:
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
    
fim_imprimir:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP

END MAIN