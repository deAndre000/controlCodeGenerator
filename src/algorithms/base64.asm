
%include "../include/const.inc"

%macro base64_char 2
	mov %1, byte [BASE64_DICT + %2]
%endmacro

%macro base64_ind 2
	push rsi
	push rcx

	mov %1, -1
	lea rsi, [BASE64_DICT]
	mov rcx, 64
%%search_loop:
	cmp byte [rsi], %2
	je %%found
	inc rsi
	loop %%search_loop
	jmp %%end
%%found:
	mov %1, 64
	sub %1, rcx
%%end:
	pop rcx
	pop rsi
%endmacro

section .text
	global encode_b64
	extern strlen

encode_b64:
	; ENTRADA:
	; rdi = Cadena , rsi = longitud de cadena
	; =============================================

    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r13, rdx                ; r13 = output_buffer (pre-asignado)
    mov r14, rdi                ; r14 = data
    mov r15, rsi                ; r15 = input_length
    xor rbx, rbx                ; rbx = índice de entrada (i)
    xor rcx, rcx                ; rcx = índice de salida (j)

.encode_loop:
    ; Cargar octetos (con 0 si estamos más allá del input)
    xor r8, r8                  ; octet_a
    xor r9, r9                  ; octet_b
    xor r10, r10                ; octet_c

    cmp rbx, r15
    jae .load_done
    mov r8b, byte [r14 + rbx]
    inc rbx

    cmp rbx, r15
    jae .load_done
    mov r9b, byte [r14 + rbx]
    inc rbx

    cmp rbx, r15
    jae .load_done
    mov r10b, byte [r14 + rbx]
    inc rbx

.load_done:
    ; Combinar los 3 octetos en un triple de 24 bits
    shl r8d, 16
    shl r9d, 8
    or r8d, r9d
    or r8d, r10d                ; r8d = triple

    ; Extraer los 4 índices de 6 bits
    mov r9d, r8d
    shr r9d, 18
    and r9d, 0x3F               ; (triple >> 18) & 0x3F

    mov r10d, r8d
    shr r10d, 12
    and r10d, 0x3F              ; (triple >> 12) & 0x3F

    mov r11d, r8d
    shr r11d, 6
    and r11d, 0x3F              ; (triple >> 6) & 0x3F

    and r8d, 0x3F               ; (triple >> 0) & 0x3F

    ; Convertir índices a caracteres Base64
    mov al, byte [BASE64_DICT + r9]
    mov byte [r13 + rcx], al
    inc rcx

    mov al, byte [BASE64_DICT + r10]
    mov byte [r13 + rcx], al
    inc rcx

    mov al, byte [BASE64_DICT + r11]
    mov byte [r13 + rcx], al
    inc rcx

    mov al, byte [BASE64_DICT + r8]
    mov byte [r13 + rcx], al
    inc rcx

    ; Verificar si hemos procesado todos los bytes de entrada
    cmp rbx, r15
    jb .encode_loop

    ; Calcular padding necesario (0, 1 o 2 '=')
    mov rax, r15
    add rax, 2
    mov rbx, 3
    xor rdx, rdx
    div rbx
    mov rbx, rdx                ; rbx = (input_length + 2) % 3

    ; Añadir padding si es necesario
    test rbx, rbx
    jz .no_padding
    mov byte [r13 + rcx - 1], '='
    cmp rbx, 1
    je .no_padding
    mov byte [r13 + rcx - 2], '='

.no_padding:
    ; Añadir null terminator
    mov byte [r13 + rcx], 0

.end:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    
    ret	
;global decode_b64
;extern strlen

;decode_b64:
;	ret


