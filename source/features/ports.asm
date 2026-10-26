; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE PUERTOS DE ENTRADA Y SALIDA
; ==================================================================

; ------------------------------------------------------------------
; os_port_byte_out -- Mandar byte a un  puerto
; ENTRADA: DX = dirección del puerto, AL = byte que se enviará.

os_port_byte_out:
	pusha

	out dx, al

	popa
	ret


; ------------------------------------------------------------------
; os_port_byte_in -- Recibe byte de un puerto
; ENTRADA: DX = dirección del puerto. SALIDA: AL = byte leído.

os_port_byte_in:
	pusha

	in al, dx
	mov word [.tmp], ax

	popa
	mov ax, [.tmp]
	ret


	.tmp dw 0


; ------------------------------------------------------------------
; os_serial_port_enable -- Poner el puerto serial para trasmitir datos
; ENTRADA: AX = 0 para modo normal (9600 baudios) o 1 para modo lento (1200 baudios).

os_serial_port_enable:
	pusha

	mov dx, 0			; Configurar puerto serial 1
	cmp ax, 1
	je .slow_mode

	mov ah, 0
	mov al, 11100011b		; 9600 baudios, sin paridad, 8 bits de datos y 1 bit de parada.
	jmp .finish

.slow_mode:
	mov ah, 0
	mov al, 10000011b		; 1200 baudios, sin paridad, 8 bits de datos y 1 bit de parada.

.finish:
	int 14h

	popa
	ret


; ------------------------------------------------------------------
; os_send_via_serial -- Mandar un byte via el puerto serial
; ENTRADA: AL = byte que se enviará. SALIDA: el bit 7 de AH queda limpio si tuvo éxito.

os_send_via_serial:
	pusha

	mov ah, 01h
	mov dx, 0			; COM1

	int 14h

	mov [.tmp], ax

	popa

	mov ax, [.tmp]

	ret


	.tmp dw 0


; ------------------------------------------------------------------
; os_get_via_serial -- Recibir un byte desde el puerto serial
; SALIDA: AL = byte recibido. El bit 7 de AH queda limpio si tuvo éxito.

os_get_via_serial:
	pusha

	mov ah, 02h
	mov dx, 0			; COM1

	int 14h

	mov [.tmp], ax

	popa

	mov ax, [.tmp]

	ret


	.tmp dw 0


; ==================================================================

