; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE SONIDOS DE PC SPEAKER
; ==================================================================

; ------------------------------------------------------------------
; os_speaker_tone -- Genera un tono con el altavoz interno del PC.
; ENTRADA: AX = frecuencia de la nota. SALIDA: ninguna (se conservan los registros).

os_speaker_tone:
	pusha

	mov cx, ax			; Guardar valor de nota por ahora

	mov al, 182
	out 43h, al
	mov ax, cx			; Poner frecuencia
	out 42h, al
	mov al, ah
	out 42h, al

	in al, 61h			; Activar el altavoz interno.
	or al, 03h
	out 61h, al

	popa
	ret


; ------------------------------------------------------------------
; os_speaker_off -- Apagar el PC speaker
; ENTRADA/SALIDA: ninguna (se conservan los registros).

os_speaker_off:
	pusha

	in al, 61h
	and al, 0FCh
	out 61h, al

	popa
	ret


; ==================================================================

