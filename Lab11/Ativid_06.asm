.MODEL SMALL
.STACK 100H

.DATA
    msg_original DB 'Byte original: $'
    msg_espelhado DB 13, 10, 'Byte espelhado: $'
    msg_binario DB 13, 10, 'Em binario: $'
    nova_linha DB 13, 10, '$'
    teste_byte DB 10110011b  ; Byte de teste: 179 decimal ou B3 hex

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Testar com byte pré-definido
    MOV BL, teste_byte
    
    ; Mostrar byte original
    LEA DX, msg_original
    MOV AH, 09H
    INT 21H
    CALL IMPRIMIR_BYTE_BINARIO
    
    ; Espelhar os bits
    CALL ESPELHAR_BITS
    
    ; Mostrar byte espelhado
    LEA DX, msg_espelhado
    MOV AH, 09H
    INT 21H
    CALL IMPRIMIR_BYTE_BINARIO
    
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; Procedimento principal de espelhamento
ESPELHAR_BITS PROC
    PUSH AX
    PUSH CX
    PUSH DX
    
    MOV CX, 8          ; Contador: 8 bits para processar
    MOV AL, BL         ; Copiar BL para AL para trabalhar
    MOV BL, 0          ; Zerar BL para construir resultado
    
espelhar_loop:
    SHR AL, 1          ; Shift right em AL, bit 0 vai para CF
    RCL BL, 1          ; Rotate left through carry em BL, CF entra no bit 0
    
    LOOP espelhar_loop  ; Repetir para todos os 8 bits
    
    POP DX
    POP CX
    POP AX
    RET
ESPELHAR_BITS ENDP

; Procedimento para imprimir byte em binário
IMPRIMIR_BYTE_BINARIO PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AH, 02H        ; Função de imprimir caractere
    MOV CX, 8          ; 8 bits para imprimir
    
imprimir_bit:
    RCL BL, 1          ; Rotate left through carry - bit mais significativo para CF
    JC imprimir_um     ; Se CF=1, imprimir '1'
    
    ; Imprimir '0'
    MOV DL, '0'
    INT 21H
    JMP proximo_bit
    
imprimir_um:
    ; Imprimir '1'
    MOV DL, '1'
    INT 21H
    
proximo_bit:
    LOOP imprimir_bit
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_BYTE_BINARIO ENDP

END MAIN