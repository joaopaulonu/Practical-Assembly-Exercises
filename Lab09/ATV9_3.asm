title soma elementos de Matriz
.model small
.stack 100h

.data
    ; Matriz 4x4 armazenada como 16 bytes consecutivos
    Matriz  db 4 dup(?)
            db 4 dup(?)
            db 4 dup(?)
            db 4 dup(?)

    ; mensagens terminadas em '$' usadas pela função 09h do INT 21h
    Msg_inicio  db 'Escreva a matriz 4x4 (com elementos de 0 a 6): $'
    Msg_matriz  db 10,13, 'A matriz digitada eh: $'
    Msg_Soma    db 10,13, 'A soma dos elementos da sua matriz eh: $'
    Pula_Linha  db 10,13, '$'

.code
main proc
    ; configurar DS para acessar a área .data
    mov ax,@data
    mov ds,ax

    xor si,si     ; limpar SI 
    xor bx,bx     ; limpar BX
    xor di,di     ; limpar DI

    ; procedimentos principais
    call escreve_matriz   ; lê 16 valores (0..6) do teclado

    lea dx,Msg_matriz
    mov ah,09
    int 21h

    lea dx,Pula_Linha
    mov ah,09
    int 21h

    call imprime_matriz   ; imprime a matriz formatada 4x4
    call soma_matriz      ; soma elementos (acumulador em BX)
    call imprime_soma     ; imprime a soma convertendo BX para decimal

    ; retorno ao DOS
    mov ah,4ch
    int 21h
main endp

escreve_matriz proc
    ; imprime o prompt
    mov ah,09
    mov dx,offset Msg_inicio
    int 21h

    ; imprime uma linha em branco
    mov ah,09
    mov dx,offset Pula_Linha
    int 21h

    lea di, Matriz    ; DI aponta para o início da matriz
    mov cx,16         ; ler 16 elementos
le_loop:
    mov ah,01         ; serviço INT 21h função 01h: lê caractere com eco
    int 21h           ; retorno: AL = caractere lido

    cmp al,13         ; ignorar Enter (CR)
    je le_loop

    sub al,'0'        ; converter ASCII -> valor numérico
    jb le_loop    ; se AL < '0' (valor negativo após sub) => inválido
    cmp al,6
    ja le_loop     ; se > 6 => inválido

    mov [di],al       ; grava valor (0..6) na matriz
    inc di
    loop le_loop
    ret
endp

imprime_matriz proc
    ; linha em branco antes da matriz
    mov ah,09
    mov dx,offset Pula_Linha
    int 21h

    lea si, Matriz    ; SI aponta para o início da matriz
    mov cx,4          ; 4 linhas
    linha:
    xor bx,bx         ; contador de colunas em BX (usar só baixo)
    coluna:
        mov al,[si]       ; carrega elemento (0..6)
        add al,'0'        ; converte para ASCII
        mov dl,al
        mov ah,02         ; INT 21h função 02h imprime caractere em DL
        int 21h

        ; imprime espaço entre colunas
        mov dl,' '
        mov ah,02
        int 21h

        inc si
        inc bx
        cmp bx,4
        jb coluna      ; repetir até 4 colunas

    ; nova linha após cada linha da matriz
    mov ah,09
    mov dx,offset Pula_Linha
    int 21h

    loop linha
    ret
endp

soma_matriz proc
    xor bx,bx         ; acumulador em BX (usar BX para evitar variáveis)
    lea si, Matriz
    mov cx,16         ; 16 elementos
    soma:
        mov al,[si]       ; pega valor 0..6
        xor ah,ah       
        add bx,ax         ; soma em BX
        inc si
        loop soma
        ret
endp

imprime_soma proc
    ; imprime mensagem da soma
    mov ah,09
    mov dx,offset Msg_Soma
    int 21h

    ; converter BX (soma) em dois dígitos decimais sem usar variáveis em .data
    mov ax,bx
    xor dx,dx
    mov cx,10
    div cx            ; AX = quociente (dezenas), DX = resto (unidades)

    cmp ax,0
    je imprime      ; se quociente é 0, pula para imprimir unidade

    ; se há dezenas, imprime o dígito das dezenas
    ; AL contém baixo de AX (dezenas), convertê-lo para ASCII
    push dx           ; salva unidade em pilha
    add al,'0'
    mov dl,al
    mov ah,02
    int 21h
    pop dx            ; restaura unidade em DX

    imprime:
    add dl,'0'        ; converte unidade para ASCII
    mov ah,02
    int 21h

    ; nova linha final
    mov ah,09
    mov dx,offset Pula_Linha
    int 21h
    ret
endp

end main