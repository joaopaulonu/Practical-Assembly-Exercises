; ==========================================================
; PUCCAMPINAS - Laboratório de Organização de Computadores
; Atividade 10 - Conversor de Bases Numéricas (BIN, DEC, HEX)
; ==========================================================

.MODEL SMALL
.STACK 100H

.DATA
    ; Variáveis de Mensagens e I/O
    MSG_MENU        DB '--- Conversor de Bases ---', 0DH, 0AH
                    DB 'Base de ENTRADA: (B)in, (D)ec, (H)ex: $'
    MSG_SAIDA       DB 0DH, 0AH, 'Base de SAIDA: (B)in, (D)ec, (H)ex: $'
    MSG_RESULTADO   DB 0DH, 0AH, 'Resultado: $'
    MSG_ERRO_OPCAO  DB 0DH, 0AH, 'Opcao invalida. Tente B, D ou H.', 0DH, 0AH, '$'
    
    ; Variáveis para o programa principal
    BASE_ENTRADA    DB ?
    BASE_SAIDA      DB ?
    NUMERO_CONVERTIDO DW 0   ; O valor numérico de 16-bits (AX)
    
    ; Variáveis para OUTPUT_DECIMAL
    PILHA_RESTOS    DW 10 DUP(?) ; Espaco para 5 digitos * 2 bytes + 1 sinal (para 16-bits)
    CONTADOR_DEC    DB 0         ; Contador de digitos
    
.CODE

; ==========================================================
; PROCEDIMENTO PRINCIPAL
; ==========================================================
MAIN PROC
    ; Inicializa registradores de segmento de dados
    MOV AX, @DATA
    MOV DS, AX

    ; --- 1. Exibir Menu e Coletar Bases ---
    CALL PROMPT_BASES

    ; --- 2. Entrada do Número na Base Escolhida ---
    CALL LEITURA_NUMERO

    ; --- 3. Saída do Número na Base Escolhida ---
    CALL SAIDA_NUMERO
    
    ; --- 4. Finalização ---
    MOV AH, 4CH      ; Função para terminar o programa
    INT 21H
MAIN ENDP

; ==========================================================
; PROCEDIMENTOS DE SUPORTE
; ==========================================================

; ----------------------------------------------------------
; PROMPT_BASES: Exibe o menu e le as bases de entrada/saida
; ----------------------------------------------------------
PROMPT_BASES PROC
    PUSH AX
    PUSH DX

    ; Leitura da Base de ENTRADA
    MOV AH, 09H
    MOV DX, OFFSET MSG_MENU
    INT 21H          ; Exibe a mensagem do menu
    
    MOV AH, 01H      ; Le um caractere
    INT 21H          ; AL contem o caractere lido
    AND AL, 5FH      ; Converte para MAIÚSCULA (B, D ou H)
    MOV BASE_ENTRADA, AL

    ; Leitura da Base de SAÍDA
    MOV AH, 09H
    MOV DX, OFFSET MSG_SAIDA
    INT 21H          ; Exibe a mensagem de saida
    
    MOV AH, 01H      ; Le um caractere
    INT 21H          ; AL contem o caractere lido
    AND AL, 5FH      ; Converte para MAIÚSCULA (B, D ou H)
    MOV BASE_SAIDA, AL
    
    ; Pulo de linha extra para limpeza visual
    CALL PULO_LINHA

    POP DX
    POP AX
    RET
PROMPT_BASES ENDP

; ----------------------------------------------------------
; PULO_LINHA: Exibe um Carriage Return (CR) e Line Feed (LF)
; ----------------------------------------------------------
PULO_LINHA PROC
    PUSH AX
    PUSH DX

    MOV AH, 02H
    MOV DL, 0DH ; CR
    INT 21H
    MOV DL, 0AH ; LF
    INT 21H

    POP DX
    POP AX
    RET
PULO_LINHA ENDP

; ----------------------------------------------------------
; LEITURA_NUMERO: Chama o procedimento de entrada correto
; Resultado: O valor convertido em AX
; ----------------------------------------------------------
LEITURA_NUMERO PROC
    PUSH BX
    
    MOV AL, BASE_ENTRADA
    CMP AL, 'B'
    JE ENTRADA_BIN
    
    CMP AL, 'D'
    JE ENTRADA_DEC
    
    CMP AL, 'H'
    JE ENTRADA_HEX
    
    JMP FIM_LEITURA ; Opção inválida (deveria ter sido tratada antes, mas JMP para segurança)

ENTRADA_BIN:
    CALL INPUT_BINARIO
    JMP FIM_LEITURA

ENTRADA_DEC:
    CALL INPUT_DECIMAL
    JMP FIM_LEITURA

ENTRADA_HEX:
    CALL INPUT_HEXADECIMAL
    
FIM_LEITURA:
    POP BX
    RET
LEITURA_NUMERO ENDP

; ----------------------------------------------------------
; SAIDA_NUMERO: Chama o procedimento de saida correto
; Entrada: O valor a ser exibido está em AX
; ----------------------------------------------------------
SAIDA_NUMERO PROC
    PUSH BX
    PUSH DX
    
    ; Exibe a mensagem "Resultado: "
    MOV AH, 09H
    MOV DX, OFFSET MSG_RESULTADO
    INT 21H
    
    MOV AL, BASE_SAIDA
    CMP AL, 'B'
    JE SAIDA_BIN
    
    CMP AL, 'D'
    JE SAIDA_DEC
    
    CMP AL, 'H'
    JE SAIDA_HEX
    
    JMP FIM_SAIDA

SAIDA_BIN:
    CALL OUTPUT_BINARIO
    JMP FIM_SAIDA

SAIDA_DEC:
    CALL OUTPUT_DECIMAL
    JMP FIM_SAIDA

SAIDA_HEX:
    CALL OUTPUT_HEXADECIMAL
    
FIM_SAIDA:
    ; Pulo de linha apos a saida do numero
    CALL PULO_LINHA
    
    POP DX
    POP BX
    RET
SAIDA_NUMERO ENDP

; ==========================================================
; PROCEDIMENTOS DE ENTRADA (Input)
; Resultado final da conversão em AX
; ==========================================================

; ----------------------------------------------------------
; INPUT_BINARIO: Le binario (string '0'/'1') -> AX (número)
; Algoritmo: Desloca 1 à esquerda, insere novo bit
; [cite: 11, 16]
; ----------------------------------------------------------
INPUT_BINARIO PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 0      ; [cite: 17] Limpa BX (registrador de armazenamento)
    
LE_BIN_LOOP:
    MOV AH, 01H    ; [cite: 18] Entra um caractere '0' ou '1'
    INT 21H        ; AL = caractere
    
    CMP AL, 0DH    ; [cite: 19] WHILE caractere diferente de CR DO (CR = 0DH)
    JE FIM_LE_BIN
    
    ; Converte caractere para valor binário (0 ou 1)
    SUB AL, '0'    ;  '0' (30h) -> 0; '1' (31h) -> 1. O resultado fica em AL
    
    ; Desloca BX 1 casa para a esquerda
    SHL BX, 1      ;  Desloca BX 1 casa para a esquerda
    
    ; Insere o valor binário lido no LSB de BX
    OR BL, AL      ;  O valor binário está em AL (0 ou 1). BL é a parte baixa de BX.
    
    JMP LE_BIN_LOOP
    
FIM_LE_BIN:
    MOV AX, BX     ; Move o resultado final para AX
    
    POP DX
    POP CX
    POP BX
    RET
INPUT_BINARIO ENDP

; ----------------------------------------------------------
; INPUT_HEXADECIMAL: Le hexadecimal (string '0'-'F') -> AX (número)
; Algoritmo: Desloca 4 à esquerda, insere novo nibble
; [cite: 40, 45]
; ----------------------------------------------------------
INPUT_HEXADECIMAL PROC
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV BX, 0      ; [cite: 46] Inicializa BX
    
LE_HEX_LOOP:
    MOV AH, 01H    ; [cite: 47] Entra um caractere hexa
    INT 21H        ; AL = caractere
    
    CMP AL, 0DH    ; [cite: 48] WHILE caractere diferente de CR DO
    JE FIM_LE_HEX
    
    CALL CONVERTE_HEX_BINARIO ; Converte o caractere AL para valor binário de 4 bits em AL
    
    ; Desloca BX 4 casas para a esquerda
    MOV CL, 4
    SHL BX, CL     ;  Desloca BX 4 casas para a esquerda
    
    ; Insere valor binário nos 4 bits inferiores de BX
    OR BL, AL      ;  O valor binário (nibble) está em AL
    
    JMP LE_HEX_LOOP
    
FIM_LE_HEX:
    MOV AX, BX     ; Move o resultado final para AX
    
    POP DX
    POP CX
    POP BX
    RET
INPUT_HEXADECIMAL ENDP

; ----------------------------------------------------------
; CONVERTE_HEX_BINARIO: Converte caractere hexa (AL) para valor (AL)
; [cite: 49] Converte caractere para binário (nibble)
; ----------------------------------------------------------
CONVERTE_HEX_BINARIO PROC
    PUSH BX
    
    CMP AL, '9'    ; É um dígito 0-9?
    JLE IS_DIGITO  ; Sim, subtrai '0' (30h)
    
    ; É uma letra A-F
    SUB AL, 'A'    ; Subtrai 'A' (41h)
    ADD AL, 0AH    ; Adiciona 10 (0AH) para ter 10-15
    JMP FIM_CONVERTE
    
IS_DIGITO:
    SUB AL, '0'    ; Subtrai '0' (30h)
    
FIM_CONVERTE:
    POP BX
    RET
CONVERTE_HEX_BINARIO ENDP

; ----------------------------------------------------------
; INPUT_DECIMAL: Le decimal (string de dígitos) -> AX (número)
; Algoritmo: total = 10 * total + valor_binário
; [cite: 68, 69]
; ----------------------------------------------------------
INPUT_DECIMAL PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    MOV AX, 0      ; [cite: 70] total = 0. AX será o nosso total
    MOV SI, 0      ; negativo = FALSO (0)
    
    ; --- Tratamento de Sinal (Opcional) ---
    MOV AH, 01H
    INT 21H        ; Le o primeiro caractere
    
    CMP AL, '-'
    JNE CHECK_PLUS
    MOV SI, 1      ; [cite: 78] negativo = VERDADEIRO (1)
    MOV AH, 01H
    INT 21H        ; [cite: 78] ler um caractere
    JMP DEC_LOOP_START
    
CHECK_PLUS:
    CMP AL, '+'
    JNE DEC_LOOP_START
    MOV AH, 01H
    INT 21H        ; [cite: 79] ler um caractere
    
DEC_LOOP_START:
    ; [cite: 81] REPEAT
    CMP AL, 0DH    ; [cite: 85] UNTIL caractere é um carriage return (CR)
    JE FIM_LE_DEC
    
    ; Converter caractere em valor binário
    SUB AL, '0'    ; [cite: 82] Caractere (AL) -> Valor binário (AL)
    MOV BL, AL     ; Move o valor binário do dígito para BL
    
    ; total = 10 * total + valor binário
    PUSH AX        ; Salva AX (total)
    MOV CL, 10
    MUL CL         ;  AX = AL * CL (AX = total * 10)
    POP CX         ; Restaura o antigo AX para CL
    ADD AX, BX     ;  AX = AX + BX (valor binário). BX contem o valor do dígito em BL
    
    MOV AH, 01H
    INT 21H        ; [cite: 84] ler um caractere
    JMP DEC_LOOP_START
    
FIM_LE_DEC:
    ; Ajuste de sinal
    CMP SI, 1
    JNE FIM_TRATAMENTO_SINAL
    
    NEG AX         ;  total = - (total)
    
FIM_TRATAMENTO_SINAL:
    ; Resultado final já está em AX
    
    POP SI
    POP DX
    POP CX
    POP BX
    RET
INPUT_DECIMAL ENDP

; ==========================================================
; PROCEDIMENTOS DE SAÍDA (Output)
; Entrada: Valor a ser exibido está em AX
; ==========================================================

; ----------------------------------------------------------
; OUTPUT_BINARIO: AX (número) -> Binario (string '0'/'1')
; Algoritmo: Rotação de 16 vezes, testa o CF
; [cite: 23, 28]
; ----------------------------------------------------------
OUTPUT_BINARIO PROC
    PUSH AX
    PUSH CX
    PUSH DX
    
    MOV CX, 16     ; [cite: 29] FOR 16 vezes DO
    
BIN_LOOP:
    ROL AX, 1      ;  Rotação de AX à esquerda 1 casa binária (MSB vai para o CF)
    JC EXIBE_UM    ; Se CF=1, JUMP para exibir '1'
    
EXIBE_ZERO:
    MOV DL, '0'    ;  ELSE exibir no monitor caractere "0"
    JMP EXIBE_CARACTERE_BIN
    
EXIBE_UM:
    MOV DL, '1'    ;  THEN exibir no monitor caractere "1"
    
EXIBE_CARACTERE_BIN:
    MOV AH, 02H
    INT 21H        ; Exibição do caractere
    
    LOOP BIN_LOOP  ; [cite: 34] END_FOR
    
    POP DX
    POP CX
    POP AX
    RET
OUTPUT_BINARIO ENDP

; ----------------------------------------------------------
; OUTPUT_HEXADECIMAL: AX (número) -> Hexadecimal (string '0'-'F')
; Algoritmo: Mover byte alto, deslocar, converter e exibir, rodar AX 4 à esquerda
; [cite: 54, 58]
; ----------------------------------------------------------
OUTPUT_HEXADECIMAL PROC
    PUSH AX
    PUSH CX
    PUSH DX
    PUSH BX ; BX não é usado, mas é bom salvar

    MOV CX, 4      ;  FOR 4 vezes DO (4 nibbles em 16 bits)
    
HEX_LOOP:
    ; Vamos usar AH (byte alto de AX) para a conversão do nibble. 
    ; Como ROL AX, 4 rotaciona 4 bits, o nibble mais significativo estará no AL apos o ROL.
    
    ; O algoritmo original usa BX, vamos adaptar para AX. O nibble mais significativo
    ; de AX está no AH. Vamos rotacionar AX 4 vezes *antes* de entrar no loop para 
    ; colocar o nibble mais significativo no AL.
    
    ; ROL AX, 4 é um atalho para rodar AX 4 casas para a esquerda
    ROL AX, 4      ;  Rotação de AX 4 casas à esquerda (o nibble MSB vai para LSB do AH)
    
    ; Mover o nibble (agora em AH, mas queremos o valor) para DL para processamento
    MOV DL, AH     ; DL recebe o nibble mais significativo (agora no AH)
    AND DL, 0FH    ; Isola apenas os 4 bits menos significativos (o nibble)
    
    CMP DL, 0AH    ; [cite: 62] IF DL < 10
    JL IS_DIGITO_HEX ; Se for menor que 10 (0-9)
    
    ; É uma letra A-F (10-15)
    ADD DL, 'A' - 0AH ; [cite: 64] ELSE converte para caractere na faixa A a F
    JMP EXIBE_CARACTERE_HEX
    
IS_DIGITO_HEX:
    ADD DL, '0'    ; [cite: 64] THEN converte para caractere na faixa 0 a 9
    
EXIBE_CARACTERE_HEX:
    MOV AH, 02H
    INT 21H        ; [cite: 65] Exibição do caractere no monitor de vídeo
    
    LOOP HEX_LOOP  ; [cite: 67] END_FOR
    
    POP BX
    POP DX
    POP CX
    POP AX
    RET
OUTPUT_HEXADECIMAL ENDP


; ----------------------------------------------------------
; OUTPUT_DECIMAL: AX (número) -> Decimal (string de dígitos)
; Algoritmo: Divisões sucessivas por 10, resto na pilha, exibir pilha
; [cite: 89, 90]
; ----------------------------------------------------------
OUTPUT_DECIMAL PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    ; --- 1. Tratamento de Sinal ---
    CMP AX, 0      ; [cite: 91] IF AX < 0. No 8086, a flag de sinal (SF) é mais direta, mas 
                   ; para simplicidade, a comparação com 0 funciona para a lógica.
    JGE DEC_LOOP_START_CONV
    
    ; Exibe sinal de menos
    MOV DL, '-'
    MOV AH, 02H
    INT 21H        ; [cite: 93] THEN exibe um sinal de menos
    
    NEG AX         ; [cite: 93] substitui-se AX pelo seu complemento de 2 (torna positivo)
    
DEC_LOOP_START_CONV:
    MOV SI, OFFSET PILHA_RESTOS ; Ponteiro para a base da pilha de restos
    MOV CONTADOR_DEC, 0         ; [cite: 94] contador = 0
    MOV BX, 10                  ; Divisor = 10 (usado na DIV)
    
DEC_LOOP_REPEAT:
    ; [cite: 95] REPEAT
    MOV DX, 0      ; O dividendo (AX) é 16 bits. DX:AX / BX
    DIV BX         ; AX = Quociente (AX/10); DX = Resto (AX mod 10)
    
    PUSH DX        ;  colocar o resto na pilha (usando a nossa área de dados)
    MOV [SI], DL   ; Salva o resto (DL) no nosso array (simulando a pilha)
    INC SI
    INC CONTADOR_DEC ;  contador = contador + 1
    
    CMP AX, 0
    JNE DEC_LOOP_REPEAT ;  UNTIL quociente = 0
    
    ; --- 2. Exibição dos Dígitos (na ordem correta) ---
    
    MOV CL, CONTADOR_DEC ; [cite: 100] FOR contador vezes DO
    MOV CH, 0            ; Zerar CH para usar CX como contador
    MOV SI, OFFSET PILHA_RESTOS ; Reinicia o ponteiro para o início
    
DEC_LOOP_EXIBE:
    DEC SI         ; Voltamos para o último resto salvo (ordem inversa)
    MOV DL, [SI]   ; [cite: 101] retirar um resto (número) da pilha (restaura o resto no DL)
    
    ADD DL, '0'    ; [cite: 102] converter para caractere ASCII
    
    MOV AH, 02H
    INT 21H        ; [cite: 103] exibir o caractere no monitor
    
    LOOP DEC_LOOP_EXIBE ; [cite: 104] END_FOR
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
OUTPUT_DECIMAL ENDP

END MAIN