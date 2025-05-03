%include "../include/const.inc"

section .text

; =============================================
;   rdi = state (estructura RC4_State)
;   rsi = key (array de bytes)
;   rdx = key_len (longitud de la clave)
; =============================================
global rc4_init
rc4_init:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    ; Verificar key_len != 0
    test rdx, rdx
    jz .error

    ; Inicializar vector S (state->S[i] = i)
    xor rcx, rcx                ; i = 0
.init_s_loop:
    mov byte [rdi + RC4_State.S + rcx], cl
    inc rcx
    cmp rcx, RC4_STATE_SIZE
    jb .init_s_loop	;si rcx < rc4_state_size

    ; Inicializar contadores
    mov byte [rdi + RC4_State.i], 0
    mov byte [rdi + RC4_State.j], 0

    ; Permutación usando la clave
    xor rcx, rcx                ; i = 0
    xor r8, r8                  ; j = 0
    mov rbx, rdx                ; Guardar key_len en rbx

.permutation_loop:
    ; Calcular nuevo j
    movzx r9, byte [rdi + RC4_State.S + rcx]
    add r8b, r9b                ; j += S[i]

    ; Calcular i % key_len
    mov rax, rcx
    xor rdx, rdx
    div rbx                     ; rdx = i % key_length

    ; Obtener key[i % key_length]
    movzx r10, byte [rsi + rdx]
    add r8b, r10b               ; j += key[i % key_length]

    ; j % STATE_SIZE =====================
    movzx rax, r8b
    xor rdx, rdx
    push rbx
    mov rbx, RC4_STATE_SIZE
    div rbx
    pop rbx
    ;mov r8b, byte [rdx]
    mov r8b, dl

    ; ===================================

    ; Intercambiar S[i] y S[j]
    movzx r11, r8b
    mov al, byte [rdi + RC4_State.S + rcx]
    mov bl, byte [rdi + RC4_State.S + r11]
    mov byte [rdi + RC4_State.S + rcx], bl
    mov byte [rdi + RC4_State.S + r11], al

    inc rcx
    cmp rcx, RC4_STATE_SIZE
    jb .permutation_loop

    xor eax, eax                ; Retorno 0 (éxito)
    jmp .end

.error:
    mov eax, -1                 ; Retorno -1 (error)

.end:
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; =============================================
; Args:
;   rdi = state (estructura RC4_State)
; Ret:
;   al = próximo byte del keystream
; =============================================
global rc4_next_byte
rc4_next_byte:
    ; Actualizar índices

    ; state->i = (state->i + 1)
    movzx rax, byte [rdi + RC4_State.i]
    inc al
    
    ; State->j = state->i % STATE_Size	
    xor rdx, rdx
    mov rbx, RC4_STATE_SIZE
    div rbx 		
    mov byte [rdi + RC4_State.i], dl

    ; Calcular nuevo j
    ;movzx rcx, al 
    movzx rcx, dl
    movzx rdx, byte [rdi + RC4_State.j] ; state->j
    add dl, byte [rdi + RC4_State.S + rcx] ; state->j + state->S[state->i]
    mov byte [rdi + RC4_State.j], dl

    ;state->j % STATESize
    movzx rax, byte [rdi + RC4_State.j]
    xor rdx, rdx
    ;mov rbx, RC4_STATE_SIZE
    div rbx
    mov byte [rdi + RC4_State.j], dl

    ; Intercambiar S[i] y S[j]
    movzx rcx, byte [rdi + RC4_State.i]
    movzx rdx, byte [rdi + RC4_State.j]
    mov al, byte [rdi + RC4_State.S + rcx]
    mov bl, byte [rdi + RC4_State.S + rdx]
    mov byte [rdi + RC4_State.S + rcx], bl
    mov byte [rdi + RC4_State.S + rdx], al

    ; Calcular byte de salida
    ; state->S[state->i]
    mov al, byte [rdi + RC4_State.S + rcx]
    ; state->S[state->i] + state->S[state->j
    add al, byte [rdi + RC4_State.S + rdx]
    ; state->S[state->i] + state->S[state->j]) % STATE_SIZE
    movzx rax, al
    xor rdx, rdx
    mov rbx, RC4_STATE_SIZE
    div rbx
    
    mov al, byte [rdi + RC4_State.S + rdx]

    ret

; =============================================
; Args:
;   rdi = state (estructura RC4_State)
;   rsi = input (datos de entrada)
;   rdx = output (buffer de salida)
;   rcx = len (longitud de los datos)
; =============================================
global rc4_process
rc4_process:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13

    mov r12, rsi                ; input
    mov r13, rdx                ; output
    mov rbx, rcx                ; len
    xor rcx, rcx                ; offset = 0

.process_loop:
    cmp rcx, rbx
    jge .process_end

    ; Preservar registros
    push rdi
    push rcx

    call rc4_next_byte          ; al = byte RC4

    pop rcx
    pop rdi

    ; XOR
    mov dl, byte [r12 + rcx]    ; input[offset]
    xor al, dl                  ; input[offset] ^ rc4_byte
    mov byte [r13 + rcx], al    ; output[offset] = resultado

    inc rcx
    jmp .process_loop

.process_end:
    pop r13
    pop r12
    pop rbx
    pop rbp

    ret


