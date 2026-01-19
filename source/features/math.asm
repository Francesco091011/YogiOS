; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS MATEMÁTICAS
; ==================================================================

; ------------------------------------------------------------------
; os_seed_random -- Semilla del generador de números aleatorios basado en el reloj
; IN: Nothing; OUT: Nothing (registros preservados)

os_seed_random:
	push bx
	push ax

	mov bx, 0
	mov al, 0x02			; Minuto
	out 0x70, al
	in al, 0x71

	mov bl, al
	shl bx, 8
	mov al, 0			; Segundo
	out 0x70, al
	in al, 0x71
	mov bl, al

	mov word [os_random_seed], bx	; Semilla será algo como 0x4435 (si fuera
					; 44 minutos y 35 segundos después de la hora)
	pop ax
	pop bx
	ret


	os_random_seed	dw 0


; ------------------------------------------------------------------
; os_get_random -- Da un entero aleatorio entre bajo y alto (inclusivos)
; IN: AX = entero bajo, BX = entero alto
; OUT: CX = entero aleatorio

os_get_random:
	push dx
	push bx
	push ax

	sub bx, ax			; Queremos un número entre 0 y (alto-bajo)
	call .generate_random
	mov dx, bx
	add dx, 1
	mul dx
	mov cx, dx

	pop ax
	pop bx
	pop dx
	add cx, ax			; Añadir el offset bajo de vuelta
	ret


.generate_random:
	push dx
	push bx

	mov ax, [os_random_seed]
	mov dx, 0x7383			; El número mágico (random.org)
	mul dx				; DX:AX = AX * DX
	mov [os_random_seed], ax

	pop bx
 	pop dx
	ret


; ------------------------------------------------------------------
; os_bcd_to_int -- Convierte número decimal codificado en binario a un entero
; IN: AL = BCD número; OUT: AX = valor entero

os_bcd_to_int:
	pusha

	mov bl, al			; Guarda el número entero por ahora

	and ax, 0Fh			; Zero-out high bits
	mov cx, ax			; CH/CL = bajo número BCD, cero extendido

	shr bl, 4			; Mover número BCD más alto en los bits más bajos, zero fill msb
	mov al, 10
	mul bl				; AX = 10 * BL

	add ax, cx			; Añadir BCD bajos a 10*altos
	mov [.tmp], ax

	popa
	mov ax, [.tmp]			; Y regresarlo en AX!
	ret


	.tmp	dw 0


; ------------------------------------------------------------------
; os_long_int_negate -- Valor múltiplo en DX:AX by -1
; IN: DX:AX = entero largo; OUT: DX:AX = -(initial DX:AX)

os_long_int_negate:
	neg ax
	adc dx, 0
	neg dx
	ret


; ==================================================================

