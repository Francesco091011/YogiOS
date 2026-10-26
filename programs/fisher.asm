;=====================================================================
;
;   Pescador de aguas profundas
;   
;   Escrito por Jasper Ziller (jziller@maine.rr.com)
;   Version 1.0
;
;   Atrapa tantos peces como puedas antes de perder los 10 anzuelos.
;      
;   El movimiento de cada pez se cambia modificando su mascara de bits
;   en el arreglo de objetos. Se combina con un contador de un byte que
;   aumenta en cada ciclo. Si el resultado es 0, el pez no se mueve.
;
;   El valor de cada pez tambien se almacena en el arreglo de objetos.
;
;=====================================================================

%define reclen  8        ;object table record length
%define hlimit  12       ;max hook can be from boat
%define obcnt   12       ;count of total objects in array
%define fishcnt 10       ;number of fish

;---------------------------------------------
;Cambie estos valores para ubicar la ventana del registro de pesca.
; Esquina superior izquierda predeterminada: columna 19, fila 4.

%define lbcol 19        ;col        
%define lbrow 4         ;row

;--------------------------------

;No cambiar estos valores.
%define lbwidth 42      ;width
%define lbbot lbrow+18  ;height



        bits 16
        %include "mikedev.inc" ;MikeOS Include file
        org 32768              ;MikeOS program area

start:  call init               ;initialize game

        ;bucle del juego

loop:   call inp                ;check for keypress
        cmp ax,011Bh            ;was it Esc ?
        je gameover             ;if yes, exit game

        call move_obs           ;move objects (ax must contain scancode)
        call coll               ;check for collisions
        call score              ;calc current score
        call drawscreen         ;refresh screen

        mov ax,1                ;set game speed 
        call os_pause   

        mov al,[goflag]         ;check game over flag
        cmp al,1               
        je gameover             ;game over, exit
        jmp loop                

        ;fin del bucle del juego

;------------------------------------------------
;Inicializar el juego

init:   
        call os_clear_screen
        call os_hide_cursor 
        call start_screen
        call os_wait_for_key

        cmp ax,011Bh            ;Escaping before starting game?
        je gameover             ;if yes, exit game

        call os_clear_screen

        ;dibujar el cielo
        mov bl,0x70             ;color
        mov dl,2                ;x start
        mov dh,1                ;y start
        mov si,76               ;width
        mov di,12               ;y end
        call os_draw_block      ;draw
                
        ;mostrar el puntaje
        mov dl,4                ;col
        mov dh,2                ;row
        call os_move_cursor
        mov si,scmsg            
        call os_print_string

        ;mostrar los anzuelos restantes
        mov dl,4                ;col
        mov dh,3                ;row
        call os_move_cursor
        mov si,hkmsg            
        call os_print_string

        call drawscreen         ;draw the rest of the screen
        ret

;------------------------------------------------
; Dibujar la pantalla inicial

start_screen:

        ;fondo de la pantalla
        mov ax,boat             ;boat graphic at top  
        add ax,3                ;graphic offset
        mov bx,credit           ;credit at bottom
        mov cx,0x10             ;color
        call os_draw_background

        ;fondo del bloque de mensajes
        mov bl,0x70             
        mov dl,15
        mov dh,6
        mov si,50
        mov di,20
        call os_draw_block     

        ;mostrar las instrucciones
pmsg:   mov dl,16               ;col
        mov dh,6                ;row
        xor cl,cl
        mov si,intro            ;message pointer
.loop   cmp cl,11               ;number of lines in message
        je .exit
        xor ax,ax
        mov al,byte [si]        ;get number of chars in line
        inc si                  ;point to string
        inc dh                  ;set to next row
        call os_move_cursor
        call os_print_string
        add si,ax               ;point to next row in message
        inc cl
        jmp .loop
.exit   ret

;------------------------------------------------
;Dibujar la pantalla
;
;Se ejecuta en cada ciclo del juego.

drawscreen:

        ;dibujar el oceano -----------------------

        mov bl,0x10
        mov dl,2
        mov dh,12
        mov si,76
        mov di,24
        call os_draw_block     
               
        ;borrar el sedal y el anzuelo ------------

        mov bl,0x10             ;ocean color
        mov dl,[boat]           ;boat x
        mov dh,[boat+1]         ;boat y
        inc dh                  ;just under boat
        mov si,1                ;one column wide
        mov di,24               ;to bottom of ocean
        call os_draw_block      ;draw ocean
       
        ;dibujar los objetos del arreglo ----------

.obs    xor cl,cl               ;loop counter
        mov bx,objects          ;object array
.obloop cmp cl,obcnt            ;last object?
        je .line
        mov dx,[bx+0]           ;x and y values (as word)
        call os_move_cursor
        mov si,bx               ;print graphic
        add si,3                ;graphic offset
        call os_print_string
        add bx,reclen           ;next object
        inc cl                  ;loop counter
        jmp .obloop

        ;dibujar el sedal entre el bote y el anzuelo

.line   mov al,[hook+1]         ;check if hook is up
        sub al,[boat+1]         ;y position
        cmp al,1                
        je .score               ;all reeled in
        mov dl,[boat]           ;boat x for line x
        mov dh,[boat+1]         ;boat y + 1 for line start
        inc dh                  ;first line segment
.loop   cmp dh,[hook+1]         ;is it at hook yet?
        je .score
        call os_move_cursor
        mov si,line             ;line graphic
        call os_print_string
        inc dh
        jmp .loop

        ;borrar puntaje y cantidad de anzuelos -----

.score  mov bl,0x70             ;sky color
        mov dl,17
        mov dh,2
        mov si,6
        mov di,4
        call os_draw_block     

        ;mostrar el puntaje -----------------------

        mov dl,17               ;col
        mov dh,2                ;row
        call os_move_cursor
        mov ax,[total]
        call os_int_to_string
        mov si,ax
        call os_print_string

        ;mostrar los anzuelos restantes ------------

        mov dl,17               ;col
        mov dh,3                ;row
        call os_move_cursor
        mov ax,[hooks]
        call os_int_to_string
        mov si,ax
        call os_print_string

        ret

;------------------------------------------------
;Obtener el codigo de tecla si se pulsa una tecla.

inp:    mov ah,1        ;check for key press
        int 16h         
        jz .nokey       ;no key pressed
        xor ah,ah       ;get key from buffer into al
        int 16h
        jmp .exit
.nokey  xor ax,ax       ;set return to 0
.exit   ret

;------------------------------------------------
; Mover los objetos.
; Llamar con el codigo de tecla en AX.

move_obs:
        ;entrada del usuario
        cmp ax,5000h            ;down arrow
        je .down
        cmp ax,4800h            ;up arrow
        je .up
        jmp movefish

.down   mov al,[hook+1]         ;check hook limit
        sub al,[boat+1]
        cmp al,hlimit
        je  movefish            ;at bottom of sea
        inc byte [hook+1]       ;lower hook
        jmp movefish
.up     mov al,[hook+1]         ;check hook limit
        sub al,[boat+1]
        cmp al,1                            
        je  movefish            ;all reeled in
        dec byte [hook+1]       ;raise hook                
        jmp movefish

movefish:
        inc byte [behav]        ;inc behavior byte
        xor cl,cl               ;loop counter
        mov bx,fish             ;fish array
.obloop cmp cl,fishcnt          ;last fish?
        je .exit
        mov al,[behav]
        and al,[bx+2]           ;fish behavior mask
        cmp al,0
        je .endl                ;doesn't move this loop
        mov al,[bx+6]           ;direction flag
        cmp al,0                ;0=east, 1=west
        je .eastf
.westf  mov al,[bx+0]           ;x position
        cmp al,2                ;check if at start of screen
        ja .wmove
        mov byte [bx+0], 77     ;reset to start
        jmp .endl
.wmove  dec al
        mov [bx+0],al
        jmp .endl
.eastf  mov al,[bx+0]           ;x position
        cmp al,77               ;check if at end of screen
        jb .emove
        mov byte [bx+0], 2      ;reset to start
        jmp .endl
.emove  inc al
        mov [bx+0],al
        jmp .endl
.endl   add bx,reclen           ;next fish 
        inc cl                  ;loop counter
        jmp .obloop
.exit   ret
                                             
;------------------------------------------------
; Colisiones

; Colisiones posibles:
;  el pez enganchado llega al bote (puntos)
;  un pez toca un anzuelo vacio (captura)
;  un pez toca el sedal (se pierde el anzuelo)

;  al capturar un pez, reemplazar el dibujo del anzuelo por el del pez.

        ;el pez enganchado llega al bote ---------

coll:   mov al,[boat+1]         ;y pos of boat
        inc al                  ;just below
        cmp al,[hook+1]         ;is hook right under the boat?
        jne hkcoll              ;no, next collision
        mov al,[hook+3]         ;is this a hook
        cmp al,0xA8             ;or a fish
        je hkcoll               ;no, next collision

        ;buscar el pez capturado
.obs    xor cl,cl               ;loop counter
        mov bx,fish             ;fish array
.obloop cmp cl,fishcnt          ;last fish?
        je hkcoll
        cmp al,[bx+3]           ;is this our fish?
        jne .eloop
        inc byte [bx+5]         ;increment caught count
        mov [hook+3],byte 0xA8  ;reset hook
        jmp hkcoll              ;done
.eloop  add bx,reclen           ;next object
        inc cl                  ;loop counter
        jmp .obloop

        ;¿un pez toco un anzuelo vacio? -----------

hkcoll: xor cl,cl               ;loop counter
        mov bx,fish             ;fish array
.obloop cmp cl,fishcnt          ;last object?
        je .exit
        mov al,[bx+0]           ;x and y values
        cmp al, [boat+0]        ;is the fish under the boat?
        jne .eloop              ;no, next fish
        mov al,[bx+1]           ;check y value
        cmp al,[hook+1]         ;is fish below hook?
        ja .eloop               ;fish is below hook
        je .hook                ;fish hit hook
                                ;el pez toco el sedal
.line   mov [hook+3], byte 0xA8 ;if fish on hook, drop
        mov [hook+1], byte 12   ;reset hook to boat
        dec word [hooks]        ;lost a hook
        cmp word [hooks], 0     ;check hooks left
        jne .eloop              ;still have some hooks
        mov [goflag], byte 1    ;game over :(
        jmp .exit

.hook   mov al, [hook+3]        ;is hook free?
        cmp al, 0xA8            ;hook graphic
        jne .eloop              ;a fish is already on hook
        mov al,[bx+3]           ;caught! get fish graphic
        mov [hook+3], al        ;replace hook

        cmp [bx+6], byte 1      ;which way was fish moving?
        je .west                ;1 = east bound, 0 = west bound
        mov [bx+0], byte 2      ;reset east bound fish
        jmp .eloop
.west   mov [bx+0], byte 77     ;reset west bound fish

.eloop  add bx,reclen           ;next object
        inc cl                  ;loop counter
        jmp .obloop

.exit   ret

;------------------------------------------------
;Calcular el puntaje

score:  xor dx,dx               ;running sum
        xor cl,cl               ;loop counter
        mov bx,fish             ;fish array
.obloop cmp cl,fishcnt          ;last fish?
        je .exit
        xor ax,ax
        mov al,[bx+7]           ;fish value
        mul byte [bx+5]         ;times number caught
        add dx,ax               ;add to current total
        add bx,reclen           ;next object
        inc cl                  ;loop counter
        jmp .obloop
.exit   mov [total],dx          ;set score
        ret

;------------------------------------------------
;Mostrar el registro de pesca


gameover:
        ;dibujar el borde verde
        mov bl,0x20
        mov dl,lbcol            
        mov dh,lbrow            
        mov si,lbwidth          
        mov di,lbbot            
        call os_draw_block     

        ;dibujar el panel del registro
        mov bl,0x70
        mov dl,lbcol+1
        mov dh,lbrow+1
        mov si,lbwidth-2
        mov di,lbbot-1
        call os_draw_block     

        ;mostrar el titulo del registro
        mov dl,lbcol+2
        mov dh,lbrow+2
        call os_move_cursor
        mov si,gomsg
        call os_print_string

        ;fecha
        mov dl,lbcol+27
        mov dh,lbrow+2
        call os_move_cursor
        mov ax,0x0040                   ;bit 7=1 for months, all others 0
        call os_set_date_fmt            ;for mmm/dd/yyyy
        mov bx,dtbuff                   ;set buffer pointer
        call os_get_date_string         ;get current date in bx
        mov si,bx
        call os_print_string

        ;encabezados de columna
        mov dl,lbcol+5
        mov dh,lbrow+4
        call os_move_cursor
        mov si,head1
        call os_print_string
        mov dh,lbrow+5
        call os_move_cursor
        mov si,head2
        call os_print_string

        ;mostrar los datos de cada tipo de pez
        mov dl,lbcol+5          ;first column
        mov dh,lbrow+6          ;first row 
        xor cl,cl               ;loop counter
        mov bx,fish             ;fish array
.obloop cmp cl,fishcnt          ;last fish?
        je .hold
        call os_move_cursor
        mov si,bx               ;current fish
        add si,3                ;graphic
        call os_print_string    ;show
        mov dl,lbcol+18         ;right col
        xor ax,ax
        mov al,[bx+7]           ;fish value
        call os_int_to_string   ;convert to string
        mov si,ax               ;set string pointer
        call os_string_length   ;right justify
        sub dl,al               ;by shifting back string length
        call os_move_cursor
        call os_print_string
        mov dl,lbcol+27          ;right col
        xor ax,ax
        mov al,[bx+5]           ;number caught
        call os_int_to_string   ;convert to string
        mov si,ax               ;set string pointer
        call os_string_length   ;right justify
        sub dl,al               ;by shifting back string length
        call os_move_cursor
        call os_print_string
        mov dl,lbcol+35         ;right col
        xor ax,ax
        mov al,[bx+7]           ;value
        mul byte [bx+5]         ;times number caught
        call os_int_to_string   ;convert to string
        mov si,ax               ;set string pointer
        call os_string_length   ;right justify
        sub dl,al               ;by shifting back string length
        call os_move_cursor
        call os_print_string
.eloop  add bx,reclen           ;next object
        inc dh                  ;row
        mov dl,lbcol+5          ;start col
        inc cl                  ;loop counter
        jmp .obloop
.hold   call os_wait_for_key
        cmp ax,011Bh            ;Esc key
        jne .hold
        call os_clear_screen
        jmp exit
        ret

;------------------------------------------------

exit:   call os_show_cursor
        ret    


;datos ---------------------------------------

goflag  db 0            ;0 = en curso, 1 = fin del juego
total   dw 0            ;puntaje total
hooks   dw 10           ;anzuelos restantes
behav   db 0            ;aumenta en cada ciclo del juego
line    db 0xB3,0       ;grafico de la linea desde el bote

objects:        
           ;x,y,comportamiento,grafico,terminador,capturado,direccion,valor
boat:   db 38,11,00000000b,0x9D,0,0,0,0       
hook:   db 38,12,00000000b,0xA8,0,0,0,0       
fish:   db 02,13,00010100b,0xAF,0,0,0,1   
        db 77,14,01000100b,0xF7,0,0,1,4  
        db 77,15,00000010b,0xAE,0,0,1,9       
        db 02,16,00100100b,0xE9,0,0,0,16       
        db 02,17,00000010b,0xEC,0,0,0,25       
        db 77,18,00001000b,0xED,0,0,1,36       
        db 02,19,00100000b,0xE0,0,0,0,49       
        db 77,20,00100100b,0xCF,0,0,1,64       
        db 02,21,01000000b,0xF0,0,0,0,81       
        db 77,22,00010000b,0xE5,0,0,1,100       

scmsg   db 'Puntaje total: ',0
hkmsg   db 'Anzuelos:      ',0

gomsg   db 'Registro de pesca',0
head1   db '       Valor    Numero',0
head2   db 'Pez    Valor    Capturas Puntos',0

        ;longitud de linea (incluido el cero), mensaje, cero
intro:  db 28,'Pescador de aguas profundas',0
        db 1,0
        db 43,'Atrapa peces y recojelos para ganar puntos',0
        db 44,'Cuanto mas profundo el pez, mas puntos vale',0
        db 44,'Si un pez toca el sedal, perdera un anzuelo',0
        db 45,'Al quedarse sin anzuelos, termina la partida',0
        db 1,0
        db 45,'Flecha arriba sube el anzuelo; abajo lo baja',0
        db 42,'Pulse Esc en cualquier momento para salir',0
        db 1,0
        db 26,'Pulse Intro para comenzar',0
es      db 0
credit: db 'Fuseki Games',0
dtbuff: times 64 db 0
seabed: db 0xDC,0xDC,0xDC,0xB0,0xB2,0xB0,0xB0,0xB2,0xB0,0


