INCLUDE Irvine32.inc

BoxWidth  = 3
BoxHeight = 3

.data
    floor     BYTE 42 DUP(0C4h)
    floorFix  BYTE 0C4h
    boxTop    BYTE 0DAh, (BoxWidth - 2) DUP(0C4h), 0BFh
    boxBody   BYTE 0B3h, (BoxWidth - 2) DUP(' '), 0B3h
    boxBottom BYTE 0C0h, (BoxWidth - 2) DUP(0C4h), 0D9h
    cactus     BYTE '|',0
    cactus_pos COORD <39, 12>
    cactus_speed DWORD 1 ; 仙人掌的速度

    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    score_pos COORD <0,0>
    floor_pos COORD <0,12>
    xyPosition COORD <3,10> ; 起始位置
    xyBound COORD <80,25> ; 螢幕邊界
    cellsWritten DWORD ?
    attributes_floor WORD 42 DUP(0Fh)
    ;attributes0 WORD BoxWidth DUP(0Ch)
    attributes0 WORD BoxWidth DUP(0Ah)
    attributes1 WORD BoxWidth DUP(0Ah)
    attributes2 WORD BoxWidth DUP(0Ah)
    ;attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    ;attributes2 WORD BoxWidth DUP(0Bh)

    keyState DWORD 0

    score DWORD 0
    scoreString BYTE "Score: 000000", 0


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
    call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, floor_pos, ADDR cellsWritten
    inc cactus_pos.x
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, cactus_pos, ADDR cellsWritten
    
    dec cactus_pos.x
    inc score
    call FormatScore
    call DrawScore


    ; 初始化 "是否有檢測到按鍵" 的標誌位
    mov keyState, 0  ; 0 表示沒有檢測到按鍵

    ; 依次檢測每個方向鍵，僅檢測到**一個**按鍵後立刻執行對應的操作
    ;INVOKE GetAsyncKeyState, VK_UP
    ;test eax, 8000h
    ;jz noUp
    ;mov keyState, 1 ; 設置標誌位，表示檢測到按鍵
    ; 向上移動
    ;dec xyPosition.y
    ;call Clrscr
    ;dec xyPosition.y
    ;dec xyPosition.y
    ;call DrawBox
    ;call DrawScore
    ;call WaitForRelease ; 等待該鍵釋放
    ;jmp mainLoop

noUp:
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz noDown
    mov keyState, 1
    ;; 向下移動
    ;inc xyPosition.y
    ;call Clrscr
    ;dec xyPosition.y
    ;dec xyPosition.y
    ;call DrawBox
    ;call DrawScore
    ;call WaitForRelease
    ;jmp mainLoop

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
    call DrawScore
    call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten
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
    call DrawScore
    call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten    call WaitForRelease
    jmp mainLoop

noRight:
    INVOKE GetAsyncKeyState, VK_SPACE
    test eax, 8000h
    jz noSpace
    mov keyState, 1
    ; 跳躍
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call DrawScore
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    inc xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    inc xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    inc xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    INVOKE Sleep, 100
    inc xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    inc score
    call FormatScore
    call DrawScore
    call WaitForRelease
    jmp mainLoop
noSpace:
    ; 如果沒有檢測到任何按鍵，則重新回到主迴圈
    cmp keyState, 0
    jz mainLoop

; 繪製方塊

DrawBox PROC
    ; 清除螢幕
    call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 42, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floor, 42, floor_pos, ADDR cellsWritten
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
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten
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
FormatScore PROC
    mov eax, score
    mov ecx, 10
    mov edi, OFFSET scoreString + 11
    mov BYTE PTR [edi], 0
    mov edi, OFFSET scoreString + 11
    mov edx, 0
    L1:
    xor edx, edx
        div ecx
        add dl, '0'
        dec edi
        mov BYTE PTR [edi], dl
        test eax, eax
        jnz L1
    ret
FormatScore ENDP
DrawScore PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, score_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR scoreString, 12, score_pos, ADDR cellsWritten
    ret
DrawScore ENDP
MoveCactus PROC
    ; 移動仙人掌
    dec cactus_pos.x
    ; 如果仙人掌越過螢幕邊界，則重新生成
    cmp cactus_pos.x, 1

    jl resetCactus
    ret

resetCactus:
    
    mov cactus_pos.x, 39 ; 重新生成仙人掌
    ret
MoveCactus ENDP
main ENDP
END main