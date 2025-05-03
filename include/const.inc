
%ifndef CONST_INC
%define CONST_INC

; =============================================
; CONSTANTES GENERALES DEL SISTEMA
; =============================================
%define SYS_EXIT 	60

%define SYS_READ 	0
%define SYS_WRITE 	1

%define STDIN  		0
%define STDOUT 		1

%define NEWLINE 	10

; =============================================
; CONSTANTES DE INSUMOS
; =============================================
%define MAX_AUTORIZACION		15

%define MAX_FACTURA	 		12

%define MAX_NIT 			12

%define MAX_KEY				256

%define MAX_CODIGO_DE_CONTROL		10 


; =============================================
; CONSTANTES PARA ALGORITMOS
; =============================================

; Alleged RC4 -------------------------------

section .rodata

 	RC4_STATE_SIZE	equ	256 
	
	struc RC4_State
       		.S	resb	RC4_STATE_SIZE
		.i	resb	1
		.j	resb	1
	endstruc


; Verhoeff ------------------------------------

	;VERHOEFF_DIGITS equ 	5 

	D_TABLE:
	db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, \
	   1, 2, 3, 4, 0, 6, 7, 8, 9, 5, \
       	   2, 3, 4, 0, 1, 7, 8, 9, 5, 6, \
       	   3, 4, 0, 1, 2, 8, 9, 5, 6, 7, \
       	   4, 0, 1, 2, 3, 9, 5, 6, 7, 8, \
       	   5, 9, 8, 7, 6, 0, 4, 3, 2, 1, \
       	   6, 5, 9, 8, 7, 1, 0, 4, 3, 2, \
       	   7, 6, 5, 9, 8, 2, 1, 0, 4, 3, \
       	   8, 7, 6, 5, 9, 3, 2, 1, 0, 4, \
       	   9, 8, 7, 6, 5, 4, 3, 2, 1, 0

	INV_TABLE:
	db 0, 4, 3, 2, 1, 5, 6, 7, 8, 9

	P_TABLE:
	db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, \
           1, 5, 7, 6, 2, 8, 3, 0, 9, 4, \
           5, 8, 0, 3, 7, 9, 6, 1, 4, 2, \
           8, 9, 1, 6, 0, 4, 3, 5, 2, 7, \
           9, 4, 5, 3, 1, 2, 6, 8, 7, 0, \
           4, 2, 8, 6, 5, 7, 3, 9, 0, 1, \
           2, 7, 9, 3, 8, 0, 6, 4, 1, 5, \
           7, 0, 4, 6, 9, 1, 3, 2, 5, 8

 
; Base64 ------------------------------------

	BASE64_DICT:
	db	'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 
	db 	'abcdefghijklmnopqrstuvwxyz' 
	db 	'0123456789+/'



	BASE64_PAD: 
	db		   	'='


; =============================================
; CONSTANTES DE CADENAS
; =============================================
	FECHA_FORMAT: 	
	db		    "AAAAMMDD",0

	CODIGO_FORMAT:	
	db		"XX-XX-XX-XX-XX",0

	SEPARADOR:      
	db		       '-',0


%endif



