
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	num_de_factura	db 	"1503", 0
	nit 		db 	"4189179011", 0
	fecha 		db 	"20070702", 0
	monto 		db 	"2500", 0
	
	llave_dosif	db	"9rCB7Sv4X29d)5k7N%3ab89p-3(5[A", 0

	msg		db	"DIGITOS DE VERHOEFF: ", 0
	msglen		equ	($ - msg - 1)

	err_msg		db	"-- ERROR --", 0
	err_msglen	equ	($ - msg - 1)

	dig_verhoeff	db	0

	line 		db	NEWLINE

	buffer times 21 db 	0

	sum_total	dq	0

section .bss
	ver_digs 	resb 	32
	digit_count 	resq 	1

section .text  	
	global _start
	extern strlen, concat_strings, int_to_str, str_to_int, strcpy, copy_substring, int_to_string
	extern generateVerhoeff, validateVerhoeff
_start:
	;mov qword [digit_count], 0 ;contador de digs de verhoeff


	; ================================
	;	VERHOEFF EN FACTURA
	;	    2 DIGITOS
	; ================================
	mov rsi, num_de_factura
	lea rdi,[buffer]
	call strcpy
	
	mov rdi, buffer
	call strlen
	mov rcx, rax

	mov rdi, num_de_factura
	call generateVerhoeff
	add eax, '0'
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx
	
	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'	
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx

	print buffer, rcx 
	print line, 1
	
	mov rdi, buffer
	call str_to_int

	mov [sum_total], rax
	
	call cln

	; ================================
	;	VERHOEFF EN NIT
	;	    2 DIGITOS
	; ================================
	mov rsi, nit
	lea rdi,[buffer]
	call strcpy
	
	mov rdi, buffer
	call strlen
	mov rcx, rax

	mov rdi, nit
	call generateVerhoeff
	add eax, '0'
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx
	
	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'	
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx

	print buffer, rcx 
	print line, 1
	
	mov rdi, buffer
	call str_to_int

	add [sum_total], rax
	
	call cln

	; ================================
	;	VERHOEFF EN FECHA
	;	    2 DIGITOS
	; ================================
	mov rsi, fecha
	lea rdi,[buffer]
	call strcpy
	
	mov rdi, buffer
	call strlen
	mov rcx, rax

	mov rdi, fecha
	call generateVerhoeff
	add eax, '0'
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx
	
	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'	
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx

	print buffer, rcx 
	print line, 1

	mov rdi, buffer
	call str_to_int

	add [sum_total], rax
	
	call cln

	; ================================
	;	VERHOEFF EN MONTO
	;	    2 DIGITOS
	; ================================
	mov rsi, monto
	lea rdi,[buffer]
	call strcpy
	
	mov rdi, buffer
	call strlen
	mov rcx, rax

	mov rdi, monto
	call generateVerhoeff
	add eax, '0'
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx
	
	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'	
	
	mov byte [buffer + rcx], al
	mov byte [buffer + rcx + 1], 0
	inc rcx

	print buffer, rcx 
	print line, 1
		
	mov rdi, buffer
	call str_to_int

	add [sum_total], rax
	
	call cln

	; ============================
	; 	 IMPRIMIR RES
	; ============================
		
	mov rdi, [sum_total]
	mov rsi, buffer

	call int_to_string

	mov rbx, rax

	print buffer, rbx ; Sumatoria
	print line, 1
	
	; ================================
	;	VERHOEFF EN SUMA TOT
	;	    5 DIGITOS
	; ================================
	; rbx = tamano del string en el buffer sin contar el terminador null
	
	mov rdi, buffer
	xor rcx, rcx

verhoeff_loop:
	cmp rcx, 5
	jae end_verhoeff_loop

	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'

	call save_verhoeff

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	inc rbx
	inc rcx

	jmp verhoeff_loop 

end_verhoeff_loop:
;	print buffer, rbx
;	print line, 1

;	mov rdi, buffer
;	mov rsi, 21

;	call clr_buffer
	call cln


sum_verhoeff_d:
;	cmp rcx, 5
	mov rdi, llave_dos
    	mov rsi, 1          ; Límite inferior (a)
    	mov rdx, 5         ; Límite superior (b)
    	mov rcx, buffer
    	call copy_substring

	; Verificar resultado
;	test rax, rax
;   	jz _end
	
	mov rbx, rax

	print line, 1
	print buffer, rbx
	print line, 1 

_end:
;	print msg, msglen
;	print ver_digs, digit_count
	print line, 1


	exit_
_err:	    
	print err_msg, err_msglen
    	print line, 1
    	exit_

; Función: clear_buffer
; Limpiador buffer
; args:
;   RDI = puntero al buffer a limpiar
;   RSI = tamaño del buffer en bytes

clr_buffer:
    push rbp
    mov rbp, rsp
    
    test rdi, rdi
    jz .done_clr           ; Si el puntero es NULL, salir
    test rsi, rsi
    jz .done_clr           ; Si el tamaño es 0, salir

    ; Limpiar buffer
    xor eax, eax       ; RAX = 0
    mov rcx, rsi       ; Contador = tamaño del buffer
    rep stosb          ; Almacenar AL (0) en [RDI], incrementando RDI, decrementando RCX hasta 0

.done_clr:
    mov rsp, rbp
    pop rbp
    ret

save_verhoeff:
	; =================================================
	; ALMACENAR DIGITOS DE VERHOEFF Y AUMENTAR CONTADOR
	;
	; -llamar despues de generar un digito de verhoeff 
	;  en al (covertir el dig a ascii)
	; =================================================
	push rdi
	push rbx
	
	mov rdi, ver_digs
	mov rbx, [digit_count]
	mov [rdi + rbx], al
	inc qword [digit_count]	

	pop rbx
	pop rdi

	ret
cln:
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

