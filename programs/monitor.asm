; ------------------------------------------------------------------
; Monitor de codigo maquina -- por Yutaka Saito y Mike Saunders
;
; Acepta codigo hexadecimal con origen 36864 (4 KiB despues de la
; direccion donde se carga este programa).
; ------------------------------------------------------------------


	BITS 16
	%INCLUDE "mikedev.inc"
	ORG 32768


	; Esta linea determina donde se generara el codigo maquina. Si la cambia,
	; debe usar ORG con la nueva direccion para el codigo que introduzca.

	CODELOC	equ 36864


	mov si, helpmsg1		; Print help text
	call os_print_string

	mov si, helpmsg2
	call os_print_string

	mov si, helpmsg3
	call os_print_string

main_loop:
	mov si, helpmsg4
	call os_print_string

.noinput:
	call os_print_newline

	mov si, prompt			; Print prompt
	call os_print_string

	mov ax, input			; Get hex string
	call os_input_string

	mov ax, input
	call os_string_length
	cmp ax, 0
	je .noinput

	mov si, input			; Convert to machine code...
	mov di, run


.more:
	cmp byte [si], '$'		; If char in string is '$', end of code
	je .done
	cmp byte [si], ' '		; If space, move on to next char
	je .space
	cmp byte [si], 'r'		; If 'r' entered, re-run existing code
	je .runprog
	cmp byte [si], 'x'		; Or if 'x' entered, return to OS
	jne .noexit
	call os_print_newline
	ret
.noexit:
	mov al, [si]
	and al, 0F0h
	cmp al, 40h
	je .H_A_to_F
.H_1_to_9:
	mov al, [si]
	sub al, 30h
	mov ah, al
	sal ah, 4
	jmp .H_end
.H_A_to_F:
	mov al, [si]
	sub al, 37h
	mov ah, al
	sal ah, 4
.H_end:
	inc si
	mov al, [si]
	and al, 0F0h
	cmp al, 40h
	je .L_A_to_F
.L_1_to_9:
	mov al, [si]
	sub al, 30h
	jmp .L_end
.L_A_to_F:
	mov al, [si]
	sub al, 37h
.L_end:
	or al, ah
	mov [di], al
	inc di
.space:
	inc si
	jmp .more
.done:
	mov byte [di], 0		; Write terminating zero

	mov si, run			; Copy machine code to location for execution
	mov di, CODELOC
	mov cx, 255
	cld
	rep movsb


.runprog:
	call os_print_newline

	call CODELOC			; Run program

	call os_print_newline

	jmp main_loop


	input		times 255 db 0	; Code entered by user (in ASCII)
	run		times 255 db 0	; Translated machine code to execute

	helpmsg1	db 'MONITOR DE CODIGO MAQUINA DE YOGIOS', 10, 13, 0
	helpmsg2	db '(Consulte la guia del usuario para una introduccion)', 13, 10, 13, 10, 0
	helpmsg3	db 'Escriba instrucciones hexadecimales y termine con $', 10, 13, 0
	helpmsg4	db 'Comandos: r = repetir codigo anterior, x = salir', 10, 13, 0

	prompt		db '= ', 0


; ------------------------------------------------------------------

