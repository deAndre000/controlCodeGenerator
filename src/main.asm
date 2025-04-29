
%include "../include/const.inc"
%include "../include/macros.inc"

section .data
	msg db "Hello World!", 0
	msg_len equ ($ - msg)
	line db NEWLINE

section .text
	global _start
_start:
	;print NEWLINE, 1
	print msg, msg_len
	print line, 1

	exit_
