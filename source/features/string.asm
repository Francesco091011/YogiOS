; ==================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; RUTINAS DE MANIPULACIÓN DE TEXTO
; ==================================================================

; ------------------------------------------------------------------
; os_string_length -- Obtener la longitud de una cadena
; ENTRADA: AX = dirección de la cadena.
; SALIDA: AX = longitud (se conservan los demás registros).

os_string_length:
	pusha

	mov bx, ax			; Move location of string to BX

	mov cx, 0			; Counter

.more:
	cmp byte [bx], 0		; Zero (end of string) yet?
	je .done
	inc bx				; If not, keep adding
	inc cx
	jmp .more


.done:
	mov word [.tmp_counter], cx	; Store count before restoring other registers
	popa

	mov ax, [.tmp_counter]		; Put count back into AX before returning
	ret


	.tmp_counter	dw 0


; ------------------------------------------------------------------
; os_string_reverse -- Invertir los caracteres de una cadena
; ENTRADA: SI = dirección de la cadena.

os_string_reverse:
	pusha

	cmp byte [si], 0		; Don't attempt to reverse empty string
	je .end

	mov ax, si
	call os_string_length

	mov di, si
	add di, ax
	dec di				; DI now points to last char in string

.loop:
	mov byte al, [si]		; Swap bytes
	mov byte bl, [di]

	mov byte [si], bl
	mov byte [di], al

	inc si				; Move towards string centre
	dec di

	cmp di, si			; Both reached the centre?
	ja .loop

.end:
	popa
	ret


; ------------------------------------------------------------------
; os_find_char_in_string -- Buscar un carácter en una cadena
; ENTRADA: SI = dirección de la cadena, AL = carácter buscado.
; SALIDA: AX = posición del carácter o 0 si no aparece.

os_find_char_in_string:
	pusha

	mov cx, 1			; Empezar a contar desde 1 para poder devolver 0
					; si no se encuentra el carácter buscado.

.more:
	cmp byte [si], al
	je .done
	cmp byte [si], 0
	je .notfound
	inc si
	inc cx
	jmp .more

.done:
	mov [.tmp], cx
	popa
	mov ax, [.tmp]
	ret

.notfound:
	popa
	mov ax, 0
	ret


	.tmp	dw 0


; ------------------------------------------------------------------
; os_string_charchange -- Reemplazar apariciones de un carácter en una cadena
; ENTRADA: SI = cadena, AL = carácter buscado, BL = carácter de reemplazo.

os_string_charchange:
	pusha

	mov cl, al

.loop:
	mov byte al, [si]
	cmp al, 0
	je .finish
	cmp al, cl
	jne .nochange

	mov byte [si], bl

.nochange:
	inc si
	jmp .loop

.finish:
	popa
	ret


; ------------------------------------------------------------------
; os_string_uppercase -- Convertir una cadena terminada en cero a mayúsculas
; ENTRADA/SALIDA: AX = dirección de la cadena.

os_string_uppercase:
	pusha

	mov si, ax			; Use SI to access string

.more:
	cmp byte [si], 0		; Zero-termination of string?
	je .done			; If so, quit

	cmp byte [si], 'a'		; In the lower case A to Z range?
	jb .noatoz
	cmp byte [si], 'z'
	ja .noatoz

	sub byte [si], 20h		; If so, convert input char to upper case

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_string_lowercase -- Convertir una cadena terminada en cero a minúsculas
; ENTRADA/SALIDA: AX = dirección de la cadena.

os_string_lowercase:
	pusha

	mov si, ax			; Use SI to access string

.more:
	cmp byte [si], 0		; Zero-termination of string?
	je .done			; If so, quit

	cmp byte [si], 'A'		; In the upper case A to Z range?
	jb .noatoz
	cmp byte [si], 'Z'
	ja .noatoz

	add byte [si], 20h		; If so, convert input char to lower case

	inc si
	jmp .more

.noatoz:
	inc si
	jmp .more

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_string_copy -- Copiar una cadena en otra
; ENTRADA/SALIDA: SI = origen, DI = destino (reservar espacio suficiente).

os_string_copy:
	pusha

.more:
	mov al, [si]			; Transfer contents (at least one byte terminator)
	mov [di], al
	inc si
	inc di
	cmp byte al, 0			; If source string is empty, quit out
	jne .more

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_string_truncate -- Recortar una cadena a la cantidad indicada de caracteres
; ENTRADA: SI = dirección de la cadena, AX = cantidad de caracteres.
; SALIDA: cadena modificada; se conservan los registros.

os_string_truncate:
	pusha

	add si, ax
	mov byte [si], 0

	popa
	ret


; ------------------------------------------------------------------
; os_string_join -- Unir dos cadenas en una tercera
; ENTRADA/SALIDA: AX y BX = cadenas de origen, CX = cadena de destino.

os_string_join:
	pusha

	mov si, ax			; Put first string into CX
	mov di, cx
	call os_string_copy

	call os_string_length		; Get length of first string

	add cx, ax			; Position at end of first string

	mov si, bx			; Add second string onto it
	mov di, cx
	call os_string_copy

	popa
	ret


; ------------------------------------------------------------------
; os_string_chomp -- Quitar los espacios iniciales y finales de una cadena
; ENTRADA: AX = dirección de la cadena.

os_string_chomp:
	pusha

	mov dx, ax			; Save string location

	mov di, ax			; Put location into DI
	mov cx, 0			; Space counter

.keepcounting:				; Get number of leading spaces into BX
	cmp byte [di], ' '
	jne .counted
	inc cx
	inc di
	jmp .keepcounting

.counted:
	cmp cx, 0			; No leading spaces?
	je .finished_copy

	mov si, di			; Address of first non-space character
	mov di, dx			; DI = original string start

.keep_copying:
	mov al, [si]			; Copy SI into DI
	mov [di], al			; Including terminator
	cmp al, 0
	je .finished_copy
	inc si
	inc di
	jmp .keep_copying

.finished_copy:
	mov ax, dx			; AX = original string start

	call os_string_length
	cmp ax, 0			; If empty or all blank, done, return 'null'
	je .done

	mov si, dx
	add si, ax			; Move to end of string

.more:
	dec si
	cmp byte [si], ' '
	jne .done
	mov byte [si], 0		; Fill end spaces with 0s
	jmp .more			; (First 0 will be the string terminator)

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_string_strip -- Quitar de una cadena el carácter indicado (máximo 255).
; ENTRADA: SI = dirección de la cadena, AL = carácter que se quitará.

os_string_strip:
	pusha

	mov di, si

	mov bl, al			; Copy the char into BL since LODSB and STOSB use AL
.nextchar:
	lodsb
	stosb
	cmp al, 0			; Check if we reached the end of the string
	je .finish			; If so, bail out
	cmp al, bl			; Check to see if the character we read is the interesting char
	jne .nextchar			; If not, skip to the next character

.skip:					; If so, the fall through to here
	dec di				; Decrement DI so we overwrite on the next pass
	jmp .nextchar

.finish:
	popa
	ret

; ------------------------------------------------------------------
; os_string_compare -- Comprobar si dos cadenas son iguales
; ENTRADA: SI y DI = cadenas que se compararán.
; SALIDA: acarreo activado si son iguales; desactivado si son distintas.

os_string_compare:
	pusha

.more:
	mov al, [si]			; Retrieve string contents
	mov bl, [di]

	cmp al, bl			; Compare characters at current location
	jne .not_same

	cmp al, 0			; End of first string? Must also be end of second
	je .terminated

	inc si
	inc di
	jmp .more


.not_same:				; If unequal lengths with same beginning, the byte
	popa				; comparison fails at shortest string terminator
	clc				; Clear carry flag
	ret


.terminated:				; Both strings terminated at the same position
	popa
	stc				; Set carry flag
	ret


; ------------------------------------------------------------------
; os_string_strincmp -- Comparar una cantidad determinada de caracteres
; ENTRADA: SI y DI = cadenas, CL = caracteres que se compararán.
; SALIDA: acarreo activado si coinciden; desactivado si son distintas.

os_string_strincmp:
	pusha

.more:
	mov al, [si]			; Retrieve string contents
	mov bl, [di]

	cmp al, bl			; Compare characters at current location
	jne .not_same

	cmp al, 0			; End of first string? Must also be end of second
	je .terminated

	inc si
	inc di

	dec cl				; If we've lasted through our char count
	cmp cl, 0			; Then the bits of the string match!
	je .terminated

	jmp .more


.not_same:				; If unequal lengths with same beginning, the byte
	popa				; comparison fails at shortest string terminator
	clc				; Clear carry flag
	ret


.terminated:				; Both strings terminated at the same position
	popa
	stc				; Set carry flag
	ret


; ------------------------------------------------------------------
; os_string_parse -- Separar una cadena (p. ej., «run foo bar baz») y devolver
; punteros a sus partes terminadas en cero (AX = «run», BX = «foo», etc.).
; ENTRADA: SI = cadena. SALIDA: AX, BX, CX y DX = cadenas separadas.

os_string_parse:
	push si

	mov ax, si			; AX = start of first string

	mov bx, 0			; By default, other strings start empty
	mov cx, 0
	mov dx, 0

	push ax				; Save to retrieve at end

.loop1:
	lodsb				; Get a byte
	cmp al, 0			; End of string?
	je .finish
	cmp al, ' '			; A space?
	jne .loop1
	dec si
	mov byte [si], 0		; If so, zero-terminate this bit of the string

	inc si				; Store start of next string in BX
	mov bx, si

.loop2:					; Repeat the above for CX and DX...
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop2
	dec si
	mov byte [si], 0

	inc si
	mov cx, si

.loop3:
	lodsb
	cmp al, 0
	je .finish
	cmp al, ' '
	jne .loop3
	dec si
	mov byte [si], 0

	inc si
	mov dx, si

.finish:
	pop ax

	pop si
	ret


; ------------------------------------------------------------------
; os_string_to_int -- Convertir una cadena decimal a un entero
; ENTRADA: SI = dirección de la cadena (máximo 5 caracteres, hasta «65536»).
; SALIDA: AX = número.

os_string_to_int:
	pusha

	mov ax, si			; First, get length of string
	call os_string_length

	add si, ax			; Work from rightmost char in string
	dec si

	mov cx, ax			; Use string length as counter

	mov bx, 0			; BX will be the final number
	mov ax, 0


	; Al avanzar hacia la izquierda, cada carácter representa un múltiplo mayor:
	; el de más a la derecha vale unidades; siguen decenas, centenas, millares
	; y, para un número de cinco caracteres, decenas de millar.

	mov word [.multiplier], 1	; Start with multiples of 1

.loop:
	mov ax, 0
	mov byte al, [si]		; Get character
	sub al, 48			; Convert from ASCII to real number

	mul word [.multiplier]		; Multiply by our multiplier

	add bx, ax			; Add it to BX

	push ax				; Multiply our multiplier by 10 for next char
	mov word ax, [.multiplier]
	mov dx, 10
	mul dx
	mov word [.multiplier], ax
	pop ax

	dec cx				; Any more chars?
	cmp cx, 0
	je .finish
	dec si				; Move back a char in the string
	jmp .loop

.finish:
	mov word [.tmp], bx
	popa
	mov word ax, [.tmp]

	ret


	.multiplier	dw 0
	.tmp		dw 0


; ------------------------------------------------------------------
; os_int_to_string -- Convertir un entero sin signo en una cadena
; ENTRADA: AX = entero. SALIDA: AX = dirección de la cadena.

os_int_to_string:
	pusha

	mov cx, 0
	mov bx, 10			; Set BX 10, for division and mod
	mov di, .t			; Get our pointer ready

.push:
	mov dx, 0
	div bx				; Remainder in DX, quotient in AX
	inc cx				; Increase pop loop counter
	push dx				; Push remainder, so as to reverse order when popping
	test ax, ax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop dx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		; Zero-terminate string

	popa
	mov ax, .t			; Return location of string
	ret


	.t times 7 db 0


; ------------------------------------------------------------------
; os_sint_to_string -- Convertir un entero con signo en una cadena
; ENTRADA: AX = entero. SALIDA: AX = dirección de la cadena.

os_sint_to_string:
	pusha

	mov cx, 0
	mov bx, 10			; Set BX 10, for division and mod
	mov di, .t			; Get our pointer ready

	test ax, ax			; Find out if X > 0 or not, force a sign
	js .neg				; If negative...
	jmp .push			; ...or if positive
.neg:
	neg ax				; Make AX positive
	mov byte [.t], '-'		; Add a minus sign to our string
	inc di				; Update the index
.push:
	mov dx, 0
	div bx				; Remainder in DX, quotient in AX
	inc cx				; Increase pop loop counter
	push dx				; Push remainder, so as to reverse order when popping
	test ax, ax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop dx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [di], dl
	inc di
	dec cx
	jnz .pop

	mov byte [di], 0		; Zero-terminate string

	popa
	mov ax, .t			; Return location of string
	ret


	.t times 7 db 0


; ------------------------------------------------------------------
; os_long_int_to_string -- Convertir el valor de DX:AX en una cadena
; ENTRADA: DX:AX = entero largo sin signo, BX = base numérica, DI = destino.
; SALIDA: DI = dirección de la cadena resultante.

os_long_int_to_string:
	pusha

	mov si, di			; Prepare for later data movement

	mov word [di], 0		; Terminate string, creates 'null'

	cmp bx, 37			; Base > 37 or < 0 not supported, return null
	ja .done

	cmp bx, 0			; Base = 0 produces overflow, return null
	je .done

.conversion_loop:
	mov cx, 0			; Zero extend unsigned integer, number = CX:DX:AX
					; Si el número es 0, recorrer el bucle una vez y guardar «0».

	xchg ax, cx			; Number order DX:AX:CX for high order division
	xchg ax, dx
	div bx				; AX = high quotient, DX = high remainder

	xchg ax, cx			; Number order for low order division
	div bx				; CX = high quotient, AX = low quotient, DX = remainder
	xchg cx, dx			; CX = digit to send

.save_digit:
	cmp cx, 9			; Eliminate punctuation between '9' and 'A'
	jle .convert_digit

	add cx, 'A'-'9'-1

.convert_digit:
	add cx, '0'			; Convert to ASCII

	push ax				; Load this ASCII digit into the beginning of the string
	push bx
	mov ax, si
	call os_string_length		; AX = length of string, less terminator
	mov di, si
	add di, ax			; DI = end of string
	inc ax				; AX = nunber of characters to move, including terminator

.move_string_up:
	mov bl, [di]			; Put digits in correct order
	mov [di+1], bl
	dec di
	dec ax
	jnz .move_string_up

	pop bx
	pop ax
	mov [si], cl			; Last digit (LSD) will print first (on left)

.test_end:
	mov cx, dx			; DX = high word, again
	or cx, ax			; Nothing left?
	jnz .conversion_loop

.done:
	popa
	ret


; ------------------------------------------------------------------
; os_set_time_fmt -- Establecer formato de hora (p. ej., «10:25 AM» o «2300 horas»)
; ENTRADA: AL = indicador de formato; 0 = formato de 12 horas.

os_set_time_fmt:
	pusha
	cmp al, 0
	je .store
	mov al, 0FFh
.store:
	mov [fmt_12_24], al
	popa
	ret


; ------------------------------------------------------------------
; os_get_time_string -- Obtener la hora actual como cadena (p. ej., «10:25»)
; ENTRADA/SALIDA: BX = dirección de la cadena.

os_get_time_string:
	pusha

	mov di, bx			; Location to place time string

	clc				; For buggy BIOSes
	mov ah, 2			; Get time data from BIOS in BCD format
	int 1Ah
	jnc .read

	clc
	mov ah, 2			; BIOS was updating (~1 in 500 chance), so try again
	int 1Ah

.read:
	mov al, ch			; Convert hours to integer for AM/PM test
	call os_bcd_to_int
	mov dx, ax			; Save

	mov al,	ch			; Hour
	shr al, 4			; Tens digit - move higher BCD number into lower bits
	and ch, 0Fh			; Ones digit
	test byte [fmt_12_24], 0FFh
	jz .twelve_hr

	call .add_digit			; BCD already in 24-hour format
	mov al, ch
	call .add_digit
	jmp short .minutes

.twelve_hr:
	cmp dx, 0			; If 00mm, make 12 AM
	je .midnight

	cmp dx, 10			; Before 1000, OK to store 1 digit
	jl .twelve_st1

	cmp dx, 12			; Between 1000 and 1300, OK to store 2 digits
	jle .twelve_st2

	mov ax, dx			; Change from 24 to 12-hour format
	sub ax, 12
	mov bl, 10
	div bl
	mov ch, ah

	cmp al, 0			; 1-9 PM
	je .twelve_st1

	jmp short .twelve_st2		; 10-11 PM

.midnight:
	mov al, 1
	mov ch, 2

.twelve_st2:
	call .add_digit			; Modified BCD, 2-digit hour
.twelve_st1:
	mov al, ch
	call .add_digit

	mov al, ':'			; Time separator (12-hr format)
	stosb

.minutes:
	mov al, cl			; Minute
	shr al, 4			; Tens digit - move higher BCD number into lower bits
	and cl, 0Fh			; Ones digit
	call .add_digit
	mov al, cl
	call .add_digit

	mov al, ' '			; Separate time designation
	stosb

	mov si, .hours_string		; Assume 24-hr format
	test byte [fmt_12_24], 0FFh
	jnz .copy

	mov si, .pm_string		; Assume PM
	cmp dx, 12			; Test for AM/PM
	jg .copy

	mov si, .am_string		; Was actually AM

.copy:
	lodsb				; Copy designation, including terminator
	stosb
	cmp al, 0
	jne .copy

	popa
	ret


.add_digit:
	add al, '0'			; Convert to ASCII
	stosb				; Put into string buffer
	ret


	.hours_string	db 'horas', 0
	.am_string 	db 'AM', 0
	.pm_string 	db 'PM', 0


; ------------------------------------------------------------------
; os_set_date_fmt -- Establecer formato de fecha (M/D/A, D/M/A o A/M/D: 0, 1, 2)
; ENTRADA: AX = indicador de formato, de 0 a 2.
; Si el bit 7 de AX es 1, usar nombres de meses.
; Si el bit 7 de AX es 0, el byte alto contiene el separador.

os_set_date_fmt:
	pusha
	test al, 80h			; ASCII months (bit 7)?
	jnz .fmt_clear

	and ax, 7F03h			; 7-bit ASCII separator and format number
	jmp short .fmt_test

.fmt_clear:
	and ax, 0003			; Ensure separator is clear

.fmt_test:
	cmp al, 3			; Only allow 0, 1 and 2
	jae .leave
	mov [fmt_date], ax

.leave:
	popa
	ret


; ------------------------------------------------------------------
; os_get_date_string -- Obtener la fecha actual como cadena (p. ej., «31/12/2007»)
; ENTRADA/SALIDA: BX = dirección de la cadena.

os_get_date_string:
	pusha

	mov di, bx			; Store string location for now
	mov bx, [fmt_date]		; BL = format code
	and bx, 7F03h			; BH = separator, 0 = use month names

	clc				; For buggy BIOSes
	mov ah, 4			; Get date data from BIOS in BCD format
	int 1Ah
	jnc .read

	clc
	mov ah, 4			; BIOS was updating (~1 in 500 chance), so try again
	int 1Ah

.read:
	cmp bl, 2			; YYYY/MM/DD format, suitable for sorting
	jne .try_fmt1

	mov ah, ch			; Always provide 4-digit year
	call .add_2digits
	mov ah, cl
	call .add_2digits		; And '/' as separator
	mov al, '/'
	stosb

	mov ah, dh			; Always 2-digit month
	call .add_2digits
	mov al, '/'			; And '/' as separator
	stosb

	mov ah, dl			; Always 2-digit day
	call .add_2digits
	jmp short .done

.try_fmt1:
	cmp bl, 1			; D/M/Y format (military and Europe)
	jne .do_fmt0

	mov ah, dl			; Day
	call .add_1or2digits

	mov al, bh
	cmp bh, 0
	jne .fmt1_day

	mov al, ' '			; If ASCII months, use space as separator

.fmt1_day:
	stosb				; Day-month separator

	mov ah,	dh			; Month
	cmp bh, 0			; ASCII?
	jne .fmt1_month

	call .add_month			; Yes, add to string
	mov ax, ', '
	stosw
	jmp short .fmt1_century

.fmt1_month:
	call .add_1or2digits		; No, use digits and separator
	mov al, bh
	stosb

.fmt1_century:
	mov ah,	ch			; Century present?
	cmp ah, 0
	je .fmt1_year

	call .add_1or2digits		; Yes, add it to string (most likely 2 digits)

.fmt1_year:
	mov ah, cl			; Year
	call .add_2digits		; At least 2 digits for year, always

	jmp short .done

.do_fmt0:				; Default format, M/D/Y (US and others)
	mov ah,	dh			; Month
	cmp bh, 0			; ASCII?
	jne .fmt0_month

	call .add_month			; Yes, add to string and space
	mov al, ' '
	stosb
	jmp short .fmt0_day

.fmt0_month:
	call .add_1or2digits		; No, use digits and separator
	mov al, bh
	stosb

.fmt0_day:
	mov ah, dl			; Day
	call .add_1or2digits

	mov al, bh
	cmp bh, 0			; ASCII?
	jne .fmt0_day2

	mov al, ','			; Yes, separator = comma space
	stosb
	mov al, ' '

.fmt0_day2:
	stosb

.fmt0_century:
	mov ah,	ch			; Century present?
	cmp ah, 0
	je .fmt0_year

	call .add_1or2digits		; Yes, add it to string (most likely 2 digits)

.fmt0_year:
	mov ah, cl			; Year
	call .add_2digits		; At least 2 digits for year, always


.done:
	mov ax, 0			; Terminate date string
	stosw

	popa
	ret


.add_1or2digits:
	test ah, 0F0h
	jz .only_one
	call .add_2digits
	jmp short .two_done
.only_one:
	mov al, ah
	and al, 0Fh
	call .add_digit
.two_done:
	ret

.add_2digits:
	mov al, ah			; Convert AH to 2 ASCII digits
	shr al, 4
	call .add_digit
	mov al, ah
	and al, 0Fh
	call .add_digit
	ret

.add_digit:
	add al, '0'			; Convert AL to ASCII
	stosb				; Put into string buffer
	ret

.add_month:
	push bx
	push cx
	mov al, ah			; Convert month to integer to index print table
	call os_bcd_to_int
	dec al				; January = 0
	mov bl, 4			; Multiply month by 4 characters/month
	mul bl
	mov si, .months
	add si, ax
	mov cx, 4
	rep movsb
	cmp byte [di-1], ' '		; May?
	jne .done_month			; Yes, eliminate extra space
	dec di
.done_month:
	pop cx
	pop bx
	ret


	.months db 'Ene.Feb.Mar.Abr.May.Jun.Jul.Ago.Sep.Oct.Nov.Dic.'


; ------------------------------------------------------------------
; os_string_tokenize -- Leer elementos de una cadena separados por el carácter
; indicado. Devolver un puntero al siguiente elemento o 0 si no quedan más.
; ENTRADA: AL = separador, SI = inicio. SALIDA: DI = siguiente elemento o 0.

os_string_tokenize:
	push si

.next_char:
	cmp byte [si], al
	je .return_token
	cmp byte [si], 0
	jz .no_more
	inc si
	jmp .next_char

.return_token:
	mov byte [si], 0
	inc si
	mov di, si
	pop si
	ret

.no_more:
	mov di, 0
	pop si
	ret


; ==================================================================

