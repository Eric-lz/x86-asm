;Ask the user to enter a number (64-bit, 19 digits) [sign optional]
;and convert it from text (ASCII) to decimal (integer)
;Store the result in RAX

;syscall codes
SYS_EXIT    equ 0x3C    ;60
SYS_READ    equ 0
SYS_WRITE   equ 1
STDIN       equ 0
STDOUT      equ 1

section .data
    prompt      db 'Enter a number: '
    prompt_len  equ $-prompt

section .bss
    input   resb 24 ;input string buffer (19 digit + sign + 0xA + extra)
    integer resb 8	;result after conversion (64 bit integer)
    output  resb 24 ;output string buffer

section .text
    global _start

_start:
    ;Prompt user for input
    mov rdi, STDOUT     ;file descriptor
    mov rsi, prompt     ;buffer
    mov rdx, prompt_len ;length
    mov rax, SYS_WRITE  ;syscall
    syscall

    ;Read and store the user input
    mov rdi, STDIN      ;file descriptor
    mov rsi, input      ;buffer
    mov rdx, 21         ;length (20 + sign)
    mov rax, SYS_READ   ;syscall
    syscall

    ;Convert input string to integer with atoi
    mov rsi, input
    call atoi
    mov [integer], rax

    ;Convert integer back to string
    mov rdx, [integer]
    call itoa
    mov output, rdi

    ;Print output string
    mov rdi, STDOUT     ;file descriptor
    mov rsi, output     ;buffer
    mov rdx, 24         ;length
    mov rax, SYS_WRITE  ;syscall
    syscall

exit:
    ; Exit code
    xor rdi, rdi         ;exit code 0
    mov rax, SYS_EXIT
    syscall


; ======================== Functions ========================
;atoi(RSI): convert string in RSI to 64-bit integer, output to RAX
atoi:
    ;store RBX, RCX and RDX
    push rbx
    push rcx
    push rdx

    ;zero RCX and RDX
    xor rcx, rcx
    xor rdx, rdx

    ;check sign
    cmp byte [rsi], '-'  ;if first character is not a sign (+ or -)
    jg atoi_loop    ;jump to loop
    inc rcx         ;otherwise increment RCX

atoi_loop:
    mov al, [rsi+rcx]   ;load digit
    cmp al, 0xA         ;if digit is newline character
    je atoi_end         ;jump to end
    sub al, '0'         ;subtract ASCII 0 to get decimal integer

    ;skip multiplication for the first digit
    cmp rcx, 0
    je atoi_skip_first

    ;multiply RDX by 10
    ;using shift and add
    shl rdx, 1      ; *2
    mov rbx, rdx    ; *2
    shl rdx, 2      ; *8
    add rdx, rbx    ; *10

atoi_skip_first:
    add rdx, rax        ;add to what's already in RDX
    inc rcx             ;increment counter

    ;if RCX reaches 20 (number is bigger than 64 bits),
    ;return from the function
    cmp rcx, 20
    je  atoi_end

    jmp atoi_loop

atoi_end:
    cmp byte [rsi], '-'
    jne atoi_skip_sign
    neg rdx

atoi_skip_sign:
    mov rax, rdx
    pop rdx
    pop rcx
    pop rbx
    ret


;itoa(RDX): convert integer in RDX to string format, output to RDI
itoa:
    ;div -> RDX:RAX, quotient in RAX, remainter in RDX
    ;make sure to zero RDX
    ;RDX will have the last digit when divided by 10
    ;RAX will have the rest of the number
    ;just keep dividing RAX and storing RDX as ASCII