SYS_EXIT    equ 60
SYS_READ    equ 0
SYS_WRITE   equ 1
STDIN       equ 0
STDOUT      equ 1

section .data                           ;Data segment
   userMsg db 'Please enter a number: ' ;Ask the user to enter a number
   lenUserMsg equ $-userMsg             ;The length of the message
   dispMsg db 'You have entered: '
   lenDispMsg equ $-dispMsg                 

section .bss           ;Uninitialized data
   num resb 5
	
section .text          ;Code Segment
   global _start
	
_start:
   ;Prompt user (print to stdout)
   mov rdi, STDOUT      ;file descriptor
   mov rsi, userMsg     ;buffer
   mov rdx, lenUserMsg  ;length
   mov rax, SYS_WRITE   ;syscall
   syscall

   ;Read and store the user input
   mov rdi, STDIN       ;file descriptor
   mov rsi, num         ;buffer
   mov rdx, 5           ;length
   mov rax, SYS_READ    ;syscall
   syscall
	
   ;Output the message 'The entered number is: '
   mov rdi, STDOUT      ;file descriptor
   mov rsi, dispMsg     ;buffer
   mov rdx, lenDispMsg  ;length
   mov rax, SYS_WRITE   ;syscall
   syscall

   ;Output the number entered
   mov rdi, STDOUT      ;file descriptor
   mov rsi, num         ;buffer
   mov rdx, 5           ;length
   mov rax, SYS_WRITE   ;syscall
   syscall

   ; Exit code
   xor rdi,rdi         ;exit code 0
   mov rax,SYS_EXIT
   syscall