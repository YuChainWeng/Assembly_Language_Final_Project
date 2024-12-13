include Irvine32.inc

.data
    String BYTE "Kevin!", 0

.code
main PROC
    mov edx, OFFSET String
    call WriteString
    invoke ExitProcess, 0
    exit
main ENDP

END main
