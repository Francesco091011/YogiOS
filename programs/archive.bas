if $1 = "" then goto help
d = ramstart

main:
  rem >>> Leer el comando; mostrar la ayuda si no es valido <<<
  gosub collect_parameter
  if $2 = "HELP" then goto help
  if $2 = "CREATE" then goto create_archive
  if $2 = "ADD" then goto add_file
  if $2 = "REMOVE" then goto remove_file
  if $2 = "EXTRACT" then goto extract_file
  if $2 = "EXTRACTALL" then goto extract_all
  if $2 = "LIST" then goto archive_list
goto help

collect_parameter:
  rem >>> Leer en $2 un parametro separado por espacios <<<
  rem >>> Actualizar el desplazamiento P en cada lectura <<<
  x = & $1
  x = x + p
  do
    x = x + 1
    peek v x
    if v = 0 then v = 32
  loop until v = 32
  poke 0 x
  x = & $1
  x = x + p
  string load $2 x
  len $2 v
  p = p + v + 1
  case upper $2
return

collect_list_item:
  rem >>> Leer un elemento de la lista separada por comas $2 a $3 <<<
  rem >>> Q contiene el desplazamiento; devolver nulo al final de la lista <<<
  if q = 255 then $3 = ""
  if q = 255 then return
  x = & $2
  x = x + q
  do
    x = x + 1
    peek v x
    if v = 0 then v = 44
    if v = 32 then v = 44
  loop until v = 44
  peek v x
  poke 0 x
  x = & $2
  x = x + q
  string load $3 x
  if v < 33 then q = 255
  len $3 v
  if q < 255 then q = q + v + 1
  case upper $3
return

find_free_block:
  rem >>> Buscar un bloque libre que pueda contener el archivo de tamano S <<<
  rem >>> Devolver N = numero de bloque y M = cantidad de bloques <<<

  if s = 0 then return

  x = d + 14
  peek y x

  rem Convertir el tamano en cantidad de bloques de 512 bytes
  m = s / 512
  v = s % 512
  if v > 0 then m = m + 1
  w = 0
  z = 0

  x = d + 5
  peekint v x
  x = d + v

  rem Buscar espacio libre en el mapa de asignacion
  do
    peek v x
    x = x + 1
    if v = 0 then w = w + 1
    if v > 0 then w = 0
    z = z + 1
    rem Si se supera el mapa de asignacion, no queda espacio
    if z > y then print "No hay espacio suficiente para este archivo."
    if z > y then end
  loop until w = m

  n = z - m
return

allocate_file_entry:
  rem >>> Crear una entrada con nombre $3, tamano S y bloque asignado <<<
  rem >>> Antes hay que ejecutar find_free_block para obtener el espacio <<<

  rem Comprobar que no se haya alcanzado el maximo de archivos
  x = d + 11
  peek v x
  x = d + 12
  peek w x
  if v = w then print "No hay entradas libres para archivos."
  if v = w then end
  rem Aumentar la cantidad de archivos del archivo comprimido
  v = v + 1
  x = d + 11  
  poke v x
  
  x = d + 7
  peekint v x
  x = v + d
  z = 0
  rem Buscar entradas vacias en la lista de archivos
  do
    peek v x
    x = x + 17
    z = z + 1
    if z > w then print "No hay entradas libres para archivos."
    if z > w then end
  loop until v = 0
  x = x - 17

  w = d + 9
  peekint z w
  
  rem Guardar la informacion en la entrada
  string store $3 x
  x = x + 13
  o = n * 512 + z
  pokeint o x
  x = x + 2
  pokeint s x
return

allocate_free_block:
  rem >>> Asignar el bloque libre encontrado por find_free_block <<<

  x = d + 5
  peekint v x
  x = d + v + n

  rem Marcar el bloque como asignado
  w = m
  do
    poke 1 x
    x = x + 1
    w = w - 1
  loop until w = 0

  rem Si el ultimo bloque asignado supera el maximo, actualizarlo
  w = n + m - 1
  x = d + 13
  peek v x
  if w > v then v = w
  poke v x
return

collect_file_data:
  rem >>> Buscar el nombre $3 y obtener desplazamiento O y tamano S <<<
  x = d + 12
  peek z x

  x = d + 7
  peekint v x
  x = d + v

  rem Buscar entradas hasta encontrar una coincidencia
  w = 0
  y = 0
  do
    string load $4 x
    if $4 = $3 then w = 1
    x = x + 17
    y = y + 1
    if y = z then print "El archivo no existe."
    if y = z then end
  loop until w = 1
  
  rem Recopilar la informacion
  x = x - 17
  x = x + 13
  peekint o x
  x = x + 2
  peekint s x
return

deallocate_block:
  rem >>> Liberar el bloque que ocupa un archivo <<<
  rem >>> Ejecutar antes collect_file_info <<<

  x = d + 9
  peekint v x

  rem Calcular el numero y la cantidad de bloques a partir del desplazamiento y tamano
  n = o - v / 512
  m = s / 512
  v = s % 512
  if v > 0 then m = m + 1
  if m = 0 then return

  x = d + 5
  peekint v x
  x = v + n + d
  y = m
  rem Marcar los bloques como libres
  do
    poke 0 x
    x = x + 1
    y = y - 1
  loop until y = 0

  x = d + 14  
  peek z x
  x = d + 5
  peekint v x
  x = d + v + z - 1
  
  rem Buscar y actualizar el nuevo bloque maximo
  z = z + 1
  do
    peek v x
    x = x - 1
    z = z - 1
    if z = 0 then v = 1
  loop until v = 1 

  x = d + 13
  poke z x
return

deallocate_file_entry:
  rem >>> Eliminar la entrada cuyo nombre es $3 <<<
  rem >>> Antes hay que ejecutar collect_file_data <<<

  rem Reducir la cantidad de archivos
  x = d + 11
  peek v x
  v = v - 1
  poke v x

  x = d + 7
  peekint v x
  x = d + v
  
  rem Buscar la entrada del archivo
  w = 0
  do
    string load $4 x
    x = x + 17
    if $4 = $3 then w = 1
  loop until w = 1

  rem Vaciar la entrada del archivo
  x = x - 17
  for y = 1 to 17
    poke 0 x
    x = x + 1
  next y
return
  
load_archive:
  rem >>> Cargar y verificar el archivo comprimido <<<

  print "Abriendo el archivo..."
  rem Obtener el nombre de los parametros de la linea de comandos
  gosub collect_parameter
  load $2 d
  rem Conservar el nombre abierto
  $8 = $2

  rem Comprobar que el archivo sea valido
  if s = 0 then print "El archivo comprimido esta vacio."
  if s = 0 then end

  if r = 1 then print "El archivo comprimido no existe."
  if r = 1 then end

  rem Comprobar la cabecera del archivo comprimido
  string load $4 d
  if $4 = "MFA" then rem
  else print "No es un archivo comprimido."
  else end

  rem Comprobar que la version sea compatible
  x = d + 4
  peek v x
  if v > 1 then print "Version del archivo no compatible."
  if v > 1 then end
return

save_archive:
  rem >>> Calcular el tamano y guardar el archivo comprimido <<<

  print "Guardando el archivo..."
  rem Tamano de la cabecera
  z = 14
  
  rem Tamano del mapa de asignacion
  x = d + 14
  peek v x
  z = z + v

  rem Tamano de la lista de archivos
  x = d + 12
  peek v x
  v = v * 17
  z = z + v

  rem Guardar solo hasta el ultimo bloque de datos asignado
  x = d + 13
  peek v x
  v = v + 1
  v = v * 512
  z = z + v

  rem Guardar con el nombre existente y sobrescribir
  delete $8
  save $8 d z
return

help:
  rem Presentar la ayuda si no hay argumentos o si el argumento no es valido
  print "============================"
  print "ARCHIVE: herramienta para comprimir archivos"
  print "============================"
  print "Version 1.0.0"
  print "Copyright (C) Joshua Beck"
  print "Correo: mikeosdeveloper@gmail.com"
  print "Licencia Publica General de GNU v3"
  print ""
  print "Uso: ARCHIVE (comando) (archivo) [lista separada por comas]"
  print ""
  print "Comandos:"
  print "    Create - Crear un archivo vacio"
  print "    Add - Agregar los archivos indicados"
  print "    Remove - Quitar los archivos indicados"
  print "    Extract - Extraer los archivos indicados"
  print "    ExtractAll - Extraer todos los archivos"
  print "    List - Mostrar los archivos del archivo"
  print "    Help - Mostrar esta ayuda"
  print ""
end

create_archive:
  rem >>> Crear un archivo comprimido nuevo <<<

  rem Identificador del archivo
  d = ramstart
  $4 = "MFA"
  string store $4 d

  rem Version del archivo
  x = d + 4
  poke 1 x

  rem Desplazamiento del mapa de asignacion
  x = d + 5
  pokeint 15 x

  rem Desplazamiento de la lista de archivos
  x = d + 7
  pokeint 45 x

  rem Desplazamiento de los datos
  x = d + 9
  pokeint 385 x

  rem Archivos contenidos
  x = d + 11
  poke 0 x

  rem Entradas de la lista de archivos
  x = d + 12
  poke 20 x

  rem Bloque asignado mas alto
  x = d + 13
  poke 0 x

  rem Bloques de 512 bytes del mapa de asignacion
  x = d + 14
  poke 40 x

  rem Crear un mapa de asignacion vacio
  x = d + 15
  for y = 1 to 40
    poke 0 x
    x = x + 1
  next y

  rem Crear una lista de archivos vacia
  x = d + 45
  for y = 1 to 340
    poke 0 x
    x = x + 1
  next y

  rem Obtener el nombre de archivo de la lista de parametros
  gosub collect_parameter
  $8 = $2
  gosub save_archive
  print "Archivo creado."
end

add_file:
  gosub load_archive

  gosub collect_parameter
  gosub collect_list_item

  t = 0
  do
    $4 = "Agregando archivo: " + $3
    print $4

    size $3 
    gosub find_free_block
    gosub allocate_file_entry
    gosub allocate_free_block  

    v = d + o
    load $3 v
    if r = 1 then print "El archivo no existe."
    if r = 1 then end

    gosub collect_list_item
    if $3 = "" then t = 1
  loop until t = 1

  gosub save_archive
  print "Se agregaron todos los archivos."
end

remove_file:
  gosub load_archive

  gosub collect_parameter
  gosub collect_list_item

  t = 0
  do
    $4 = "Quitando archivo: " + $3
    print $4

    gosub collect_file_data
    gosub deallocate_block
    gosub deallocate_file_entry

    gosub collect_list_item
    if $3 = "" then t = 1
  loop until t = 1

  gosub save_archive
  print "Se quitaron todos los archivos."
end

extract_file:
  gosub load_archive

  gosub collect_parameter
  gosub collect_list_item

  t = 0
  do
    $4 = "Extrayendo archivo: " + $3
    print $4

    gosub collect_file_data
    v = o + d
    delete $3
    save $3 v s
    if r > 0 then print "Nombre no valido o disco protegido contra escritura."
    if r > 0 then end

    gosub collect_list_item
    if $3 = "" then t = 1
  loop until t = 1

  print "Se extrajeron todos los archivos."
end

extract_all:
  gosub load_archive
  
  x = d + 12
  peek w x
  w = w * 17
  x = d + 7
  peekint t x
  t = t + d
  u = t + w

  do
    string load $3 t
    t = t + 17

    $4 = "Extrayendo archivo: " + $3
    if $3 = "" then rem
    else print $4

    gosub collect_file_data
    v = o + d
    if $3 = "" then rem
    else delete $3
    else save $3 v s

    if r = 1 then print "Nombre no valido o disco protegido contra escritura."
    if r = 1 then end
  loop until t = u

  print "Se extrajeron todos los archivos."
end

archive_list:
  gosub load_archive

  x = d + 11
  peek a x
  $4 = "Archivos: " + a
  x = d + 12
  peek b x  

  $4 = "Archivos:            " + a
  $5 = "Maximo de archivos:  " + b
  $6 = "Tamano del archivo:  " + s

  print "Archivo Mega File - Version 1"
  print $4
  print $5
  print $6
  print "Lista de archivos:"
  if v = 0 then end

  x = d + 12
  peek w x
  x = d + 7
  peekint v x
  x = d + v
  
  do
    string load $4 x
    if $4 = "" then rem
    else print $4
    x = x + 17
    w = w - 1
  loop until w = 0
end


