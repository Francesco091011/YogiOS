; =============================================================================
; El arrancador del Yogi Operating System (Sistema Operativo YOGI)
; Copyright (C) 2026 FAEH Premiu,
;
; Basado en un arrancador libre de E Dehling. Escanea el diskete FAT12 para el
; KERNEL.BIN (el kernel de YogiOS), lo carga y lo ejecuta.
; Esto debería crecer no más que 512 bytes (one sector), con los últimos dos
; bytes siendo el signo de arranque (AA55h). Note que en FAT12, un cluster es
; lo mismo que un sector: 512 bytes.
; =============================================================================


	BITS 16

	jmp short bootloader_start	; Salta a la sección de descripción del 
                                        ; disco.
	nop				; Pad out before disk description


; ------------------------------------------------------------------
; Tabla de descripción del disco, para hacerlo un diskete válido.
; Nota: algunos de estos valores están hard-coded en el código!
; Valores son los usados por IBM para disketes de 1.44 MB y 3.5".

OEMLabel		db "MIKEBOOT"	; Nombre de disco
BytesPerSector		dw 512		; Bytes por sector
SectorsPerCluster	db 1		; Sectores por cluster
ReservedForBoot		dw 1		; Sectores reservados para grabación de
                                        ; arranque
NumberOfFats		db 2		; Número de copias del FAT
RootDirEntries		dw 224		; Número de entradas en el directorio
					; root (224*32=7168=14 sectores porleer)
LogicalSectors		dw 2880		; Número de sectores lógicos
MediumByte		db 0F0h		; Byte descriptor medio
SectorsPerFat		dw 9		; Sectores por FAT
SectorsPerTrack		dw 18		; Sectores por track (36/cilindro)
Sides			dw 2		; Número de lados/cabeceras
HiddenSectors		dd 0		; Número de sectores ocultps
LargeSectors		dd 0		; Número de sectores LBA
DriveNo			dw 0		; Drive No: 0
Signature		db 41		; Drive signature: 41 para diskete
VolumeID		dd 00000000h	; ID de Volumen: cualquier número
VolumeLabel		db "MIKEOS     "; Volume Label: cualquier once caráct.
FileSystem		db "FAT12   "	; File system tipo: no cambiarlo!


; ------------------------------------------------------------------
; Main bootloader code

bootloader_start:
	mov ax, 07C0h			; Poner 4K de espacio stack sobre el
                                        ; buffer
	add ax, 544			; 8k buffer = 512 parágrafos + 32 
                                        ; parágrafos (loader)
	cli				; Deshabilita interruptores al cambiar stack
	mov ss, ax
	mov sp, 4096
	sti				; Restaura interruptores

	mov ax, 07C0h			; Pone segmentos de datos donde estamos
                                        ; cargados.
	mov ds, ax

	; NOTA: Algunos BIOSes iniciales son repportados de impropiamente poner en DL

	cmp dl, 0
	je no_change
	mov [bootdev], dl		; Guardar número de dispositivo boot
	mov ah, 8			; Obtener parámetros del drive.
	int 13h
	jc fatal_disk_error
	and cx, 3Fh			; Máximo número de sector
	mov [SectorsPerTrack], cx	; Números de sector inicia en 1
	movzx dx, dh			; Máximo número de cabecera
	add dx, 1			; Números de cabecera inicia en 0 -
                                        ; añadir 1 for total
	mov [Sides], dx

no_change:
	mov eax, 0			; Necesitado para algunos BIOSes viejos.


; Primero, necesitamos cargar el directorio root desde el disco. Detalles técnicos:
; Start of root = ReservedForBoot + NumberOfFats * SectorsPerFat = logical 19
; Number of root = RootDirEntries * 32 bytes/entry / 512 bytes/sector = 14
; Start of user data = (start of root) + (number of root) = logical 33

floppy_ok:				; Listo para leer el primer bloque de datos
	mov ax, 19			; Directorio Root inicia en el sector lógico 19
	call l2hts

	mov si, buffer			; Poner ES:BX para apuntar a nuestro buffer
                                        ; (ver fin del código)
	mov bx, ds
	mov es, bx
	mov bx, si

	mov ah, 2			; Parámetros para int 13h: leer sectores de diskete
	mov al, 14			; Y leer 14 de esos

	pusha				; Preparar para entrar en bucle


read_root_dir:
	popa				; En caso registros son alterados por int 13h
	pusha

	stc				; Algunos BIOSes no lo ponen propiamente por error
	int 13h				; Leer sectores usando BIOS

	jnc search_dir			; Si lectura fue OK, saltar ahead
	call reset_floppy		; Si no, resetear controlador de diskete y reintentarlo
	jnc read_root_dir		; Reseteo de diskete OK?

	jmp reboot			; Si no, doble error fatal


search_dir:
	popa

	mov ax, ds			; Directorio Root está ahora en [buffer]
	mov es, ax			; Poner DI en esta info
	mov di, buffer

	mov cx, word [RootDirEntries]	; Buscar todas las entradas (224)
	mov ax, 0			; Buscando en el offset 0


next_root_entry:
	xchg cx, dx			; Usamos CX in the inner loop...

	mov si, kern_filename		; Iniciar búsqueda para el kernel filename
	mov cx, 11
	rep cmpsb
	je found_file_to_load		; Apuntador DI estará en el offset 11

	add ax, 32			; Bump searched entries by 1 (32 bytes per entry)

	mov di, buffer			; Apuntar a la siguiente entrada
	add di, ax

	xchg dx, cx			; Tener el CX original de vuelta
	loop next_root_entry

	mov si, file_not_found		; Si kernel no se encuentra, bail out
	call print_string
	jmp reboot


found_file_to_load:			; Fetch cluster y cargar FAT en la RAM
	mov ax, word [es:di+0Fh]	; Offset 11 + 15 = 26, contiene el 1er cluster
	mov word [cluster], ax

	mov ax, 1			; Sector 1 = primer sector del primer FAT
	call l2hts

	mov di, buffer			; ES:BX apunta a nuestro buffer
	mov bx, di

	mov ah, 2			; int 13h parámetris: leer (FAT) sectores
	mov al, 9			; Todos los 9 sectores del 1er FAT

	pusha				; Preparar para entran en bucle


read_fat:
	popa				; En caso registros son alterados por int 13h
	pusha

	stc
	int 13h				; Leer sectores usando la BIOS

	jnc read_fat_ok			; Si lectura fue OK, saltar ahead
	call reset_floppy		; Si no, resetear controlador de diskete y reintentar
	jnc read_fat			; Reseteo de diskete OK?

; ******************************************************************
fatal_disk_error:
; ******************************************************************
	mov si, disk_error		; si no, imprimir mensaje de error y reinicia.
	call print_string
	jmp reboot			; Doble error fatal


read_fat_ok:
	popa

	mov ax, 2000h			; Segmento donde cargaremos el kernel
	mov es, ax
	mov bx, 0

	mov ah, 2			; int 13h floppy lee params
	mov al, 1

	push ax				; Guardar en caso nosotros (o llamadas int) lo perdamos


; Ahora debemos cargar el FAT desde el disco. Aquí es como encontramos donde inicia:
; FAT cluster 0 = media descriptor = 0F0h
; FAT cluster 1 = filler cluster = 0FFh
; Cluster start = ((cluster number) - 2) * SectorsPerCluster + (start of user)
;               = (cluster number) + 31

load_file_sector:
	mov ax, word [cluster]		; Convertir sector a lógico
	add ax, 31

	call l2hts			; Hacer parámetros apropiados para int 13h

	mov ax, 2000h			; Set buffer past what we've already read
	mov es, ax
	mov bx, word [pointer]

	pop ax				; Guardar en caso nosotros (o llamadas int) lo perdamos.
	push ax

	stc
	int 13h

	jnc calculate_next_cluster	; Si no hay error...

	call reset_floppy		; Si no, resetear diskete y reintentar
	jmp load_file_sector


	; En el FAT, valores de clusteres están guardados en 12 bits, así que tenemos
	; que hacer un par de mates para descubrir si es que estamos trabajando con un
	; byte y 4 bits del byte siguiente -- o los últimos 4 bits de un byte y el byte
	; siguiente!

calculate_next_cluster:
	mov ax, [cluster]
	mov dx, 0
	mov bx, 3
	mul bx
	mov bx, 2
	div bx				; DX = [cluster] mod 2
	mov si, buffer
	add si, ax			; AX = word in FAT for the 12 bit entry
	mov ax, word [ds:si]

	or dx, dx			; Si DX = 0 [cluster] es par; if DX = 1 entonces es impar

	jz even				; Si [cluster] es par, echar los últimos 4 bits de la
					; palabra con el siguiente cluster; si impar, echar los 
                                        ; primeros 4 bits

odd:
	shr ax, 4			; Shift out first 4 bits (ellos pertenecen a una otra entrada)
	jmp short next_cluster_cont


even:
	and ax, 0FFFh			; Mask out final 4 bits


next_cluster_cont:
	mov word [cluster], ax		; Guardar cluster

	cmp ax, 0FF8h			; FF8h = marcador de fin de archivo en FAT12
	jae end

	add word [pointer], 512		; Increase buffer pointer 1 sector length
	jmp load_file_sector


end:					; Ya tenemos el archivo por cargar!
	pop ax				; Limpiar el stack (AX was pushed anteriormente)
	mov dl, byte [bootdev]		; Dar al kernel el boot device info

	jmp 2000h:0000h			; Saltar al punto de entrada al kernel cargado!


; ------------------------------------------------------------------
; BOOTLOADER SUBROUTINES

reboot:
	mov ax, 0
	int 16h				; Espera para keystroke
	mov ax, 0
	int 19h				; Reinicia el sistema


print_string:				; Texto de salida en SI a la pantalla
	pusha

	mov ah, 0Eh			; int 10h teletype function

.repeat:
	lodsb				; Obtener carácter de texto
	cmp al, 0
	je .done			; Si el carácter es 0, fin del texto
	int 10h				; Si no, imprimirlo
	jmp short .repeat

.done:
	popa
	ret


reset_floppy:		; IN: [bootdev] = boot device; OUT: carry set on error
	push ax
	push dx
	mov ax, 0
	mov dl, byte [bootdev]
	stc
	int 13h
	pop dx
	pop ax
	ret


l2hts:			; Calcular ajustes de cabecera, track y sector para int 13h
			; IN: sector lógico in AX, OUT: registros correctos para int 13h
	push bx
	push ax

	mov bx, ax			; Guardar sector lógico

	mov dx, 0			; Primero el sector
	div word [SectorsPerTrack]
	add dl, 01h			; Sectores físicos inician en 1
	mov cl, dl			; Sectores pertenecen en CL para int 13h
	mov ax, bx

	mov dx, 0			; Ahora calcular la cabecera
	div word [SectorsPerTrack]
	mov dx, 0
	div word [Sides]
	mov dh, dl			; Cabecera/lado
	mov ch, al			; Track

	pop ax
	pop bx

	mov dl, byte [bootdev]		; Poner dispositivo correcto

	ret


; ------------------------------------------------------------------
; STRINGS AND VARIABLES

	kern_filename	db "KERNEL  BIN"	; YogiOS kernel filename

	disk_error	db "Error de diskete! Presionar cualquier tecla...", 0
	file_not_found	db "KERNEL.BIN no encontrado!", 0

	bootdev		db 0 	; Boot device number
	cluster		dw 0 	; Cluster del archivo que queremos cargar
	pointer		dw 0 	; Apuntador al Buffer, para cargar el kernel


; ------------------------------------------------------------------
; END OF BOOT SECTOR AND BUFFER START

	times 510-($-$$) db 0	; Pad remainder of boot sector with zeros
	dw 0AA55h		; Boot signature (DO NOT CHANGE!)


buffer:				; Disk buffer begins (8k after this, stack starts)


; ==================================================================

