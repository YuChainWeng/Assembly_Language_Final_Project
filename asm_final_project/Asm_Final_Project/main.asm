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

    cactus_speed WORD 5 ; �P�H�x���t��
    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    highscore_pos COORD <35,0>
    score_pos COORD <55,0>
    gameOver_pos COORD <47,2>
    exit_pos COORD <44,4>
    restart_pos COORD <42,5>
    floor_pos COORD <0,12>
    xyPosition COORD <3,10> ; �_�l��m
    xyBound COORD <80,25> ; �ù����
    cellsWritten DWORD ?
    attributes_floor WORD 100 DUP(0Fh)
    ;attributes0 WORD BoxWidth DUP(0Ch)
    attributes0 WORD BoxWidth DUP(0Ah)
    attributes1 WORD BoxWidth DUP(0Ah)
    attributes2 WORD BoxWidth DUP(0Ah)
    ;attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    ;attributes2 WORD BoxWidth DUP(0Bh)
    velocity WORD 0  ; �t�סA������D�W�ɩM�U��
    gravity WORD 1   ; ���O�A�|���t�רC����� 1
    keyState DWORD 0

    redColor WORD 100 DUP(0Ch)  ; 0C��ܬ���
    blueColor WORD 100 DUP(01h) ; 0A����Ŧ�

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
    Sleep PROTO STDCALL :DWORD  ; ������

main PROC
    INVOKE SetConsoleOutputCP, 437

    ; ���o����x����X����
    INVOKE GetStdHandle, STD_OUTPUT_HANDLE
    mov outputHandle, eax

    ; �e�X��l�����
    call DrawBox
    call DrawCactus


    ; �D�j��
mainLoop:
    ; �[�J����A�קK���ʳt�׹L��
    INVOKE Sleep, 75  ; ���� 75 �@��
    
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, floor_pos, ADDR cellsWritten
    
    inc score
    call FormatScore
    ;��^�e����Ҧ첾��2��
    dec xyPosition.y
    dec xyPosition.y
    call DrawBackground
    call CheckJumpKey
    mov eax, 0
    ; �ˬd�O�_�I����P�H�x
    call CheckCollision
    cmp eax, 1
    je GameOver ; �p�G�I����P�H�x�A�h�C������
    ; �p�G�S���˴���������A�h���s�^��D�j��
    jmp mainLoop

Gameover:
    call GameOverMsg
    jmp mainLoop
  
    

; **�˴��W��M�ť��䪺���D**
CheckJumpKey PROC
    ; �˴��W�� (VK_UP)
    INVOKE GetAsyncKeyState, VK_UP
    test eax, 8000h
    jnz DoJump  ; �p�G���U�W��A������D

    ; �˴��ť��� (VK_SPACE)
    INVOKE GetAsyncKeyState, VK_SPACE
    test eax, 8000h
    jnz DoJump  ; �p�G���U�ť���A������D
    ret

DoJump:
    call Jump
    call WaitForRelease ; ���ݫ�������A�קK���Ƹ��D
    ret
CheckJumpKey ENDP

; **���D���ʧ@ (�W�ߥX�@�Ӥl�{��)**
; **���D���ʧ@�A�[�J���O�ĪG**
Jump PROC
    ; �]�w��l�t�� (�Ҧp�t�� 6 �i�H���ո��o�h��)
    mov velocity, 6
    mov gravity, 2  ; ���O�A�C����s�t�׮ɷ|���

JumpLoop:
    ; ��s Y �y�СA�����V�W�M�V�U�B��
    mov ax, velocity
    sub xyPosition.y, ax  ; y = y - velocity
    
    ; ��s���U�@�ɨ誺�e��
    call DrawBackground
    ;�~��W�[score
    inc score
    call FormatScore
    
    ; �������O�ĪG�A�t�׷|�v�����
    mov ax, velocity      ; Load velocity into AX
    sub ax, gravity       ; Add gravity to velocity
    mov velocity, ax      ; Store updated velocity back to memory
    
    ; �ˬd���s�O�_�w�g�^��a��
    cmp xyPosition.y, 10  ; ���]�a�� y �y�Ь� 10
    jge EndJump           ; �p�G y >= 10�A�h�������D
    
    ; ����A���ʧ@���|�ӧ�
    INVOKE Sleep, 100
    jmp JumpLoop  ; �~��U�@�V

EndJump:
    ; �T�O���s�^��a��
    mov xyPosition.y, 10
    call DrawBackground
    ret
Jump ENDP

CheckCollision PROC
    ; �ˬd�O�_�I����P�H�x
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

    ; �p�G�o�͸I���A�ˬd���ƬO�_���� highScore
    mov eax, score                 ; Load current score into eax
    mov ebx, highscore             ; Load high score into ebx
    cmp eax, ebx                   ; Compare current score with high score
    jle NoUpdateHighScore         ; Jump if current score is not greater than high score

    ; ��s high score
    mov highscore, eax             ; Update high score

    ; �I�s FormatHighScore ����ܧ�s�᪺ high score
    call FormatHighScore

NoUpdateHighScore:
    ; �p�G�o�͸I���A��^ 1�A��ܹC������
    mov eax, 1                    ; Set eax to 1 indicating collision happened
    ret

NoCollision:
    ; �p�G�S���I���A��^ 0
    mov eax, 0                    ; Set eax to 0 indicating no collision
    ret
CheckCollision ENDP




; **���m�C���ܼơA���C�����s�}�l**
RestartGame PROC
    ; ���m����
    mov score, 0
    mov BYTE PTR [scoreString + 7], '0'
    mov BYTE PTR [scoreString + 8], '0'
    mov BYTE PTR [scoreString + 9], '0'
    mov BYTE PTR [scoreString + 10], '0'
    ; ���m���s����m
    mov xyPosition.x, 3     ; �_�l��m X
    mov xyPosition.y, 10    ; ���s��m Y�]�b�a���W�^

    ; ���m�P�H�x����m
    mov cactus_pos.x, 70    ; �P�H�x�b�ù��k��
    mov cactus_pos.y, 12    ; �P�H�x���a������

    ; ���m��L�C���ܼ�
    mov velocity, 6         ; ����s�����D�t��
    mov gravity, 2          ; ���O���m
    mov cactus_speed, 5     ; �P�H�x���t��
    
    ; ���sø�s�e��
    call DrawBackground
    ret
RestartGame ENDP

; **�C������**
GameOverMsg PROC
    ; ��� "Game Over!" �T��
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR redColor, 10, gameOver_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR gameOverMessage, 10, gameOver_pos, ADDR cellsWritten
    
    ; ��� "Press Enter to restart" �M "Press Esc to exit" �T��
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 40, restart_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR restartMessage, 23, restart_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR blueColor, 40, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 23, exit_pos, ADDR cellsWritten
    
    ; ���ݪ��a���U Enter �� Esc ��
    call WaitForEnter
    ret
GameOverMsg ENDP

WaitForEnter PROC
    ; �˴��O�_���U Enter �� Esc ��
WaitLoop:
    INVOKE GetAsyncKeyState, VK_RETURN
    test eax, 8000h        ; �ˬd�O�_���U Enter ��
    jnz RestartGame        ; �p�G���U Enter�A���ҹC��

    INVOKE GetAsyncKeyState, VK_ESCAPE
    test eax, 8000h        ; �ˬd�O�_���U Esc ��
    jnz ExitGame           ; �p�G���U Esc�A�h�X�C��

    jmp WaitLoop           ; �p�G�S�����U������A�~�򵥫�
WaitForEnter ENDP

; **�����C��**
ExitGame PROC
    ; ��ܰh�X�T��
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, exit_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR exitMessage, 23, exit_pos, ADDR cellsWritten
    ; �����{��
    INVOKE ExitProcess, 0
ExitGame ENDP

; ø�s���
DrawBox PROC
    ; �M���ù�
    ;call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, floorLength, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floor, floorLength, floor_pos, ADDR cellsWritten
    ; �W���
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes0, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxTop, BoxWidth, xyPosition, ADDR cellsWritten

    inc xyPosition.y    ; ���ʨ�U�@��

    ; ���������e
    mov ecx, BoxHeight - 2
L1: 
    push ecx
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, BoxWidth, xyPosition, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR boxBody, BoxWidth, xyPosition, ADDR cellsWritten
    inc xyPosition.y
    pop ecx
    loop L1

    ; �U���
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

;ø�s�U�@�ɨ誺�I��(���ʥP�H�x)
DrawBackground PROC
    call Clrscr
    call DrawBox
    call MoveCactus
    call DrawScore
    call DrawHighScore
    ret
DrawBackground ENDP

MoveCactus PROC
    ; ���ʥP�H�x
    mov ax, cactus_speed
    sub cactus_pos.x, ax
    dec cactus_pos.y
    dec cactus_pos.y
    call DrawCactus
    ; �p�G�P�H�x�V�L�ù���ɡA�h���s�ͦ�
    cmp cactus_pos.x, 0

    jl resetCactus
    ret

resetCactus:
    mov eax, 20
    call RandomRange
    add eax, 50
    mov cactus_pos.x, ax ; ���s�ͦ��P�H�x
    ret
MoveCactus ENDP

; ���ݫ�������
WaitForRelease PROC
    ; ecx = �����䪺�N�X
WaitLoop:
    INVOKE GetAsyncKeyState, ecx
    test eax, 8000h
    jnz WaitLoop ; �p�G�٦b���۫���A�~�򵥫�
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