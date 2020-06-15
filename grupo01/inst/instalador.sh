#!/bin/bash

GRUPO="$(cd "$(dirname "$0")";cd ..;pwd -P)"
DIRINST="$GRUPO/inst"
DIRPAQUETE="$DIRINST/paquete"

# Funciones

function logger {

	sh $DIRPAQUETE/logger.sh "$DIRINST" "instalador" "$1" "$2"

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

	if [[ ! -z "$VAR_DIRBIN" && -d "$GRUPO/$VAR_DIRBIN"
		|| ! -z "$VAR_DIRTAB" && -d "$GRUPO/$VAR_DIRTAB"
	    || ! -z "$VAR_DIRNOV" && -d "$GRUPO/$VAR_DIRNOV"
	    || ! -z "$VAR_DIROK" && -d "$GRUPO/$VAR_DIROK"
	    || ! -z "$VAR_DIRNOK" && -d "$GRUPO/$VAR_DIRNOK"
	    || ! -z "$VAR_DIRPROC" && -d "$GRUPO/$VAR_DIRPROC"
	    || ! -z "$VAR_DIRSAL" && -d "$GRUPO/$VAR_DIRSAL"
	    || ! -z "$VAR_HCIERRE" ]]
	then
		return 0
	else
		return -1
	fi
}

function mostrarConfiguracion {

	logger "TP SO7508 1º Cuatrimestre 2020. Copyright © Grupo 01" "INF"
	echo "TP SO7508 1º Cuatrimestre 2020. Copyright © Grupo 01"
	logger "Directorio padre:                $GRUPO" "INF"
	echo "Directorio padre:                $GRUPO"
	logger "Script Instalador:               $GRUPO/inst/instalador.sh" "INF"
	echo "Script Instalador:               $GRUPO/inst/instalador.sh"
	logger "Log de la instalación: $GRUPO/inst/instalador.log" "INF"
	echo "Log de la instalación:               $GRUPO/inst/instalador.log"
	logger "Configuración de la instalación: $GRUPO/inst/instalador.conf" "INF"
	echo "Configuración de la instalación:     $GRUPO/inst/instalador.conf"
	logger "Directorio de ejecutables: $GRUPO/$DIRBIN" "INF"
	echo "Directorio de ejecutables:         $GRUPO/$DIRBIN"
	logger "Directorio de tablas: $GRUPO/$DIRTAB" "INF"
	echo "Directorio de tablas:              $GRUPO/$DIRTAB"
	logger "Directorio de novedades: $GRUPO/$DIRNOV" "INF"
	echo "Directorio de novedades:           $GRUPO/$DIRNOV"
	logger "Directorio de aceptados: $GRUPO/$DIROK" "INF"
	echo "Directorio de aceptados:           $GRUPO/$DIROK"	
	logger "Directorio de rechazados: $GRUPO/$DIRNOK" "INF"
	echo "Directorio de rechazados:          $GRUPO/$DIRNOK"
	logger "Directorio de procesados: $GRUPO/$DIRPROC" "INF"
	echo "Directorio de procesados:          $GRUPO/$DIRPROC"
	logger "Directorio de salidas: $GRUPO/$DIRSAL" "INF"
	echo "Directorio de salidas:             $GRUPO/$DIRSAL"
	logger "Hora de Cierre (formato hhmmss): $HCIERRE" "INF"
	echo "Hora de Cierre (formato hhmmss):   $HCIERRE"

	return 0
}

function cargarConfiguracion {

	if [ "$(variableConfigurada DIRBIN)" ]
	then 
		DIRBIN="$(variableConfigurada DIRBIN)"
	else
		DIRBIN=bin
	fi

	if [ "$(variableConfigurada DIRTAB)" ]
	then 
		DIRTAB="$(variableConfigurada DIRTAB)"
	else
		DIRTAB=tab
	fi

	if [ "$(variableConfigurada DIRNOV)" ]
	then 
		DIRNOV="$(variableConfigurada DIRNOV)"
	else
		DIRNOV=nov
	fi

	if [ "$(variableConfigurada DIROK)" ]
	then 
		DIROK="$(variableConfigurada DIROK)"
	else
		DIROK=ok
	fi

	if [ "$(variableConfigurada DIRNOK)" ]
	then 
		DIRNOK="$(variableConfigurada DIRNOK)"
	else
		DIRNOK=nok
	fi

	if [ "$(variableConfigurada DIRPROC)" ]
	then 
		DIRPROC="$(variableConfigurada DIRPROC)"
	else
		DIRPROC=proc
	fi

	if [ "$(variableConfigurada DIRSAL)" ]
	then 
		DIRSAL="$(variableConfigurada DIRSAL)"
	else
		DIRSAL=sal
	fi

	if [ "$(variableConfigurada HCIERRE)" ]
	then 
		HCIERRE="$(variableConfigurada HCIERRE)"
	else
		HCIERRE=180000 #(formato hhmmss)
	fi

	ESTADO_INSTALACION="CONF"

	return 0
}

function crearArchivoLog {

	chown $USER:$USER "$GRUPO" -R
	chmod 777 "$GRUPO" -R

	if [ ! -f "$DIRINST/instalador.log" ]
	then
		touch "$DIRINST/instalador.log"
	fi

	if [ ! -r "$DIRINST/instalador.log" ]
	then
		logger "Seteando permiso de lectura a instalador.log" "INF"
		chmod +r "$DIRINST/instalador.log"
		if ! [ $? -eq 0 ]
		then
			logger "Falló el seteo de permiso de lectura a instalador.log" "ERR"
			return 1
		fi
	fi

	logger "Archivo de instalador.log se ha creado satisfactoriamente en el directorio $DIRINST" "INF"

	return 0
}

function validarDirectorioReservado {

	if [ "$1" == "inst" ]
	then
		logger "El directorio $1 se encuentra reservado" "ALE"
		echo "El directorio $1 se encuentra reservado. Por favor, vuelva a ingresar el directorio."
		return -1
	fi

	return 0
}

function validarDirectorioSeleccionado {

	for i in "${directoriosSeleccionados[@]}"
	do
		if [[ "$i" = "$1" ]]
		then
			logger "El directorio $1 ya se encuentra seleccionado para otro directorio" "ALE"
			echo "El directorio $1 ya se encuentra seleccionado para otro directorio. Por favor, vuelva a ingresar el directorio."
			return -1
		fi
	done

	if validarDirectorioReservado "$1"
	then
		return 0
	else
		return -1
	fi
}

function validarRespuesta {

	read RESPUESTA

	if [[ "$RESPUESTA" = "" ]]
	then
		RESPUESTA=`eval echo '$'$1`
		eval "$1=\"$RESPUESTA\""
		return 0

	elif validarDirectorioSeleccionado "$RESPUESTA"
	then
		eval "$1=\"$RESPUESTA\""
		return 0
	else
		return -1
	fi
}

function validarRespuestaHoraCierre {

	read RESPUESTA

	if [[ "$RESPUESTA" = "" ]]
	then
		RESPUESTA=`eval echo '$'$1`
		eval "$1=\"$RESPUESTA\""
		return 0

	elif  echo "$RESPUESTA" | grep '^\(0[0-9]\|1[0-9]\|2[0-3]\)\([0-5][0-9]\)\([0-5][0-9]\)$'
	then
		eval "$1=\"$RESPUESTA\""
		return 0
	else
		logger "La Hora de Cierre $RESPUESTA es incorrecta (debe tener el formato hhmmss)." "ALE"
		echo "La Hora de Cierre $RESPUESTA es incorrecta (debe tener el formato hhmmss). Por favor, vuelva a ingresar la Hora de Cierre."
		return -1
	fi
}

function configuracionDirectorios() {

	echo "CONFIGURACIÓN DE DIRECTORIOS"
	logger "Iniciando configuración de directorios." "INF"

	logger "Configuración del directorio de ejecutables." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de ejecutables ($DIRBIN): "
		if validarRespuesta DIRBIN
		then
			directoriosSeleccionados+=("$DIRBIN")
			logger "El usuario seleccionó $DIRBIN como directorio de ejecutables" "INF"

			esRespuestaValida="true"
		fi
	done
	
	logger "Configuración del directorio de tablas." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de tablas ($DIRTAB): "
		if validarRespuesta DIRTAB
		then
			directoriosSeleccionados+=("$DIRTAB")
			logger "El usuario seleccionó $DIRTAB como directorio de tablas" "INF"

			esRespuestaValida="true"
		fi
	done

	logger "Configuración del directorio de novedades." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de novedades ($DIRNOV): "
		if validarRespuesta DIRNOV
		then
			directoriosSeleccionados+=("$DIRNOV")
			logger "El usuario seleccionó $DIRNOV como directorio de novedades" "INF"

			esRespuestaValida="true"
		fi
	done

	logger "Configuración del directorio de aceptados." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de aceptados ($DIROK): "
		if validarRespuesta DIROK
		then
			directoriosSeleccionados+=("$DIROK")
			logger "El usuario seleccionó $DIROK como directorio de aceptados" "INF"

			esRespuestaValida="true"
		fi
	done

	logger "Configuración del directorio de rechazados." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de rechazados ($DIRNOK): "
		if validarRespuesta DIRNOK
		then
			directoriosSeleccionados+=("$DIRNOK")
			logger "El usuario seleccionó $DIRNOK como directorio de rechazados" "INF"

			esRespuestaValida="true"
		fi
	done

	logger "Configuración del directorio de procesados." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de procesados ($DIRPROC): "
		if validarRespuesta DIRPROC
		then
			directoriosSeleccionados+=("$DIRPROC")
			logger "El usuario seleccionó $DIRPROC como directorio de procesados" "INF"

			esRespuestaValida="true"
		fi
	done
	
	logger "Configuración del directorio de salida." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar el directorio de salida ($DIRSAL): "
		if validarRespuesta DIRSAL
		then
			directoriosSeleccionados+=("$DIRSAL")
			logger "El usuario seleccionó $DIRSAL como directorio de salida" "INF"

			esRespuestaValida="true"
		fi
	done

	logger "Configuración Hora de Cierre." "INF"
	esRespuestaValida="false"
	while [[ "$esRespuestaValida" = "false" ]]
	do
		echo "Seleccionar Hora de Cierre ($HCIERRE): "
		if validarRespuestaHoraCierre HCIERRE
		then
			logger "El usuario seleccionó $HCIERRE como hora de cierre" "INF"

			esRespuestaValida="true"
		fi
	done

	ESTADO_INSTALACION="LISTA"
}

function confirmarConfiguracion {

	logger "Estado de la instalación: $ESTADO_INSTALACION" "INF"
	echo "Estado de la instalación: $ESTADO_INSTALACION"

	confirmo="false"
	while [[ "$confirmo" == "false" ]]
	do
		logger "¿Confirma la instalación? (SI-NO)" "INF"
		echo "¿Confirma la instalación? (SI-NO)"

		read confirmacion
		logger "Respuesta de confirmación: $confirmacion" "INF"

		confirmacion=$(echo $confirmacion | awk '{print tolower($0)}')

		if [[ "$confirmacion" = "si" ]]
		then
			ESTADO_INSTALACION="INST"
			confirmo="true"

		elif [[ "$confirmacion" = "no" ]]
		then
			ESTADO_INSTALACION="CONF"
			confirmo="true"
			clear
		else
			logger "Respuesta de confirmación incorrecta" "ALE"
			echo "Por favor, responda únicamente SI-NO"
		fi
	done
}

function grabarArchivoConfiguracion {
	
	logger "Grabando archivo de configuración: grupo01/inst/instalador.conf" "INF"
	echo "Grabando archivo de configuración: grupo01/inst/instalador.conf"

	echo "GRUPO-$GRUPO" > "$DIRINST/instalador.conf"
	echo "DIRINST-$DIRINST" >> "$DIRINST/instalador.conf"
	echo "DIRBIN-$DIRBIN" >> "$DIRINST/instalador.conf"
	echo "DIRTAB-$DIRTAB" >> "$DIRINST/instalador.conf"
	echo "DIRNOV-$DIRNOV" >> "$DIRINST/instalador.conf"
	echo "DIROK-$DIROK" >> "$DIRINST/instalador.conf"
	echo "DIRNOK-$DIRNOK" >> "$DIRINST/instalador.conf"
	echo "DIRPROC-$DIRPROC" >> "$DIRINST/instalador.conf"
	echo "DIRSAL-$DIRSAL" >> "$DIRINST/instalador.conf"
	echo "HCIERRE-$HCIERRE" >> "$DIRINST/instalador.conf"
}

function crearDirectorios {

	logger "Creando directorios del programa" "INF"
	echo "Creando directorios del programa"

	logger  "Directorio seleccionado de ejecutables: $GRUPO/$DIRBIN" "INF"
	mkdir  -m777  -p "$GRUPO/$DIRBIN"
	cp "$DIRPAQUETE/"*.sh "$GRUPO/$DIRBIN"

	logger "Directorio seleccionado de tablas: $GRUPO/$DIRTAB" "INF"
	mkdir -m777 -p "$GRUPO/$DIRTAB"
	cp "$DIRPAQUETE/"*.csv "$GRUPO/$DIRTAB"

	logger "Directorio seleccionado de novedades: $GRUPO/$DIRNOV" "INF"
	mkdir -p "$GRUPO/$DIRNOV"

	logger "Directorio seleccionado de aceptados: $GRUPO/$DIROK" "INF"
	mkdir -p "$GRUPO/$DIROK"

	logger "Directorio seleccionado de rechazados: $GRUPO/$DIRNOK" "INF"
	mkdir -p "$GRUPO/$DIRNOK"

	logger "Directorio seleccionado de procesados: $GRUPO/$DIRPROC" "INF"
	mkdir -p "$GRUPO/$DIRPROC"

	logger "Directorio seleccionado de salida: $GRUPO/$DIRSAL" "INF"
	mkdir -p "$GRUPO/$DIRSAL"

	chown $USER:$USER "$GRUPO" -R
	chmod 777 "$GRUPO" -R
	if ! [ $? -eq 0 ]
	then
		logger "Falló el seteo de permiso de lectura, escritura y ejecución para los directorios" "ERR"
		return 1
	fi

}

function instalar {

	logger "Iniciando instalación" "INF"
	echo "Iniciando instalación"

	cargarConfiguracion	

	while [ "$ESTADO_INSTALACION" == "CONF" ]
	do
		directoriosSeleccionados=()

		configuracionDirectorios

		mostrarConfiguracion

		confirmarConfiguracion
	done

	grabarArchivoConfiguracion

	crearDirectorios

	logger "Instalación finalizada satisfactoriamente" "INF"
	echo "Instalación finalizada satisfactoriamente"

	return 0
}

function reparar() {

	logger "Iniciando reparación del programa" "INF"
	echo "Iniciando reparación del programa"

	eliminarInstalacionPrevia

	instalar
}

function eliminarInstalacionPrevia {

	logger "Eliminado instalación previa" "INF"
	echo "Eliminado instalación previa"

	for dir in "$GRUPO"/*
	do
	    if [ "$dir" != "$GRUPO/inst" ]
	    then
	    	find "$dir" ! -name "*.log" -delete 2>/dev/null
	    fi
	done
}

# Principal

crearArchivoLog

if [[ "$1" != "-r" ]]
then
	if ! hayInstalacionPrevia
	then
		if ! hayInstalacionCorrupta
		then
			instalar
		else
			reparar
		fi
	else
		logger "El Programa ya se encuentra instalado correctamente" "INF"
		echo "El Programa ya se encuentra instalado correctamente"
		cargarConfiguracion
		mostrarConfiguracion
	fi
else
	reparar
fi

exit 0
