
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	digito_Verhoeff db 0	

	num db "236", 0
	
	line db NEWLINE

	msg db "DIGITO DE VERHOEFF: ", 0

	msglen equ ($ - msg)
		
section .text
	global _start
	extern generateVerhoeff
_start:
	mov rdi, num
	
	call generateVerhoeff

	add eax, '0'	
	
	mov [digito_Verhoeff], al
	
	print msg, msglen

	print digito_Verhoeff, 1	

	print line, 1

	exit_
