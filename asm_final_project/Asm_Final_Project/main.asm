INCLUDE Irvine32.inc

.data
    floorLength DWORD 100
    floor BYTE 100 DUP(0C4h)
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

    cactus_speed WORD 5 ; 仙人掌的速度
    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    highscore_pos COORD <35,0>
    score_pos COORD <55,0>
    gameOver_pos COORD <47,2>
    exit_pos COORD <44,4>
    restart_pos COORD <42,5>
    floor_pos COORD <0,12>
    xyPosition COORD <3,10> ; 起始位置
    xyBound COORD <80,25> ; 螢幕邊界
    cellsWritten DWORD ?
    attributes_floor WORD 100 DUP(0Fh)
    ;attributes0 WORD BoxWidth DUP(0Ch)
    attributes0 WORD BoxWidth DUP(0Ah)
    attributes1 WORD BoxWidth DUP(0Ah)
    attributes2 WORD BoxWidth DUP(0Ah)
    ;attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    ;attributes2 WORD BoxWidth DUP(0Bh)
    velocity WORD 0  ; 速度，控制跳躍上升和下降
    gravity WORD 1   ; 重力，會讓速度每次減少 1
    keyState DWORD 0

    redColor WORD 100 DUP(0Ch)  ; 0C表示紅色
    blueColor WORD 100 DUP(01h) ; 0A表示藍色

    score DWORD 0
    highscore DWORD 0
    scoreString BYTE "Score: 0000", 0
    highscoreString BYTE "High Score: 0000", 0
    gameOverMessage BYTE "Game Over!", 0
    restartMessage BYTE "Press Enter to restart", 0
    exitMessage BYTE "Press Esc to exit", 0

    hConsole HANDLE ?                ; Handle to the console
    cursorInfo CONSOLE_CURSOR_INFO <> ; Structure to store cursor info

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
    INVOKE Sleep, 75  ; 延遲 75 毫秒
    
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, floor_pos, ADDR cellsWritten
    
    inc score
    call FormatScore
    ;減回畫方塊所位移的2格
    dec xyPosition.y
    dec xyPosition.y
    call DrawBackground
    call CheckJumpKey
    mov eax, 0
    ; 檢查是否碰撞到仙人掌
    call CheckCollision
    cmp eax, 1
    je GameOver ; 如果碰撞到仙人掌，則遊戲結束
    ; 如果沒有檢測到任何按鍵，則重新回到主迴圈
    jmp mainLoop

Gameover:
    call GameOverMsg
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
    ; 設定初始速度 (例如速度 6 可以測試跳得多高)
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

CheckCollision PROC
    ; 檢查是否碰撞到仙人掌
    mov ax, cactus_pos.x          ; Get the cactus's x position
    mov cx, xyPosition.x         ; Get the dinosaur's x position
    sub ax, 1
    sub ax, cx                    ; Calculate the horizontal distance between cactus and dinosaur
    cmp ax, 3                     ; If the difference is 3 or more, no collision
    jge NoCollision               ; Jump to NoCollision if no collision on x-axis

    mov ax, cactus_pos.y          ; Get the cactus's y position
    mov cx, xyPosition.y         ; Get the dinosaur's y position
    sub ax, cx                    ; Calculate the vertical distance between cactus and dinosaur
    cmp ax, 3                     ; If the difference is 3 or more, no collision
    jge NoCollision               ; Jump to NoCollision if no collision on y-axis

    ; 如果發生碰撞，檢查分數是否高於 highScore
    mov eax, score                 ; Load current score into eax
    mov ebx, highscore             ; Load high score into ebx
    cmp eax, ebx                   ; Compare current score with high score
    jle NoUpdateHighScore         ; Jump if current score is not greater than high score

    ; 更新 high score
    mov highscore, eax             ; Update high score

    ; 呼叫 FormatHighScore 來顯示更新後的 high score
    call FormatHighScore

NoUpdateHighScore:
    ; 如果發生碰撞，返回 1，表示遊戲結束
    mov eax, 1                    ; Set eax to 1 indicating collision happened
    ret

NoCollision:
    ; 如果沒有碰撞，返回 0
    mov eax, 0                    ; Set eax to 0 indicating no collision
    ret
CheckCollision ENDP




; **重置遊戲變數，讓遊戲重新開始**
RestartGame PROC
    ; 重置分數
    mov score, 0
    mov BYTE PTR [scoreString + 7], '0'
    mov BYTE PTR [scoreString + 8], '0'
    mov BYTE PTR [scoreString + 9], '0'
    mov BYTE PTR [scoreString + 10], '0'
    ; 重置恐龍的位置
    mov xyPosition.x, 3     ; 起始位置 X
    mov xyPosition.y, 10    ; 恐龍位置 Y（在地面上）

    ; 重置仙人掌的位置
    mov cactus_pos.x, 70    ; 仙人掌在螢幕右邊
    mov cactus_pos.y, 12    ; 仙人掌的地面高度

    ; 重置其他遊戲變數
    mov velocity, 6         ; 停止恐龍的跳躍速度
    mov gravity, 2          ; 重力重置
    mov cactus_speed, 5     ; 仙人掌的速度
    
    ; 重新繪製畫面
    call DrawBackground
    ret
RestartGame ENDP

; **遊戲結束**
GameOverMsg PROC
    ; 顯示 "Game Over!" 訊息
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR redColor, 10, gameOver_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR gameOverMessage, 10, gameOver_pos, ADDR cellsWritten
    
    ; 顯示 "Press Enter to restart" 和 "Press Esc to exit" 訊息
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 40, restart_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR restartMessage, 23, restart_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 40, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 23, exit_pos, ADDR cellsWritten
    
    ; 等待玩家按下 Enter 或 Esc 鍵
    call WaitForEnter
    ret
GameOverMsg ENDP

WaitForEnter PROC
    ; 檢測是否按下 Enter 或 Esc 鍵
WaitLoop:
    INVOKE GetAsyncKeyState, VK_RETURN
    test eax, 8000h        ; 檢查是否按下 Enter 鍵
    jnz RestartGame        ; 如果按下 Enter，重啟遊戲

    INVOKE GetAsyncKeyState, VK_ESCAPE
    test eax, 8000h        ; 檢查是否按下 Esc 鍵
    jnz ExitGame           ; 如果按下 Esc，退出遊戲

    jmp WaitLoop           ; 如果沒有按下任何鍵，繼續等待
WaitForEnter ENDP

; **結束遊戲**
ExitGame PROC
    ; 顯示退出訊息
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 23, exit_pos, ADDR cellsWritten
    ; 結束程式
    INVOKE ExitProcess, 0
ExitGame ENDP

; 繪製方塊
DrawBox PROC
    ; 清除螢幕
    ;call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, floorLength, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floor, floorLength, floor_pos, ADDR cellsWritten
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
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR highscoreString, 17, highscore_pos, ADDR cellsWritten
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
    mov ax, cactus_speed
    sub cactus_pos.x, ax
    dec cactus_pos.y
    dec cactus_pos.y
    call DrawCactus
    ; 如果仙人掌越過螢幕邊界，則重新生成
    cmp cactus_pos.x, 0

    jl resetCactus
    ret

resetCactus:
    mov eax, 20
    call RandomRange
    add eax, 50
    mov cactus_pos.x, ax ; 重新生成仙人掌
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

FormatHighScore PROC
    mov eax, highscore
    mov ecx, 10
    mov edi, OFFSET highscoreString + 16
    mov BYTE PTR [edi], 0
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
FormatHighScore ENDP

main ENDP
END main