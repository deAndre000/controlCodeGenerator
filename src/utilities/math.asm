
%include "../include/const.inc"

section .text
; =============================================
;   rdi = num_1 (128bits)
;   rsi = num_2 (128bits)
;   rdx = buffer de salida (128bits) 
; =============================================
global add128
add128:
	mov rax, [rdi]
	add rcx, [rdi + 8]

	add rax, [rsi]
	adc rcx, [rsi + 8]

	mov [rdx], rax
	mov [rdx + 8], rcx

	ret

; =============================================
;   rdi = num_1 (256bits)
;   rsi = num_2 (256bits)
;   rdx = buffer de salida (256bits) 
; =============================================
global add256
add256:
	mov rax, [rdi]
	mov rbx, [rdi + 8]
	mov rcx, [rdi + 16]
	mov r8, [rdi + 24]

	add rax, [rsi]
	adc rbx, [rsi + 8]
	adc rcx, [rsi + 16]
	adc r8,  [rsi + 24]

	mov [rdx], rax
	mov [rdx + 8], rbx
	mov [rdx + 16], rcx
	mov [rdx + 24], r8

	ret
	
