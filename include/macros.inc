
%include "../include/const.inc"

section .data
	print_buffer times 21 db 0
    	float_buffer times 21 db 0
    	ten dq 10.0 ; Constante para operaciones con floats  

section .bss

%macro base64_output_size 2
        mov %2, %1
        add %2, 2
        mov rax, 3
        xor rdx, rdx
        div rax
        shl rax, 2
        inc rax
        mov %2, rax
%endmacro

%macro newline_ 0
	push rax
	push rdi
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, NEWLINE
	mov rdx, 1
	syscall
	pop rdi
	pop rax
%endmacro

%macro print 2
	push rax
	push rdi
	mov rax, SYS_WRITE
    	mov rdi, STDOUT
    	mov rsi, %1
    	mov rdx, %2
    	syscall
	pop rdi
	pop rax
%endmacro

%macro printd 1
	mov rax, %1
	lea rdi, [print_buffer + 20]
	mov byte [rdi], 0
	mov rbx, 10
	
%%convert_loop:
	xor rdx, rdx
	div rbx
	add dl, '0'
	dec rdi
	mov [rdi], dl
	test rax, rax
	jnz %%convert_loop
	
	; Calcular longitud
    	mov rsi, rdi
    	lea rdx, [print_buffer + 20]
    	sub rdx, rsi
    
    	; Llamar a sys_write
    	mov rax, SYS_WRITE
    	mov rdi, STDOUT
    	syscall
%endmacro

%macro printdf 1
	fld qword [%1]
	
	fld st0
	frndint
	fsub st1, st0
	fistp qword [float_buffer]
	mov rax, [float_buffer]
    	
	printd rax
    	
    	; Punto decimal
    	print ".", 1
    	
    	; Parte fraccionaria (2 dígitos)
    	fld qword [ten]
    	fmulp st1, st0      ; Multiplicar por 10
    	frndint
    	fistp qword [float_buffer]
    	mov rax, [float_buffer]
    	
	printd rax
    
    	; Nueva línea
    	print NEWLINE, 1
%endmacro

%macro exit_ 0
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
%endmacro

