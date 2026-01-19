; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE SONIDOS DE PC SPEAKER
; ==================================================================

; ------------------------------------------------------------------
; os_speaker_tone -- Genera tono de PC speaker (call os_speaker_off to turn off)
; IN: AX = nota frecuancia; OUT: Nothing (registros preservados)

os_speaker_tone:
	pusha

	mov cx, ax			; Guardar valor de nota por ahora

	mov al, 182
	out 43h, al
	mov ax, cx			; Poner frecuencia
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h			; Switch PC speaker on
	or al, 03h
	out 61h, al

	popa
	ret


; ------------------------------------------------------------------
; os_speaker_off -- Apagar el PC speaker
; IN/OUT: Nothing (registros preservados)

os_speaker_off:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret


; ==================================================================

