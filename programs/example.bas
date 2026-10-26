rem *** Demostracion de BASIC para YogiOS ***

cls

$1 = "Volcado hexadecimal,MikeTron"
$2 = "Elija un programa para ejecutar,"
$3 = "o pulse Esc para salir"

listbox $1 $2 $3 a

if a = 1 then goto runhex
if a = 2 then goto runmiketron

cls
end


runhex:

rem *** Volcado hexadecimal ***

cls

print "Nombre del archivo para volcar en hexadecimal:"
input $1

x = RAMSTART

load $1 x
if r = 1 then goto hexerror

hexloop:
  peek a x
  print hex a ;
  print "  " ;
  x = x + 1
  s = s - 1
  if s = 0 then goto hexfinish
  goto hexloop

hexfinish:
print ""
end

hexerror:
print "No se pudo cargar el archivo. Existe?"
end



runmiketron:

rem *** MikeTron ***

cls

print "Controlas un vehiculo que deja un rastro."
print ""
print "El vehiculo siempre avanza. Si toca el rastro"
print "o el borde (los signos +), termina la partida."
print "Use Q y A para subir y bajar, y O y P para"
print "moverse a la izquierda y a la derecha."
print "Sobrevive todo lo que puedas! Veras tu puntuacion al final."
print ""
print "NOTA: la velocidad podria variar en algunos emuladores."
print ""
print "Pulsa una tecla para comenzar..."

waitkey x


cls
cursor off


rem *** Dibujar el borde de la pantalla ***

gosub setupscreen


rem *** Comenzar en el centro de la pantalla ***

x = 40
y = 12

move x y


rem *** Direcciones: 1 a 4 = arriba, abajo, izquierda, derecha ***
rem *** Comenzar el juego moviendose a la derecha ***

d = 4


rem *** S = variable del puntaje ***

s = 0


mainloop:
  print "+" ;

  pause 1

  getkey k

  if k = 'q' then d = 1
  if k = 'a' then d = 2
  if k = 'o' then d = 3
  if k = 'p' then d = 4

  if d = 1 then y = y - 1
  if d = 2 then y = y + 1
  if d = 3 then x = x - 1
  if d = 4 then x = x + 1

  move x y

  curschar c
  if c = '+' then goto finish

  s = s + 1
  goto mainloop


finish:
cursor on
cls

print "Tu puntuacion fue: " ;
print s
print "Pulsa Esc para terminar"

escloop:
  waitkey x
  if x = 27 then end
  goto escloop


setupscreen:
  move 0 0
  for x = 0 to 78
    print "+" ;
  next x

  move 0 24
  for x = 0 to 78
    print "+" ;
  next x

  move 0 0
  for y = 0 to 24
    move 0 y
    print "+" ;
  next y

  move 78 0
  for y = 0 to 24
    move 78 y
    print "+" ;
  next y

  return

