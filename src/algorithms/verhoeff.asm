
%include "../include/const.inc"

%macro dTable 3
	mov %1, %2
	imul %1, 10
	add %1, %3
	movzx %1, byte [D_TABLE + %1]
%endmacro

%macro pTable 3
	mov %1, %2
	imul %1, 10
	add %1, %3
	movzx %1, byte [P_TABLE + %1]
%endmacro

%macro invTable 2
	movzx %1, byte [INV_TABLE + %2]
%endmacro

section .text
	global generateVerhoeff
generateVerhoeff:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14

	xor eax, eax
	mov rbx, rdi ;Numero
	xor rcx, rcx

; CALCULO DE CADENAS (MOVER A OP. CON CADENAS)
.strlen_loop:
	cmp byte [rbx + rcx], 0
	je .strlen_done
	inc rcx
	jmp .strlen_loop
.strlen_done:
	test rcx, rcx
	jz .done

	xor r12, r12	
	
.main_loop:
	; CALCULO DE DIGITO
	mov rdx, rcx
	sub rdx, r12
	dec rdx
	movzx edx, byte [rbx + rdx]
	sub edx, '0' ;convertir a dec
	
	;INDICE DE PERMUTACION
	lea r8d, [r12 + 1]
	and r8d, 7	;% 8
	
	;OBTENER INDICE DE TABLA P
	pTable r8d, r8d, edx 
	
	;OBTENER DIGITO DE TABLA D
	dTable eax, eax, r8d

	inc r12
	cmp r12, rcx
	jb .main_loop

.done:
	invTable eax, eax	

	pop r14
    	pop r13
    	pop r12
    	pop rbx
    	pop rbp
    	ret







