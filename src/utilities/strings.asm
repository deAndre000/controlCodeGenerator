
%include "../include/const.inc"

section .text
	global strlen
strlen:
	push rbp
	mov rbp, rsp
	push rbx
	push rcx
	
	xor rax, rax
	mov rbx, rdi ;cadena de entrada
	
	xor rcx, rcx

.strlen_loop:
	cmp byte [rbx + rcx], 0
	je .strlen_done
	inc rcx
	jmp .strlen_loop

.strlen_done:
	mov rax, rcx
	pop rcx
	pop rbx
	pop rbp
 
	ret

	;============== ASCII a entero (base 10)
; Args:
;   rdi - puntero al str
; Ret:
;   rax - valor numérico

global str_to_int
str_to_int:
    push rdx

    xor rax, rax          
    xor rcx, rcx         
    
.next_digit:
    movzx rdx, byte [rdi + rcx]  
    test rdx, rdx          
    jz .done
    
    ; Validar(0-9)
    cmp rdx, '0'
    jb .invalid
    cmp rdx, '9'
    ja .invalid
    
    ; ASCII a num
    sub rdx, '0'
    
    imul rax, 10
    add rax, rdx
    
    inc rcx     
    jmp .next_digit

.invalid:
    mov rax, -1             ; err
    ret

.done:
    pop rdx
    ret

; entero a str ASCII (base 10)
; Args:
;   rdi = valor numérico
;   rsi = puntero al buffer de salida
; Ret:
;   rax - longitud del string generado
global int_to_str
int_to_str:
    mov rax, rdi            
    lea rdi, [rsi + 20]     ;final de buffer
    mov byte [rdi], 0       
    mov r8, 10             
    
    ; caso especial 0
    test rax, rax
    jnz .conv
    dec rdi
    mov byte [rdi], '0'
    mov rax, 1
    ret
    
.conv:
    xor rcx, rcx        
    
    test rax, rax
    jns .positive
    neg rax
    inc rcx                 ; Reservar espacio para '-'
    
.positive:
    dec rdi                 
    
.divide_loop:
    xor rdx, rdx           
    div r8                  
    add dl, '0'            
    mov [rdi], dl          
    dec rdi
    inc rcx
    test rax, rax        
    jnz .divide_loop
    
    ; signo si es necesario
    cmp rdi, rsi
    jae .no_sign
    mov byte [rdi], '-'
    dec rdi
    inc rcx
    
.no_sign:
    ; Mover el string al inicio del buffer
    lea rsi, [rdi + 1]
    mov rdi, [rsp + 8]     
    mov rax, rcx           
    rep movsb               ; Copiar string
    
    ret


global concat_strings

; ======================================
; Args:
;   rdi - primer str
;   rsi - segundo str
;   rdx - buffer de salida
; Ret:
;   rax - len total
; ======================================
concat_strings:
    push rbp
    mov rbp, rsp
    push rbx                
    push r12
    push r13
    
    mov rbx, rdx           
    xor r12, r12           
    
    ; Copiar primer str
.copy_first:
    mov al, [rdi]          
    test al, al            
    jz .copy_second         
    
    mov [rdx], al          
    inc rdi                 
    inc rdx
    inc r12                
    jmp .copy_first

.copy_second:
    ; Copiar 2do
    mov al, [rsi]          
    test al, al             
    jz .copy_done               
    
    mov [rdx], al           
    inc rsi                
    inc rdx
    inc r12                 
    jmp .copy_second

.copy_done:
    mov byte [rdx], 0       ; terminador nulo
    mov rax, r12            ;  len total
    
    pop r13                 
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp

    ret

global strcpy
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


; ========================================================
; Función: copy_substring
; Copia un substring desde una cadena a un buffer
; Parámetros:
;   RDI = puntero al string de entrada (null-terminated)
;   RSI = índice inicial (a) - basado en 0
;   RDX = índice final (b) - inclusive
;   RCX = puntero al buffer de salida (debe tener suficiente espacio)
; Retorno:
;   RAX = longitud del substring copiado (0 si hay error)
global copy_substring
copy_substring:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14

    ; Validar índices (a <= b)
    cmp rsi, rdx
    ja .error

    ; Calcular longitud del string original
    mov r12, rdi        ; Guardar puntero al string
    call strlen
    mov r13, rax        ; Longitud del string

    ; Validar que b no excede la longitud
    cmp rdx, r13
    jae .error

    ; Calcular longitud del substring
    mov r14, rdx
    sub r14, rsi        ; r14 = b - a
    inc r14             ; r14 = (b - a) + 1 (longitud del substring)

    ; Copiar substring
    mov rdi, r12        ; String origen
    add rdi, rsi        ; Posición inicial (a)
    mov rsi, rcx        ; Buffer destino
    mov rcx, r14        ; Longitud a copiar
    rep movsb           ; Copiar RCX bytes

    ; Añadir terminador nulo
    mov byte [rsi], 0

    ; Retornar longitud
    mov rax, r14
    jmp .done_

.error:
    xor rax, rax        ; Retornar 0 en caso de error

.done_:
    pop r14
    pop r13
    pop r12
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

; ================================================================
; Parámetros:
;   RDI = número entero (quadword) a convertir
;   RSI = puntero al buffer de salida (debe tener al menos 21 bytes)
; Retorno:
;   RAX = longitud de la cadena (sin incluir NULL)
global int_to_string
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
    jmp .done_str

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

.done_str:
    pop r12
    pop rdx
    pop rbx
    mov rsp, rbp
    pop rbp
    ret

