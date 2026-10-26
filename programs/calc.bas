rem Aplicacion de calculadora (CALC.BAS)
rem Una calculadora sencilla.
rem Version 2.0.1
rem Creada por Joshua Beck
rem Publicada bajo la Licencia Publica General de GNU, version 3
rem Enviar errores, ideas o comentarios a mikeosdeveloper@gmail.com

rem Usa la biblioteca MB++ version 3.0
rem Disponible en code.google.com/p/mikebasic-applications
INCLUDE "MBPP.BAS"

START:
  CLS
  REM Inicializar las funciones de MB++
  GOSUB STARTPRG
  REM Establecer el color del texto y el resaltado del menu
  C = 3
  H = 11
  REM Establecer el color de los cuadros
  T = 2
  MOVE 30 13
  PRINT "Calculando..."
GOTO MAIN

MAIN:
  REM Menu principal
  $T = "Calculadora"
  $5 = "Calculos sencillos"
  $6 = "Matematicas avanzadas"
  $7 = "Cambiar colores"
  $8 = "Acerca de"
  $9 = "Salir"
  GOSUB MENUBOX
  IF V = 1 THEN GOSUB BASEMATH
  IF V = 2 THEN GOSUB ADVMATH
  IF V = 3 THEN GOSUB COLCHANGE
  IF V = 4 THEN GOSUB ABOUT
  IF V = 5 THEN GOSUB ENDPROG
GOTO MAIN

COLCHANGE:
  $T = "Cambiar colores"
  $5 = "Nuevo color del borde, 1-255"
  $6 = "Nuevo color del texto, 1-15"
  V = 0
  GOSUB DINBOX
  $E = "Color no valido"
  IF A < 1 THEN GOTO ERRBOX
  IF A > 255 THEN GOTO ERRBOX
  IF B < 1 THEN GOTO ERRBOX
  IF B > 15 THEN GOTO ERRBOX
  T = A
  C = B
  $5 = "Nuevo color de resaltado, 1-15"
  $6 = ""
  V = 0
  GOSUB INPBOX
  $E = "Color no valido"
  IF V < 1 THEN GOTO ERRBOX
  IF V > 15 THEN GOTO ERRBOX
  H = V
RETURN
  
BASEMATH:
  REM Iniciar el bucle del menu
  DO
    REM Definir titulo y opciones del menu
    $T = "Calculos sencillos"
    $5 = "Suma"
    $6 = "Resta"
    $7 = "Multiplicacion"
    $8 = "Division"
    $9 = "Volver"
    REM Mostrar el menu
    GOSUB MENUBOX
    REM Averiguar que opcion eligio y llamar a su rutina
    IF V = 1 THEN GOSUB ADD
    IF V = 2 THEN GOSUB SUB
    IF V = 3 THEN GOSUB MUL
    IF V = 4 THEN GOSUB DIV
  REM Repetir el menu salvo que se haya elegido «Volver»
  LOOP UNTIL V = 5
  V = 0
RETURN

ADD:
  REM INPBOX y DINBOX usan V para elegir entrada de texto o numerica
  V = 0
  REM Solicitar los dos valores para la suma
  $T = "Suma"
  $5 = "Ingrese el primer numero..."
  $6 = "Ingrese el segundo numero..."
  REM DINBOX permite solicitar dos valores a la vez.
  GOSUB DINBOX
  REM Realizar la operacion: A es el primer valor y B el segundo.
  a = a + b
  REM Mostrar el resultado; la segunda cadena queda vacia.
  $6 = ""
  REM Mostrar el resultado en un cuadro numerico.
  GOSUB NUMBOX
  REM Volver al menu principal.
RETURN

SUB:
  v = 0
  $T = "Resta"
  $5 = "Numero al que se resta..."
  $6 = "Numero que se resta..."
  GOSUB DINBOX
  A = A - B
  $5 = "Resultado:"
  $6 = ""
  GOSUB NUMBOX
RETURN

MUL:
  v = 0
  $T = "Multiplicacion"
  $5 = "Ingrese el primer numero..."
  $6 = "Ingrese el segundo numero..."
  GOSUB DINBOX
  A = A * B
  $5 = "Resultado:"
  $6 = ""
  GOSUB NUMBOX
RETURN

DIV:
  v = 0
  $T = "Division"
  $5 = "Ingrese el dividendo..."
  $6 = "Ingrese el divisor..."
  GOSUB DINBOX
  REM Definir el error que se muestra si el divisor es cero.
  $E = "No se puede dividir entre cero"
  IF B = 0 THEN GOTO ERRBOX
  D = A / B
  E = A % B
  A = D
  B = E
  $5 = "Resultado:"
  $6 = "Residuo:"
  GOSUB NUMBOX
RETURN

ADVMATH:
  DO
    $T = "Matematicas avanzadas"
    $5 = "Elevar al cuadrado/cubo"
    $6 = "Potencia"
    $7 = "Suma acumulada"
    $8 = "Resta acumulada"
    $9 = "Volver"
    GOSUB MENUBOX
    IF V = 1 THEN GOSUB SQUARE
    IF V = 2 THEN GOSUB POWER
    IF V = 3 THEN GOSUB MASSADD
    IF V = 4 THEN GOSUB MASSTAKE
  LOOP UNTIL V = 5
  V = 0
RETURN

SQUARE:
  $T = "Elevar al cuadrado/cubo"
  $5 = ""
  $6 = "Ingrese un numero para elevar al cuadrado y al cubo"
  V = 0
  GOSUB INPBOX
  A = V
  D = A
  A = A * D
  B = A * D
  $T = "Elevar al cuadrado/cubo"
  $5 = "Al cuadrado:"
  $6 = "Al cubo:"
  GOSUB NUMBOX
RETURN

POWER:
  $T = "Potencia"
  $5 = "Ingrese un numero"
  $6 = "Ingrese el exponente"
  V = 0
  GOSUB DINBOX
  D = A
  IF B = 0 THEN A = 1
  IF B = 0 THEN GOTO POWERSKIP
  IF B = 1 THEN GOTO POWERSKIP
  DO
    A = A * D
    B = B - 1
  LOOP UNTIL B = 1
  POWERSKIP:
  $T = "Potencia"
  $5 = "Resultado:"
  $6 = ""
  GOSUB NUMBOX
RETURN

MASSADD:
  $T = "Suma acumulada"
  $5 = "Ingrese el numero base"
  $6 = "Ingrese el primer sumando"
  V = 0
  GOSUB DINBOX
  N = A
  N = N + B
ADDMORE:
  $T = "Suma acumulada"
  $5 = "Ingrese otro sumando"
  $6 = "o cero para terminar"
  V = 0
  GOSUB INPBOX
  N = N + V
  IF V > 0 THEN GOTO ADDMORE
  $5 = "Numero base: "
  $6 = "Total: "
  B = N
  GOSUB NUMBOX
RETURN

MASSTAKE:
  $T = "Resta acumulada"
  $5 = "Ingrese el numero base"
  $6 = "Ingrese el primer sustraendo"
  V = 0
  GOSUB DINBOX
  N = A
  N = N - B
TAKEMORE:
  $T = "Resta acumulada"
  $5 = "Ingrese otro sustraendo"
  $6 = "o cero para terminar"
  V = 0
  GOSUB INPBOX
  N = N - V
  IF V > 0 THEN GOTO TAKEMORE
  $5 = "Numero base: "
  $6 = "Total: "
  B = N
  GOSUB NUMBOX
RETURN 

ABOUT:
  $T = "Acerca de"
  $5 = "Calculadora, version 2.0.1"
  $6 = "Una calculadora avanzada"
  $7 = "Publicada bajo la licencia GNU GPL v3"
  $8 = "Escrita en BASIC para YogiOS"
  $9 = "Gracias al equipo de MikeOS"
  GOSUB MESBOX

  $5 = "Usa la biblioteca MB++, version 3.0"
  $6 = "Una biblioteca de interfaz de texto"
  $7 = "Creada por Joshua Beck"
  $8 = "Correo: mikeosdeveloper@gmail.com"
  $9 = "Pruebe la suma y resta acumuladas"
  GOSUB MESBOX
RETURN
