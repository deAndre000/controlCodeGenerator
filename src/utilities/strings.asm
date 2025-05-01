
%include "../include/const.inc"

section .text
	global strlen
strlen:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	
	xor rax, rax
	mov rbx, rdi ;cadena de entrada
	
	xor rcx, rcx

.strlen_loop:
	cmp byte [rbx + rcx], 0
	je .strlen_done
	inc rcx
	jmp .strlen_loop

.strlen_done:
	mov rax, rcx
	pop rcx
	pop rbx
	pop rbp
 
	ret



