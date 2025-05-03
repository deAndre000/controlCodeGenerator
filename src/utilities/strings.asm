
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

; ASCII a entero (base 10)
; Args:
;   rdi - puntero al str
; Ret:
;   rax - valor numérico

global str_to_int
str_to_int:
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






