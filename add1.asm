INCLUDE Irvine32.inc
;gotoxy x列 dl y行 dh
CENTER_ROW EQU 15
CENTER_COL EQU 50

SetCursor MACRO row, col
    mov  al, row
    mov  dh, al
    mov  dl, col
    call Gotoxy
ENDM

.data
    prompt1 BYTE "Enter first integer: ", 0
    prompt2 BYTE "Enter second integer: ", 0
    result  BYTE "Sum = ", 0

.code
main PROC
    call Clrscr

    SetCursor CENTER_ROW-1, CENTER_COL
    mov  edx, OFFSET prompt1
    call WriteString
    call ReadInt
    mov  ebx, eax              ; 保存第一个数

    SetCursor CENTER_ROW, CENTER_COL
    mov  edx, OFFSET prompt2
    call WriteString
    call ReadInt               ; eax = 第二个数

    add  eax, ebx              ; eax = 正确结果
    mov  ebx, eax              ; 先保存结果到 ebx

    SetCursor CENTER_ROW+1, CENTER_COL   ; 这里会破坏 eax
    mov  eax, ebx              ; 恢复结果到 eax

    mov  edx, OFFSET result
    call WriteString
    call WriteInt              ; 输出正确结果
    call Crlf

    exit
main ENDP
END main