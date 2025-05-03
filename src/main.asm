
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
    str_ db "Hello World!", 0
    strlen_ equ ($ - str_ - 1)        
    
    key db "SecretKey", 0
    keylen equ ($ - key - 1)

    line db NEWLINE, 0
    encrypted_msg db "Texto cifrado: ", 0
    encrypted_msg_len equ $ - encrypted_msg
  ;  decrypted_msg db "Texto descifrado: ", 0
   ; decrypted_msg_len equ $ - decrypted_msg

section .bss
    state resb RC4_State_size
    encrypted resb strlen_ + 1   ; +1 para el null terminator
    decrypted resb strlen_ + 1

section .text
    global _start   
    extern rc4_init, rc4_process

_start:
    ; Inicializar RC4
    	mov rdi, state
    	mov rsi, key
    	mov rdx, keylen
    	
	call rc4_init
		
	test eax, eax
	js .error_handling	

    ; Cifrar el mensaje
    	mov rdi, state
    	mov rsi, str_
    	mov rdx, encrypted
    	mov rcx, strlen_

    	call rc4_process

    	mov byte [encrypted + strlen_], 0 ; Añadir null terminator

    ; Mostrar mensaje cifrado
    	print encrypted_msg, encrypted_msg_len
    	print encrypted, strlen_
    	print line, 1

	; Re-inicializar RC4 para descifrar (misma clave)
        mov rdi, state
        mov rsi, key
        mov rdx, keylen
        call rc4_init

    ; Descifrar el mensaje
        mov rdi, state
        mov rsi, encrypted
        mov rdx, decrypted
        mov rcx, strlen_
        
	call rc4_process
        
	mov byte [decrypted + strlen_], 0 ; Añadir null terminator

        ; Mostrar mensaje descifrado
 ;       print decrypted_msg, decrypted_msg_len
        print decrypted, strlen_
.error_handling:
  
  	print line, 1

	exit_


