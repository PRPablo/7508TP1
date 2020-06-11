#!/bin/bash

GRUPO="$(cd "$(dirname "$0")";cd ..;pwd -P)"
DIRINST="$GRUPO/inst"

# Funciones

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

	if [[ -d "$GRUPO/$(variableConfigurada DIRBIN)" 
		&&  -d "$GRUPO/$(variableConfigurada DIRTAB)" 
	    &&  -d "$GRUPO/$(variableConfigurada DIRNOV)"
	    &&  -d "$GRUPO/$(variableConfigurada DIROK)"
	    &&  -d "$GRUPO/$(variableConfigurada DIRNOK)"
	    &&  -d "$GRUPO/$(variableConfigurada DIRPROC)"
	    &&  -d "$GRUPO/$(variableConfigurada DIRSAL)"
	    &&  ! -z "$(variableConfigurada HCIERRE)" ]]
	then
		return 0
	else
		return -1
	fi
}

function hayInstalacionCorrupta {

	if [[ -d "$GRUPO/$(variableConfigurada DIRBIN)"
		|| -d "$GRUPO/$(variableConfigurada DIRTAB)"
	    || -d "$GRUPO/$(variableConfigurada DIRNOV)"
	    || -d "$GRUPO/$(variableConfigurada DIROK)"
	    || -d "$GRUPO/$(variableConfigurada DIRNOK)"
	    || -d "$GRUPO/$(variableConfigurada DIRPROC)"
	    || -d "$GRUPO/$(variableConfigurada DIRSAL)"
	    || ! -z "$(variableConfigurada HCIERRE)" ]]
	then
		return 0
	else
		return -1
	fi
}

function mostrarConfiguracion {

	echo "TP SO7508 1º Cuatrimestre 2020. Copyright © Grupo 01"
	echo "Directorio padre:                $GRUPO"
	echo "Script Instalador:               $GRUPO/inst/instalador.sh"
	echo "Log de la instalación:           $GRUPO/inst/instalador.log"
	echo "Configuración de la instalación: $GRUPO/inst/instalador.conf"
	echo "Directorio de ejecutables:       $GRUPO/$DIRBIN"
	echo "Directorio de tablas:            $GRUPO/$DIRTAB"
	echo "Directorio de novedades:         $GRUPO/$DIRNOV"
	echo "Directorio de aceptados:         $GRUPO/$DIROK"	
	echo "Directorio de rechazados:        $GRUPO/$DIRNOK"
	echo "Directorio de procesados:        $GRUPO/$DIRPROC"
	echo "Directorio de salidas:           $GRUPO/$DIRSAL"
	echo "Hora de Cierre:                  $HCIERRE" "(formato hhmmss)"

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

function logger {

	echo "$1" "$2"

	return 0
}

function crearArchivoLog {

	logger "Creando archivo instalador.log" "INF"

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

	echo "Estado de la instalación: $ESTADO_INSTALACION"

	confirmo="false"
	while [[ "$confirmo" == "false" ]]
	do
		echo "¿Confirma la instalación? (SI-NO)"
		logger "¿Confirma la instalación? (SI-NO)" "INF"

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
			echo "Por favor, responda únicamente SI-NO"
			logger "Respuesta de confirmación incorrecta" "ALE"
		fi
	done
}

function grabarArchivoConfiguracion {
	
	logger "Grabando archivo de configuración: grupo01/inst/instalador.conf" "INF"
	echo "Grabando archivo de configuración: grupo01/inst/instalador.conf"

	echo "GRUPO-$GRUPO" > $DIRINST/instalador.conf
	echo "DIRINST-$DIRINST" >> $DIRINST/instalador.conf
	echo "DIRBIN-$DIRBIN" >> $DIRINST/instalador.conf
	echo "DIRTAB-$DIRTAB" >> $DIRINST/instalador.conf
	echo "DIRNOV-$DIRNOV" >> $DIRINST/instalador.conf
	echo "DIROK-$DIROK" >> $DIRINST/instalador.conf
	echo "DIRNOK-$DIRNOK" >> $DIRINST/instalador.conf
	echo "DIRPROC-$DIRPROC" >> $DIRINST/instalador.conf
	echo "DIRSAL-$DIRSAL" >> $DIRINST/instalador.conf
	echo "HCIERRE-$HCIERRE" >> $DIRINST/instalador.conf
}

function crearDirectorios {

	logger "Creando directorios del programa" "INF"
	echo "Creando directorios del programa"

	logger  "Directorio seleccionado de ejecutables: $GRUPO/$DIRBIN" "INF"
	mkdir -p "$GRUPO/$DIRBIN"

	logger "Directorio seleccionado de tablas: $GRUPO/$DIRTAB" "INF"
	mkdir -p "$GRUPO/$DIRTAB"

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
}

function instalar {

	logger "Iniciando instalación" "INF"
	echo "Iniciando instalación"

	cargarConfiguracion

	crearArchivoLog	

	while [ "$ESTADO_INSTALACION" == "CONF" ]
	do
		directoriosSeleccionados=()

		configuracionDirectorios

		mostrarConfiguracion

		confirmarConfiguracion
	done

	grabarArchivoConfiguracion

	crearDirectorios

	logger "Instalación finalizada correctamente" "INF"
	echo "Instalación finalizada correctamente"

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
	    	rm -R "$dir"
	    fi
	done
}

# Principal

if [[ $1 != "-r" ]]
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
		echo "El Programa se encuentra instalado correctamente"
		cargarConfiguracion
		mostrarConfiguracion
	fi
else
	if ! hayInstalacionPrevia
	then
		reparar
	else
		echo "El Programa se encuentra instalado correctamente"
		cargarConfiguracion
		mostrarConfiguracion
	fi
fi

exit 0
