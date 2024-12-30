INCLUDE Irvine32.inc

.data
    floorLength DWORD 100
    floor BYTE 100 DUP(0C4h)
    floorFix  BYTE 0C4h

    cactusTop     BYTE '|', 0    ; The top part of the cactus
    cactusMiddle  BYTE '|', '_', '|', '_', '|', 0 ; The middle part of the cactus
    cactusBottom  BYTE  '|', 0    ; The bottom part of the cactus
    cactus_pos    COORD <80, 18>           ; Cactus position
    cactus_height DWORD 3                  ; Height of the cactus (3 lines)

    dinosaurFirstLine  BYTE '     ____', 0
    dinosaurSecondLine BYTE '    | o__| ', 0
    dinosaurThirdLine  BYTE '    | |_ ', 0
    dinosaurFourthLine BYTE '/\__/ |- ', 0
    dinosaurFifthLine  BYTE '\____/ ', 0
    dinosaurFirstLeg   BYTE 'L', 0
    dinosaurSecondLeg  BYTE 'L', 0
    dinosaurStep BYTE '-', 0
    dino_pos COORD <3,13> ; 起始位置

    dinosaurSquatFirstLine BYTE '         ____ ', 0
    dinosaurSquatSecondLine BYTE ' /\_____| o__| ', 0
    dinosaurSquatThirdLine BYTE ' \_______/ ', 0
    dinosaurSquatFirstLeg BYTE 'L', 0
    dinosaurSquatSecondLeg BYTE 'L', 0
    dinosaurSquatFirstHand BYTE '"', 0

    title1 BYTE  '       _      _                _  _____      ', 0
    title2 BYTE  '      | |    |_|   _      _   | ||  ___|     ', 0
    title3 BYTE  '      | |     _  _| |_  _| |_ | || |___      ', 0
    title4 BYTE  '      | |    | ||_   _||_   _|| ||  ___|     ', 0
    title5 BYTE  '      | |___ | |  | |    | |  | || |___      ', 0
    title6 BYTE  '      |_____||_|  |_|    |_|  |_||_____|     ', 0
    title7 BYTE  ' _____   _                                   ', 0
    title8 BYTE  '|  __ \ |_|                                   ', 0
    title9 BYTE  '| |  | | _  _ __   ___  ___  __ _  _   _  _ _', 0
    title10 BYTE '| |  | || || |_ \ / _ \/ __|/ _` || | | || |/', 0
    title11 BYTE '| |__| || || | | ||(_)|\__ \|(_| || | | || | ', 0
    title12 BYTE '|_____/ |_||_| |_|\___/|___/\__,_| \____||_| ', 0
    
    birdFlyUpFirstLine BYTE '|\', 0
    birdFlyUpSecondLine BYTE '<o)_| \_', 0
    birdFlyUpThirdLine BYTE '\__/', 0

    birdDeleteFirstLine BYTE '       ', 0
    birdFlyDownFirstLine BYTE '<o)____', 0
    birdFlyDownSecondLine BYTE '\__/ ', 0
    birdFlyDownThirdLine BYTE '|/', 0
    bird_pos COORD <50, 11> ; 起始位置
    bird_speed WORD 7 ; 鳥的速度

    cactus_speed WORD 10 ;仙人掌的速度

    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    title_pos COORD <30,2>
    highscore_pos COORD <37,0>
    score_pos COORD <57,0>
    gameOver_pos COORD <47,2>
    intro_pos COORD <37,21>
    exit_pos COORD <44,4>
    restart_pos COORD <42,5>
    start_pos COORD <42,19>
    floor_pos COORD <0,18>
    xyBound COORD <80,25> ; 螢幕邊界
    cellsWritten DWORD ?
    attributes_floor WORD 100 DUP(0Fh)
    velocity WORD 0  ; 速度，控制跳躍上升和下降
    gravity WORD 1   ; 重力，會讓速度每次減少 1
    keyState DWORD 0

    brownColor WORD 100 DUP(06h) ; 06表示棕色
    greenColor WORD 100 DUP(0Ah) ; 0A表示綠色
    redColor WORD 100 DUP(0Ch)  ; 0C表示紅色
    blueColor WORD 100 DUP(01h) ; 0A表示藍色
    purpleColor WORD 100 DUP(05h) ; 05表示紫色
    darkBlueColor WORD 100 DUP(09h) ; 09表示深藍色

    score DWORD 0
    highscore DWORD 0
    introString BYTE "Press SPACE or UP ARROW to jump", 0
    scoreString BYTE "Score: 0000", 0
    highscoreString BYTE "High Score: 0000", 0
    gameOverMessage BYTE "Game Over!", 0
    restartMessage BYTE "Press ENTER to restart", 0
    startMessage BYTE "Press ENTER to start", 0
    enterMessage BYTE "ENTER", 0
    exitMessage BYTE "Press ESC to exit", 0
    escMessage BYTE "ESC", 0
    spaceMessage BYTE "SPACE", 0
    upMessage BYTE "UP ARROW", 0

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

    ; 畫出初始背景
    call DrawTitle
    call DrawIntro
    call DrawStartMessage
    call WaitForStart
    ; 主迴圈
mainLoop:
    ; 加入延遲，避免移動速度過快
    INVOKE Sleep, 25  ; 延遲 75 毫秒
    inc score
    call FormatScore
    ;減回畫方塊所位移的2格
    sub dino_pos.y, 5
    sub dino_pos.x, 4
    call DrawStandLeftStepBackground
    INVOKE Sleep, 50
    sub dino_pos.x, 4
    sub dino_pos.y, 5
    call DrawStandRightStepBackground
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

    ;check down key
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jnz DoSquat  ; 如果按下下鍵，執行蹲下
    ret

DoJump:
    call Jump
    call WaitForRelease ; 等待按鍵釋放，避免重複跳躍
    ret

DoSquat:
    call Squat
    ret
CheckJumpKey ENDP

; **跳躍的動作 (獨立出一個子程式)**
; **跳躍的動作，加入重力效果**
Jump PROC
    ; 設定初始速度
    mov velocity, 14
    mov gravity, 4  ; 重力，每次更新速度時會減少

JumpLoop:
    ; 檢查下鍵是否被按下
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz NormalDescent  ; 如果沒有按下下鍵，使用正常重力
    
    ; 如果按下下鍵，加快下降速度
    mov gravity, 10    ; 增加重力值使下降更快
    
NormalDescent:
    ; 計算下一個位置
    mov ax, velocity
    mov bx, dino_pos.y
    mov cx, bx        ; 保存當前位置
    sub bx, ax       ; 計算新的位置
    
    ; 檢查是否會超過地面(14)
    cmp bx, 14
    jg LandOnGround   ; 如果新位置會超過地面，直接著陸
    
    ; 如果不會超過地面，更新位置
    mov dino_pos.y, bx
    sub dino_pos.x, 4
    
    ; 增加分數並立即更新顯示
    inc score
    call FormatScore
  
    ; 繪製更新後的背景
    call DrawBackground
    
    ; 模擬重力效果，速度會逐漸減少
    mov ax, velocity
    sub ax, gravity
    mov velocity, ax
    
    ; 檢查是否已經到達地面
    cmp dino_pos.y, 18
    jge CheckForSquat
    
    ; 增加適當的延遲以控制動畫速度
    INVOKE Sleep, 50
    
    jmp JumpLoop

LandOnGround:
    ; 直接設定到地面位置
    mov dino_pos.y, 18
    jmp CheckForSquat

CheckForSquat:
    ; 檢查下鍵是否仍被按著
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jnz GoToSquat     ; 如果下鍵仍被按著，執行蹲下動作
    
    ; 如果沒有按下鍵，恢復正常站立姿勢
    sub dino_pos.x, 4
    sub dino_pos.y, 5
    call DrawBackground
    ret

GoToSquat:
    ; 重置重力值為正常值
    mov gravity, 5
    ; 直接跳轉到蹲下程序
    call Squat
    ret
Jump ENDP

Squat PROC
    ; 進入蹲下循環
SquatLoop:
    ; 檢查下鍵是否仍然被按著
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz RestoreNormalStance  ; 如果放開按鍵，恢復正常姿勢

    ;INVOKE GetAsyncKeyState, VK_UP
    ;test eax, 8000h
    ;jnz jump

    ; 如果仍在按著，繼續蹲下狀態
    sub dino_pos.x, 7
    sub dino_pos.y, 3
    call DrawSquatFirstStepBackground
    INVOKE Sleep, 50
    sub dino_pos.x, 7
    sub dino_pos.y, 3
    call DrawSquatSecondStepBackground
    
    ; 增加分數
    inc score
    call FormatScore
    
    ; 檢查碰撞
    call CheckCollision
    cmp eax, 1
    je GameOverMsg
    
    ; 繼續循環
    jmp SquatLoop

RestoreNormalStance:
    ; 恢復正常姿勢
    sub dino_pos.x, 4
    sub dino_pos.y, 5
    call DrawBackground
    ret
Squat ENDP
    
CheckCollision PROC
    ; 檢查是否碰撞到仙人掌
    mov ax, cactus_pos.x          ; Get the cactus's x position
    mov cx, dino_pos.x            ; Get the dinosaur's x position
    add cx, 3                     ; Add 3 to the cactus's x position to account for its width
    sub ax, cx                    ; Calculate the horizontal distance between cactus and dinosaur
    cmp ax, 3                     ; If the difference is 3 or more, no collision
    jge DetBirdCollision          ; Jump to DetBirdCollision if no collision on x-axis

    mov ax, cactus_pos.y          ; Get the cactus's y position
    mov cx, dino_pos.y            ; Get the dinosaur's y position
    sub ax, cx                    ; Calculate the vertical distance between cactus and dinosaur
    cmp ax, 3                     ; If the difference is 3 or more, no collision
    jge DetBirdCollision          ; Jump to DetBirdCollision if no collision on y-axis
    jmp CollisionDetected         ; Jump to CollisionDetected if collision detected

    DetBirdCollision:
    mov ax, bird_pos.x
    mov cx, dino_pos.x
    add cx, 5
    sub ax, cx
    cmp ax, 3
    jge NoCollision

    mov ax, bird_pos.y
    mov cx, dino_pos.y
    add cx, 5
    sub ax, cx
    call abs
    cmp ax, 3
    jge NoCollision


CollisionDetected:
    ; 如果發生碰撞，檢查分數是否高於 highScore
    mov eax, score                 ; Load current score into eax
    mov ebx, highscore             ; Load high score into ebx
    cmp eax, ebx                   ; Compare current score with high score
    jle NoUpdateHighScore         ; Jump if current score is not greater than high score

    ; 更新 high score
    mov highscore, eax             ; Update high score

    ; 呼叫 FormatHighScore 來顯示更新後的 high score
    call FormatHighScore
    call DrawHighScore
    call FormatScore
    call DrawScore

NoUpdateHighScore:
    ; 如果發生碰撞，返回 1，表示遊戲結束
    mov eax, 1                    ; Set eax to 1 indicating collision happened
    ret

NoCollision:
    ; 如果沒有碰撞，返回 0
    mov eax, 0                    ; Set eax to 0 indicating no collision
    ret
CheckCollision ENDP

abs PROC
    cmp ax, 0
    jge NoNeg
    neg ax
    NoNeg:
        ret
abs ENDP


; **重置遊戲變數，讓遊戲重新開始**
RestartGame PROC
    ; 重置分數
    mov score, 0
    mov BYTE PTR [scoreString + 7], '0'
    mov BYTE PTR [scoreString + 8], '0'
    mov BYTE PTR [scoreString + 9], '0'
    mov BYTE PTR [scoreString + 10], '0'
    ; 重置恐龍的位置
    mov dino_pos.x, 3     ; 起始位置 X
    mov dino_pos.y, 13    ; 恐龍位置 Y（在地面上）

    ; 重置仙人掌的位置
    mov cactus_pos.x, 80    ; 仙人掌在螢幕右邊
    mov cactus_pos.y, 18    ; 仙人掌的地面高度

    mov bird_pos.x, 50
    mov bird_pos.y, 11

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
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 17, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 17, exit_pos, ADDR cellsWritten
    add exit_pos.x, 6
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 3, exit_pos , ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR escMessage, 3, exit_pos , ADDR cellsWritten
    sub exit_pos.x, 6

    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 23, restart_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR restartMessage, 23, restart_pos, ADDR cellsWritten
    add restart_pos.x, 6
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 5, restart_pos , ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR enterMessage, 5, restart_pos , ADDR cellsWritten
    sub restart_pos.x, 6
    
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

WaitForStart PROC
    ; 檢測是否按下 Enter鍵
WaitForStartLoop:
    INVOKE GetAsyncKeyState, VK_RETURN
    test eax, 8000h        ; 檢查是否按下 Enter 鍵
    jnz RestartGame          ; 如果按下 Enter，開始遊戲
    jmp WaitForStartLoop   ; 如果沒有按下任何鍵，繼續等待
WaitForStart ENDP

; **結束遊戲**
ExitGame PROC
    ; 顯示退出訊息
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 23, exit_pos, ADDR cellsWritten
    ; 結束程式
    INVOKE ExitProcess, 0
ExitGame ENDP

DrawTitle PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title1, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title2, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title3, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title4, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title5, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title6, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title7, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title8, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title9, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title10, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title11, 45, title_pos, ADDR cellsWritten
    inc title_pos.y
    INVOKE sleep, 150
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 100, title_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR title12, 45, title_pos, ADDR cellsWritten
    INVOKE sleep, 150
    ret
DrawTitle ENDP

DrawFloor PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, floorLength, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floor, floorLength, floor_pos, ADDR cellsWritten
    ret
DrawFloor ENDP

DrawDinosaur PROC
    call DrawFloor
    ; Draw the dinosaur at its current position 
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFirstLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSecondLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurThirdLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 10, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFourthLine, 10, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFifthLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFirstLeg, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSecondLeg, 1, dino_pos, ADDR cellsWritten
    ret
DrawDinosaur ENDP

DrawDinosaurStandLeftStep PROC
    call DrawFloor
    ; Draw the dinosaur at its current position 
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFirstLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSecondLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurThirdLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 10, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFourthLine, 10, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFifthLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFirstLeg, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurStep, 1, dino_pos, ADDR cellsWritten
    ret
DrawDinosaurStandLeftStep ENDP

DrawDinosaurStandRightStep PROC
    call DrawFloor
    ; Draw the dinosaur at its current position 
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFirstLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSecondLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurThirdLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 10, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFourthLine, 10, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 8, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurFifthLine, 8, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurStep, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSecondLeg, 1, dino_pos, ADDR cellsWritten
    ret
DrawDinosaurStandRightStep ENDP

DrawSquatFirstStep PROC
    call DrawFloor
    ; Draw the dinosaur at its current position 
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 15, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatFirstLine, 15, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 17, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatSecondLine, 17, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatThirdLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    add dino_pos.x, 3
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurStep, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatSecondLeg, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatFirstHand, 1, dino_pos, ADDR cellsWritten
    ret
DrawSquatFirstStep ENDP

DrawSquatSecondStep PROC
    call DrawFloor
    ; Draw the dinosaur at its current position 
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 15, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatFirstLine, 15, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 17, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatSecondLine, 17, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 11, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatThirdLine, 11, dino_pos, ADDR cellsWritten
    inc dino_pos.y
    add dino_pos.x, 3
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatFirstLeg, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurStep, 1, dino_pos, ADDR cellsWritten
    add dino_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR brownColor, 1, dino_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dinosaurSquatFirstHand, 1, dino_pos, ADDR cellsWritten
    ret
DrawSquatSecondStep ENDP

DrawBirdFlyUp PROC
    ; Draw the bird at its current position
    add bird_pos.x, 4
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 2, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyUpFirstLine, 2, bird_pos, ADDR cellsWritten
    ; Move down to the next line for middle part
    sub bird_pos.x, 4
    inc bird_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 8, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyUpSecondLine, 8, bird_pos, ADDR cellsWritten
    ; Move down to the next line for bottom part
    inc bird_pos.y
    inc bird_pos.x
    inc bird_pos.x
    add bird_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 4, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyUpThirdLine, 4, bird_pos, ADDR cellsWritten
    sub bird_pos.x, 2
    ret
DrawBirdFlyUp ENDP

DrawBirdFlyDown PROC
    dec bird_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 7, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdDeleteFirstLine, 7, bird_pos, ADDR cellsWritten
    ; Draw the bird at its current position
    inc bird_pos.y
    dec bird_pos.x
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 8, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyDownFirstLine, 8, bird_pos, ADDR cellsWritten
    ; Move down to the next line for middle part
    inc bird_pos.y
    add bird_pos.x, 3
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 5, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyDownSecondLine, 5, bird_pos, ADDR cellsWritten
    ; Move down to the next line for bottom part
    inc bird_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR darkBlueColor, 2, bird_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR birdFlyDownThirdLine, 2, bird_pos, ADDR cellsWritten
    ret
DrawBirdFlyDown ENDP

DrawIntro PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 31, intro_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR introString, 31, intro_pos, ADDR cellsWritten
    add intro_pos.x, 6
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR purpleColor, 5, intro_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR spaceMessage, 5, intro_pos, ADDR cellsWritten
    add intro_pos.x, 9
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR purpleColor, 8, intro_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR upMessage, 8, intro_pos, ADDR cellsWritten
    sub intro_pos.x, 15
    ret
DrawIntro ENDP

DrawStartMessage PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, start_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR startMessage, 20, start_pos, ADDR cellsWritten
    add start_pos.x, 6
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 5, start_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR enterMessage, 5, start_pos, ADDR cellsWritten
    sub start_pos.x, 6
    ret
DrawStartMessage ENDP

DrawCactus PROC
    ; Draw the cactus at its current position
    ; Draw top part
    add cactus_pos.x, 2
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR greenColor, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactusTop, 1, cactus_pos, ADDR cellsWritten
    sub cactus_pos.x, 2

    ; Move down to the next line for middle part
    inc cactus_pos.y
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR greenColor, 5, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactusMiddle, 5, cactus_pos, ADDR cellsWritten

    ; Move down to the next line for bottom part
    inc cactus_pos.y
    inc cactus_pos.x
    inc cactus_pos.x
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR greenColor, 1, cactus_pos, ADDR cellsWritten
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
    call DrawFloor
    call DrawDinosaur
    call DrawIntro
    call MoveCactus
    call MoveBird
    call DrawScore
    call DrawHighScore
    ret
DrawBackground ENDP

DrawStandLeftStepBackground PROC
    call Clrscr
    call DrawFloor
    call DrawDinosaurStandLeftStep
    call DrawIntro
    call MoveCactus
    call MoveBird
    call DrawScore
    call DrawHighScore
    ret
DrawStandLeftStepBackground ENDP

DrawStandRightStepBackground PROC
    call Clrscr
    call DrawFloor
    call DrawDinosaurStandRightStep
    call DrawIntro
    call MoveCactus
    call MoveBird
    call DrawScore
    call DrawHighScore
    ret
DrawStandRightStepBackground ENDP

DrawSquatFirstStepBackground PROC
    call Clrscr
    call DrawFloor
    call DrawSquatFirstStep
    call DrawIntro
    call MoveCactus
    call MoveBird
    call DrawScore
    call DrawHighScore
    ret
DrawSquatFirstStepBackground ENDP

DrawSquatSecondStepBackground PROC
    call Clrscr
    call DrawFloor
    call DrawSquatSecondStep
    call DrawIntro
    call MoveCactus
    call MoveBird
    call DrawScore
    call DrawHighScore
    ret
DrawSquatSecondStepBackground ENDP


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
    mov eax, 51           
    call RandomRange
    add eax, 50           
    mov cactus_pos.x, ax  ; 重新生成仙人掌位置
    ret
MoveCactus ENDP


MoveBird PROC
    ; 移動小鳥
    mov ax, bird_speed
    sub bird_pos.x, ax
    sub bird_pos.y, 3
    call DrawBirdFlyUp
    INVOKE Sleep, 50
    sub bird_pos.y, 1
    sub bird_pos.x, 1
    call DrawBirdFlyDown
    ; 如果小鳥越過螢幕邊界，則重新生成
    cmp bird_pos.x, 0
    jl resetBird
    ret

    resetBird:
    mov eax, 41           
    call RandomRange
    add eax, 70 
    mov bird_pos.x, ax ; 重新生成小鳥

    mov eax, 11           ; 隨機數範圍 0~20
    call RandomRange
    add eax, 5           ; 將範圍轉換為 10~30
    mov bird_pos.y, ax    ; 重新生成小鳥 y 坐標

    ret
MoveBird ENDP

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