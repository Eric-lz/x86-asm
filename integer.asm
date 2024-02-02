;Ask the user to enter a number
;and convert it from text (ASCII) to decimal (integer)

;syscall codes
SYS_EXIT    equ 0x3C    ;60
SYS_READ    equ 0
SYS_WRITE   equ 1
STDIN       equ 0
STDOUT      equ 1

section .data
    prompt      db 'Enter a number (6 digit max): '
    prompt_len  equ $-prompt

section .bss
    string  resb 7      ;string buffer (6 digit limit + newline character)  '000000A'
    integer resb 2      ;integer result after conversion

section .text
    global _start

_start:
    ;set newline after integer
    ;that way it prints \n automatically
    mov byte [integer+1], 0xA

    ;Prompt user for input
    mov rdi, STDOUT     ;file descriptor
    mov rsi, prompt     ;buffer
    mov rdx, prompt_len ;length
    mov rax, SYS_WRITE  ;syscall
    syscall

    ;Read and store the user input
    mov rdi, STDIN      ;file descriptor
    mov rsi, string     ;buffer
    mov rdx, 7          ;length
    mov rax, SYS_READ   ;syscall
    syscall

    ;Convert string to integer with atoi
    mov rsi, string
    call atoi
    mov [integer], rax

    ;Print integer in ASCII form
    mov rdi, STDOUT     ;file descriptor
    mov rsi, integer    ;buffer
    mov rdx, 2          ;length
    mov rax, SYS_WRITE  ;syscall
    syscall

exit:
    ; Exit code
    xor rdi, rdi         ;exit code 0
    mov rax, SYS_EXIT
    syscall


; ======================== Functions ========================
;atoi(RSI): convert string in RSI to integer, output to RAX
atoi:
    ;store RBX, RCX and RDX
    push rbx
    push rcx
    push rdx

    ;zero RCX and RDX and set RBX to 1
    xor rcx, rcx
    xor rdx, rdx
    mov rbx, 1

atoi_loop:
    mov al, [rsi+rcx]   ;load digit
    cmp al, 0xA         ;if digit is newline character
    je atoi_end         ;jump to end

    cmp rcx, 0
    je atoi_skip_first

    ;multiply RBX by 10
    push rax    ;ASCII digit
    push rdx    ;output

    mov eax, ebx
    mov ebx, 10
    mul ebx
    shl rdx, 16
    add rdx, rax
    mov rbx, rdx

    ;multiply RDX by RBX
    push rbx    ;base
    pop rdx     ;output

    mov eax, edx
    mul ebx
    shl rdx, 16
    add rdx, rax

    pop rbx     ;base
    pop rax     ;digit

atoi_skip_first:
    sub al, '0'         ;subtract ASCII 0 to get decimal integer
    add rdx, rax        ;add to what's already in RDX

    inc rcx

    ;if RCX reaches 7, return from the function
    cmp rcx, 7
    je  atoi_end

    jmp atoi_loop

atoi_end:
    mov rax, rdx
    pop rdx
    pop rcx
    pop rbx
    ret
