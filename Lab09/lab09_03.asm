; =================================================================
; PARTE 3: PROGRAMA DE SOMA DE MATRIZES
; Objetivo: Ler, Imprimir e Somar elementos de uma matriz 4x4.
; Usa procedimentos separados para Ler, Somar e Imprimir.
; =================================================================

.MODEL SMALL
.STACK 100H

; --- CONSTANTES ---
TAM_LINHA EQU 4   ; Número de colunas
NUM_LINHAS EQU 4  ; Número de linhas
MATRIZ_SIZE EQU 16 ; 4 * 4 = 16 elementos

; --- SEGMENTO DE DADOS ---
.DATA
    ; Matriz 4x4 (reservando espaço, sem inicializar)
    MATRIZ4X4 DB MATRIZ_SIZE DUP(?) 
    
    ; Variável para armazenar a soma total (Define Word = 16 bits)
    SOMA_TOTAL DW 0 
    
    MSG_LER DB 'Digite um numero (0-6): $'
    MSG_LIDA DB 0DH, 0AH, 'Matriz Lida:', 0DH, 0AH, '$' 
    MSG_SOMA DB 0DH, 0AH, 'Soma Total: $'
    ESP_SEP DB ' $' 
    QUEBRA_LINHA DB 0DH, 0AH, '$' 
    
    ; Buffer auxiliar para conversão de números binários para ASCII (máximo 5 dígitos para 16 bits)
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
    
    ; 4. Imprimir a soma (chamamos a rotina de impressão de número)
    MOV AH, 09H
    LEA DX, MSG_SOMA
    INT 21H
    
    CALL IMPRIME_NUMERO_DEC ; Imprime o valor de SOMA_TOTAL
    
    ; Terminar o programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; =================================================================
; PROCEDIMENTO 1: LER_MATRIZ
; Lê 16 elementos da matriz via input do usuário.
; SI (Linha), BX (Coluna)
; =================================================================
LER_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    XOR SI, SI                          ; SI = 0 (Índice da Linha)
    
LOOP_LINHAS_LER:
    CMP SI, NUM_LINHAS
    JGE FIM_LER_MATRIZ
    
    XOR BX, BX                          ; BX = 0 (Índice da Coluna)
    
LOOP_COLUNAS_LER:
    CMP BX, TAM_LINHA
    JGE FIM_COLUNAS_LER
    
    ; --- CÁLCULO DO OFFSET E MENSAGEM ---
    
    ; 1. Imprime a mensagem de leitura
    MOV AH, 09H
    LEA DX, MSG_LER
    INT 21H
    
    ; 2. Chama a rotina para ler um dígito (0-9) e armazena em AL (BINÁRIO)
    CALL LER_NUMERO                     ; Resultado BINÁRIO em AL
    
    ; 3. Calcula o Offset total (SI * 4 + BX)
    PUSH BX                             ; Salva BX (índice da Coluna)
    PUSH SI                             ; Salva SI (índice da Linha)
    
    MOV CH, TAM_LINHA                   ; CH = 4
    MOV CL, AL                          ; AL (o número lido) está livre. Usaremos AL para guardar o valor
    MOV AL, 4                           ; AL = 4
    MUL SI                              ; AX = AL * SI (Offset da Linha)
    ADD AX, BX                          ; AX = Offset da Linha + BX (Offset Total)
    
    ; 4. Armazena o valor lido na matriz
    MOV DI, AX                          ; Usa DI como offset
    MOV MATRIZ4X4[DI], CL               ; Armazena o valor lido (que está em CL) na posição [DI]
    
    POP SI                              ; Restaura SI
    POP BX                              ; Restaura BX
    
    ; --- Atualização do Índice da Coluna ---
    
    INC BX
    JMP LOOP_COLUNAS_LER
    
FIM_COLUNAS_LER:
    ; Imprime uma quebra de linha após a linha de prompts
    MOV AH, 09H
    LEA DX, QUEBRA_LINHA
    INT 21H

    ; --- Atualização do Índice da Linha ---
    
    INC SI
    JMP LOOP_LINHAS_LER
    
FIM_LER_MATRIZ:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
LER_MATRIZ ENDP

; --- ROTINA AUXILIAR PARA LER UM DÍGITO (0-9) ---
LER_NUMERO PROC
    PUSH DX
    PUSH CX
    
    ; Lê um caractere (INT 21h, AH=01h)
    MOV AH, 01H
    INT 21H                             ; AL contém o caractere ASCII lido (e é impresso)
    
    SUB AL, '0'                         ; Converte de ASCII para BINÁRIO (Ex: '4' - '0' = 4)
    ; O valor lido (0-9) está em AL
    
    MOV DL, 0DH                         ; Imprime CR (Carriage Return) para pular a linha
    MOV AH, 02H
    INT 21H
    
    MOV DL, 0AH                         ; Imprime LF (Line Feed)
    MOV AH, 02H
    INT 21H
    
    POP CX
    POP DX
    RET
LER_NUMERO ENDP

; =================================================================
; PROCEDIMENTO 2: IMPRIMIR_MATRIZ
; Imprime a matriz no formato 4x4. Reutiliza lógica da Parte 2.
; SI (Linha), BX (Coluna)
; =================================================================
IMPRIMIR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; Imprime a mensagem "Matriz Lida:"
    MOV AH, 09H
    LEA DX, MSG_LIDA
    INT 21H
    
    XOR SI, SI                          ; SI = 0 (Índice da Linha)
    
LOOP_LINHAS_IMP:
    CMP SI, NUM_LINHAS
    JGE FIM_IMPRIMIR_MATRIZ
    
    XOR BX, BX                          ; BX = 0 (Índice da Coluna)
    
LOOP_COLUNAS_IMP:
    CMP BX, TAM_LINHA
    JGE FIM_COLUNAS_IMP
    
    ; --- CÁLCULO E ACESSO AO ELEMENTO ---
    ; Endereço = [MATRIZ4X4 + (SI * 4) + BX]
    
    ; 1. Calcula o Offset total (SI * 4 + BX)
    PUSH BX                             ; Salva BX
    PUSH SI                             ; Salva SI
    
    MOV AL, 4                           ; AL = 4 (Tamanho da linha)
    MUL SI                              ; AX = AL * SI (Offset da Linha)
    ADD AL, BL                          ; AL = Offset da Linha (parte baixa) + BL (Offset da Coluna)
    
    ; 2. Acessa e imprime o elemento
    MOV BL, AL                          ; BL agora contém o offset total
    MOV AL, MATRIZ4X4[BX]               ; AL recebe o valor BINÁRIO do elemento
    
    ; 3. Converte para ASCII e imprime
    ADD AL, '0'                         ; AL = AL + 30H
    
    MOV DL, AL                          ; Caractere para DL
    MOV AH, 02H
    INT 21H
    
    ; 4. Imprimir o espaço separador
    MOV AH, 09H
    LEA DX, ESP_SEP
    INT 21H
    
    POP SI                              ; Restaura SI
    POP BX                              ; Restaura BX
    
    ; --- Atualização do Índice da Coluna ---
    
    INC BX
    JMP LOOP_COLUNAS_IMP
    
FIM_COLUNAS_IMP:
    ; Quebra de linha
    MOV AH, 09H
    LEA DX, QUEBRA_LINHA
    INT 21H
    
    ; --- Atualização do Índice da Linha ---
    
    INC SI
    JMP LOOP_LINHAS_IMP
    
FIM_IMPRIMIR_MATRIZ:
    POP SI
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_MATRIZ ENDP

; =================================================================
; PROCEDIMENTO 3: SOMAR_MATRIZ
; Percorre a matriz e acumula a soma em SOMA_TOTAL (DW - 16 bits).
; =================================================================
SOMAR_MATRIZ PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    
    MOV CX, MATRIZ_SIZE                 ; CX = 16 (Contador de elementos)
    MOV DI, OFFSET MATRIZ4X4            ; DI aponta para o início da matriz
    
    ; Zera a soma total (garantia)
    MOV WORD PTR SOMA_TOTAL, 0          ; SOMA_TOTAL = 0
    
LOOP_SOMA:
    MOV AL, [DI]                        ; AL recebe o elemento BINÁRIO atual
    CBW                                 ; Converte Byte para Word (AL para AX, estendendo o sinal)
    ADD SOMA_TOTAL, AX                  ; SOMA_TOTAL = SOMA_TOTAL + AX (soma acumulada em 16 bits)
    
    INC DI                              ; Próximo elemento (DI++)
    LOOP LOOP_SOMA                      ; Decrementa CX e salta se CX != 0
    
    POP DI
    POP CX
    POP BX
    POP AX
    RET
SOMAR_MATRIZ ENDP

; --- ROTINA AUXILIAR PARA IMPRIMIR NÚMERO (16 BITS) EM DECIMAL ---
; Assume que o número a ser impresso está em SOMA_TOTAL (DW)
IMPRIME_NUMERO_DEC PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV AX, SOMA_TOTAL                  ; AX = Número a ser convertido (ex: 96)
    MOV CX, 0                           ; CX será o contador de dígitos
    MOV BX, 10                          ; Divisor para decimal (10)
    
CONVERTE_LOOP:
    XOR DX, DX                          ; DX:AX / BX = AX (quociente), DX (resto)
    DIV BX                              ; Divide AX por 10. Quociente em AX, Resto em DX.
    PUSH DX                             ; Coloca o dígito (resto) na pilha (ex: 6)
    INC CX                              ; Incrementa o contador de dígitos
    CMP AX, 0                           ; Verifica se o quociente (AX) é zero
    JNE CONVERTE_LOOP                   ; Se não for zero, continua a divisão
    
    ; --- Imprimir os dígitos da pilha ---
    
IMPRIME_LOOP_DEC:
    POP DX                              ; Pega o dígito da pilha (ex: 9, depois 6)
    ADD DL, '0'                         ; Converte para ASCII
    MOV AH, 02H                         ; Função de impressão de caractere
    INT 21H                             ; Imprime
    LOOP IMPRIME_LOOP_DEC               ; Decrementa CX e repete até CX=0
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
IMPRIME_NUMERO_DEC ENDP

END MAIN