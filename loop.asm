SYS_EXIT    equ 1
SYS_READ    equ 3
SYS_WRITE   equ 4
STDIN       equ 0
STDOUT      equ 1

section .bss
    num resb 1

section .text
    global _start

_start:
    mov byte [num],'0'  ;first number to print
    mov ecx,10           ;loop instruction uses ECX as counter

l1:   ;print loop
    push rcx            ;store ECX (RCX in 64-bit mode)
    
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
    pop rcx
    loop l1

    ;exit
    mov eax,SYS_EXIT
    xor ebx,ebx
    int 0x80
    