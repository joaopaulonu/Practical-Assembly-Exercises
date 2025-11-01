; =================================================================
; PARTE 2: PROGRAMA PARA MANIPULAÇÃO DE MATRIZES (IMPRESSÃO)
; Objetivo: Imprimir uma matriz 4x4 no formato de linhas e colunas.
; Utiliza procedimentos e registradores SI (Linha) e BX (Coluna).
; =================================================================

.MODEL SMALL
.STACK 100H

; --- CONSTANTES ---
TAM_LINHA EQU 4   ; Tamanho de uma linha (Número de colunas)
NUM_LINHAS EQU 4  ; Número de linhas da matriz

; --- SEGMENTO DE DADOS ---
.DATA
    MSG_TITULO DB 'Matriz 4x4 Impressa:', 0DH, 0AH, '$' ; 0DH, 0AH = Nova Linha
    ESP_SEP DB ' $' ; Espaçamento entre os números
    QUEBRA_LINHA DB 0DH, 0AH, '$' ; Quebra de linha (Carriage Return + Line Feed)

    ; Matriz 4x4 declarada (16 bytes, um byte por elemento)
    MATRIZ4X4 DB 1, 2, 3, 4
              DB 4, 3, 2, 1
              DB 5, 6, 7, 8
              DB 8, 7, 6, 5

; --- SEGMENTO DE CÓDIGO ---
.CODE
MAIN PROC
    ; Inicializa o segmento de dados
    MOV AX, @DATA
    MOV DS, AX

    ; Imprime o título
    MOV AH, 09H
    LEA DX, MSG_TITULO
    INT 21H

    ; Chama o procedimento para imprimir a matriz
    CALL IMPRIMIR_MATRIZ

    ; Terminar o programa (INT 21h, AH=4Ch)
    MOV AH, 4CH
    INT 21H
MAIN ENDP

; =================================================================
; PROCEDIMENTO: IMPRIMIR_MATRIZ
; Percorre a matriz usando loop aninhado (Linhas e Colunas)
; SI (Source Index) é usado como índice da LINHA.
; BX (Base Register) é usado como índice da COLUNA.
; =================================================================
IMPRIMIR_MATRIZ PROC
    ; Preserva os registradores que serão modificados (boa prática)
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH SI
    
    ; --- LOOP EXTERNO: LINHAS ---
    
    XOR SI, SI                          ; SI = 0 (Índice da Linha atual)
    
LOOP_LINHAS:
    CMP SI, NUM_LINHAS                  ; Compara SI com 4 (número de linhas)
    JGE FIM_IMPRIME_MATRIZ              ; Se SI >= 4, terminamos a impressão
    
    ; --- LOOP INTERNO: COLUNAS ---
    
    XOR BX, BX                          ; BX = 0 (Índice da Coluna atual)
    
LOOP_COLUNAS:
    CMP BX, TAM_LINHA                   ; Compara BX com 4 (número de colunas)
    JGE FIM_LOOP_COLUNAS                ; Se BX >= 4, terminamos a linha, salta para quebrar linha
    
    ; --- CÁLCULO E ACESSO AO ELEMENTO ---
    ; Endereço = [MATRIZ4X4 + (SI * TAM_LINHA) + BX]
    
    ; 1. Calcula o Deslocamento da Linha (SI * TAM_LINHA)
    MOV AL, 4                           ; AL = 4 (Tamanho da linha)
    MUL SI                              ; AX = AL * SI. Resultado (Offset da Linha) está em AX.
    
    ; 2. Adiciona o Deslocamento da Coluna (BX)
    ADD AL, BL                          ; AL = Offset da Linha (só a parte baixa) + BX (índice da Coluna)
                                        ; Note: O resultado da MUL está em AX, mas como a matriz é pequena (4x4),
                                        ; o offset máximo é 15 (Fh), que cabe em AL.
    
    ; 3. Acessa o elemento da matriz
    ; Usamos BX para o índice combinado, carregando o offset calculado no registrador de base
    MOV BL, AL                          ; BL agora contém o offset total para o elemento
    MOV AL, MATRIZ4X4[BX]               ; AL recebe o valor de MATRIZ4X4[Offset]
    
    ; --- IMPRESSÃO DO ELEMENTO ---
    
    ; 1. Converte para ASCII ('0' a '9')
    ADD AL, '0'                         ; AL = AL + 30H
    
    ; 2. Imprimir o caractere
    MOV DL, AL                          ; Caractere para DL
    MOV AH, 02H                         ; Função de imprimir caractere
    INT 21H                             ; Executa a impressão
    
    ; 3. Imprimir o espaço separador
    PUSH DX                             ; Salva o valor de DL/DX para poder usar DX na impressão de string
    MOV AH, 09H
    LEA DX, ESP_SEP
    INT 21H
    POP DX                              ; Restaura DL/DX
    
    ; --- Atualização do Índice da Coluna ---
    
    INC BX                              ; BX++ (Próxima coluna)
    JMP LOOP_COLUNAS                    ; Volta para o loop interno
    
FIM_LOOP_COLUNAS:
    ; --- QUEBRA DE LINHA ---
    
    ; Imprime a quebra de linha após a conclusão de uma linha da matriz
    MOV AH, 09H
    LEA DX, QUEBRA_LINHA
    INT 21H
    
    ; --- Atualização do Índice da Linha ---
    
    INC SI                              ; SI++ (Próxima linha)
    JMP LOOP_LINHAS                     ; Volta para o loop externo
    
FIM_IMPRIME_MATRIZ:
    ; Restaura os registradores
    POP SI
    POP CX
    POP BX
    POP AX
    RET
IMPRIMIR_MATRIZ ENDP

END MAIN