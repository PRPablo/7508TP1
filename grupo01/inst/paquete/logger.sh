#!/bin/bash

DIRLOG="$1"
ORIGEN="$2"
MENSAJE="$3"

if [ ! -z "$4" ]
then
	NIVEL="$4"
else
	NIVEL="INF"
fi

echo "$(date +%Y-%m-%d_%H:%M:%S)-$NIVEL-$MENSAJE-$ORIGEN-$USER" >> "$DIRLOG/$ORIGEN.log"

exit 0
