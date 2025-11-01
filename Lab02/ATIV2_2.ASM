TITLE exemplo

.MODEL small

.DATA
    msg db 'ola bem vindo',13,10,'$'

.CODE
    MAIN PROC
        MOV AX, @DATA
        MOV DS,AX

        MOV AH,09
        MOV DX, OFFSET MSG
        INT 21h

        MOV AH,4Ch
        INT 21h
    MAIN endp
END MAIN

; ;                     AX  BX  CX  DX  SI  DI  DS    CS   IP
; MOV AX,@DATA ;        2173  0   0   0   0   0  2156  2172  3
; MOV DS,AX ;           2173  0   0   0   0   0  2173  2172  5
; MOV AH,09 ;           2429  0   0   0   0   0  2173  2172  7
; MOV DX,OFFSET MSG ;   2429  0   0   0   0   0  2173  2172  10
; INT 21H ;             2340  0   0   0   0   0  2173  2172  12
; MOV AH,4CH ;          19492 0   0   0   0   0  2173  2172  14
; INT 21H ;             1805  0   789 6   1   0  789   0     0