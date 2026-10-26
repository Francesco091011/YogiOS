rem Dibujante ASCII, version 3.0.0 (DRAW.BAS)
rem Programa de dibujo en modo texto para YogiOS
rem Copyright (C) Joshua Beck 2002
rem Correo: mikeosdeveloper@gmail.com
rem Licencia Publica General de GNU; consulte licence.txt

rem Requiere la biblioteca MB++, version 3.2.2 o posterior
include "mbpp.bas"

initlib:
  gosub startprg
  c = 4
  h = 12
  t = 4
  z = 4
  $T = "Dibujante ASCII"
  gosub settitle
  gosub anistart
  gosub border
  
preload:
  m = ramstart
  n = 64100 - m

  cursor off

  for w = m to 63999
    poke 0 w
  next w
  
  gosub help_about

  if $1 = "" then goto nofile
  len $1 x
  if x < 5 then goto nofile
  size $1
  if r = 1 then goto nofile
  if s > n then goto nofile
  if s = 0 then goto nofile
  $3 = $1
  load $3 m
  
mainloop:
  rem ***BUCLE PRINCIPAL***
  
  e = 2
  f = 3
  gosub highlight_on
  gosub render_image
  
  do
    waitkey k
    if k = 1 then gosub moveup
    if k = 2 then gosub movedown
    if k = 3 then gosub moveleft
    if k = 4 then gosub moveright
    if k = 18 then gosub render_image
    if k = 19 then gosub savefile
    if k = 27 then gosub mainmenu
    if k > 31 and k < 127 then gosub inschar
  loop endless
  
  
render_image:
  gosub savevar
  gosub highlight_off
  
  ink 7
  for y = 3 to 23
    move 2 y
    for x = 2 to 77
      print " " ;
    next x
  next y
  
  string load $4 m
  if $4 = "AAP" then rem
  else goto invalid_file
  
  w = m + 4
  peek v w
  if v = 1 then rem
  else goto invalid_file
  w = m + 5
  peek v w
  if v = 0 then goto invalid_file
  if v > 1 then goto invalid_file
  w = m + 6
  peekint d w
  d = d + m

  w = m + 8
  peek a w
  if a = 0 then goto invalid_file
  if a > 76 then goto invalid_file

  w = m + 9
  peek b w
  if b = 0 then goto invalid_file
  if b > 21 then goto invalid_file

  w = m + 200
  string load $4 w
  $T = "Dibujante ASCII - " + $4
  gosub settitle

  w = d
  move 2 3
  for y = 1 to b
    j = y + 2
    move 2 j
    for x = 1 to a
      peek v w
      ink v
      w = w + 1
      peek v w
      print chr v ;
      w = w + 1
    next x
  next y

  gosub highlight_on
  gosub loadvar
return

invalid_file:
  $E = "Error de dibujo: formato de archivo incorrecto"
  gosub errbox
  gosub endprog
  
highlight_on:
  if o = 1 then return
  gosub savevar
  move e f
  curschar v
  curscol j
  x = j % 16
  y = 15 - x
  x = y
  j = j / 16
  y = 15 - j
  j = y * 16 + x
  ink j
  print chr v ;
  o = 1
  gosub loadvar
return

highlight_off:
  if o = 0 then return
  gosub savevar
  move e f
  curschar v
  curscol j
  x = j % 16
  y = 15 - x
  x = y
  j = j / 16
  y = 15 - j
  j = y * 16 + x
  ink j
  print chr v ;
  o = 0
  gosub loadvar
return
  
moveleft:
  if e = 2 then return
  gosub highlight_off
  e = e - 1
  gosub highlight_on
return

moveright:
  gosub savevar
  gosub highlight_off
  x = e - 1
  if a = x then goto invalid_move
  e = e + 1
  gosub highlight_on
  gosub loadvar
return

moveup:
  if f = 3 then return
  gosub highlight_off
  f = f - 1
  gosub highlight_on
return

movedown:
  gosub savevar
  gosub highlight_off
  y = f - 2
  if b = y then goto invalid_move
  f = f + 1
  gosub highlight_on
  gosub loadvar
return
  
invalid_move:
  gosub highlight_on
  gosub loadvar
return

inschar:
  gosub highlight_off
  gosub savevar
  move e f
  gosub find_key_value
  x = k % 256
  ink x
  x = k / 256
  print chr x ;
  q = k
  gosub store_data
  gosub highlight_on
  gosub loadvar
return
  
find_key_value:
  if k < 31 then k = 0
  if k > 126 then k = 0
  if k = 0 then return
  gosub savevar
  x = m + 10
  y = k - 32
  y = y * 2
  x = x + y
  peekint k x
  gosub loadvar
return
  
set_key_value:
  if k < 31 then k = 0
  if k > 126 then k = 0
  if k = 0 then return
  gosub savevar
  x = m + 10
  y = k - 32
  y = y * 2
  x = x + y
  pokeint v x
  gosub loadvar
return
  
load_data:
  gosub savevar
  x = e - 2
  y = f - 3
  j = y * a
  j = j + x
  j = j * 2
  j = j + d
  peekint q j
  gosub loadvar
return

store_data:
  gosub savevar
  x = e - 2
  y = f - 3
  j = y * a
  j = j + x
  j = j * 2
  j = j + d
  pokeint q j
  gosub loadvar
return

nofile:
  $4 = "AAP"
  string store $4 m
  w = m + 4
  poke 1 w
  w = m + 5
  poke 1 w
  w = m + 6
  pokeint 261 w
  w = m + 8
  poke 76 w
  w = m + 9
  poke 21 w
  w = m + 10
  gosub resetkey
  w = m + 200
  $4 = "Dibujo sin titulo"
  string store $4 w
  w = m + 261
  for x = 1 to 1596
    poke 7 w
    w = w + 1
    poke 0 w
    w = w + 1
  next x
goto mainloop

mainmenu:
  do
    $T = "            Menu principal"
    $5 = "               Archivo"
    $6 = "             Herramientas"
    $7 = "             Mapa de teclas"
    $8 = "                Ayuda"
    $9 = "                Salir"
    gosub menubox
    if v = 1 then gosub filemenu
    if v = 2 then gosub toolsmenu
    if v = 3 then gosub keymapmenu
    if v = 4 then gosub helpmenu
    if v = 5 then gosub endprog
  loop until v = 6
return

filemenu:
  do
    $T = "           Menu Archivo"
    $5 = "                Nuevo"
    $6 = "              Restaurar"
    $7 = "                Cargar"
    $8 = "               Guardar"
    $9 = "              Guardar como"
    gosub menubox
    if v = 1 then gosub newfile
    if v = 2 then gosub revert
    if v = 3 then gosub loadfile
    if v = 4 then gosub savefile
    if v = 5 then gosub saveas
  loop until v = 6
  v = 0
return

toolsmenu:
  do
    $T = "        Menu Herramientas"
    $5 = "                Borrar"
    $6 = "               Rellenar"
    $7 = "               Invertir"
    $8 = "          Cambiar fondo"
    $9 = "          Cambiar texto"
    gosub menubox
    if v = 1 then gosub clear
    if v = 2 then gosub fill
    if v = 3 then gosub invert
    if v = 4 then gosub setback
    if v = 5 then gosub setfore
  loop until v = 6
  v = 0
return

keymapmenu:
  do
    $T = "       Menu Mapa de teclas"
    $5 = "               Restablecer"
    $6 = "                Cargar"
    $7 = "               Guardar"
    $8 = "             Cambiar tecla"
    $9 = "          Cambiar colores"
    gosub menubox
    if v = 1 then gosub resetkey
    if v = 2 then gosub loadkey
    if v = 3 then gosub savekey
    if v = 4 then gosub changekey
    if v = 5 then gosub setmapcolour
  loop until v = 6
  v = 0
return

helpmenu:
  do
    $T = "             Menu Ayuda"
    $5 = "               Acerca de"
    $6 = "               Basicos"
    $7 = "               Archivos"
    $8 = "             Herramientas"
    $9 = "          Mapa de teclas"
    gosub menubox
    if v = 1 then gosub help_about
    if v = 2 then gosub help_basics
    if v = 3 then gosub help_files
    if v = 4 then gosub help_tools
    if v = 5 then gosub help_keymap
  loop until v = 6
  v = 0
return

newfile:
  gosub savevar
  $4 = "AAP"
  string store $4 m
  w = m + 4
  poke 1 w
  w = m + 5
  poke 1 w
  w = m + 6
  pokeint 261 w
  
  $T = "          Archivo nuevo (titulo)"
  $5 = "Que nombre quiere darle al dibujo?"
  $6 = "Hasta 35 caracteres."
  v = 1
  gosub inpbox
  $4 = $I
  w = m + 200
  string store $4 w
  
  w = m + 10
  for x = 32 to 126
    poke 7 w
    w = w + 1
    poke x w
    w = w + 1
  next x

  w = m + 261
  for x = 1 to 3192
    poke 0 w
    w = w + 1
  next x
  
  $T = "          Archivo nuevo (tamano)"
  $5 = "Cuantas columnas?"
  $6 = "Cuantas filas?"
  v = 0
  gosub dinbox
  w = m + 8
  pokeint a w
  w = m + 9
  pokeint b w
  
  gosub loadvar
  
  gosub render_image
  $3 = "" 
return

revert:
  if $3 = "" then return
  load $3 m
  gosub render_image
return

loadfile:
  $T = "             Cargar archivo"
  $5 = "Que archivo desea cargar?"
  $6 = "Solo nombres 8.3, por ejemplo foo.aap"
  v = 1
  gosub inpbox
  $4 = $I

  size $4
  if r = 1 then $E = "Error al cargar: nombre no valido"
  if r = 1 then goto errbox
  if s = 0 then $E = "Error al cargar: archivo vacio"
  if s = 0 then goto errbox
  if s > n then $E = "Error al cargar: memoria insuficiente"
  if s > n then goto errbox
  load $4 m
  $3 = $4

  string load $4 m
  if $4 = "AAP" then rem
  else $E = "Error al cargar: tipo de archivo incorrecto"
  else goto errbox
  w = m + 4
  peek v w
  if v = 0 goto badformat
  if v > 1 then goto futureversion
  w = m + 5
  if v = 0 then goto badformat
  if v > 1 then goto badformat
  w = m + 8
  peek v w
  if v > 76 then $E = "Error de archivo: no cabe en pantalla"
  if v > 76 then goto errbox
  w = m + 9
  peek v w
  if v > 21 then $E = "Error de archivo: no cabe en pantalla"
  if v > 21 then goto errbox

image_okay:
  gosub render_image
  
  gosub highlight_off
  e = 2
  f = 3
  gosub highlight_on
return

badformat:
  $E = "Error de archivo: formato incorrecto"
  goto errbox
  
futureversion:
  $T = "             Cargar archivo"
  $5 = ""
  $6 = "Este archivo parece creado con una version"
  $7 = "posterior de este programa."
  $8 = "Intentar cargarlo de todos modos?"
  $9 = ""
  gosub askbox
  if v = 1 then goto image_okay
return

savefile:
  if $3 = "" then goto saveas
  delete $3
  
  w = m + 6
  peekint v w
  j = a * b * 2 + v
  save $3 m j
  if r > 0 then $3 = ""
  if r > 0 then $E = "Fallo al guardar en el disco."
  if r > 0 then goto errbox
return

saveas:
  $T = "          Guardar archivo como..."
  $5 = "Con que nombre desea guardar el archivo?"
  $6 = "Solo nombres 8.3, por ejemplo foo.aap"
  v = 1
  gosub inpbox
  $3 = $I
goto savefile

clear:
  gosub savevar
  w = d
  for x = 1 to 1596
    poke 7 w
    w = w + 1
    poke 0 w
    w = w + 1
  next x
  
  gosub render_image
  gosub loadvar
return

fill:
  gosub savevar
  $T = "           Rellenar dibujo"
  $5 = "Que caracter desea usar?"
  $6 = "Debe estar entre 0 y 255"
  v = 0
  gosub inpbox
  w = d + 1
  for x = 1 to 1596
    poke v w
    w = w + 2
  next x
  
  gosub render_image
  gosub loadvar
return

setback:
  gosub savevar
  $T = "          Color de fondo"
  $5 = "Que color desea asignar?"
  $6 = "Debe estar entre 0 y 15"
  v = 0
  gosub inpbox
  w = d
  j = v * 16
  for x = 1 to 1596
    peek v w
    v = v % 16
    v = v + j
    poke v w
    w = w + 2
  next x
  
  gosub render_image
  gosub loadvar
return

setfore:
  gosub savevar
  $T = "          Color del texto"
  $5 = "Que color desea asignar?"
  $6 = "Debe estar entre 0 y 15"
  v = 0
  gosub inpbox
  w = d
  j = v
  for x = 1 to 1596
    peek v w
    v = v / 16
    v = v * 16
    v = v + j
    poke v w
    w = w + 2
  next x
  
  gosub render_image
  gosub loadvar
return

invert:
  gosub savevar
  w = d
  for x = 1 to 1596
    peek v w
    j = v / 16
    y = j
    j = j * 16
    v = v - j
    j = 15 - y
    j = j * 16
    v = v + j
    
    j = v % 16
    y = j
    v = v - j
    j = 15 - y
    v = v + j
    
    poke v w
    w = w + 2
  next x
  
  gosub render_image
  gosub loadvar
return

resetkey:
  gosub savevar
  w = m + 10
  for x = 32 to 126
    poke 7 w
    w = w + 1
    poke x w
    w = w + 1
  next x
  w = m + 200
  gosub loadvar
return
  
loadkey:
  $T = "        Cargar mapa de teclas"
  $5 = "Que mapa de teclas desea cargar?"
  $6 = "Solo nombres 8.3, por ejemplo foo.map"
  v = 1
  gosub inpbox
  $4 = $I
  
  size $4
  if r = 1 then $E = "Cargar mapa: no se encontro el archivo"
  if r = 1 then goto errbox
  if s > 200 then $E = "Cargar mapa: tamano incorrecto"
  if s > 200 then goto errbox

  w = m + 3500
  load $4 w
  
  string load $4 w
  if $4 = "AAP" then rem
  else goto badkeyformat
  w = w + 4
  peek v w
  if v = 1 then rem
  else goto badkeyformat
  w = w + 1
  peek v w
  if v = 2 then rem
  else goto badkeyformat
  
  w = w + 1
  j = m + 10
  for x = 1 to 190
    peek v w
    poke v j
    w = w + 1
    j = j + 1
  next x
  v = 0
return
  
badkeyformat:
  $E = "Cargar mapa: formato incorrecto"
  goto errbox
  
savekey:
  $T = "       Guardar mapa de teclas"
  $5 = "Que nombre desea darle al mapa?"
  $6 = "Solo nombres 8.3, por ejemplo foo.map"
  v = 1
  gosub inpbox

  w = m + 3500
  $4 = "AAP"
  string store $4 w
  w = w + 4
  poke 1 w
  w = w + 1
  poke 2 w

  w = w + 1
  j = m + 10
  for x = 1 to 190
    peek v j
    poke v w
    j = j + 1
    w = w + 1
  next x
  
  w = m + 3500
  $4 = $I
  save $4 w 196
  v = 0
return
  
changekey:
  gosub savevar
  x = a
  y = b
  $T = "          Cambiar tecla"
  $5 = "Ingrese el valor ASCII de la tecla"
  $6 = "Ingrese el nuevo valor de salida"
  v = 0
  gosub dinbox

  k = a
  w = b * 256
  
  $T = "          Cambiar tecla"
  $5 = "Ingrese el color de fondo"
  $6 = "Ingrese el color del texto"
  v = 0
  gosub dinbox
  
  j = a * 16
  j = j + b
  v = j + w
  gosub set_key_value
  
  a = x
  b = y
  gosub loadvar
  k = 0
return

setmapcolour:
  gosub savevar
  $T = "        Cambiar color de fondo"
  $5 = "Que color quiere para el fondo"
  $6 = "del mapa de teclas (0-15)?"
  v = 0
  gosub inpbox
  if v > 15 then v = 0

  w = m + 10
  for x = 1 to 95
    peek y w
    j = y / 16
    j = j * 16
    y = y - j
    j = v * 16
    y = y + j
    poke y w
    w = w + 2
  next x

  $T = "       Cambiar color del texto"
  $5 = "Que color quiere para el texto"
  $6 = "del mapa de teclas (0-15)?"
  v = 0
  gosub inpbox
  if v > 15 then v = 7
  
  w = m + 10
  for x = 1 to 95
    peek y w
    j = y % 16
    y = y - j
    y = y + v
    poke y w
    w = w + 2
  next x
  gosub loadvar
return
    
help_about:
  $T = "            Acerca de"
  $5 = "Dibujante ASCII, version 3.0.0"
  $6 = "Copyright (C) Joshua Beck 2012"
  $7 = "Correo: mikeosdeveloper@gmail.com"
  $8 = "Licencia GNU GPL v3"
  $9 = "Usa la biblioteca MB++, version 3.2.2"
  gosub mesbox
return

help_basics:
  $T = "             Basicos"
  $5 = "Use las flechas para desplazarse."
  $6 = "Las teclas de letras, numeros y simbolos"
  $7 = "dibujan el caracter correspondiente."
  $8 = "Pulse Esc para abrir el menu principal"
  $9 = "y para salir de los menus."
  gosub mesbox
return

help_tools:
  $T = "          Herramientas"
  $5 = "El menu Herramientas permite hacer"
  $6 = "cambios a gran escala en el dibujo."
  $7 = "Puede borrarlo, rellenarlo con un"
  $8 = "caracter, invertirlo y cambiar todos"
  $9 = "los colores."
  gosub mesbox
return

help_keymap:
  $T = "          Mapa de teclas"
  $5 = "Cada tecla imprimible corresponde a"
  $6 = "un caracter. De forma predeterminada"
  $7 = "coincide con su simbolo y usa el color"
  $8 = "blanco, pero puede personalizar estos"
  $9 = "valores."
  gosub mesbox
return

help_files:
  $T = "            Archivos"
  $5 = "El programa usa su propio formato."
  $6 = "Admite titulos, colores, tamanos"
  $7 = "personalizados y mapas de teclas."
  $8 = "Guarde dibujos desde el menu Archivo"
  $9 = "y mapas desde el menu correspondiente."
  gosub mesbox
return

