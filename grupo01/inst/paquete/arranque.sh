#!/bin/bash

# Funciones

function logger {

  ./logger.sh "$DIRPROC" "arranque" "$1" "$2"

  return 0
}


# Principal

if [ "$INICIALIZADO" == "S" ]
then

  NOMBRE_PROCESO="proceso.sh"
  CANT_PROCESOS_CORRIENDO=`ps -a | grep $NOMBRE_PROCESO | wc -l`

  if [ $CANT_PROCESOS_CORRIENDO -gt 0 ]
  then
    PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`
    logger "El programa ya se encuentra corriendo en segundo plano con pid: $PID_PROCESO" "ALE"
    echo "El programa ya se encuentra corriendo en segundo plano con pid: $PID_PROCESO"
    exit 0
  fi

  ./proceso.sh &

  PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`
  logger "Programa iniciado exitosamente en segundo plano con pid: $PID_PROCESO" "INF"
  echo "Programa iniciado exitosamente en segundo plano con pid: $PID_PROCESO"

else
  logger "El ambiente no fue inicializado. Por favor, ejecutar el script inicializador.sh del directorio $DIRBIN" "ERR"
  echo "El ambiente no fue inicializado. Por favor, ejecutar el script inicializador.sh del directorio $DIRBIN"
fi

exit 0

