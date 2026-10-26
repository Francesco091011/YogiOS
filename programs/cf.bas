rem Vuelo cosmico (CF.BAS)
rem Creado por Joshua Beck
rem Version 2.0.2
rem Publicado bajo la Licencia Publica General de GNU v3
rem Correo: mikeosdeveloper@gmail.com
goto start
    
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

start:
  cls

  rem ***Texto de introduccion***
  gosub intro  

  cls

  rem ***Dibujar los bordes***
  gosub drawscreen

  rem ***Mostrar el caracter***
  ink 8
  move 40 24
  print chr 202 ;
  ink 7

  e = 0
  f = 0

  rem ***Obtener la hora de inicio***
  t = timer

  rem ***Ubicar el caracter donde se imprimio***
  p = 40

  rem ***Comenzar con una nave gris***
  c = 8
  cursor off

play:
  do
    rem ***Bucle principal del juego***
    do
      rem ***Desplazar la pantalla cada 0,5 segundos o 10 pulsos***
      n = timer
      n = n - 6 

      rem ***Procesar el movimiento mientras esperamos***
      rem ***Asi el personaje responde rapidamente***
      getkey k

      rem ***Terminar si se pulsa Esc***
      if k = 27 then goto endgame

      rem ***Convertir a minuscula la letra mayuscula***
      if k > 64 and k < 91 then k = k + 32

      rem ***Mover el personaje si se pulsa una tecla de direccion***
      if k = 'a' then gosub goleft
      if k = 'd' then gosub goright

      if k = ' ' then gosub fireweapon

      rem ***Repetir hasta que haya que desplazar la pantalla***
      n = n + 1
    loop until n > t

    rem ***Obtener la hora del siguiente ciclo***
    t = timer

    rem ***Desplazar el area de juego una linea hacia abajo***
    gosub scrollscreen

    rem ***Mostrar el nuevo puntaje y los modificadores***
    gosub printscore

    rem ***Colocar un objeto en la linea vacia***
    y = 0
    gosub placebonus

    rem ***Agregar objetos segun el puntaje***
    rem ***La mayoria seran perjudiciales***
    if s > 1999 then gosub placebonus
    if s > 4999 then gosub placebonus
    if s > 9999 then gosub placebonus

    rem ***Cambiar el color del personaje segun el puntaje***
    gosub colourchange

    rem ***Volver a mostrar el personaje***
    ink c
    move p 24
    print chr 202 ;
    ink 7

    rem ***Reducir los beneficios, si los hay***
    if e > 0 then e = e - 1
    if f > 0 then f = f - 1

    rem ***Repetir hasta salir o perder***
  loop endless
  cursor on
end

goleft:
  rem ***Asegurarse de que el personaje siga en pantalla***
  if p < 31 then return

  rem ***Borrar la posicion actual***
  move p 24
  print " " ;

  rem ***Moverse a la nueva posicion***
  p = p - 1
  move p 24
  curschar b
  gosub checkbonus

  rem ***Mostrar el personaje con el color correcto***
  ink c
  print chr 202 ;
  ink 7
return

goright:
  rem ***Asegurarse de que el personaje permanezca en pantalla***
  if p > 49 then return

  rem ***Borrar la posicion actual***
  move p 24
  print " " ;

  rem ***Moverse a la nueva posicion***
  p = p + 1
  move p 24

  rem ***Buscar objetos y aplicar sus efectos***
  curschar b
  gosub checkbonus

  rem ***Mostrar el personaje con el color correcto***
  ink c
  print chr 202 ;
  ink 7
return

colourchange:
  rem ***Elegir el color segun los puntos obtenidos***
  if s < 100 then c = 8
  if s > 99 then c = 7
  if s > 199 then c = 15
  if s > 499 then c = 14
  if s > 999 then c = 12
  if s > 1999 then c = 9
  if s > 4999 then c = 11
  if s > 9999 then c = 13
return

fireweapon:
  q = 0
  if s > 99 then q = q + 1
  if s > 199 then q = q + 1
  if s > 499 then q = q + 1
  if s > 999 then q = q + 1
  if s > 1999 then q = q + 1
  if s > 4999 then q = q + 1
  if s > 9999 then q = q + 1
  if q = 0 then return
  if e > 0 then q = q + 1
  if e > 0 then e = e - 1
  ink c
  if q = 1 then for r = 0 to 3
  if q = 2 then for r = 0 to 7
  if q = 3 then for r = 0 to 11
  if q > 3 then for r = 0 to 23
    y = 23 - r
    move p y
    print "|" ;
    if q > 4 then gosub extrawp
    y = y % 4
    if y = 3 then pause 1
  next r
  pause 1
  t = timer
  ink 7
  if q = 1 then for r = 0 to 3
  if q = 2 then for r = 0 to 7
  if q = 3 then for r = 0 to 11
  if q > 3 then for r = 0 to 23
    y = 23 - r
    move p y
    print " " ;
    if q > 4 then gosub extrawp
  next r
  move p 24
  gosub colourchange
  ink c
  print chr 202 ;
  ink 7
  if s > 99 then s = s - 100
  if s > 1999 then s = s - 200
  if s > 4999 then s = s - 500
  if s > 9999 then s = s - 1000
  gosub scrollscreen
return

extrawp:
  move p y
  curschar b
  v = p - 1
  move v y
  if v > 29 then print chr b ;
  v = p + 1
  move v y
  if v < 51 then print chr b ;
  if q = 5 then return
  v = p - 2
  move v y
  if v > 29 then print chr b ;
  v = p + 2
  move v y
  if v < 51 then print chr b ;
  if q = 6 then return
  v = p - 3
  move v y
  if v > 29 then print chr b ;
  v = p + 3
  move v y
  if v < 51 then print chr b ; 
  v = p - 4
  move v y
  if v > 29 then print chr b ;
  v = p + 4
  move v y
  if v > 51 then print chr b ;
return

checkbonus:
  rem ***Asegurarse de que exista un objeto***
  if b = 0 then return
  if b = 32 then return

  rem ***Comprobar el efecto del objeto***
  i = 0
  j = 0

  rem ***Objetos beneficiosos***
  if b = 224 then j = 10
  if b = 225 then j = 20
  if b = 227 then j = 50
  if b = 228 then j = 100
  if b = 172 then j = 250
  if b = 171 then j = 500
  if b = 252 then j = 1000
  if b = 253 then j = 2000

  rem ***Objetos perjudiciales***
  if b = 35 then i = 50
  if b = 168 then i = 100
  if b = 254 then i = 200
  if b = 64 then i = 500
  if b = 33 then i = 1000
  if b = 19 then i = 2000

  rem ***Cambiar la cantidad de modificadores activos***
  if m = 1 then j = j + 10
  if m = 2 then j = j + 20
  if m = 3 then j = j + 50
  if m = 4 then j = j * 2
  if m = 4 then i = i * 3
  if m = 5 then j = j * 2
  if m = 5 then i = i * 3

  rem ***Si hay un modificador activo, reducir sus usos en uno***
  if m > 0 then l = l - 1

  rem ***Eliminar el modificador cuando sus usos lleguen a cero***
  if l = 0 then m = 0

  rem ***Eliminar el modificador si se recoge un objeto negativo***
  if i > 0 then m = 0

  rem ***Buscar mejoras y crear modificadores***
  if b = 43 then m = 2
  if b = 43 then l = 10
  if b = 36 then m = 3
  if b = 36 then l = 10
  if b = 42 then m = 5
  if b = 42 then l = 20

  rem ***Bonificaciones de armas***
  if b = 94 then e = e + 5

  rem ***Bonificaciones de escudo***
  if b = 62 then f = f + 50

  rem ***Sumar al puntaje el total positivo***
  if i = 0 then s = s + j

  rem ***Comprobar que el puntaje supere el total negativo***
  rem ***Si no, el jugador pierde***
  if i > s then goto gameover

  rem ***Restar del puntaje el total negativo***
  if i > 0 then s = s - i
return

gameoverani:
  219 178 177 176 32

gameover:
  rem ***Mostrar la animacion de derrota***
  ink 4
  v = p - 1
  p = p + 1
  for t = 1 to 5
    read gameoverani t j
    for w = v to p
      for x = 23 to 24
        move w x
        print chr j ;
      next x
    next w
    pause 1
  next t

  rem ***Mostrar el mensaje de fin de partida***
  ink 7
  move 0 4
  print "Fin del juego"

  rem ***Calcular cuanto quedo por debajo de cero el puntaje***
  i = i - s

  rem ***Mostrarlo en rojo***
  move 0 0
  ink 4
  print "Energia: -" ;
  number i $1
  print $1
  waitkey k

  rem ***Restablecer los valores y salir***
  ink 7
  cls
  cursor on
end

endgame:
  move 0 4
  print "Fin del juego"
  waitkey k
  ink 7
  cls
  cursor on
end 

scrollscreen:
  rem ***Desplazar una linea hacia abajo***
  for r = 0 to 23

    rem ***Recorrer las lineas en orden inverso (23 a 0)***
    y = 23 - r

    for w = 30 to 50
      rem ***Guardar el caracter***
      move w y
      curschar b
      curscol v
      
      rem ***No sobrescribir al jugador; guardar el caracter anterior como bono***
      if w = p and y = 23 then gosub checkbonus
      if w = p and y = 23 then goto noscroll

      rem ***Bajar una linea y mostrar el caracter***
      y = y + 1
      move w y
      ink v
      print chr b ;
      y = y - 1
      noscroll:
    next w

    rem ***Dejar vacia la linea despues del desplazamiento***
    move 30 y
    print "                     " ;
  next r
  ink 7
return

drawscreen:
  for y = 0 to 24
    rem ***Dibujar los bordes***
    move 29 y
    print chr 221 ;
    move 51 y
    print chr 222 ;

    rem ***Colocar objetos al azar***
    rand x 1 5
    if y < 10 and x = 1 then gosub placebonus
  next y

  rem ***Mostrar la informacion basica***
  move 0 0
  print "Energia: 0"
  print "Record: 0"
  print "Modificador: Ninguno"
  print "Sin arma"
return

placebonus:
  rem ***Elegir una posicion vertical aleatoria***
  rand w 30 50
  move w y

  rem ***Ajustar la cantidad de objetos buenos y malos segun el puntaje***
  if s = 0 then goto goodbonus
  d = s / 10
  rem ***Llegar hasta un 80 por ciento de objetos malos (800 puntos)***
  if d > 80 then d = 80

  rem ***Aumentar aun mas para puntajes superiores***
  if s > 5000 then d = 90
  if s > 10000 then d = 95

  rand w 1 100
  if w < d then goto badbonus

goodbonus:
  rem ***Elegir un objeto***
  rem ***Los objetos menos comunes valen mas***
  rem ***A mayor puntaje, aparecen objetos mas raros***
  rand w 1 88
  if s > 999 then rand w 26 92
  if s > 1999 then rand w 51 100
  if s > 4999 then rand w 76 100
  if s > 4999 and w > 95 then rand w 76 100
  if s > 9999 then rand w 91 100
  if s > 9999 and w > 95 then rand w 91 100
  if s > 9999 and w > 95 then rand w 91 100

  rem ***Bonificaciones positivas, de valor creciente***
  if w < 51 then v = 224
  if w > 50 and w < 76 then v = 225
  if w > 75 and w < 86 then v = 227
  if w > 85 and w < 91 then v = 228
  if w > 90 and w < 93 then v = 172
  if w = 93 then v = 171
  if w = 94 then v = 252
  if w = 95 then v = 253

  rem ***Los ultimos cinco son mejoras***
  if w = 96 then v = 43
  if w = 97 then v = 62
  if w = 98 then v = 36
  if w = 99 then v = 94
  if w = 100 then v = 42

  rem ***Mostrar los objetos buenos y las mejoras en verde***
  ink 2
  print chr v ;
  ink 7
return

badbonus:
  rem ***Elegir un objeto***
  rem ***Los objetos menos comunes son mas peligrosos***
  rem ***A mayor puntaje, aparecen objetos mas peligrosos***
  rand w 1 50
  if s > 999 then rand w 46 75
  if s > 1999 then rand w 51 100
  if s > 4999 then rand w 76 100
  if s > 9999 then rand w 91 100

  rem ***Objetos malos, con perdida de energia creciente***
  if w < 51 then v = 35
  if w > 50 and w < 76 then v = 168
  if w > 75 and w < 86 then v = 254
  if w > 85 and w < 96 then v = 15
  if w > 95 and w < 100 then v = 33
  if w = 100 then v = 19

  rem ***Mostrar los objetos malos en rojo***
  ink 4
  print chr v ;
  ink 7
return

printscore:
  rem ***Mostrar el puntaje actual***
  if s > g then ink 2
  if s = g then ink 7
  if s < g then ink 4
  g = s
  move 9 0
  print "     " ;
  move 9 0
  print s
  ink 7
  if s > h then ink 2
  if s > h then h = s
  move 9 1
  print "     " ;
  move 9 1
  print h
  ink 7

  rem ***Mostrar el modificador y los usos restantes***
  move 10 2
  print "                  " ;
  move 10 2
  if m = 0 then print "Ninguno" ;
  if m = 2 then print "+20" ;
  if m = 3 then print "+50" ;
  if m = 5 then print "Doble" ;
  if m > 0 then print " (" ;
  if m > 0 then print l ;
  if m > 0 then print " usos)"

  rem ***Determinar el arma actual***
  q = 0
  if s > 99 then q = q + 1
  if s > 199 then q = q + 1
  if s > 499 then q = q + 1
  if s > 999 then q = q + 1
  if s > 1999 then q = q + 1
  if s > 4999 then q = q + 1
  if s > 9999 then q = q + 1
  if e > 0 then q = q + 1
  
  rem ***Mostrar el arma***
  gosub colourchange
  ink c
  move 0 3
  if q = 0 then print "Sin arma       "
  if q = 1 then print "Laser pequeno  "
  if q = 2 then print "Laser normal   "
  if q = 3 then print "Laser potente  "
  if q = 4 then print "Laser de fuego "
  if q = 5 then print "Rayo mega      "
  if q = 6 then print "Rayo giga      "
  if q > 6 then ink 71
  if q > 6 then print "Rayo mortal    "
  if q > 6 then ink 7
  ink 7
return

intro:
  cls
  x = 25
  y = 1
  cursor off
  ink 0
  move x y
  print "#### #### ### ##### ##### ####"
  y = y + 1
  move x y
  print "#    #  # #   # # #   #   #   "
  y = y + 1
  move x y
  print "#    #  # ### # # #   #   #   "
  y = y + 1
  move x y
  print "#    #  #   # # # #   #   #   "
  y = y + 1
  move x y
  print "#### #### ### # # # ##### ####"
  y = y + 2
  move x y
  print "#### #    ##### #### #  # #####"
  y = y + 1
  move x y
  print "#    #      #   #    #  #   #  "
  y = y + 1
  move x y
  print "#### #      #   # ## ####   #  "
  y = y + 1
  move x y
  print "#    #      #   #  # #  #   #  "
  y = y + 1
  move x y
  print "#    #### ##### #### #  #   #  "

  y = y - 10
  v = x + 30
  w = y + 10

  for t = x to v
    for u = y to w
      move t u
      curschar z
      if z = '#' then print chr 219 ;
    next u
  next t

  ink 15
  v = x - 5
  w = x + 35
  for u = 0 to 24
    for t = 0 to v
      move t u
      rand s 1 10
      if s = 10 then print chr 42 ;
    next t
    for t = w to 79
      move t u
      rand s 1 10
      if s = 10 then print chr 42 ;
    next t
  next u

  ink 12
  for s = 1 to 13
    if s = 7 then s = 8
    if s = 8 then y = y + 6
    w = y + 5
    read letterstart s v
    v = v + x
    s = s + 1
    read letterstart s r
    s = s - 1
    r = r - 1 + x
    for t = v to r
      for u = y to w
        move t u
        curschar z
        print chr z ;
      next u
    next t
    if s < 7 then pause 2
    sound 5000 1
  next s

  y = y - 6
  w = x - 3
  u = x + 33
  ink 8
  for v = 0 to 24
    move w v
    print chr 219 ; 
    move u v
    print chr 219 ;
    t = timer
    do 
      z = timer
    loop until z > t
  next v

  ink 28
  w = w + 1
  u = u - 1
  for v = 0 to 24
    for t = w to u
      move t v
      curschar s
      print chr s ;
    next t
  next v

  pause 1

  ink 31
  w = y + 12
  v = x - 1
  move v w
  print "Vuelo cosmico es un juego rapido"
  gosub newline
  print "de aventura en el que debes guiar"
  gosub newline
  print "tu pequena nave por una galaxia"
  gosub newline
  print "peligrosa y recoger tanta energia"
  gosub newline
  print "como puedas."
  gosub newline
  gosub newline
  print "Usa A y D para moverte; espacio"
  gosub newline
  print "para disparar tu arma laser."
  gosub newline
  print "Recoge objetos " ;
  ink 18
  print "verdes" ;
  ink 31 
  print " y evita los " ;
  ink 20
  print "rojos" ; 
  ink 31
  gosub newline
  print ". Cuanto mas poderoso seas,"
  gosub newline
  print "mas dificil sera el juego."

  v = x - 21
  w = y + 12
  ink 2
  move v w
  print "Objetos buenos:"
  gosub newline
  print chr 224 ;
  print " =   10 energia"
  gosub newline
  print chr 225 ;
  print " =   20 energia"
  gosub newline
  print chr 227 ;
  print " =   50 energia"
  gosub newline
  print chr 228 ;
  print " =  100 energia"
  gosub newline
  print chr 172 ;
  print " =  250 energia"
  gosub newline
  print chr 171 ;
  print " =  500 energia"
  gosub newline
  print chr 252 ;
  print " = 1000 energia"
  gosub newline
  print chr 253 ;
  print " = 2000 energia"

  v = x + 36
  w = y + 12
  move v w
  ink 4
  print "Objetos malos:"
  gosub newline
  print chr 35 ;
  print " =   -50 energia"
  gosub newline
  print chr 168 ;
  print " =  -100 energia"
  gosub newline
  print chr 254 ;
  print " =  -200 energia"
  gosub newline
  print chr 15 ;
  print " =  -500 energia"
  gosub newline
  print chr 33 ;
  print " = -1000 energia"
  gosub newline
  print chr 19 ;
  print " = -2000 energia"  

  v = x - 1
  w = y + 23
  move v w
  ink 31
  print "Pulsa una tecla para comenzar... " ;
  v = v + 25
  move v w
  cursor on
  waitkey k

  cls
  ink 7
  r = 0
  s = 0
  t = 0 
  u = 0
  v = 0
  w = 0
  x = 0
  y = 0
  z = 0
return

letterstart:
  0 5 10 14 20 26 31
  0 5 10 16 21 26 32

newline:
  w = w + 1
  move v w
  pause 2
return
