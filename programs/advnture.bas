
REM ------------------------------------------------
REM AVENTURA 2.3 -- Por Justin Tokarchuk
REM Para YogiOS y derivados de MikeBasic
REM ------------------------------------------------

REM VARIABLES:
REM $1 = nombre del jugador
REM a = numero de habitacion
REM b = obtuvo la nota
REM c = obtuvo la vela
REM d = abrio el cofre
REM e = obtuvo la llave

a = 1
b = 0
c = 0
d = 0
e = 0
f = 0
$1 = ""

LOGO:
  CLS
  PRINT "          _______     __                     __                     __ " 
  PRINT "         |   _   |.--|  |.--.--.-----.-----.|  |_.--.--.----.-----.|  |"
  PRINT "         |       ||  _  ||  |  |  -__|     ||   _|  |  |   _|  -__||__|"
  PRINT "         |___|___||_____| \___/|_____|__|__||____|_____|__| |_____||__|"
  PRINT " "
  PRINT "         --------------------------------------------------------------"
  PRINT "                        | Juego de aventuras de texto |               "
  PRINT "                         -------------------------------               "
  PRINT ""
  PRINT ""
  PRINT ""
  PRINT ""

GETNAME:
  PRINT ""
  PRINT " Como te llamas?: " ;
  INPUT $1
  IF $1 = "" THEN GOTO GETNAME

GETNAMEREMARK:
  RAND X 1 3
  PRINT ""
  PRINT " " ;
  PRINT $1 ;
  if x = 1 then PRINT "! Tu madre te queria? Bueno, es tu nombre."
  if x = 2 then PRINT "? Que clase de nombre es ese! No podemos cambiarlo."
  if x = 3 then PRINT "!? No eres de por aqui, verdad?"
  GOSUB PRESSAKEY
  
GOTO GAMEINTRO

HELP:
  PRINT ""  
  PRINT " Estos son los comandos disponibles:"
  PRINT ""
  PRINT " LIMPIAR                   - LIMPIA LA PANTALLA"
  PRINT " MIRAR                     - MUESTRA LA DESCRIPCION"
  PRINT " INVENTARIO                - MUESTRA TUS OBJETOS"
  PRINT " NORTE, OESTE, SUR, ESTE   - CAMBIA DE DIRECCION"
  PRINT " EXAMINAR (OBJETO)         - EXAMINA UN OBJETO"
  PRINT " USAR (OBJETO)             - USA UN OBJETO"
  PRINT " TOMAR (OBJETO)            - TOMA UN OBJETO"
  PRINT " ABRIR (OBJETO)            - ABRE UN CONTENEDOR"
  PRINT " DESBLOQUEAR (OBJETO)      - INTENTA ABRIR UNA CERRADURA"
  PRINT " AYUDA                     - MUESTRA ESTA AYUDA"
  PRINT " SALIR                     - TERMINA EL JUEGO"
  RETURN

LOWERCASE:
  J = & $2
  FOR X = 1 TO 20
    PEEK K J
    IF K < 65 THEN GOTO NOTCAPITAL
    IF K > 90 THEN GOTO NOTCAPITAL
    K = K + 32
    POKE K J
    NOTCAPITAL:
    J = J + 1
  NEXT X
RETURN

GAMEINTRO:
  PRINT ""
  PRINT " NOCHE DE HALLOWEEN. La noche mas tenebrosa del ano. Aunque tu cuarto"
  PRINT " no da mucho miedo. Que importa si limpiar el papel higienico de la"
  PRINT " casa del senor Raul toma horas? Por que me castigaron?"
  GOSUB PRESSAKEY
  PRINT " NO IMPORTA. Soy " ;
  PRINT $1 ;
  PRINT ", soy valiente! Mis padres no me detendran!"
  PRINT " Voy a escaparme y demostrar que la casa del senor Raul"
  PRINT " no esta embrujada!"
  GOSUB PRESSAKEY
  PRINT " Bajas sigilosamente las escaleras y ves que tu madre duerme en el"
  PRINT " sofa. Es tu oportunidad. Sales por la puerta y cruzas la calle"
  PRINT " hasta la casa del senor Raul."
  GOSUB PRESSAKEY
  PRINT " La puerta esta entreabierta. La empujas y entras."
  GOSUB PRESSAKEY
  PRINT " -- PUM -- La puerta se cierra detras de ti. -- CLIC --"
  PRINT " Al examinarla, encuentras un candado que la mantiene cerrada."
  GOSUB PRESSAKEY
  GOSUB MOVEROOM
  GOTO PARSER   
 
MOVEROOM:
  IF a = 1 THEN GOSUB R1
  IF a = 2 THEN GOSUB R2
  IF a = 3 THEN GOSUB R3
  IF a = 4 THEN GOSUB R4
  IF a = 5 THEN GOSUB R5
  IF a = 6 THEN GOSUB R6
  RETURN

R1:
  PRINT ""
  PRINT " -- Entrada de la casa -- "
  PRINT " Estas en la entrada de la casa."
  PRINT " Un candado grande te impide salir."
  RETURN

R2:
  PRINT ""
  PRINT " -- Comedor -- "
  PRINT " Hay una mesa grande en medio de la habitacion y varias puertas."
  PRINT " Tambien ves un cuadro grande."
  RETURN

R3:
  PRINT ""
  PRINT " -- Cocina -- "
  PRINT " Hay una puerta arrancada de sus bisagras. Que extrano."
  PRINT " El resto de la cocina esta impecable."
  RETURN

R4:
  PRINT ""
  PRINT " -- Bano -- "
  PRINT " Es extrano: no hay ventanas ni ventilacion."
  IF c = 0 THEN PRINT " Hay una vela sobre el lavabo."
  RETURN

R5:
  PRINT ""
  PRINT " -- Habitacion -- "
  PRINT " Una puerta lleva de vuelta al comedor."
  RETURN

R6:
  PRINT ""
  PRINT " -- Sotano -- "
  IF c = 1 THEN PRINT " + Enciendes la vela."
  IF c = 1 THEN PRINT " Hay un cofre en el suelo."
  IF c = 0 THEN PRINT " Esta demasiado oscuro para ver algo."
  RETURN

PARSER:
  x = 0
  PRINT ""
  PRINT "> " ;
  INPUT $2
  GOSUB LOWERCASE
  IF $2 = "cls" THEN CLS
  IF $2 = "limpiar" THEN CLS
  IF $2 = "help" THEN GOSUB HELP
  IF $2 = "ayuda" THEN GOSUB HELP
  IF $2 = "north" THEN GOSUB NORTH
  IF $2 = "n" THEN GOSUB NORTH
  IF $2 = "norte" THEN GOSUB NORTH
  IF $2 = "south" THEN GOSUB SOUTH
  IF $2 = "s" THEN GOSUB SOUTH
  IF $2 = "sur" THEN GOSUB SOUTH
  IF $2 = "west" THEN GOSUB WEST
  IF $2 = "w" THEN GOSUB WEST
  IF $2 = "oeste" THEN GOSUB WEST
  IF $2 = "east" THEN GOSUB EAST
  IF $2 = "e" THEN GOSUB EAST
  IF $2 = "este" THEN GOSUB EAST
  IF $2 = "look" THEN GOSUB MOVEROOM
  IF $2 = "mirar" THEN GOSUB MOVEROOM
  IF $2 = "inventory" THEN GOSUB INVENTORY
  IF $2 = "inventario" THEN GOSUB INVENTORY
  IF $2 = "examine rug" AND a = 1 THEN PRINT " Una alfombra vieja, gastada y manchada."
  IF $2 = "examinar alfombra" AND a = 1 THEN PRINT " Una alfombra vieja, gastada y manchada."
  IF $2 = "examine table" AND a = 2 THEN PRINT " Una mesa enorme de madera noble."
  IF $2 = "examinar mesa" AND a = 2 THEN PRINT " Una mesa enorme de madera noble."
  IF $2 = "examine table" AND a = 2 AND b = 0 THEN PRINT " Hay una nota encima."
  IF $2 = "examinar mesa" AND a = 2 AND b = 0 THEN PRINT " Hay una nota encima."
  IF $2 = "examine painting" AND a = 2 THEN PRINT " Es un retrato del senor Raul."
  IF $2 = "examinar cuadro" AND a = 2 THEN PRINT " Es un retrato del senor Raul."
  IF $2 = "take note" AND a = 2 AND b = 0 THEN b = 1
  IF $2 = "tomar nota" AND a = 2 AND b = 0 THEN b = 1
  IF $2 = "take note" AND a = 2 AND b = 1 THEN PRINT " Ya tienes la nota."
  IF $2 = "tomar nota" AND a = 2 AND b = 1 THEN PRINT " Ya tienes la nota."
  IF $2 = "open treasure chest" THEN GOSUB TREASURECHEST
  IF $2 = "abrir cofre" THEN GOSUB TREASURECHEST
  IF $2 = "unlock door" AND a = 1 AND e = 1 THEN GOTO GAMEEND
  IF $2 = "desbloquear puerta" AND a = 1 AND e = 1 THEN GOTO GAMEEND
  IF $2 = "abrir puerta" AND a = 1 AND e = 1 THEN GOTO GAMEEND
  IF $2 = "use note" THEN GOSUB NOTE
  IF $2 = "usar nota" THEN GOSUB NOTE
  IF $2 = "read note" THEN GOSUB NOTE
  IF $2 = "leer nota" THEN GOSUB NOTE
  IF $2 = "take candle" AND a = 4 AND c = 0 THEN GOSUB CANDLE
  IF $2 = "tomar vela" AND a = 4 AND c = 0 THEN GOSUB CANDLE
  IF $2 = "exit" THEN END
  IF $2 = "salir" THEN END
  IF $2 = "" THEN PRINT " Te perdiste? Escribe HELP para ver los comandos."
  GOTO PARSER

CANDLE:
  PRINT " + Tomas la vela del lavabo."
  c = 1
  RETURN

TREASURECHEST:
  IF a = 6 AND c = 1 THEN e = 1
  IF a = 6 AND e = 1 AND f = 0 THEN PRINT " + Abres el cofre y sacas una LLAVE."
  IF f = 1 THEN PRINT " Ya tienes el tesoro."
  f = 1
  RETURN    

NOTE:
  IF b = 1 THEN PRINT " La nota dice:"
  IF b = 1 THEN PRINT " Tu libertad esta dentro de una caja."
  RETURN

GAMEEND:
  PRINT " Abres la puerta y corres afuera a respirar aire libre."
  PRINT " Casi pasas la noche aqui. Ya esta oscureciendo, asi que"
  PRINT " decides volver a casa antes de que despierte tu madre."
  PRINT " FIN DEL JUEGO. Gracias por jugar."
  END

INVENTORY:
  PRINT ""
  IF b = 0 AND c = 0 AND e = 0 THEN GOSUB EMPTY
  IF b = 1 THEN PRINT " NOTE"   
  IF c = 1 THEN PRINT " CANDLE"  
  IF e = 1 THEN PRINT " KEY"
  RETURN

EMPTY:
  RAND X 1 5
  IF X = 1 THEN PRINT " Nada. Ni siquiera una mosca en tu mochila."
  IF X = 2 THEN PRINT " Tu mochila pesa poco porque esta vacia."
  IF X = 3 THEN PRINT " Tu mochila esta sorprendentemente vacia."
  IF X = 4 THEN PRINT " Solo hay unas cuantas moscas muertas."
  IF X = 5 THEN PRINT " Tu mochila esta llena de tesoros."
  IF X = 5 THEN PRINT " En realidad, esta vacia."
  RETURN

NODIR:
  RAND X 1 3
  IF x = 1 THEN PRINT " Asi se siente la pared en la cara. Genial."
  IF x = 2 THEN PRINT " No puedes ir por ahi."
  IF x = 3 THEN PRINT " Ganaste."
  IF x = 3 THEN PRINT " Es broma."
  RETURN

NORTH:
  REM -- DE LA ENTRADA AL COMEDOR --
  IF a = 1 THEN x = 1
  IF a = 1 THEN a = 2
  IF x = 1 THEN GOSUB MOVEROOM
  IF x = 1 THEN RETURN
  REM -- DEL COMEDOR A LA COCINA --
  IF a = 2 THEN x = 2
  IF a = 2 THEN a = 3
  IF x = 2 THEN GOSUB MOVEROOM
  IF x = 2 THEN RETURN
  GOSUB NODIR  
  RETURN

WEST:
  REM -- DE LA ENTRADA A LA HABITACION --
  IF a = 1 THEN x = 1
  IF a = 1 THEN a = 5
  IF x = 1 THEN GOSUB MOVEROOM
  IF x = 1 THEN RETURN
  REM -- DEL COMEDOR AL SOTANO --
  IF a = 2 THEN x = 2
  IF a = 2 THEN a = 6
  IF x = 2 THEN GOSUB MOVEROOM
  IF x = 2 THEN RETURN
  REM -- DE LA COCINA AL BANO
  IF a = 3 THEN x = 3
  IF a = 3 THEN a = 4
  IF x = 3 THEN GOSUB MOVEROOM
  IF x = 3 THEN RETURN
  GOSUB NODIR
  RETURN

SOUTH:
  REM -- DEL COMEDOR A LA ENTRADA
  IF a = 2 THEN x = 2
  IF a = 2 THEN a = 1
  IF x = 2 THEN GOSUB MOVEROOM
  IF x = 2 THEN RETURN
  REM -- DE LA COCINA AL COMEDOR --
  IF a = 3 THEN x = 3
  IF a = 3 THEN a = 2
  IF x = 3 THEN GOSUB MOVEROOM
  IF x = 3 THEN RETURN
  GOSUB NODIR
  RETURN

EAST:
  REM -- DEL BANO A LA COCINA --
  IF a = 4 THEN x = 4
  IF a = 4 THEN a = 3
  IF x = 4 THEN GOSUB MOVEROOM
  IF x = 4 THEN RETURN
  REM -- DE LA HABITACION A LA ENTRADA --
  IF a = 5 THEN x = 5
  IF a = 5 THEN a = 1
  IF x = 5 THEN GOSUB MOVEROOM
  IF x = 5 THEN RETURN
  REM -- DEL SOTANO AL COMEDOR --
  IF a = 6 THEN x = 6
  IF a = 6 then a = 2
  IF x = 6 THEN GOSUB MOVEROOM
  IF x = 6 THEN RETURN
  GOSUB NODIR
  RETURN

PRESSAKEY:
  PRINT ""
  PRINT " -- Pulse una tecla para continuar. --"
  WAITKEY X
  PRINT ""
  RETURN



