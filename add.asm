SYS_EXIT    equ 1
SYS_READ    equ 3
SYS_WRITE   equ 4
STDIN       equ 0
STDOUT      equ 1

section	.data
    usrInput1   db 'Type a number: '        ;first user input
    usrInput1Len equ $-usrInput1            ;$ means current addr, effectively results in usrInput length
    usrInput2   db 'Type another number: '  ;second user input
    usrInput2Len equ $-usrInput2            ;length of usrInput2
    usrResult   db 'The sum of those is: '
    usrResultLen equ $-usrResult

section .bss            ;uninitialized data
    op1     resb 2      ;reserve 1 byte for first operand
    op2     resb 2      ;reserve 1 byte for second operand
    result  resb 1      ;reserve 1 byte for result

section .text           ;code segment
    global _start

_start:                     ;entry point
    mov	eax,SYS_WRITE       ;system call number (sys_write)
    mov	ebx,STDOUT          ;file descriptor (stdout)
    mov	ecx,usrInput1       ;message to write
    mov edx,usrInput1Len    ;message length
    int 0x80		        ;call kernel

    ;read first operand
    mov eax,SYS_READ
    mov ebx,STDIN
    mov ecx,op1
    mov edx,2
    int 80h

    ;print second message
    mov eax,SYS_WRITE
    mov ebx,STDOUT
    mov ecx,usrInput2
    mov edx,usrInput2Len
    int 0x80
    
    ;read second operand
    ;sys_read writes EDX bytes into memory address ECX
    ;that's why it doesn't need [], because it's expecting the address
    mov eax,SYS_READ
    mov ebx,STDIN
    mov ecx,op2
    mov edx,2
    int 80h

    ;print result message
    mov eax,SYS_WRITE
    mov ebx,STDOUT
    mov ecx,usrResult
    mov edx,usrResultLen
    int 80h

    ;now we move the first number to eax register. it is stored in the op1 address,
    ;that's why we need the [], because we're reading the contents of address op1.
    ;then we subtract ASCII '0' to convert it into a decimal number
    mov eax,[op1]
    sub eax,'0'

    ;moving the second number to ebx register
    ;and doing the same thing
    mov ebx,[op2]
    sub ebx,'0'

    ;adding eax and abx into eax
    ;and adding ASCII '0' to convert back to ASCII
    add eax,ebx
    add eax,'0'

    ;store the result
    ;(move the contents of EAX into the memory address result)
    mov [result],eax

    ;print result number
    mov eax,SYS_WRITE
    mov ebx,STDOUT
    mov ecx,result
    mov edx,1           ;print 1 byte
    int 80h

    mov	eax,SYS_EXIT    ;system call number (sys_exit)
    xor ebx,ebx         ;exit code
    int	80h		        ;call kernel
