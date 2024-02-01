SYS_EXIT    equ 1
SYS_READ    equ 3
SYS_WRITE   equ 4
STDIN       equ 0
STDOUT      equ 1

section .bss
    num resb 2      ;one byte for numbers and one for newline character

section .text
    global _start

_start:
    mov byte [num+1],0xA    ;set newline character (0xA) in address next to num
    mov byte [num],'0'      ;initialize first number to print
    mov ecx,10              ;loop instruction uses ECX as counter

l1: ;print loop
    push rcx    ;store ECX (RCX in 64-bit mode)
    
    ;print num
    mov eax,SYS_WRITE
    mov ebx,STDOUT
    mov ecx,num
    mov edx,1
    int 0x80
    
    ;increment num
    ;no need to convert ASCII to decimal, just increment
    inc byte [num]

    ;get ECX counter back for the loop
    pop rcx     ;ECX is RCX in elf64 mode
    loop l1     ;loop 10 times

    ;print newline
    mov eax,SYS_WRITE
    mov ebx,STDOUT
    mov ecx,num+1       ;where the newline 0xA character is stored
    mov edx,1           ;1 character = 1 byte
    int 0x80

    ;exit signal
    mov eax,SYS_EXIT
    xor ebx,ebx         ;exit code 0
    int 0x80
    