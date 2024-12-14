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
    cactus_speed DWORD 1 ; �P�H�x���t��

    outputHandle DWORD 0
    bytesWritten DWORD 0
    count DWORD 0
    score_pos COORD <0,0>
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

    keyState DWORD 0

    score DWORD 0
    scoreString BYTE "Score: 000000", 0


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


    ; �D�j��
mainLoop:
    ; �[�J����A�קK���ʳt�׹L��
    INVOKE Sleep, 100  ; ���� 100 �@��
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


    ; ��l�� "�O�_���˴������" ���лx��
    mov keyState, 0  ; 0 ��ܨS���˴������

    ; �̦��˴��C�Ӥ�V��A���˴���**�@��**�����ߨ����������ާ@
    ;INVOKE GetAsyncKeyState, VK_UP
    ;test eax, 8000h
    ;jz noUp
    ;mov keyState, 1 ; �]�m�лx��A����˴������
    ; �V�W����
    ;dec xyPosition.y
    ;call Clrscr
    ;dec xyPosition.y
    ;dec xyPosition.y
    ;call DrawBox
    ;call DrawScore
    ;call WaitForRelease ; ���ݸ�������
    ;jmp mainLoop

noUp:
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz noDown
    mov keyState, 1
    ;; �V�U����
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
    ; �V������
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
    ; �V�k����
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
    ; ���D
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
    ; �p�G�S���˴���������A�h���s�^��D�j��
    cmp keyState, 0
    jz mainLoop

; ø�s���

DrawBox PROC
    ; �M���ù�
    call MoveCactus
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
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes1, 1, cactus_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR cactus, 1, cactus_pos, ADDR cellsWritten
    ret
DrawBox ENDP

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
DrawScore PROC
    INVOKE WriteConsoleOutputAttribute, outputHandle, ADDR attributes_floor, 40, score_pos, ADDR cellsWritten
    INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR scoreString, 12, score_pos, ADDR cellsWritten
    ret
DrawScore ENDP
MoveCactus PROC
    ; ���ʥP�H�x
    dec cactus_pos.x
    ; �p�G�P�H�x�V�L�ù���ɡA�h���s�ͦ�
    cmp cactus_pos.x, 1

    jl resetCactus
    ret

resetCactus:
    
    mov cactus_pos.x, 39 ; ���s�ͦ��P�H�x
    ret
MoveCactus ENDP
main ENDP
END main