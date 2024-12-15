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
    cactus_speed DWORD 1 ; �P�H�x���t��
    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    highscore_pos COORD <5,0>
    score_pos COORD <25,0>
    floor_pos COORD <0,12>
    xyPosition COORD <3,10> ; �_�l��m
    xyBound COORD <80,25> ; �ù����
    cellsWritten DWORD ?
    attributes_floor WORD 42 DUP(0Fh)
    ;attributes0 WORD BoxWidth DUP(0Ch)
    attributes0 WORD BoxWidth DUP(0Ah)
    attributes1 WORD BoxWidth DUP(0Ah)
    attributes2 WORD BoxWidth DUP(0Ah)
    ;attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    ;attributes2 WORD BoxWidth DUP(0Bh)
    velocity WORD 0  ; �t�סA������D�W�ɩM�U��
    gravity WORD 1   ; ���O�A�|���t�רC����� 1
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
    INVOKE Sleep, 75  ; ���� 100 �@��
    
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 1, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floorFix, 1, floor_pos, ADDR cellsWritten
    
    inc score
    call FormatScore
    ;��^�e����Ҧ첾��2��
    dec xyPosition.y
    dec xyPosition.y
    call DrawBackground
    call CheckJumpKey

    ; �ˬd�O�_�I����P�H�x
    ;call CheckCollision
    ; �p�G�I���A��ܹC�������T���õ����{��
    cmp eax, 1
    ;call GameOver ; �p�G�I���A�h���� GameOver

    ; �p�G�S���˴���������A�h���s�^��D�j��
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
    ; �]�w��l�t�� (�Ҧp�t�� 5 �i�H���ո��o�h��)
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

; **�ˬd�O�_�I����P�H�x**
CheckCollision PROC
    ; �ˬd���s�O�_�P�P�H�x�I��
    mov ax, xyPosition.x
    mov bx, cactus_pos.x
    cmp ax, bx
    
    jl NoCollision  ; �p�G���s�� x �p��P�H�x�� x�A�h�S���I��

    mov ax, xyPosition.x
    add ax, BoxWidth
    mov bx, cactus_pos.x
    cmp ax, bx
    jg NoCollision  ; �p�G���s���k��ɤj��P�H�x�� x�A�h�S���I��

    mov ax, xyPosition.y
    mov bx, cactus_pos.y
    cmp ax, bx
    jl NoCollision  ; �p�G���s�� y �p��P�H�x�� y�A�h�S���I��

    mov ax, xyPosition.y
    add ax, BoxHeight
    mov bx, cactus_pos.y
    cmp ax, bx
    jg NoCollision  ; �p�G���s���U��ɤj��P�H�x�� y�A�h�S���I��

    ; �p�G�S�����L�o���ˬd�A�h�o�͸I��
    mov eax, 1

NoCollision:
    mov eax, 0
    ret
CheckCollision ENDP


; **�C������**
GameOver PROC
    ; ��� "Game Over!" �T��
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, score_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR gameOverMessage, 10, score_pos, ADDR cellsWritten
    INVOKE Sleep, 5000  ; ���� 2 �����ᵲ���C��
    INVOKE ExitProcess, 0
GameOver ENDP

; ø�s���
DrawBox PROC
    ; �M���ù�
    ;call MoveCactus
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 42, floor_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR floor, 42, floor_pos, ADDR cellsWritten
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
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR highscoreString, 18, highscore_pos, ADDR cellsWritten
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
    dec cactus_pos.x
    dec cactus_pos.x
    dec cactus_pos.x
    dec cactus_pos.y
    dec cactus_pos.y
    call DrawCactus
    ; �p�G�P�H�x�V�L�ù���ɡA�h���s�ͦ�
    cmp cactus_pos.x, 0

    jl resetCactus
    ret

resetCactus:
    
    mov cactus_pos.x, 39 ; ���s�ͦ��P�H�x
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
