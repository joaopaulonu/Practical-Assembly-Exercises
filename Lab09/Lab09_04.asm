; =================================================================
; PARTE 4: PROGRAMA DE SOMA DE MATRIZES (COM MACROS)
; Objetivo: Ler, Imprimir e Somar elementos de uma matriz 4x4.
; Usa procedimentos e MACROS para modularização.
; =================================================================

.MODEL SMALL
.STACK 100H

; --- CONSTANTES ---
TAM_LINHA EQU 4   ; Número de colunas
NUM_LINHAS EQU 4  ; Número de linhas
MATRIZ_SIZE EQU 16 ; 4 * 4 = 16 elementos

; --- DEFINIÇÃO DE MACROS ---
; 1. Macro para imprimir uma string
IMPRIME_STR MACRO MENSAGEM
    PUSH AX
    PUSH DX
    MOV AH, 09H             ; Função de imprimir string (INT 21h)
    LEA DX, MENSAGEM        ; Carrega o endereço da mensagem
    INT 21H
    POP DX
    POP AX
ENDM

; 2. Macro para imprimir uma quebra de linha
QUEBRA_LINHA MACRO
    IMPRIME_STR QUEBRA_LINHA_VAR
ENDM

; --- SEGMENTO DE DADOS ---
.DATA
    MATRIZ4X4 DB MATRIZ_SIZE DUP(?) ; Reserva 16 bytes
    SOMA_TOTAL DW 0                 ; Armazena a soma total (16 bits)
    
    MSG_LER DB 'Digite um numero (0-6): $'
    MSG_LIDA DB 0DH, 0AH, 'Matriz Lida:', 0DH, 0AH, '$' 
    MSG_SOMA DB 0DH, 0AH, 'Soma Total: $'
    ESP_SEP DB ' $' 
    QUEBRA_LINHA_VAR DB 0DH, 0AH, '$' ; Variável para a macro QUEBRA_LINHA
    
    ; Buffer auxiliar para conversão de números binários para ASCII
    BUFFER_ASCII DB '     $' 
    
; --- SEGMENTO DE CÓDIGO ---
.CODE
MAIN PROC
    ; Inicializa o segmento de dados
    MOV AX, @DATA
    MOV DS, AX

    ; 1. Ler a matriz
    CALL LER_MATRIZ

    ; 2. Imprimir a matriz lida
    CALL IMPRIMIR_MATRIZ
    
    ; 3. Somar a matriz
    CALL SOMAR_MATRIZ
    
    ; 4. Imprimir a soma
    IMPRIME_STR MSG_SOMA        ; Usando a MACRO!
    CALL IMPRIME_NUMERO_DEC     ; Imprime o valor de SOMA_TOTAL (procedimento)
    
    ; Terminar o programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; --- ROTINA AUXILIAR PARA LER UM DÍGITO (0-9) ---
LER_NUMERO PROC
    PUSH DX
    PUSH CX
    
    MOV AH, 01H
    INT 21H                             ; AL contém o caractere ASCII lido (e é impresso)
    
    SUB AL, '0'                         ; Converte de ASCII para BINÁRIO (Valor em AL)
    
    QUEBRA_LINHA                        ; Usando a MACRO para formatar o output
    
    POP CX
    POP DX
    RET
LER_NUMERO ENDP

; =================================================================
; PROCEDIMENTO 1: LER_MATRIZ (Usa Macros e Procedimentos)
; =================================================================
LER_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    XOR SI, SI                          ; SI = 0 (Índice da Linha)
    
LOOP_LINHAS_LER_4:
    CMP SI, NUM_LINHAS
    JGE FIM_LER_MATRIZ_4
    
    XOR BX, BX                          ; BX = 0 (Índice da Coluna)
    
LOOP_COLUNAS_LER_4:
    CMP BX, TAM_LINHA
    JGE FIM_COLUNAS_LER_4
    
    ; 1. Imprime a mensagem de leitura (usando a MACRO)
    IMPRIME_STR MSG_LER
    
    ; 2. Chama a rotina para ler um dígito (Resultado BINÁRIO em AL)
    CALL LER_NUMERO
    MOV CL, AL                          ; Salva o valor lido (BINÁRIO) em CL
    
    ; 3. Calcula o Offset total (SI * 4 + BX)
    PUSH BX                             
    PUSH SI                             
    
    MOV AL, 4                           
    MUL SI                              ; AX = Offset da Linha
    ADD AX, BX                          ; AX = Offset Total
    
    ; 4. Armazena o valor lido na matriz
    MOV DI, AX                          ; Usa DI como offset
    MOV MATRIZ4X4[DI], CL               ; Armazena o valor lido (em CL)
    
    POP SI                              
    POP BX                              
    
    INC BX
    JMP LOOP_COLUNAS_LER_4
    
FIM_COLUNAS_LER_4:
    QUEBRA_LINHA                        ; Usando a MACRO para pular linha entre os prompts
    
    INC SI
    JMP LOOP_LINHAS_LER_4
    
FIM_LER_MATRIZ_4:
    POP DI
    POP SI
    POP CX
    POP BX
    POP AX
    RET
LER_MATRIZ ENDP

; =================================================================
; PROCEDIMENTO 2: IMPRIMIR_MATRIZ (Usa Macros e Procedimentos)
; =================================================================
IMPRIMIR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Imprime a mensagem "Matriz Lida:" (usando a MACRO)
    IMPRIME_STR MSG_LIDA
    
    XOR SI, SI                          ; SI = 0 (Índice da Linha)
    
LOOP_LINHAS_IMP_4:
    CMP SI, NUM_LINHAS
    JGE FIM_IMPRIMIR_MATRIZ_4
    
    XOR BX, BX                          ; BX = 0 (Índice da Coluna)
    
LOOP_COLUNAS_IMP_4:
    CMP BX, TAM_LINHA
    JGE FIM_COLUNAS_IMP_4
    
    ; --- CÁLCULO E ACESSO AO ELEMENTO ---
    PUSH BX                             
    PUSH SI                             
    
    MOV AL, 4                           
    MUL SI                              ; AX = Offset da Linha
    ADD AL, BL                          ; AL = Offset Total (parte baixa)
    
    ; 2. Acessa e imprime o elemento
    MOV BL, AL                          
    MOV AL, MATRIZ4X4[BX]               ; AL recebe o valor BINÁRIO
    
    ; 3. Converte para ASCII e imprime
    ADD AL, '0'                         
    
    MOV DL, AL                          
    MOV AH, 02H
    INT 21H                             ; Imprime o dígito
    
    IMPRIME_STR ESP_SEP                 ; Usando MACRO para o espaço
    
    POP SI                              
    POP BX                              
    
    INC BX
    JMP LOOP_COLUNAS_IMP_4
    
FIM_COLUNAS_IMP_4:
    QUEBRA_LINHA                        ; Usando MACRO
    
    INC SI
    JMP LOOP_LINHAS_IMP_4
    
FIM_IMPRIMIR_MATRIZ_4:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_MATRIZ ENDP

; =================================================================
; PROCEDIMENTO 3: SOMAR_MATRIZ (Igual à Parte 3)
; =================================================================
SOMAR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    
    MOV CX, MATRIZ_SIZE                 ; CX = 16 (Contador)
    MOV DI, OFFSET MATRIZ4X4            ; DI aponta para o início
    
    MOV WORD PTR SOMA_TOTAL, 0          ; Zera a soma total
    
LOOP_SOMA_4:
    MOV AL, [DI]                        ; AL recebe o elemento BINÁRIO
    CBW                                 ; Converte Byte para Word (AL para AX)
    ADD SOMA_TOTAL, AX                  ; SOMA_TOTAL += AX
    
    INC DI                              ; Próximo elemento
    LOOP LOOP_SOMA_4
    
    POP DI
    POP CX
    POP BX
    POP AX
    RET
SOMAR_MATRIZ ENDP

; --- ROTINA AUXILIAR PARA IMPRIMIR NÚMERO (16 BITS) EM DECIMAL (Igual à Parte 3) ---
IMPRIME_NUMERO_DEC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV AX, SOMA_TOTAL                  ; AX = Número a ser convertido
    MOV CX, 0                           ; CX será o contador de dígitos
    MOV BX, 10                          ; Divisor para decimal (10)
    
CONVERTE_LOOP_4:
    XOR DX, DX                          
    DIV BX                              ; Divisão por 10
    PUSH DX                             ; Coloca o dígito (resto) na pilha
    INC CX                              
    CMP AX, 0                           
    JNE CONVERTE_LOOP_4                 
    
IMPRIME_LOOP_DEC_4:
    POP DX                              
    ADD DL, '0'                         ; Converte para ASCII
    MOV AH, 02H                         
    INT 21H                             
    LOOP IMPRIME_LOOP_DEC_4               
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIME_NUMERO_DEC ENDP

END MAIN