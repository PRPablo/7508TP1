#!/bin/bash

# Funciones

function logger {

	sh $DIRBIN/logger.sh "$DIRPROC" "proceso" "$1" "$2"

	return 0
}


# Principal

PROCESO_ACTIVO="S"

function detener_proceso {
   let PROCESO_ACTIVO="N"
}

#atrapamos la senial para detener el proceso
trap detener_proceso SIGINT SIGTERM

while [ "$PROCESO_ACTIVO" == "S" ]
do
	sleep 10
done

logger "Proceso finalizado correctamente" "INF"
echo "Proceso finalizado correctamente"

exit 0
