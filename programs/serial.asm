; ------------------------------------------------------------------
; Emulador de terminal serie sencillo para YogiOS
; ------------------------------------------------------------------


; Con este programa y un cable serie adecuado (módem nulo), puede iniciar
; sesión en equipos Linux. Configure un terminal serie en /etc/inittab,
; por ejemplo:
;
;	T0:2345:respawn:/sbin/getty/ -L ttyS0 9600 vt100
;
; Conecte el cable serie al equipo con YogiOS y al equipo Linux. Inicie
; YogiOS y ejecute SERIAL.BIN; luego inicie Linux con la entrada de terminal
; anterior. En YogiOS aparecerá el inicio de sesión de Linux. La emulación
; VT100 es limitada, por lo que programas complejos como Emacs podrían verse
; incorrectamente.
;
; Pulse F8 para salir.


	BITS 16

	%INCLUDE "mikedev.inc"
	ORG 32768


start:
	mov ax, warnmsg_1
	mov bx, warnmsg_2
	mov cx, 0
	mov dx, 1
	call os_dialog_box
	cmp ax, 0
	je .proceed

	call os_clear_screen
	ret


.proceed:
	call os_clear_screen

	mov ax, 0			; 9600 baud mode
	call os_serial_port_enable

	mov si, start_msg
	call os_print_string


main_loop:
	mov dx, 0			; Set port to COM1
	mov ax, 0
	mov ah, 03h			; Check COM1 status
	int 14h

	bt ax, 8			; Data received?
	jc received_byte

	mov ax, 0			; If not, have we something to send?
	call os_check_for_key

	cmp ax, 4200h			; F8 key pressed?
	je finish			; Quit if so

	cmp al, 0			; If no other key pressed, go back
	je main_loop

	call os_send_via_serial		; Otherwise send it
	jmp main_loop

received_byte:				; Print data received
	call os_get_via_serial

	cmp al, 1Bh			; 'Esc' character received?
	je esc_received

	mov ah, 0Eh			; Otherwise print char
	int 10h
	jmp main_loop

finish:
	mov si, finish_msg
	call os_print_string

	call os_wait_for_key

	ret



esc_received:
	call os_get_via_serial		; Get next character...
	cmp al, '['			; Is it a screen control code?
	jne main_loop

	mov bl, al			; Store for now

	call os_get_via_serial		; If control code, parse it

	cmp al, 'H'
	je near move_to_home

	cmp al, 'J'
	je near erase_to_bottom

	cmp al, 'K'
	je near erase_to_end_of_line


					; Si aún no podemos interpretar el carácter de control,
					; mostrar la secuencia completa para depurarla.

	mov cl, al			; Store second char
	mov al, bl			; Get first

	mov ah, 0Eh			; Print them
	int 10h
	mov al, cl
	int 10h

	jmp main_loop



move_to_home:
	mov dx, 0
	call os_move_cursor
	jmp main_loop


erase_to_bottom:
	call os_get_cursor_pos

	push dx				; Store where we are

	call erase_sub

	inc dh				; Move to start of next line
	mov dl, 0
	call os_move_cursor

	mov ah, 0Ah			; Get ready to print 80 spaces
	mov al, ' '
	mov bx, 0
	mov cx, 80
.more:
	int 10h
	inc dh				; Next line...
	call os_move_cursor
	cmp dh, 25			; Reached bottom of screen?
	jne .more

	pop dx				; Put cursor back to where we started
	call os_move_cursor

	jmp main_loop



erase_to_end_of_line:
	call erase_sub
	jmp main_loop


erase_sub:
	call os_get_cursor_pos

	push dx				; Store where we are

	mov ah, 80			; Calculate how many spaces
	sub ah, dl			; we need to print...

	mov cx, 0			; And drop into CL
	mov cl, ah

	mov ah, 0Ah			; Print spaces CL number of times
	mov al, ' '
	mov bx, 0
	int 10h

	pop dx
	call os_move_cursor

	ret


	warnmsg_1	db 'Terminal serie: podria bloquearse.', 0
	warnmsg_2	db 'Sin puertos serie. Desea continuar?', 0

	start_msg	db 'Terminal serie de YogiOS -- Pulse F8 para salir', 13, 10, 'Conectando a 9600 baudios...', 13, 10, 13, 10, 0
	finish_msg	db 13, 10, 13, 10, 'Saliendo del terminal serie; pulse una tecla para volver a YogiOS', 13, 10, 0


; ------------------------------------------------------------------

