#!/bin/bash

# Funciones

function logger {

  ./logger.sh "$DIRPROC" "detencion" "$1" "$2"

  return 0
}


# Principal

NOMBRE_PROCESO=proceso.sh
PID_PROCESO=`ps -a | grep "$NOMBRE_PROCESO" | awk '{print $1}'`

if [ -z "$PID_PROCESO" ]
then
  logger "El programa no se encuentra ejecutado" "ERR"
  echo "El programa no se encuentra ejecutado"
else
  #lanzamos senial para detener el proceso
  kill -15 "$PID_PROCESO"
  logger "Detención del programa con pid: $PID_PROCESO" "INF"
  echo "Detención del programa con pid: $PID_PROCESO"
fi

exit 0
