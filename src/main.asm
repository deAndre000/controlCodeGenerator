
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	num_de_factura	db 	"1503", 0
	nit 		db 	"4189179011", 0
	fecha 		db 	"20070702", 0
	monto 		db 	"2500", 0
	
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
	extern strlen, concat_strings, int_to_str, str_to_int
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

;	lea rdi, [rsp + 8] 
;	mov rsi, buffer
;	call strcpy ; guardar cadena

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

;	lea rdi, [rsp + 8]
;	mov rsi, buffer
;	call strcpy ; guardar cadena

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

;	lea rdi, [rsp + 8]
;	mov rsi, buffer
;	call strcpy ; guardar cadena

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
	jae _end

	mov rdi, buffer
	call generateVerhoeff
	add eax, '0'

	call save_verhoeff

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	inc rbx
	inc rcx

	jmp verhoeff_loop 

_end:
	print buffer, rbx
	print line, 1

	print msg, msglen
	print ver_digs, digit_count
	print line, 1


	exit_
_err:	    
	print err_msg, err_msglen
    	print line, 1
    	exit_

sum_stack:
	; =================================================
	; SUMATORIA EN PILA
	; RDI = cantidad de cadenas numericas 
	; RSI = buffer para suma
	; RAX = (resultado)
	; solo funciona con nums de hasta 8 bytes
	; =================================================

	push rbp
    	mov rbp, rsp
    	push rbx                
    	push r12
    	push r13
    
    	mov r12, rdi           	; contador de strs
    	xor r13, r13            
    	lea rbx, [rbp + 40]     ; Apuntar a str1
    
.procesar_cadena:
    	test r12, r12           
    	jz .fin
    
    	mov rdi, [rbx]          ; puntero a cadena
    	call str_to_int         ; str --> entero 
    
    	add r13, rax            ; sumatoria

	

    	add rbx, 8
    	dec r12       
    	jmp .procesar_cadena
    
.fin:
	

    	mov rax, r13 ; res
    
    	pop r13      
    	pop r12
    	pop rbx
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


; Parámetros:
;   RDI = número entero (quadword) a convertir
;   RSI = puntero al buffer de salida (debe tener al menos 21 bytes)
; Retorno:
;   RAX = longitud de la cadena (sin incluir NULL)

int_to_string:
    push rbp
    mov rbp, rsp
    push rbx
    push rdx
    push r12        ; Usaremos R12 para guardar el puntero al buffer

    mov rax, rdi    ; Número a convertir
    mov r12, rsi    ; Guarda el puntero al buffer original
    mov rbx, 10     ; Divisor (base 10)
    xor rcx, rcx    ; Contador de dígitos (inicializado a 0)

    ; Caso especial: RAX = 0
    test rax, rax
    jnz .convert_loop
    mov byte [rsi], '0'
    mov byte [rsi + 1], 0
    mov rax, 1      ; Longitud = 1
    jmp .done

.convert_loop:
    ; Extrae dígitos y los guarda en la pila (en orden inverso)
    xor rdx, rdx    ; Limpia RDX para la división
    div rbx         ; RDX:RAX / 10 → RAX=cociente, RDX=resto
    add dl, '0'     ; Convierte dígito a ASCII
    push rdx        ; Guarda en la pila
    inc rcx         ; Incrementa contador de dígitos
    test rax, rax   ; ¿Cociente = 0?
    jnz .convert_loop

    ; Copia dígitos desde la pila al buffer (en orden correcto)
    mov rax, rcx    ; RAX = longitud de la cadena
.copy_loop:
    pop rdx
    mov [r12], dl   ; Escribe dígito en el buffer
    inc r12         ; Avanza el puntero
    loop .copy_loop

    ; Terminador NULL y retorno
    mov byte [r12], 0
    ; RAX ya contiene la longitud

.done:
    pop r12
    pop rdx
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

cln:
	xor rax, rax
	xor rbx, rbx
	xor rcx, rcx
	xor rdx, rdx
	ret

