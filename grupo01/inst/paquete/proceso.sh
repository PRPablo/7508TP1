#proceso.sh
	#HCIERRE="$GRUPO/$VAR_HCIERRE"

PATH_NOVEDADES="$DIRBIN" 
PATH_ACEPTADOS="$DIROK"
PATH_RECHAZADOS="$DIRNOK"
PATH_SALIDA="$DIRSAL"
PATH_PROCESADOS="$DIRPROC"
ARCH_COMERCIO="$DIRTAB/CodigosComercio.csv"
ARCH_PROVINCIA="$DIRTAB/CodigosProvincia.csv"
ARCH_RESPUESTA="$DIRTAB/CodigosDeRespuestaGateway.csv"

function logger {

	sh $DIRBIN/logger.sh "$DIRPROC" "proceso" "$1" "$2"

	return 0
}

ValidarArchivoNoVacioYRegular()
{
   if [ -s "$file" ]
   then
	if [ -r "$file" ]
	then
		if [ -f "$file" ]
		then
			return 0
		fi
        	logger "$file el archivo no es normal"

	fi
	logger "$file el archivo no es regular"	
   fi	
   logger "$file el archivo es vacio"
 
   return -1   
}

ValidarNombreArchivo()
{
   #nombreArchivoValido=$(echo "$file" | sed "s/[0-9]\{4\}-[A-B]-[0-9]\{8\}/S/")
   nombreArchivoValido= echo "$file" | grep -c  "^\([0-9]{4}\)-\([A-Z]\)-\([0-9]{8}\)*$"
   
   if [ "$?" -eq 0 ]
   then
	mv "$file" "$PATH_RECHAZADOS"
	logger "el archivo $file no cumple el formato de nombre valido se mueve a RECHAZADOS"
    fi	   

}



validarArchivo()
{
   if ValidarArchivoNoVacioYRegular;	   
   then
	    if ValidarNombreArchivo;
	    then 
         	    return 0;
	    	    
  	    fi
   fi

   return -1
}


procesamos()
{
	for file in "$PATH_ACEPTADOS/"*;
	do
		if [ ! "$(ls $PATH_ACEPTADOS/)"]
		then
			logger "no hay mas archivos para procesar en ACEPTADOS"
			return 0
		fi	

		transaccionDate=$(echo "$file" | sed "s/^\([^-]*\)-.*/\1/");
                StateCode=$(echo "$file" | sed "s/^[^-]*-\([^-]*\)-.*/\1/");
                MerchantCode=$(echo "$file" | sed "s/^[^-]*-[^-]*-\([^-]*\)/\1/");


                #verifico si StateCode existe en el ARCHIVO DE CODIGOS-PROVINCIAS
                if ! ( grep -q "$StateCode" "$ARCH_PROVINCIA" )
                then
                        mv "$file" "$PATH_RECHAZADOS"
                        log "EL ARCHIVO $file NO ES VALIDO PORQUE NO EXISTE EL CODIGO EN EL ARCHIVO PROVINCIAS"

                fi
		
	done
}


# Principal

CICLO=0
PROCESO_ACTIVO="S"

function detener_proceso {
   let PROCESO_ACTIVO="N"
}

#atrapamos la senial para detener el proceso
trap detener_proceso SIGINT SIGTERM


while [ "$PROCESO_ACTIVO" == "S" ]
do
        #verificandoSystemInicializado()

	for file in "$PATH_NOVEDADES/"*.csv;
        do
	    let "CICLO=CICLO+1"
            logger "Voy por el ciclo: $CICLO"

	    if [ "$(ls $PATH_NOVEDADES/)" ]
	    then 
                   if validarArchivo;
                   then 
                       mv "$file" "$PATH_ACEPTADOS"
                       logger "EL ARCHIVO $file ES VALIDO SE MUEVE A ACEPTADOS $PATH_ACEPTADOS"
                   else
                       mv "$file" "$PATH_RECHAZADOS"
                       logger "EL ARCHIVO $file NO ES VALIDO SE MUEVE A RECHAZADOS $PATH_RECHAZADOS"
                   fi	

            else 
              
		logger "No hay mas archivos en $PATH_NOVEDADES"
	   fi
	  
        done  

        if [ "$(ls $PATH_ACEPTADOS/)" ]
	then
		procesamos
	fi

       sleep 10
done  

logger "Proceso finalizado correctamente" "INF"
echo "Procesif [ "$?" -eq 0 ]
