
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
		
	sum_total	dq	0
	
	str_c times 10  dq	0
	

section .bss
	ver_digs 	resb 	5
	digit_count 	resq 	1


section .text  	
	global _start
	extern generateVerhoeff, validateVerhoeff
	extern strlen, str_to_int, strcpy, int_to_string, substring_buf

_start:
call cln_all

       ; ===============================================================
       ;              GENERAR 2 DIGITOS VERHOEFF POR DATO
       ; ===============================================================

gen_verhoeff:
	lea rdx, SECOND_HALF(0)

	push rdi
	
	mov rsi, data
	mov rdi, rsi
	
	call strlen
	
	mov rdi, rdx
	call strcpy

	add rdx, rax
	add rdx, 1

	add rsi, rax
	add rsi, 1

	mov r8, datalen
	dec r8

; -------------------------------;
; 	  LOOP PRINCIPAL	 ;
; -------------------------------;
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

; ----------------------------------------;
; LOOP GENERADOR DE 2 DIGITOS DE VERHOEFF ;
; ----------------------------------------;
.digits_loop:
	cmp rcx, DIGS_POR_DATO
	jae .sum
	
	call generateVerhoeff
	add eax, '0'	

	mov [dig_verhoeff], al

	mov byte [buffer + rbx], al
	mov byte [buffer + rbx + 1], 0

	push rcx
	print dig_verhoeff, 1
	;print line, 1
	pop rcx	

	inc rbx
	inc rcx

	jmp .digits_loop 

; -------------------------------;
;       SUMATORIA DE DATOS	 ;    
; -------------------------------;
.sum:
	mov rdi, buffer
	call strlen

	print line, 1
 
; GUARDAR CADENAS CON DIGITOS ----------------------
push rsi 
	mov rdi, rdx
	
	mov rsi, buffer 
	call strcpy
	call strlen

	mov rbx, rax

	; IMPRESION DE CONTROL
	print msg3, msg3len
	print line, 1
	print buffer, rbx
	print line, 1
 
	add rdx, rax
	inc rdx

 pop rsi


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

; ===== FIN DE LOOP =====
	
	
	; IMPRIMIR SUMA

	mov rdi, [sum_total]
	mov rsi, buffer

	call int_to_string

	mov rbx, rax
	print buffer, rbx
	print line, 1
	print line, 1

	; GENERAR 5 DIGITOS DE VERHOEFF SOBRE LA SUMA
	; INICIAR CONTADOR DE DIGITOS DE VERHOEFF
	mov qword [digit_count], 0 	
	mov rdi, buffer
	xor rcx, rcx


	; ================================================================
        ;         GENERAR 5 DIGITOS DE VERHOEFF SOBRE LA SUMATORIA
        ; ================================================================

.verhoeff_sum_loop:
	cmp rcx, DIGS_SUMATORIA
	jae .end_of_loop


	call generateVerhoeff
	add eax, '0'


	; GUARDAR DIGITO DE VERHOEFF
	call save_verhoeff	

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

 

; IMPRESION DE CONTROL
mov rcx, datalen
lea rsi, SECOND_HALF(0)

.control_loop:
	add rsi, rbx
	mov rdi, buffer
        call strcpy
        call strlen
	
	mov rbx, rax
	
	push rbx
	push rcx
	print msg2, msg2len
        print line, 1
	print buffer, rbx
	print line, 1
	pop rcx
	pop rbx	

	inc rbx
	dec rcx
	jnz .control_loop

print line, 1
call cln_all


	; ================================================================
        ;            LOOP DE SUBSTRING Y CONCATENACION DE 
	;                DATOS CON DIGITOS DE VERHOEFF
        ; ================================================================

mov r8, datalen
lea rsi, SECOND_HALF(0)

.extract_substrings:
; -------------------------------;
; CARGAR EN BUFFER IZQUIERDO STR ;
; GUARDADO EN BUFFER DERECHO     ;
; -------------------------------;
	push rbx

	mov rdi, rsi
        call strlen

        lea rdi, [buffer]
        add rdi, rcx
	call strcpy

	add rsi, rax
	inc rsi	

	add rax, rcx 

	pop rbx

; ------------------------------------------;
; EXTRAER SUBSTRING CON DIGITOS DE VERHOEFF ;
; Y CONCATENAR CON STR CARGADO EN BUFER IZQ ;
; ------------------------------------------;
	push rsi

	mov rdi, llave_dosif

	mov rcx, buffer	
	add rcx, rax
	push rax
	
	mov rsi, rdx

	xor rax, rax
	mov al, [ver_digs + rbx] 
	sub al, '0'
	inc al

	movzx rax, al
	add rdx, rax

	push rdx
	call substring_buf
	pop rdx

	inc rbx

	pop rcx
	add rcx, rax

	pop rsi 

	dec r8
	jnz .extract_substrings

	
	
; ======== FIN DE LOOP ======== 

; MOVER CADENA CONCATENADA A MEMORIA
	mov rsi, buffer
	lea rdi, [str_c]
        
	call strcpy
	call strlen
	
	mov rcx, rax

	;IMPRESION DE CONTROL
	print str_c, rcx
	print line, 1


	; ================================================================
        ;         		       SALIDA
        ; ================================================================
_end:
	print line, 1
	exit_



	; ================================================================
        ;         		SALIDA DE -- ERROR --
        ; ================================================================
_err:	    
	print err_msg, err_msglen
    	print line, 1
    	exit_





	; =================================================
        ; LIMPIAR BUFFER
        ; args: 
        ;   RDI = puntero al buffer a limpiar
	;   RSI = tamaño del buffer en bytes
        ; =================================================

clr_buffer:
    push rbp
    mov rbp, rsp
    
    test rdi, rdi
    jz .done_clr           
    test rsi, rsi
    jz .done_clr           

    ; Limpiar buffer
    xor eax, eax      
    mov rcx, rsi      
    rep stosb        

.done_clr:
    mov rsp, rbp
    pop rbp
    ret
	; =================================================
        ; ALMACENAR DIGITOS DE VERHOEFF Y AUMENTAR CONTADOR
        ; -llamar despues de generar un digito de verhoeff 
        ;  en al (covertir el dig a ascii)
	; =================================================

save_verhoeff:
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
