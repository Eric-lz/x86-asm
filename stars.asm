section	.text
   global _start    ;must be declared for linker (ld)
	
_start:             ;tell linker entry point
   mov	eax,4		;system call number (sys_write)
   mov	ebx,1		;file descriptor (stdout)
   mov	ecx, stars	;message to write
   mov  edx,9		;message length
   int	0x80		;call kernel

   mov	eax,1		;system call number (sys_exit)
   int	0x80		;call kernel

section	.data
stars   times 9 db '*'