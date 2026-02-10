; =============================================================================
; YogiOS -- El kernel del Yogi Operating System
; Copyright (C) 2026 FAEH Premium
;
; Esto es cargado desde el drive por BOOTLOAD.BIN, como KERNEL.BIN.
; Primero tenemos los system call vectors, que inician en un punto estático
; para que usen los programas. Siguiendo lo que es el código del kernel
; principal y también código adicional de llamadas al sistema es incluído.
; =============================================================================


	BITS 16

	%DEFINE YOGIOS_VER '0.1'	; Número de versión del SO
	%DEFINE YOGIOS_API_VER 1	; Versión API para que chequeen los
                                        ; programas

	; Esta es la ubicación en RAM para operaciones de disco del kernel, 24K
	; después del punto donde el kernel ha sido cargado; es 8K en tamaño,
	; porque programas externos cargan después de eso en el punto de 32K:

	disk_buffer	equ	24576


; ------------------------------------------------------------------
; OS CALL VECTORS -- Ubicaciones estáticas para system call vectors
; Nota: estos no pueden ser movidos, o romperán las calls!

; Los comentarios muestran ubicaciones exactas de instrucciones en esta
; sección, y son usados en programas/yogidev.inc así que un programa externo
; puede usar una llamada al sistema de YogiOS sin tener que conocer su posición
; exacta en el código fuente del kernel...

os_call_vectors:
	jmp os_main			; 0000h -- Called from bootloader
	jmp os_print_string		; 0003h
	jmp os_move_cursor		; 0006h
	jmp os_clear_screen		; 0009h
	jmp os_print_horiz_line		; 000Ch
	jmp os_print_newline		; 000Fh
	jmp os_wait_for_key		; 0012h
	jmp os_check_for_key		; 0015h
	jmp os_int_to_string		; 0018h
	jmp os_speaker_tone		; 001Bh
	jmp os_speaker_off		; 001Eh
	jmp os_load_file		; 0021h
	jmp os_pause			; 0024h
	jmp os_fatal_error		; 0027h
	jmp os_draw_background		; 002Ah
	jmp os_string_length		; 002Dh
	jmp os_string_uppercase		; 0030h
	jmp os_string_lowercase		; 0033h
	jmp os_input_string		; 0036h
	jmp os_string_copy		; 0039h
	jmp os_dialog_box		; 003Ch
	jmp os_string_join		; 003Fh
	jmp os_get_file_list		; 0042h
	jmp os_string_compare		; 0045h
	jmp os_string_chomp		; 0048h
	jmp os_string_strip		; 004Bh
	jmp os_string_truncate		; 004Eh
	jmp os_bcd_to_int		; 0051h
	jmp os_get_time_string		; 0054h
	jmp os_get_api_version		; 0057h
	jmp os_file_selector		; 005Ah
	jmp os_get_date_string		; 005Dh
	jmp os_send_via_serial		; 0060h
	jmp os_get_via_serial		; 0063h
	jmp os_find_char_in_string	; 0066h
	jmp os_get_cursor_pos		; 0069h
	jmp os_print_space		; 006Ch
	jmp os_dump_string		; 006Fh
	jmp os_print_digit		; 0072h
	jmp os_print_1hex		; 0075h
	jmp os_print_2hex		; 0078h
	jmp os_print_4hex		; 007Bh
	jmp os_long_int_to_string	; 007Eh
	jmp os_long_int_negate		; 0081h
	jmp os_set_time_fmt		; 0084h
	jmp os_set_date_fmt		; 0087h
	jmp os_show_cursor		; 008Ah
	jmp os_hide_cursor		; 008Dh
	jmp os_dump_registers		; 0090h
	jmp os_string_strincmp		; 0093h
	jmp os_write_file		; 0096h
	jmp os_file_exists		; 0099h
	jmp os_create_file		; 009Ch
	jmp os_remove_file		; 009Fh
	jmp os_rename_file		; 00A2h
	jmp os_get_file_size		; 00A5h
	jmp os_input_dialog		; 00A8h
	jmp os_list_dialog		; 00ABh
	jmp os_string_reverse		; 00AEh
	jmp os_string_to_int		; 00B1h
	jmp os_draw_block		; 00B4h
	jmp os_get_random		; 00B7h
	jmp os_string_charchange	; 00BAh
	jmp os_serial_port_enable	; 00BDh
	jmp os_sint_to_string		; 00C0h
	jmp os_string_parse		; 00C3h
	jmp os_run_basic		; 00C6h
	jmp os_port_byte_out		; 00C9h
	jmp os_port_byte_in		; 00CCh
	jmp os_string_tokenize		; 00CFh


; ------------------------------------------------------------------
; INICIO DEL CÓDIGO PRINCIPAL DEL KERNEL

os_main:
	cli	; Limpia interruptores
	mov ax, 0
	mov ss, ax ; Poner el segmento stack y apuntador
	mov sp, 0FFFFh
	sti				; Restaurar interruptores

	cld ; La dirección predeterminada para operaciones de texto será 'up' - incrementando dirección en RAM

	mov ax, 2000h		; Poner todos los segmentos para coincidir donde el kernel
	mov ds, ax			; está cargado. Después de eso, no necesitaremos
	mov es, ax			; fastidiarnos con segmentos no más, como YogiOS y sus
	mov fs, ax			; programas viven enteramente en 64K
	mov gs, ax

	cmp dl, 0
	je no_change
	mov [bootdev], dl		; Guardar el número del boot device
	push es
	mov ah, 8			; Obtener parámetros del drive
	int 13h
	pop es
	and cx, 3Fh			; Número máximo de sector
	mov [SecsPerTrack], cx		; Números de sector incian en 1
	movzx dx, dh			; Número máximo de cabecera
	add dx, 1			; Números de cabecera incian en 0 - añadir 1 para el total
	mov [Sides], dx

no_change:
	mov ax, 1003h			; Poner texto de salida con ciertos atributos
	mov bx, 0			; to be bright, and not blinking
	int 10h

	call os_seed_random		; Generador de número aleatorio por semilla


	; Vamos a ver si hay un archivo llamado AUTORUN.BIN y ejecutarlo si es que sí,
	; antes de ir al menú de lanzador de programas

	mov ax, autorun_bin_file_name
	call os_file_exists
	jc no_autorun_bin		; Saltar las siguientes tres líneas si AUTORUN.BIN no existe

	mov cx, 32768			; Si no, cargar el programa al RAM...
	call os_load_file
	jmp execute_bin_program		; ...y moverlo a la parte ejecutable


	; O más bien habrá un archivo AUTORUN.BAS?

no_autorun_bin:
	mov ax, autorun_bas_file_name
	call os_file_exists
	jc option_screen		; Saltar la sección siguiente si AUTORUN.BAS no existe

	mov cx, 32768			; Si no, cargar el programa en el RAM
	call os_load_file
	call os_clear_screen
	mov ax, 32768
	call os_run_basic		; Correr el intérprete BASIC del kernel

	jmp app_selector		; E ir al menú selector de aplicaciones cuando BASIC termine


	; Ahora mostramos una caja de diálogo ofreciendo al usuario la opción de
	; un selector de progrmaas menu-driven, o una interfaz a línea de comando

option_screen:
	mov ax, os_init_msg		; Poner la pantalla de bienvenida
	mov bx, os_version_msg
	mov cx, 10011111b		; Color: texto blanco en fondo celeste
	call os_draw_background

	mov ax, dialog_string_1		; Pedir si el usuario quiere el selector
	mov bx, dialog_string_2         ; de aplicaciones o líneas de comando
	mov cx, dialog_string_3
	mov dx, 1			; Queremos una caja de diálogo con dos opciones (OK o Cancelar)
	call os_dialog_box

	cmp ax, 1			; Si OK (opción 0) escogido, iniciar selector de apps
	jne near app_selector

	call os_clear_screen		; Si no limpiar pantalla e iniciar el CLI
	call os_command_line

	jmp option_screen		; Ofrecer menu/CLI opciones después CLI haya salido.


	; Data for the above code...

	os_init_msg		db 'Bienvenido a YogiOS', 0
	os_version_msg		db 'Version ', YOGIOS_VER, 0

 dialog_string_1		db 'Gracias por probar YogiOS! Por favor, se-', 0
	dialog_string_2		db 'leccionar una opcion: OK para el menu de', 0
	dialog_string_3		db 'programas, Cancelar para lineas de comando', 0


app_selector:
	mov ax, os_init_msg		; Dibujar diseño de pantalla principal
	mov bx, os_version_msg
	mov cx, 10011111b		; Color: texto blanco en fondo celeste
	call os_draw_background

	call os_file_selector		; Hacer al usuario seleccionar un archivo, y guardar
					; la ubicación del texto resultante en AX
					; (otros registros son indeterminados)

	jc option_screen		; Regresar a la pantalla de escogida CLI/menu si Esc presionado

	mov si, ax			; El usuario trató de correr 'KERNEL.BIN'?
	mov di, kern_file_name
	call os_string_compare
	jc no_kernel_execute		; Mostrar un mensaje de error si es que sí.


	; Luego, necesitamos chequear que el programa que estamos tratando de correr es
	; válido -- en otras palabras, que tiene la extensión .BIN

	push si				; Guardar nombre de archivo temporalmente

	mov bx, si
	mov ax, si
	call os_string_length

	mov si, bx
	add si, ax			; SI ahora apunta al final del nombre de archivo...

	dec si
	dec si
	dec si				; ...y ahora a iniciar la extensión!

	mov di, bin_ext
	mov cx, 3
	rep cmpsb			; Son los últimos 3 carácteres 'BIN'?
	jne not_bin_extension		; Si no, sería un '.BAS'

	pop si				; Restaurar nombre de archivo


	mov ax, si
	mov cx, 32768			; Donde cargar el archivo de programa
	call os_load_file		; Cargar nombre de archivo apuntado por AX


execute_bin_program:
	call os_clear_screen		; Limpiar pantalla antes de correr

	mov ax, 0			; Limpiar todos los registros
	mov bx, 0
	mov cx, 0
	mov dx, 0
	mov si, 0
	mov di, 0

	call 32768			; Llamar el código del programa externo,
					; cargado al segundo segmento de 32K
					; (el programa debe terminar en 'ret')

	call os_clear_screen		; Cuando terminado, limpiar pantalla
	jmp app_selector		; y volver a la lista de programas


no_kernel_execute:			; Advertencia sobre tratando de ejecutar el kernel!
	mov ax, kerndlg_string_1
	mov bx, kerndlg_string_2
	mov cx, kerndlg_string_3
	mov dx, 0			; Un botón para la caja de diálogo
	call os_dialog_box

	jmp app_selector		; Iniciar de nuevo...


not_bin_extension:
	pop si				; We pushed durante el chequeo de la extensión .BIN

	push si				; Guardarlo de nuevo en caso de error...

	mov bx, si
	mov ax, si
	call os_string_length

	mov si, bx
	add si, ax			; SI ahora apunta al fin de nombre de archivo...

	dec si
	dec si
	dec si				; ...y ahora a iniciar la extensión!

	mov di, bas_ext
	mov cx, 3
	rep cmpsb			; Son los últimos 3 carácteres 'BAS'?
	jne not_bas_extension		; Si no, sale error


	pop si

	mov ax, si
	mov cx, 32768			; Donde cargar el archivo de programa
	call os_load_file		; Cargar nombre de archivo apuntado por AX

	call os_clear_screen		; Limpiar pantalla antes de correr

	mov ax, 32768
	mov si, 0			; No parámetros para pasar
	call os_run_basic		; Y correr nuestro intérprete BASIC en el códgio!

	mov si, basic_finished_msg
	call os_print_string
	call os_wait_for_key

	call os_clear_screen
	jmp app_selector		; y volver a la lista de programas


not_bas_extension:
	pop si

	mov ax, ext_string_1
	mov bx, ext_string_2
	mov cx, 0
	mov dx, 0			; Un botón para la caja de diálogo
	call os_dialog_box

	jmp app_selector		; Iniciar de nuevo...


	; Y ahora datos para el código antes mencionado...

	kern_file_name		db 'KERNEL.BIN', 0

	autorun_bin_file_name	db 'AUTORUN.BIN', 0
	autorun_bas_file_name	db 'AUTORUN.BAS', 0

	bin_ext			db 'BIN'
	bas_ext			db 'BAS'

	kerndlg_string_1	db 'No se pudo cargar y ejecutar el kernel de YogiOS!', 0
	kerndlg_string_2	db 'KERNEL.BIN es el corazón de YogiOS, y', 0
	kerndlg_string_3	db 'no es un programa normal.', 0

	ext_string_1		db 'Extensión del archivo inválido! Solo', 0
	ext_string_2		db 'puedes ejecutar programas .BIN o .BAS.', 0

	basic_finished_msg	db '>>> Programa BASIC terminado -- presionar una tecla', 0


; ------------------------------------------------------------------
; VARIABLES DE SISTEMA -- Ajustes para programas y llamadas a sistema


	; Formateo de hora y fecha

	fmt_12_24	db 0		; No-cero = formato 24-hr

	fmt_date	db 0, '/'	; 0, 1, 2 = M/D/Y, D/M/Y or Y/M/D
					; Bit 7 = usa nombre para meses
					; Si bit 7 = 0, segundo byte = carácter separador


; ------------------------------------------------------------------
; FEATURES -- Code to pull into the kernel


	%INCLUDE "features/cli.asm"
 	%INCLUDE "features/disk.asm"
	%INCLUDE "features/keyboard.asm"
	%INCLUDE "features/math.asm"
	%INCLUDE "features/misc.asm"
	%INCLUDE "features/ports.asm"
	%INCLUDE "features/screen.asm"
	%INCLUDE "features/sound.asm"
	%INCLUDE "features/string.asm"
	%INCLUDE "features/basic.asm"


; ==================================================================
; FIN DEL KERNEL
; ==================================================================

