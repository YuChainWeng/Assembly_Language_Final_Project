INCLUDE Irvine32.inc

BoxWidth  = 3
BoxHeight = 3

.data
    boxTop    BYTE 0DAh, (BoxWidth - 2) DUP(0C4h), 0BFh
    boxBody   BYTE 0B3h, (BoxWidth - 2) DUP(' '), 0B3h
    boxBottom BYTE 0C0h, (BoxWidth - 2) DUP(0C4h), 0D9h

    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    xyPosition COORD <10,10> ; 起始位置
    xyBound COORD <80,25> ; 螢幕邊界

    cellsWritten DWORD ?
    attributes0 WORD BoxWidth DUP(0Ch)
    attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    attributes2 WORD BoxWidth DUP(0Bh)

    keyState DWORD 0

main EQU start@0

.code
    SetConsoleOutputCP PROTO STDCALL :DWORD
    GetAsyncKeyState PROTO STDCALL :DWORD
    Sleep PROTO STDCALL :DWORD  ; 延遲函數

main PROC
    INVOKE SetConsoleOutputCP, 437

    ; 取得控制台的輸出控制
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; 畫出初始的方塊
    call DrawBox

    ; 主迴圈
mainLoop:
    ; 加入延遲，避免移動速度過快
    INVOKE Sleep, 100  ; 延遲 100 毫秒

    ; 初始化 "是否有檢測到按鍵" 的標誌位
    mov keyState, 0  ; 0 表示沒有檢測到按鍵

    ; 依次檢測每個方向鍵，僅檢測到**一個**按鍵後立刻執行對應的操作
    INVOKE GetAsyncKeyState, VK_UP
    test eax, 8000h
    jz noUp
    mov keyState, 1 ; 設置標誌位，表示檢測到按鍵
    ; 向上移動
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease ; 等待該鍵釋放
    jmp mainLoop

noUp:
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz noDown
    mov keyState, 1
    ; 向下移動
    inc xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease
    jmp mainLoop

noDown:
    INVOKE GetAsyncKeyState, VK_LEFT
    test eax, 8000h
    jz noLeft
    mov keyState, 1
    ; 向左移動
    dec xyPosition.x
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease
    jmp mainLoop

noLeft:
    INVOKE GetAsyncKeyState, VK_RIGHT
    test eax, 8000h
    jz noRight
    mov keyState, 1
    ; 向右移動
    inc xyPosition.x
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease
    jmp mainLoop

noRight:
    ; 如果沒有檢測到任何按鍵，則重新回到主迴圈
    cmp keyState, 0
    jz mainLoop

; 繪製方塊
DrawBox PROC
    ; 上邊框
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes0, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxTop, BoxWidth, xyPosition, ADDR cellsWritten

    inc xyPosition.y    ; 移動到下一行

    ; 中間的內容
    mov ecx, BoxHeight - 2
L1: 
    push ecx
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxBody, BoxWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
    pop ecx
    loop L1

    ; 下邊框
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes2, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxBottom, BoxWidth, xyPosition, ADDR cellsWritten
    ret
DrawBox ENDP

; 等待按鍵釋放
WaitForRelease PROC
    ; ecx = 虛擬鍵的代碼
WaitLoop:
    INVOKE GetAsyncKeyState, ecx
    test eax, 8000h
    jnz WaitLoop ; 如果還在按著按鍵，繼續等待
    ret
WaitForRelease ENDP

main ENDP
END main
