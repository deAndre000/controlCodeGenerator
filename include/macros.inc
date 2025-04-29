
%include "../include/const.inc"

section .bss
	buffer resb 21
	buffer_b resb 21

%macro printdf 1
	fld qword [%1]
	
	fld st0
	frndint
	fsub st1, st0
	
	fistp qword [buffer_b]
	mov rax, [buffer_b]
	printd rax

	print ".", 1

	mov rbx, 10

	push rax

%%digits_loop:
	xor rdx, rdx
	fld qword [10.0]
	fmul st1, st0
	div rbx
	test rax, rax
	
	jnz %%digits_loop

	pop rax

	fld st1
	frndint
	fistp qword [buffer_b]

	mov rax, [buffer_b]

	printd rax

	print NEWLINE, 1
%endmacro

%macro printd 1 
	print NEWLINE, 1

	mov rax, %1
	lea rdi, [buffer + 20]
	mov byte, [rdi], 0
	mov rbx, 10

%%convert_loop:
	xor rdx, rdx
	div rbx
	add dl, '0'

	dec rdi
	mov [rdi], dl
	test rax, rax

	jnz %%convert_loop	
	
	mov rsi, rdi
	lea rdx, [buffer + 20]
	sub rdx, rsi

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	syscall
%endmacro

%macro print 2
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, %1
	mov rdx, %2
	syscall
%endmacro

%macro exit_ 0
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall
%endmacro

push_all:
	push rax
    	push rbx
    	push rcx
    	push rdx
    	push rdi
    	push rsi
    	push r8
	ret
	
pop_all:
	pop r8
    	pop rsi
    	pop rdi
    	pop rdx
    	pop rcx
    	pop rbx
    	pop rax
	ret
