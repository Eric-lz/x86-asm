; This program prompts the user to input two numbers
; then displays the sum of those numbers

;syscall codes
SYS_EXIT    equ 0x3C
SYS_READ    equ 0
SYS_WRITE   equ 1
STDIN       equ 0
STDOUT      equ 1

section	.data
    usrInput1     db 'Type a number: '        ;first user input prompt
    usrInput1Len  equ $-usrInput1             ;$ means current addr, effectively results in usrInput length
    usrInput2     db 'Type another number: '  ;second user input prompt
    usrInput2Len  equ $-usrInput2             ;length of usrInput2
    usrResult     db 'The sum of those is: '  ;result text
    usrResultLen  equ $-usrResult             ;result text length

section .bss          ;uninitialized data
    input1  resb 24   ;reserve 24 bytes for first input (ASCII string)
    input2  resb 24   ;reserve 24 bytes for second input (ASCII string)
    output  resb 24   ;reserve 24 bytes for output string
    op1     resb 8    ;reserve 8 bytes for first operand (64-bit integer)
    op2     resb 8    ;reserve 8 bytes for second operand (64-bit integer)
    result  resb 8    ;reserve 8 bytes for result (64-bit integer)

section .text         ;code segment
    global _start

_start:                 ;entry point
    ;Prompt user for first input
    mov rdi, STDOUT       ;file descriptor
    mov rsi, usrInput1    ;buffer
    mov rdx, usrInput1Len ;length
    mov rax, SYS_WRITE    ;syscall code
    syscall               ;call kernel

    ;Read user input
    mov rdi, STDIN        ;file descriptor
    mov rsi, input1       ;buffer
    mov rdx, 21           ;length (19 digits + sign + 0xA)
    mov rax, SYS_READ     ;syscall code
    syscall               ;call kernel

    ;Prompt user for second input
    mov rdi, STDOUT       ;file descriptor
    mov rsi, usrInput2    ;buffer
    mov rdx, usrInput2Len ;length
    mov rax, SYS_WRITE    ;syscall code
    syscall               ;call kernel

    ;Read user input
    mov rdi, STDIN        ;file descriptor
    mov rsi, input2       ;buffer
    mov rdx, 21           ;length (19 digits + sign + 0xA)
    mov rax, SYS_READ     ;syscall code
    syscall               ;call kernel

    ;Convert input numbers from ASCII to integer
    ;op1
    mov rsi, input1     ;move input string to RSI
    call atoi           ;call atoi()
    mov [op1], rax      ;move value to op1
    ;op2
    mov rsi, input2     ;move input string to RSI
    call atoi           ;call atoi()
    mov [op2], rax      ;move value to op2

    ;Add numbers together
    mov rax, [op1]      ;move op1 to RAX
    add rax, [op2]      ;add op2 to RAX
    mov [result], rax   ;move RAX to result

    ;Print result text
    mov rdi, STDOUT       ;file descriptor
    mov rsi, usrResult    ;buffer
    mov rdx, usrResultLen ;length
    mov rax, SYS_WRITE    ;syscall code
    syscall               ;call kernel

    ;Convert result back to ASCII string
    mov rdx, [result]   ;move result to RDX
    mov rdi, output     ;move output address to RDI
    call itoa           ;call itoa()

    ;Put 0xA (newline) at the end of output string
    mov byte [output+20], 0xA

    ;Print result number
    mov rdi, STDOUT     ;file descriptor
    mov rsi, output     ;buffer
    mov rdx, 24         ;length
    mov rax, SYS_WRITE  ;syscall code
    syscall             ;call kernel

exit:
    ; Exit code
    xor rdi, rdi        ;exit code 0
    mov rax, SYS_EXIT   ;syscall code
    syscall             ;call kernel



; ======================== Functions ========================
;atoi(RSI): convert string in RSI to 64-bit integer, output to RAX
atoi:
    ;store registers
    push rbx
    push rcx
    push rdx

    ;zero RCX and RDX
    xor rcx, rcx
    xor rdx, rdx

    ;check sign
    cmp byte [rsi], '-' ;if first character is not a sign (+ or -)
    jg atoi_loop        ;jump to loop
    inc rcx             ;otherwise increment RCX

atoi_loop:
    mov al, [rsi+rcx]   ;load digit
    cmp al, 0xA         ;if digit is newline character
    je atoi_end         ;jump to end, otherwise
    sub al, '0'         ;subtract ASCII 0 to get decimal integer

    ;skip multiplication for the first digit
    cmp rcx, 0
    je atoi_skip_first

    ;for all next digits
    ;multiply RDX by 10
    ;using shift and add method
    shl rdx, 1      ; *2
    mov rbx, rdx    ; *2
    shl rdx, 2      ; *8
    add rdx, rbx    ; *10

atoi_skip_first:
    add rdx, rax        ;add to what's already in RDX
    inc rcx             ;increment counter

    cmp rcx, 20         ;if RCX reaches 20 (number is bigger than 64 bits),
    je  atoi_end        ;return from the function

    jmp atoi_loop       ;jump to next digit

atoi_end:
    cmp byte [rsi], '-' ;if there's no minus sign
    jne atoi_skip_sign  ;treat number as positive (duh)
    neg rdx             ;otherwise negate the output

atoi_skip_sign:
    ;move RDX into RAX (expected return)
    ;and restore registers
    mov rax, rdx
    pop rdx
    pop rcx
    pop rbx
    ret


;itoa(RDX): convert integer in RDX to string format, output to RDI
itoa:    
    ;store and set up registers
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    xor rsi, rsi        ;clear RSI to use as index for the buffer
    xor rcx, rcx        ;clear RCX to count number of digits
    mov rbx, 10         ;use RBX to divide by 10

itoa_check_sign:
    cmp rax, 0          ;if RAX is positive
    jge itoa_loop       ;skip this step, otherwise
    mov byte [rdi], '-' ;add minus sign to beginning of string
    inc rsi             ;advance one position on the buffer
    neg rax             ;treat RAX as positive number from now on

itoa_loop:
    xor rdx, rdx        ;clear RDX (unused upper bits of div)
    div rbx             ;divide RAX by 10 using RBX
    add rdx, '0'        ;convert digit to ASCII
    push rdx            ;store in the stack to reverse the order later
    inc rcx             ;go to next digit
    cmp rax, 0          ;while RAX is not zero
    jne itoa_loop       ;keep looping division

itoa_end:
    pop rdx             ;get digits in reverse order
    mov [rdi+rsi], rdx  ;save them to buffer
    inc rsi             ;using RSI as offset index
    loop itoa_end       ;loop for each digit
    
    ;restore registers
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret    
