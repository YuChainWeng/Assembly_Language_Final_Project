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
    xyPosition COORD <10,10> ; �_�l��m
    xyBound COORD <80,25> ; �ù����

    cellsWritten DWORD ?
    attributes0 WORD BoxWidth DUP(0Ch)
    attributes1 WORD (BoxWidth-1) DUP(0Eh),0Ah
    attributes2 WORD BoxWidth DUP(0Bh)

    keyState DWORD 0

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

    ; ��l�� "�O�_���˴������" ���лx��
    mov keyState, 0  ; 0 ��ܨS���˴������

    ; �̦��˴��C�Ӥ�V��A���˴���**�@��**�����ߨ����������ާ@
    INVOKE GetAsyncKeyState, VK_UP
    test eax, 8000h
    jz noUp
    mov keyState, 1 ; �]�m�лx��A����˴������
    ; �V�W����
    dec xyPosition.y
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease ; ���ݸ�������
    jmp mainLoop

noUp:
    INVOKE GetAsyncKeyState, VK_DOWN
    test eax, 8000h
    jz noDown
    mov keyState, 1
    ; �V�U����
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
    ; �V������
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
    ; �V�k����
    inc xyPosition.x
    call Clrscr
    dec xyPosition.y
    dec xyPosition.y
    call DrawBox
    call WaitForRelease
    jmp mainLoop

noRight:
    ; �p�G�S���˴���������A�h���s�^��D�j��
    cmp keyState, 0
    jz mainLoop

; ø�s���
DrawBox PROC
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

main ENDP
END main
