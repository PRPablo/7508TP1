#/bin/bash

#Variable de ambiente que indica con una S si el programa esta inicializado (INICIALIZADO=S)
INICIALIZADO="N"
GRUPO="$(cd "$(dirname "$0")";cd ..;pwd -P)"
DIRINST="$GRUPO/inst"
DIRPAQUETE="$DIRINST/paquete"

# Funciones

function logger {

	sh $DIRPAQUETE/logger.sh "$DIRPROC" "inicializador" "$1" "$2"

	return 0
}

function variableConfigurada {

	if [ -f "$DIRINST/instalador.conf" ]
	then
		echo $(grep $1 $DIRINST/instalador.conf | cut -d '-' -f 2)
		return 0
	else
		return -1
	fi
}

function hayInstalacionPrevia {

	VAR_DIRBIN=$(variableConfigurada DIRBIN)
	VAR_DIRTAB="$(variableConfigurada DIRTAB)"
	VAR_DIRNOV="$(variableConfigurada DIRNOV)"
	VAR_DIROK="$(variableConfigurada DIROK)"
	VAR_DIRNOK="$(variableConfigurada DIRNOK)"
	VAR_DIRPROC="$(variableConfigurada DIRPROC)"
	VAR_DIRSAL="$(variableConfigurada DIRSAL)"
	VAR_HCIERRE="$(variableConfigurada HCIERRE)"

	if [[ ! -z "$VAR_DIRBIN" && -d "$GRUPO/$VAR_DIRBIN" && -r "$GRUPO/$VAR_DIRBIN"
		&& ! -z "$VAR_DIRTAB" && -d "$GRUPO/$VAR_DIRTAB"  && -r "$GRUPO/$VAR_DIRTAB"
	    && ! -z "$VAR_DIRNOV" && -d "$GRUPO/$VAR_DIRNOV"  && -r "$GRUPO/$VAR_DIRNOV"
	    && ! -z "$VAR_DIROK" && -d "$GRUPO/$VAR_DIROK"   && -r "$GRUPO/$VAR_DIROK"
	    && ! -z "$VAR_DIRNOK" && -d "$GRUPO/$VAR_DIRNOK"  && -r "$GRUPO/$VAR_DIRNOK"
	    && ! -z "$VAR_DIRPROC" && -d "$GRUPO/$VAR_DIRPROC" && -r "$GRUPO/$VAR_DIRPROC"
	    && ! -z "$VAR_DIRSAL" && -d "$GRUPO/$VAR_DIRSAL"  && -r "$GRUPO/$VAR_DIRSAL"
	    && ! -z "$VAR_HCIERRE" ]]
	then
		return 0
	else
		return -1
	fi
}

function hayInstalacionCorrupta {

	if [[ ! -z "$VAR_DIRBIN" || -d "$GRUPO/$VAR_DIRBIN"
		|| ! -z "$VAR_DIRTAB" || -d "$GRUPO/$VAR_DIRTAB"
	    || ! -z "$VAR_DIRNOV" || -d "$GRUPO/$VAR_DIRNOV"
	    || ! -z "$VAR_DIROK" || -d "$GRUPO/$VAR_DIROK"
	    || ! -z "$VAR_DIRNOK" || -d "$GRUPO/$VAR_DIRNOK"
	    || ! -z "$VAR_DIRPROC" || -d "$GRUPO/$VAR_DIRPROC"
	    || ! -z "$VAR_DIRSAL" || -d "$GRUPO/$VAR_DIRSAL"
	    || ! -z "$VAR_HCIERRE" ]]
	then
		return 0
	else
		return -1
	fi
}

function notificarInstalacion {

	logger "El programa no se encuentra instalado. Por favor, ejecutar el script instalador.sh del directorio grupo01/inst (sh instalador)" "INF"
	echo "El programa no se encuentra instalado. Por favor, ejecutar el script instalador.sh del directorio grupo01/inst (sh instalador)"
}

function notificarReparacion {

	logger "El programa necesita una reparación. $1. Por favor, ejecutar el script instalador.sh con el parámetro -r del directorio grupo01/inst (sh instalador -r)" "ERR"
	echo "El programa necesita una reparación. $1. Por favor, ejecutar el script instalador.sh con el parámetro -r del directorio grupo01/inst (sh instalador -r)"
}

function crearArchivoLog {

	VAR_DIRPROC="$(variableConfigurada DIRPROC)"
	DIRPROC="$GRUPO/$VAR_DIRPROC"

	if [ -d "$DIRPROC" ]
	then
		if [ ! -f "$DIRPROC/inicializador.log" ]
		then
			touch "$DIRPROC/inicializador.log"
		fi

		if [ ! -r "$DIRPROC/inicializador.log" ]
		then
			logger "Seteando permiso de lectura a inicializador.log" "INF"
			chmod +r "$DIRPROC/inicializador.log"
			if ! [ $? -eq 0 ]
			then
				logger "Falló el seteo de permiso de lectura a inicializador.log" "ERR"
				return 1
			fi
		fi
	else
		mkdir -p "$DIRPROC"
		touch "$DIRPROC/inicializador.log"
		chmod +r "$DIRPROC/inicializador.log"
	fi

	logger "Archivo de inicializador.log se ha creado satisfactoriamente en el directorio $DIRPROC" "INF"

	return 0
}

function verificarArchivos {

	DIRBIN="$GRUPO/$VAR_DIRBIN"
	DIRTAB="$GRUPO/$VAR_DIRTAB"

	logger "Verificación archivo de tabla de códigos comercio" "INF"
	echo "Verificación de archivo de tabla de códigos comercio"

	if [ -f "$DIRTAB/CodigosComercio.csv" ]
	then
		if [ ! -r "$DIRTAB/CodigosComercio.csv" ]
		then
			chmod +r "$DIRTAB/CodigosComercio.csv"
		fi
	else
		notificarReparacion "El archivo de tabla de códigos comercio 'CodigosComercio.csv' no existe."
		return -1
	fi

	logger "Verificación archivo de tabla de códigos provincia" "INF"
	echo "Verificación de archivo de tabla de códigos provincia"

	if [ -f "$DIRTAB/CodigosProvincia.csv" ]
	then
		if [ ! -r "$DIRTAB/CodigosProvincia.csv" ]
		then
			chmod +r "$DIRTAB/CodigosProvincia.csv"
		fi
	else
		notificarReparacion "El archivo de tabla de códigos provincia 'CodigosProvincia.csv' no existe."
		return -1
	fi

	logger "Verificación archivo de tabla de códigos de repuesta gateway" "INF"
	echo "Verificación de archivo de tabla de códigos de repuesta gateway"

	if [ -f "$DIRTAB/CodigosDeRespuestaGateway.csv" ]
	then
		if [ ! -r "$DIRTAB/CodigosDeRespuestaGateway.csv" ]
		then
			chmod +r "$DIRTAB/CodigosDeRespuestaGateway.csv"
		fi
	else
		notificarReparacion "El archivo de tabla de códigos de repuesta gateway 'CodigosDeRespuestaGateway.csv' no existe."
		return -1
	fi

	logger "Verificación del comando arranque.sh" "INF"
	echo "Verificación del comando arranque.sh"

	if [ -f "$DIRBIN/arranque.sh" ]
	then
		if [ ! -x "$DIRBIN/arranque.sh" ]
		then
			chmod +x "$DIRBIN/arranque.sh"
		fi
	else
		notificarReparacion "El comando 'arranque.sh' no existe."
		return -1
	fi

	logger "Verificación del comando detencion.sh" "INF"
	echo "Verificación del comando detencion.sh"

	if [ -f "$DIRBIN/detencion.sh" ]
	then
		if [ ! -x "$DIRBIN/detencion.sh" ]
		then
			chmod +x "$DIRBIN/detencion.sh"
		fi
	else
		notificarReparacion "El comando 'detencion.sh' no existe."
		return -1
	fi

	logger "Verificación del comando proceso.sh" "INF"
	echo "Verificación del comando proceso.sh"

	if [ -f "$DIRBIN/proceso.sh" ]
	then
		if [ ! -x "$DIRBIN/proceso.sh" ]
		then
			chmod +x "$DIRBIN/proceso.sh"
		fi
	else
		notificarReparacion "El comando 'proceso.sh' no existe."
		return -1
	fi

	return 0
}

function exportarVariablesAmbiente {

	logger "Inicialización de las variables de ambientes" "INF"
	echo "Inicialización de las variables de ambientes"

	DIRBIN="$GRUPO/$VAR_DIRBIN"
	DIRTAB="$GRUPO/$VAR_DIRTAB"
	DIRNOV="$GRUPO/$VAR_DIRNOV"
	DIROK="$GRUPO/$VAR_DIROK"
	DIRNOK="$GRUPO/$VAR_DIRNOK"
	DIRPROC="$GRUPO/$VAR_DIRPROC"
	DIRSAL="$GRUPO/$VAR_DIRSAL"
	HCIERRE="$VAR_HCIERRE"

	INICIALIZADO="S"
	export INICIALIZADO
	export GRUPO
	export DIRINST
	export DIRBIN
	export DIRTAB
	export DIRNOV
	export DIROK
	export DIRNOK
	export DIRPROC
	export DIRSAL
	export HCIERRE
}

function ejecutarProceso {

	logger "Ejecutando el proceso en segundo plano" "INF"
	echo "Ejecutando el proceso en segundo plano"

	./arranque.sh

	NOMBRE_PROCESO="proceso.sh"
	PID_PROCESO=`ps -a | grep "$NOMBRE_PROCESO" | awk '{print $1}'`

	logger "El programa se encuentra corriendo con id de proceso: $PID_PROCESO. La hora de cierre es: $HCIERRE (formato hhmmss)" "INF"
	echo "El programa se encuentra corriendo con id de proceso: $PID_PROCESO. La hora de cierre es: $HCIERRE (formato hhmmss)"

	logger "Para detener / arrancar el proceso manualmente, ejecutar el script detencion.sh / arranque.sh del directorio $DIRBIN" "INF"
	echo "Para detener / arrancar el proceso manualmente, ejecutar el script detencion.sh / arranque.sh del directorio $DIRBIN"

	logger "Para modificar el parámetro de hora de cierre, necesita reparar el programa. Ejecutar el script instalador.sh con el parámetro -r del directorio grupo01/inst (sh instalador -r). Aclaración, se perderán todos los datos procesados" "INF"
	echo "Para modificar el parámetro de hora de cierre, necesita reparar el programa. Ejecutar el script instalador.sh con el parámetro -r del directorio grupo01/inst (sh instalador -r). Aclaración, se perderán todos los datos procesados"
}


# Principal

crearArchivoLog

if [ "$INICIALIZADO" == "S" ]
then
	logger "El programa ya se encuentra inicializado" "ALE"
	echo "El programa ya se encuentra inicializado"
	exit 0
fi

if hayInstalacionPrevia
then
	if verificarArchivos
	then
		exportarVariablesAmbiente

		ejecutarProceso

		logger "Programa inicializado satisfactoriamente" "INF"
	    echo "Programa inicializado satisfactoriamente"
	fi
else
	if ! hayInstalacionCorrupta
	then
		notificarInstalacion
	else
		notificarReparacion "Hay directorios dañados o ilegibles."
	fi
fi
