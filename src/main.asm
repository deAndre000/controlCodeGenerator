
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	num_de_factura	db 	"1503", 0
	nit 		db 	"4189179011", 0
	fecha 		db 	"20070702", 0
	monto 		db 	"2500", 0
	
	msg		db	"DIGITO DE VERHOEFF: ", 0
	msglen		equ	($ - msg - 1)

	dig_verhoeff	db	0

	line 		db	NEWLINE

	buffer times 21 db 	0

section .bss
	ver_digs 	resb 	32
	digit_count 	resq 	1

section .text  	
	global _start
	extern strlen, concat_strings, int_to_str
	extern generateVerhoeff, validateVerhoeff
_start:
	;mov qword [digit_count], 0 ;contador de digs de verhoeff
	sub rsp, 128 ;espacio en pila para cadenas

	mov rdi, num_de_factura
	call generateVerhoeff
	add eax, '0'
	
	mov rsi, num_de_factura
	xor rcx, rcx

.res_loop:
	cmp byte [rsi], 0
	jz _end

	mov bl, byte [rsi]
	mov byte [buffer + rcx], bl
	
	inc rcx
	inc rsi

	jmp .res_loop
_end:
	;add eax, '0'
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0

	inc rcx
	
	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'	
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx

	lea rdi, [rsp]
	mov rsi, buffer
	call strcpy ; guardar cadena

	print buffer, rcx 
	print line, 1

	add rsp, 128 ;liberar pila

	exit_

save_verhoeff:
	; =================================================
	; ALMACENAR DIGITOS DE VERHOEFF Y AUMENTAR CONTADOR
	;
	; -llamar despues de generar un digito de verhoeff 
	;  en al (covertir el dig a ascii)
	; =================================================
	
	mov rdi, ver_digs
	mov rbx, [digit_count]
	mov [rdi + rbx], al
	inc qword [digit_count]	
	ret
strcpy:
	; ==============================================
	; COPIA STRINGS
	; Parámetros:
	;   RSI = origen
	;   RDI = destino
	; ==============================================
	push rax
	push rcx
	xor rcx, rcx
	
.copy_loop:
	mov al, [rsi + rcx]
	mov [rdi + rcx], al
	test al, al
	jz .done
	inc rcx
	jmp .copy_loop
.done:
	pop rcx
	pop rax
	ret

cln:
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret


