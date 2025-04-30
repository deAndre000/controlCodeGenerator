
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

%define FECHA_FORM		    "AAAAMMDD"

%define CODIGO_FORM		"XX-XX-XX-XX-XX"

%define SEPARADOR 		       '-'


; =============================================
; CONSTANTES PARA ALGORITMOS
; =============================================

; Verhoeff ------------------------------------

%define VERHOEFF_DIGITS 5 

%define D_TABLE \
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

%define INV_TABLE \
	db 0, 4, 3, 2, 1, 5, 6, 7, 8, 9

%define P_TABLE \
	db 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, \
           1, 5, 7, 6, 2, 8, 3, 0, 9, 4, \
           5, 8, 0, 3, 7, 9, 6, 1, 4, 2, \
           8, 9, 1, 6, 0, 4, 3, 5, 2, 7, \
           9, 4, 5, 3, 1, 2, 6, 8, 7, 0, \
           4, 2, 8, 6, 5, 7, 3, 9, 0, 1, \
           2, 7, 9, 3, 8, 0, 6, 4, 1, 5, \
           7, 0, 4, 6, 9, 1, 3, 2, 5, 8


; Base64 ------------------------------------

%define BASE64_DICT \
	db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' \
	   'abcdefghijklmnopqrstuvwxyz' \
	   '0123456789+/'



%define BASE64_PAD	'='




; Alleged RC4 -------------------------------


%define RC4_STATE	256 









