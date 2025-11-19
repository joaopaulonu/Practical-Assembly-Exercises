.MODEL SMALL
.STACK 100H

.DATA
    
    tabela_traducao DB 256 DUP(?)  ; Tabela completa ASCII
    
    ; Mensagens para teste
    msg_teste1 DB 'Digite uma letra maiuscula: $'
    msg_teste2 DB 13, 10, 'Convertida para minuscula: $'
    msg_original DB 13, 10, 'Original: $'
    nova_linha DB 13, 10, '$'

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    
    ; Inicializar a tabela de tradução
    CALL INICIALIZAR_TABELA
    
    ; ========== TESTE DO PROCEDIMENTO ==========
    ; Pedir letra ao usuário
    LEA DX, msg_teste1
    MOV AH, 09H
    INT 21H
    
    ; Ler um caractere
    MOV AH, 01H
    INT 21H
    
    ; Chamar procedimento de conversão
    CALL CONVERTER_MINUSCULA
    
    ; Salvar resultado
    PUSH AX
    
    ; Mostrar resultado
    LEA DX, msg_teste2
    MOV AH, 09H
    INT 21H
    
    POP AX
    MOV DL, AL
    MOV AH, 02H
    INT 21H
    
    ; Finalizar programa
    MOV AH, 4CH
    INT 21H
MAIN ENDP

;  Preenche a tabela de tradução para conversão maiúscula→minúscula
INICIALIZAR_TABELA PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DI
    
    LEA DI, tabela_traducao  ; DI aponta para início da tabela
    MOV CX, 256              ; 256 bytes na tabela
    MOV AL, 0                ; Começar com código 0
    
preencher_tabela:
    ; Para a maioria dos caracteres, mapeia para si mesmo
    MOV [DI], AL
    
    ; Verificar se é letra maiúscula (A-Z: 65-90)
    CMP AL, 'A'
    JB proximo_caractere     ; Se < 'A', pular
    CMP AL, 'Z'
    JA proximo_caractere     ; Se > 'Z', pular
    
    ; Se é letra maiúscula, mapear para minúscula
    ; Diferença entre maiúscula e minúscula: 32 ('a' - 'A')
    ADD AL, 32               ; Converter para minúscula
    MOV [DI], AL             ; Armazenar na tabela
    SUB AL, 32               ; Restaurar AL para continuidade
    
proximo_caractere:
    INC DI                   ; Próxima posição na tabela
    INC AL                   ; Próximo código ASCII
    LOOP preencher_tabela
    
    POP DI
    POP CX
    POP BX
    POP AX
    RET
INICIALIZAR_TABELA ENDP

; Usa XLAT com tabela predefinida para converter maiúsculas em minúsculas
CONVERTER_MINUSCULA PROC
    PUSH BX                  ; Salvar BX
    PUSH DS                  ; Salvar DS
    
    ; Configurar BX com offset da tabela e DS com segmento
    LEA BX, tabela_traducao  ; BX = offset da tabela
    ; DS já está apontando para @DATA onde a tabela está
    
    ; Usar instrução XLAT para traduzir
    ; XLAT busca o byte em [BX + AL] e coloca em AL
    XLAT
    
    POP DS                   ; Restaurar DS
    POP BX                   ; Restaurar BX
    RET
CONVERTER_MINUSCULA ENDP

END MAIN