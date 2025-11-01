; Diretivas de modelo de memoria e pilha
.MODEL small
.STACK 100h

; Segmento de dados
.DATA
    ; Mensagens para o usuario. Note o "$" no final.
    msg_prompt DB "Digite uma letra minuscula: $"
    msg_result DB 0Dh, 0Ah, "A letra maiuscula correspondente eh: $"
    
    ; Variavel para armazenar o caractere digitado
    input_char DB ?
    
    ; Diferenca ASCII entre 'a' e 'A'
    diff_ascii EQU 'a' - 'A'

; Segmento de codigo
.CODE
    ; Rotina de inicio do programa
    _start:
        ; Define o DS (Data Segment) para o segmento de dados
        mov ax, @data
        mov ds, ax

        ; Exibe a mensagem "Digite uma letra minuscula: "
        ; AH=09h - Servico para imprimir string
        ; DX aponta para o inicio da string
        mov ah, 09h
        mov dx, OFFSET msg_prompt
        int 21h

        ; Le um unico caractere do teclado
        ; AH=01h - Servico para ler um caractere
        ; O caractere lido e retornado em AL
        mov ah, 01h
        int 21h
        
        ; Salva o caractere lido
        mov input_char, al

        ; Converte o caractere para maiuscula
        ; O caractere lido ja esta em AL, subtrai a diferenca ASCII
        sub input_char, diff_ascii

        ; Exibe a mensagem de resultado
        ; AH=09h - Servico para imprimir string
        mov ah, 09h
        mov dx, OFFSET msg_result
        int 21h
        
        ; Imprime o caractere convertido
        ; AH=02h - Servico para imprimir um caractere
        ; DL deve conter o caractere a ser impresso
        mov ah, 02h
        mov dl, input_char
        int 21h

        ; Finaliza o programa
        ; AH=4Ch - Servico para terminar o programa
        mov ah, 4Ch
        int 21h
        
        END _start