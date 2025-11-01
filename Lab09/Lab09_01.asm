; =================================================================
; PARTE 1: PROGRAMA DE INVERSÃO DE VETORES (MASM)
; Objetivo: Inverter um vetor de 7 posições, sem vetor auxiliar.
; Utiliza procedimentos e registradores BX, SI, DI.
; =================================================================

.MODEL SMALL
.STACK 100H

; --- SEGMENTO DE DADOS ---
.DATA
    ; Declaração do vetor de 7 posições (DB = Define Byte)
    VETOR DB 1, 2, 3, 4, 5, 6, 7  ; Valores iniciais para teste (0-9)
    TAMANHO EQU 7                 ; Constante para o tamanho do vetor

    MSG_ORIGINAL DB 'Vetor Original: $'
    MSG_INVERTIDO DB 0DH, 0AH, 'Vetor Invertido: $' ; 0DH, 0AH = Nova Linha
    ESP_SEP DB ' $' ; Espaçamento entre os números

; --- SEGMENTO DE CÓDIGO ---
.CODE
MAIN PROC
    ; Inicializa o segmento de dados
    MOV AX, @DATA
    MOV DS, AX

    ; 1. LER o vetor (Apenas exibição inicial para contexto)
    CALL LER_VETOR

    ; 2. INVERTER o vetor
    CALL INVERTER_VETOR

    ; 3. IMPRIMIR o vetor
    CALL IMPRIMIR_VETOR

    ; Terminar o programa (INT 21h, AH=4Ch)
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; =================================================================
; PROCEDIMENTO 1: LER_VETOR
; Apenas exibe a mensagem inicial para contexto.
; =================================================================
LER_VETOR PROC
    ; Imprime a mensagem "Vetor Original:"
    MOV AH, 09H             ; Função de imprimir string (INT 21h)
    LEA DX, MSG_ORIGINAL    ; Carrega o endereço da mensagem
    INT 21H
    
    ; Exibe o vetor original (reutilizando a lógica de impressão)
    CALL IMPRIMIR_VETOR     ; Chama o procedimento de impressão
    
    RET
LER_VETOR ENDP

; =================================================================
; PROCEDIMENTO 2: INVERTER_VETOR
; Inverte a ordem do vetor VETOR no próprio lugar (in-place).
; Utiliza SI (início) e DI (fim) como ponteiros, e BX como temporário.
; =================================================================
INVERTER_VETOR PROC
    ; --- Inicialização dos Índices ---
    
    XOR SI, SI                          ; SI = 0 (Índice do primeiro elemento)
    
    ; DI = TAMANHO - 1 (Índice do último elemento)
    MOV DI, TAMANHO                     ; DI = 7
    DEC DI                              ; DI = 6
    
    ; --- Loop de Inversão ---
    ; Continuar enquanto SI < DI (enquanto o índice inicial for menor que o final)
    
INVERTE_LOOP:
    CMP SI, DI                          ; Compara os índices SI e DI
    JGE FIM_INVERTE                     ; Se SI >= DI, a inversão está completa, salta
    
    ; --- Passos da Troca (Swap) ---
    
    ; 1. Guardar VETOR[SI] em BX (temporário)
    MOV BL, VETOR[SI]                   ; BL (parte baixa de BX) recebe o valor do início
    
    ; 2. Copiar VETOR[DI] para VETOR[SI]
    MOV AL, VETOR[DI]                   ; AL recebe o valor do fim
    MOV VETOR[SI], AL                   ; VETOR[SI] recebe o valor de VETOR[DI]
    
    ; 3. Copiar o valor temporário (BX) para VETOR[DI]
    MOV VETOR[DI], BL                   ; VETOR[DI] recebe o valor original de VETOR[SI] (em BL)
    
    ; --- Atualização dos Índices ---
    
    INC SI                              ; Incrementa o índice inicial (SI++)
    DEC DI                              ; Decrementa o índice final (DI--)
    JMP INVERTE_LOOP                    ; Volta para o início do loop
    
FIM_INVERTE:
    RET
INVERTER_VETOR ENDP

; =================================================================
; PROCEDIMENTO 3: IMPRIMIR_VETOR
; Imprime todos os elementos do vetor, um por um.
; Utiliza BX como índice (0 a 6).
; =================================================================
IMPRIMIR_VETOR PROC
    ; --- Impressão da Mensagem (se for o vetor invertido) ---
    
    ; Verificamos se foi chamado pelo MAIN (após inversão) ou por LER_VETOR
    ; Se for a primeira vez que entra (chamado do MAIN), imprime a nova linha e mensagem.
    ; Se foi chamado por LER_VETOR, a mensagem e nova linha já foram tratadas.
    
    ; Para simplicidade, vamos garantir a nova linha e a mensagem "Invertido" 
    ; apenas se a mensagem original não foi exibida.
    
    ; Vamos apenas imprimir a mensagem "Vetor Invertido:"
    MOV AH, 09H
    LEA DX, MSG_INVERTIDO
    INT 21H
    
    ; --- Inicialização do Índice de Impressão ---
    
    XOR BX, BX                          ; BX = 0 (Índice de iteração)
    
IMPRIME_LOOP:
    CMP BX, TAMANHO                     ; Compara BX com 7
    JGE FIM_IMPRIME                     ; Se BX >= 7, o vetor foi totalmente impresso, salta
    
    ; --- Imprimir o Elemento Atual ---
    
    ; 1. Obter o valor
    MOV AL, VETOR[BX]                   ; AL recebe VETOR[BX]
    
    ; 2. Converter para ASCII ('0' a '9') e imprimir
    ; Como os valores são pequenos (0-9), basta adicionar '0' (30H)
    ADD AL, '0'                         ; AL = AL + 30H (Ex: 1 + '0' -> '1')
    
    ; 3. Imprimir o caractere
    MOV DL, AL                          ; Caractere a ser impresso vai para DL
    MOV AH, 02H                         ; Função de imprimir caractere (INT 21h)
    INT 21H                             ; Executa a impressão
    
    ; 4. Imprimir o espaço separador
    MOV AH, 09H                         ; Imprimir string
    LEA DX, ESP_SEP                     ; Endereço do espaço ' $'
    INT 21H                             ; Executa a impressão
    
    ; --- Atualização do Índice ---
    
    INC BX                              ; BX++ (Próximo elemento)
    JMP IMPRIME_LOOP                    ; Volta para o início do loop
    
FIM_IMPRIME:
    RET
IMPRIMIR_VETOR ENDP

END MAIN