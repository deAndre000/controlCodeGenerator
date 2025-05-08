
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
	extern strlen

generateVerhoeff:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	push rdx
	push r12
	push r13
	push r14

	call strlen
	mov rcx, rax ;longitud de cadena
	mov rbx, rdi ;Numero
	
	xor rax, rax

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
	pop rdx
	pop rcx
    	pop rbx
    	pop rbp
    	ret



global validateVerhoeff 
extern strlen

validateVerhoeff:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push rdi

	call strlen
	mov rcx, rax ;longitud de cadena
	mov rbx, rdi ;Numero
	pop rdi
	
	xor rax, rax
	xor r12, r12	
	
.main_loop:
	; CALCULO DE DIGITO
	mov rdx, rcx
	sub rdx, r12
	dec rdx
	movzx edx, byte [rbx + rdx]
	sub edx, '0' ;convertir a dec
	
	;INDICE DE PERMUTACION
	mov r8d, r12d
	and r8d, 7	;% 8
	
	;OBTENER INDICE DE TABLA P
	pTable r8d, r8d, edx 
	
	;OBTENER DIGITO DE TABLA D
	dTable eax, eax, r8d

	inc r12
	cmp r12, rcx
	jb .main_loop


	test eax, eax
	jz .valid
.invalid:
	xor eax, eax
	jmp .end

.valid:
	mov eax, 1

.end:	
	pop r14
    	pop r13
    	pop r12
    	pop rbx
    	pop rbp
    	ret


	
