; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE MANEJO DE TECLADO
; ==================================================================

; ------------------------------------------------------------------
; os_wait_for_key -- Espera para presión de tecla y entrega la tecla
; IN: Nothing; OUT: AX = tecla presionada, otros registros preservados

os_wait_for_key:
	pusha

	mov ax, 0
	mov ah, 10h			; llamada a BIOS a esperar una tecla
	int 16h

	mov [.tmp_buf], ax		; Guardar tecla presionada resultante

	popa				; Pero restaura los demás registros
	mov ax, [.tmp_buf]
	ret


	.tmp_buf	dw 0


; ------------------------------------------------------------------
; os_check_for_key -- Escanea teclado para entrada, pero no espera
; IN: Nothing; OUT: AX = 0 si no tecla presionada, sino escaneo de código

os_check_for_key:
	pusha

	mov ax, 0
	mov ah, 1			; Llamada de BIOS para chequear por tecla
	int 16h

	jz .nokey			; Si no tecla, saltar al final

	mov ax, 0			; Si no, obténlo del buffer
	int 16h

	mov [.tmp_buf], ax		; Guardar tecla presionada resultante

	popa				; Pero restaura los demás registros
	mov ax, [.tmp_buf]
	ret

.nokey:
	popa
	mov ax, 0			; Resultado cero si ninguna tecla presionada
	ret


	.tmp_buf	dw 0


; ==================================================================

