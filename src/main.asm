
%include "../include/const.inc"
%include "../include/macros.inc"

%define FIRST_HALF(index)  [buffer + (index)*8]
%define SECOND_HALF(index) [buffer + (11 + (index))*8]

section .data
	; ================================================================
	;			DATOS DE FACTURACION
	; ================================================================
	data:	
		db	"29040011007",	0		; NUMERO DE AUTORIZACION
		db 	"1503", 	0		; NUMERO DE FACTURA
		db 	"4189179011", 	0		; NIT
		db 	"20070702", 	0		; FECHA
		db 	"2500", 	0		; MONTO
	
	datalen 	equ		5	

	llave_dosif	db	"9rCB7Sv4X29d)5k7N%3ab89p-3(5[A", 0
	
	DIGS_POR_DATO	equ		2	

	DIGS_SUMATORIA	equ		5
	; ================================================================
	;			MENSAJES DE CONTROL
	; ================================================================
	msg		db	"DIGITOS DE VERHOEFF: "	, 	0
	msglen		equ	($ - msg - 1)
	
	msg2		db	"CONTENIDO: "		,	0	
	msg2len		equ	($ - msg2 - 1)	

	msg3		db	"ITERACION: "		,	0
	msg3len		equ	($ - msg3 - 1)

	err_msg		db	"-- ERROR --"		, 	0
	err_msglen	equ	($ - err_msg - 1)

	dig_verhoeff	db	0

	line 		db	NEWLINE
	
	; ================================================================
	;		      BUFFERS - CONTENEDORES
	; ================================================================
	buffer times 21 dq 	0

	;llave de cifrado 

	sum_total	dq	0

	

section .bss
	ver_digs 	resb 	32
	digit_count 	resq 	1

section .text  	
	global _start
	extern generateVerhoeff, validateVerhoeff
	extern strlen, str_to_int, strcpy, copy_substring, int_to_string

_start:
gen_verhoeff:	
	mov rsi, data
	mov rdi, rsi
	
	call strlen 				; no afecta a rdx
	
	add rsi, rax
	add rsi, 1

	mov r8, datalen
	dec r8
; ====================================
; 	INICIO DEL LOOP PRINCIPAL
; ====================================
.process_loop:	
	mov rdi, rsi
	call strlen
	mov rbx, rax	

	print rsi, rbx

	lea rdi, [buffer]
	call strcpy				; no afecta a rdx
	
	mov rdi, buffer
	xor rcx, rcx
	push r8
	push rbx

; ====================================
; 	  INICIO DE SUB LOOP 
;        2 DIGITOS DE VERHOEFF
; ====================================	
.digits_loop:
	cmp rcx, DIGS_POR_DATO
	jae .sum
	
	call generateVerhoeff			; talvez afecta a rdx
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

; ====================================
;    SUMATORIA DE DATOS CON DIGITO
; ====================================
.sum:	
	print line, 1
	pop rbx
	pop r8
	mov rdi, buffer
	call str_to_int			; podria afectar rdx

	add [sum_total], rax

	add rsi, rbx
	add rsi, 1
	

	dec r8
	jnz .process_loop

; ===== FIN DE LOOP PRINCIPAL =====

	; IMPRIMIR SUMA (CONTROL)
	mov rdi, [sum_total]
	mov rsi, buffer

	call int_to_string

	mov rbx, rax
	print buffer, rbx
	print line, 1
	print line, 1


; ====================================
;      LOOP - 5 DIGITOS VERHOEFF
; ====================================
;INICIAR CONTADOR DE DIGITOS DE VERHOEFF
	mov qword [digit_count], 0 
	mov rdi, buffer
	xor rcx, rcx

.verhoeff_sum_loop:
	cmp rcx, DIGS_SUMATORIA
	jae .end_of_loop

	;mov rdi, buffer
	call generateVerhoeff
	add eax, '0'

	call save_verhoeff		;GUARDAR DIGITO DE VERHOEFF

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	inc rbx
	inc rcx

	jmp .verhoeff_sum_loop 	

.end_of_loop:
	;IMPRIMIR DATOS	
	print msg2, msg2len
	print line, 1
	print buffer, rbx
	print line, 1
	print line, 1
	call cln_all	



_end:
	print line, 1
	exit_
_err:	    
	print err_msg, err_msglen
    	print line, 1
    	exit_



; Función substring_buf
; Parámetros:
;   rdi - cadena de entrada
;   rsi - índice inferior
;   rdx - índice superior
;   rcx - buffer de salida
; Retorno:
;   rax - longitud del substring
substring_buf:
    push rbp
    mov rbp, rsp
    push rbx
    push r12

    ; Validar índices
    cmp rsi, rdx
    jge .invalid_range
    cmp rdx, 0
    jl .invalid_range

    ; Calcular longitud de la cadena original
    mov r12, rdi
    call strlen
    cmp rdx, rax
    jg .invalid_range

    ; Calcular longitud del substring
    mov rax, rdx
    sub rax, rsi

    ; Copiar el substring
    mov rbx, rcx        ; rbx = buffer de salida
    lea rsi, [r12 + rsi] ; rsi = inicio del substring
    mov rcx, rax        ; rcx = contador

.copy_loop:
    mov dl, [rsi]
    mov [rbx], dl
    inc rsi
    inc rbx
    loop .copy_loop

    ; Añadir null-terminator (opcional)
    mov byte [rbx], 0

    ; Retornar longitud
    jmp .done

.invalid_range:
    xor rax, rax        ; Retornar longitud 0 para indicar error

.done:
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret


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

cln_all:
	xor rax, rax
        xor rbx, rbx
        xor rcx, rcx
        xor rdx, rdx
        xor rsi, rsi
	xor rdi, rdi
	ret

cln:
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

