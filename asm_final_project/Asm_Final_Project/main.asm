INCLUDE Irvine32.inc

.data
    floor     BYTE 42 DUP(0C4h)
    floorFix  BYTE 0C4h
    BoxWidth  = 3
    BoxHeight = 3

    boxTop    BYTE 0DAh, (BoxWidth - 2) DUP(0C4h), 0BFh
    boxBody   BYTE 0B3h, (BoxWidth - 2) DUP(' '), 0B3h
    boxBottom BYTE 0C0h, (BoxWidth - 2) DUP(0C4h), 0D9h

    cactusTop    BYTE '  ', '|', ' ', 0    ; The top part of the cactus
    cactusMiddle BYTE '|', '_', '|', '_', '|', 0 ; The middle part of the cactus
    cactusBottom  BYTE  '|', 0    ; The bottom part of the cactus
    cactus_pos    COORD <37, 10>           ; Cactus position
    cactus_height DWORD 3                  ; Height of the cactus (3 lines)

    cactus     BYTE '|',0
    ;cactus_pos COORD <39, 12>
    cactus_speed DWORD 1 ; 仙人掌的速度
    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    highscore_pos COORD <5,0>
    score_pos COORD <25,0>
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
    velocity WORD 0  ; 速度，控制跳躍上升和下降
    gravity WORD 1   ; 重力，會讓速度每次減少 1
    keyState DWORD 0

    score DWORD 0
    highscore DWORD 0
    scoreString BYTE "Score: 0000", 0
    highscoreString BYTE "High Score: 000 0", 0
    gameOverMessage BYTE "Game Over!", 0

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
    call DrawCactus

    ; 主迴圈
mainLoop:
    ; 加入延遲，避免移動速度過快
    INVOKE Sleep, 75  ; 延遲 100 毫秒
    
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, floor_pos, ADDR cellsWritten
    
    inc score
    call FormatScore
    ;減回畫方塊所位移的2格
    dec xyPosition.y
    dec xyPosition.y
    call DrawBackground
    call CheckJumpKey

    ; 檢查是否碰撞到仙人掌
    ;call CheckCollision
    ; 如果碰撞，顯示遊戲結束訊息並結束程式
    cmp eax, 1
    ;call GameOver ; 如果碰撞，則跳到 GameOver

    ; 如果沒有檢測到任何按鍵，則重新回到主迴圈
    jmp mainLoop


; **檢測上鍵和空白鍵的跳躍**
CheckJumpKey PROC
    ; 檢測上鍵 (VK_UP)
    INVOKE GetAsyncKeyState, VK_UP
    test eax, 8000h
    jnz DoJump  ; 如果按下上鍵，執行跳躍

    ; 檢測空白鍵 (VK_SPACE)
    INVOKE GetAsyncKeyState, VK_SPACE
    test eax, 8000h
    jnz DoJump  ; 如果按下空白鍵，執行跳躍
    ret

DoJump:
    call Jump
    call WaitForRelease ; 等待按鍵釋放，避免重複跳躍
    ret
CheckJumpKey ENDP

; **跳躍的動作 (獨立出一個子程式)**
; **跳躍的動作，加入重力效果**
Jump PROC
    ; 設定初始速度 (例如速度 5 可以測試跳得多高)
    mov velocity, 6
    mov gravity, 2  ; 重力，每次更新速度時會減少

JumpLoop:
    ; 更新 Y 座標，模擬向上和向下運動
    mov ax, velocity
    sub xyPosition.y, ax  ; y = y - velocity
    
    ; 更新成下一時刻的畫面
    call DrawBackground
    ;繼續增加score
    inc score
    call FormatScore
    
    ; 模擬重力效果，速度會逐漸減少
    mov ax, velocity      ; Load velocity into AX
    sub ax, gravity       ; Add gravity to velocity
    mov velocity, ax      ; Store updated velocity back to memory
    
    ; 檢查恐龍是否已經回到地面
    cmp xyPosition.y, 10  ; 假設地面 y 座標為 10
    jge EndJump           ; 如果 y >= 10，則結束跳躍
    
    ; 延遲，讓動作不會太快
    INVOKE Sleep, 100
    jmp JumpLoop  ; 繼續下一幀

EndJump:
    ; 確保恐龍回到地面
    mov xyPosition.y, 10
    call DrawBackground
    ret
Jump ENDP

; **檢查是否碰撞到仙人掌**
CheckCollision PROC
    ; 檢查恐龍是否與仙人掌碰撞
    mov ax, xyPosition.x
    mov bx, cactus_pos.x
    cmp ax, bx
    
    jl NoCollision  ; 如果恐龍的 x 小於仙人掌的 x，則沒有碰撞

    mov ax, xyPosition.x
    add ax, BoxWidth
    mov bx, cactus_pos.x
    cmp ax, bx
    jg NoCollision  ; 如果恐龍的右邊界大於仙人掌的 x，則沒有碰撞

    mov ax, xyPosition.y
    mov bx, cactus_pos.y
    cmp ax, bx
    jl NoCollision  ; 如果恐龍的 y 小於仙人掌的 y，則沒有碰撞

    mov ax, xyPosition.y
    add ax, BoxHeight
    mov bx, cactus_pos.y
    cmp ax, bx
    jg NoCollision  ; 如果恐龍的下邊界大於仙人掌的 y，則沒有碰撞

    ; 如果沒有跳過這些檢查，則發生碰撞
    mov eax, 1

NoCollision:
    mov eax, 0
    ret
CheckCollision ENDP


; **遊戲結束**
GameOver PROC
    ; 顯示 "Game Over!" 訊息
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, score_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR gameOverMessage, 10, score_pos, ADDR cellsWritten
    INVOKE Sleep, 5000  ; 等待 2 秒鐘後結束遊戲
    INVOKE ExitProcess, 0
GameOver ENDP

; 繪製方塊
DrawBox PROC
    ; 清除螢幕
    ;call MoveCactus
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
    ;INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    ;INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten
    ret
DrawBox ENDP

DrawCactus PROC
    ; Draw the cactus at its current position
    ; Draw top part
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 3, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactusTop, 3, cactus_pos, ADDR cellsWritten

    ; Move down to the next line for middle part
    inc cactus_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 6, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactusMiddle, 6, cactus_pos, ADDR cellsWritten

    ; Move down to the next line for bottom part
    inc cactus_pos.y
    inc cactus_pos.x
    inc cactus_pos.x
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactusBottom, 1, cactus_pos, ADDR cellsWritten
    ret
DrawCactus ENDP

DrawScore PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, score_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR scoreString, 12, score_pos, ADDR cellsWritten
    ret
DrawScore ENDP

DrawHighScore PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, highscore_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR highscoreString, 18, highscore_pos, ADDR cellsWritten
    ret
DrawHighScore ENDP

;繪製下一時刻的背景(移動仙人掌)
DrawBackground PROC
    call Clrscr
    call DrawBox
    call MoveCactus
    call DrawScore
    call DrawHighScore
    ret
DrawBackground ENDP

MoveCactus PROC
    ; 移動仙人掌
    dec cactus_pos.x
    dec cactus_pos.x
    dec cactus_pos.x
    dec cactus_pos.y
    dec cactus_pos.y
    call DrawCactus
    ; 如果仙人掌越過螢幕邊界，則重新生成
    cmp cactus_pos.x, 0

    jl resetCactus
    ret

resetCactus:
    
    mov cactus_pos.x, 39 ; 重新生成仙人掌
    ret
MoveCactus ENDP

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

main ENDP
END main
