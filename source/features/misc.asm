; ==================================================================
; YogiOS -- The Yogi Operating System kernel
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS MISCELÁNEAS
; ==================================================================

; ------------------------------------------------------------------
; os_get_api_version -- Regresa versión actual del YogiOS API
; IN: Nothing; OUT: AL = número de versión API

os_get_api_version:
	mov al, YOGIOS_API_VER
	ret


; ------------------------------------------------------------------
; os_pause -- Retrasa la ejecución por trozos específicos de 110ms
; IN: AX = trozos de 100 milisegundos por esperar (máx. tardanza es 32767,
;     que multiplicado por 55ms = 1802 segundos = 30 minutos)

os_pause:
	pusha
	cmp ax, 0
	je .time_up			; Si retraso = 0 entonces bail out

	mov cx, 0
	mov [.counter_var], cx		; Vacía la variable contadora

	mov bx, ax
	mov ax, 0
	mov al, 2			; 2 * 55ms = 110ms
	mul bx				; Multiplicador por el número de trozos de 110ms requerido
	mov [.orig_req_delay], ax	; Guárdalo

	mov ah, 0
	int 1Ah				; Obtener contador de tick	

	mov [.prev_tick_count], dx	; Guárdalo para comparación posterior

.checkloop:
	mov ah,0
	int 1Ah				; Obtener contador de tick de nuevo

	cmp [.prev_tick_count], dx	; Comparar con el contador de tick previo

	jne .up_date			; Si cambió, chequéalo
	jmp .checkloop			; Si no, espere un poco más

.time_up:
	popa
	ret

.up_date:
	mov ax, [.counter_var]		; Inc counter_var
	inc ax
	mov [.counter_var], ax

	cmp ax, [.orig_req_delay]	; Es counter_var = retraso requerido?
	jge .time_up			; Sí, así, retírese

	mov [.prev_tick_count], dx	; No, así actualiza .prev_tick_count 

	jmp .checkloop			; Y anda a esperar un poco más


	.orig_req_delay		dw	0
	.counter_var		dw	0
	.prev_tick_count	dw	0


; ------------------------------------------------------------------
; os_fatal_error -- Muestra mensaje de error y ejecución de halt¡
; IN: AX = ubicación del texto del mensaje de error

os_fatal_error:
	mov bx, ax			; Guardar ubicación del texto por aghora

	mov dh, 0
	mov dl, 0
	call os_move_cursor

	pusha
	mov ah, 09h			; Dibuja barra roja encima
	mov bh, 0
	mov cx, 240
	mov bl, 01001111b
	mov al, ' '
	int 10h
	popa

	mov dh, 0
	mov dl, 0
	call os_move_cursor

	mov si, .msg_inform		; Informe de error fatal
	call os_print_string

	mov si, bx			; Mensaje de error dado por programa
	call os_print_string

	jmp $				; Ejecución halt

	
	.msg_inform		db '>>> ERROR FATAL DEL SISTEMA OPERATIVO', 13, 10, 0


; ==================================================================

