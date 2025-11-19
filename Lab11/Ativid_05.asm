.MODEL SMALL
.STACK 100H

.DATA
    msg_resultado DB 'Resultado: $'
    msg_overflow DB ' (Overflow!)$'
    nova_linha DB 13, 10, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Teste 1: Multiplicar 5 por 4 (2^2) - deve dar 20
    MOV AX, 5
    MOV CL, 2
    CALL MULTIPLICAR_POTENCIA_DOIS
    CALL MOSTRAR_RESULTADO
    
    ; Teste 2: Multiplicar 10 por 8 (2^3) - deve dar 80
    MOV AX, 10
    MOV CL, 3
    CALL MULTIPLICAR_POTENCIA_DOIS
    CALL MOSTRAR_RESULTADO
    
    ; Teste 3: Multiplicar 1000 por 1024 (2^10) - deve dar overflow
    MOV AX, 1000
    MOV CL, 10
    CALL MULTIPLICAR_POTENCIA_DOIS
    CALL MOSTRAR_RESULTADO
    
    ; Teste 4: Multiplicar 0 por qualquer valor - deve dar 0
    MOV AX, 0
    MOV CL, 20
    CALL MULTIPLICAR_POTENCIA_DOIS
    CALL MOSTRAR_RESULTADO
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;  Multiplica um número por uma potência de dois usando shift aritmético
MULTIPLICAR_POTENCIA_DOIS PROC
    PUSH CX
    PUSH BX
    
    ; Limpar flag de carry inicialmente
    CLC
    
    ; Verificar se expoente é zero
    CMP CL, 0
    JE sucesso              ; Multiplicação por 1, retorna AX inalterado
    
    ; Verificar se expoente é negativo
    CMP CL, 0
    JL erro                 ; Expoente negativo não é suportado
    
    ; Verificar se expoente é muito grande (>15 para word)
    CMP CL, 15
    JG verificar_overflow_max
    
    ; Realizar multiplicação por shift left
    ; SHL atualiza CF se houve overflow no último shift
    SHL AX, CL
    
    ; Verificar se ocorreu overflow durante o shift
    JC erro                 ; Se carry flag foi setada, houve overflow
    JMP sucesso
    
verificar_overflow_max:
    ; Para CL > 15, só 0 pode ser multiplicado sem overflow
    CMP AX, 0
    JE sucesso              ; 0 * qualquer coisa = 0
    JMP erro                ; Overflow garantido para AX ≠ 0
    
erro:
    STC                     ; Setar flag de carry indicando erro/overflow
    MOV AX, 0               ; Zerar resultado em caso de erro
    JMP fim
    
sucesso:
    CLC                     ; Limpar carry - operação bem sucedida
    
fim:
    POP BX
    POP CX
    RET
MULTIPLICAR_POTENCIA_DOIS ENDP

; Procedimento para mostrar resultado
MOSTRAR_RESULTADO PROC
    PUSH AX
    PUSH DX
    
    LEA DX, msg_resultado
    MOV AH, 09H
    INT 21H
    
    ; Verificar se houve overflow
    JC mostrar_overflow
    
    ; Mostrar número normal
    CALL IMPRIMIR_NUMERO
    JMP fim_mostrar
    
mostrar_overflow:
    LEA DX, msg_overflow
    MOV AH, 09H
    INT 21H
    
fim_mostrar:
    LEA DX, nova_linha
    MOV AH, 09H
    INT 21H
    
    POP DX
    POP AX
    RET
MOSTRAR_RESULTADO ENDP

; Procedimento para imprimir número
IMPRIMIR_NUMERO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CX, 0
    MOV BX, 10
    
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
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE preparar_pilha
    
imprimir_digitos:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP imprimir_digitos
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_NUMERO ENDP

END MAIN