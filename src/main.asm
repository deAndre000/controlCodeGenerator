
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	; ================================================================
	;			DATOS DE FACTURACION
	; ================================================================
	data:
		db 	"1503", 	0		; NUMERO DE FACTURA
		db 	"4189179011", 	0		; NIT
		db 	"20070702", 	0		; FECHA
		db 	"2500", 	0		; MONTO
	
	datalen 	equ		4	

	llave_dosif	db	"9rCB7Sv4X29d)5k7N%3ab89p-3(5[A", 0
	
	; ================================================================
	;			MENSAJES DE CONTROL
	; ================================================================
	msg		db	"DIGITOS DE VERHOEFF: ", 0
	msglen		equ	($ - msg - 1)
	
	msg2		db	"CONTENIDO: ", 0	
	msg2len		equ	($ - msg2 - 1)	

	msg3		db	"ITERACION: "
	msg3len		equ	($ - msg3 - 1)

	err_msg		db	"-- ERROR --", 0
	err_msglen	equ	($ - err_msg - 1)

	dig_verhoeff	db	0

	line 		db	NEWLINE
	
	; ================================================================
	;		      BUFFERS - CONTENEDORES
	; ================================================================
	buffer times 21 db 	0

	sum_total	dq	0

section .bss
	ver_digs 	resb 	32
	digit_count 	resq 	1

section .text  	
	global _start
	extern strlen, str_to_int, strcpy, copy_substring, int_to_string
	extern generateVerhoeff, validateVerhoeff
_start:
gen_verhoeff:	
	mov rsi, data
	mov r8, datalen

.process_loop:	
	mov rdi, rsi
	call strlen
	mov rbx, rax	

	print rsi, rbx

	lea rdi, [buffer]
	call strcpy
	
	mov rdi, buffer
	xor rcx, rcx
	push r8
	push rbx
	
.digits_loop:
	cmp rcx, 2		;2 DIGITOS DE VERHOEFF
	jae .sum
	
	call generateVerhoeff
	add eax, '0'	

	mov [dig_verhoeff], al

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	push rcx
	print dig_verhoeff, 1
	pop rcx	

	inc rbx
	inc rcx

	jmp .digits_loop 

.sum:	
	print line, 1
	pop rbx
	pop r8
	mov rdi, buffer
	call str_to_int

	add [sum_total], rax

	add rsi, rbx
	add rsi, 1
	dec r8
	
	jnz .process_loop

	; IMPRIMIR SUMA

	mov rdi, [sum_total]
	mov rsi, buffer

	call int_to_string

	mov rbx, rax
	print buffer, rbx
	print line, 1

	; GENERAR 5 DIGITOS DE VERHOEFF SOBRE LA SUMA

	mov qword [digit_count], 0 	;INICIAR CONTADOR DE DIGITOS DE VERHOEFF
	mov rdi, buffer
	xor rcx, rcx

.verhoeff_sum_loop:
	cmp rcx, 5
	jae _end

	;mov rdi, buffer
	call generateVerhoeff
	add eax, '0'

	call save_verhoeff		;GUARDAR DIGITO DE VERHOEFF

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	inc rbx
	inc rcx

	jmp .verhoeff_sum_loop 	

_end:
	print buffer, rbx
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

push_all:
	push rax
	push rbx
	push rcx
	push rdx
	push rdi
	push rsi
	ret

pop_all:
	pop rsi
	pop rdi
	pop rdx
	pop rcx
	pop rbx
	pop rax
	ret

cln:
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

