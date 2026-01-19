; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE PUERTOS DE ENTRADA Y SALIDA
; ==================================================================

; ------------------------------------------------------------------
; os_port_byte_out -- Mandar byte a un  puerto
; IN: DX = dirección del puerto, AL = byte por mandar

os_port_byte_out:
	pusha

	out dx, al

	popa
	ret


; ------------------------------------------------------------------
; os_port_byte_in -- Recibe byte de un puerto
; IN: DX = dirección de puerto
; OUT: AL = byte de puerto

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
; IN: AX = 0 para modo normal (9600 baud), or 1 para modo lento (1200 baud)

os_serial_port_enable:
	pusha

	mov dx, 0			; Configurar puerto serial 1
	cmp ax, 1
	je .slow_mode

	mov ah, 0
	mov al, 11100011b		; 9600 baud, no parity, 8 data bits, 1 stop bit
	jmp .finish

.slow_mode:
	mov ah, 0
	mov al, 10000011b		; 1200 baud, no parity, 8 data bits, 1 stop bit	

.finish:
	int 14h

	popa
	ret


; ------------------------------------------------------------------
; os_send_via_serial -- Mandar un byte via el puerto serial
; IN: AL = byte para mandar via serial; OUT: AH = Bit 7 limpio en éxito

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
; OUT: AL = byte que fue recibido; OUT: AH = Bit 7 limpio en éxito

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

