#!/bin/bash

# Parámetros: Carpeta de imágenes y archivo de salida
IMAGES_FOLDER=$1
AUDIO_FILE=$2
OUTPUT_VIDEO=$3

# Verificar parámetros
if [ -z "$IMAGES_FOLDER" ] || [ -z "$AUDIO_FILE" ] || [ -z "$OUTPUT_VIDEO" ]; then
  echo "Uso: $0 <carpeta_imagenes> <archivo_audio|""no""> <archivo_salida>"
  exit 1
fi

FILTER_COMPLEX=""
TRANSITIONS=""
let total=-1
for IMAGE in "$IMAGES_FOLDER"/*.{jpg,jpeg,png}; do
  if [[ "$IMAGE" != *'*'* ]]; then
	  FILTER_COMPLEX+=" -loop 1 -t 3 -i \"${IMAGE}\""
	  total=$((total+1))
	  echo "$total. ${IMAGE}"
  else
	  echo "omitiendo..."
  fi
done

let total2=$(($total-1))
echo "t2=$total2"

# Crear las transiciones
for i in $(seq 0 $total2); do
  OFFSET=$((((i+1) * 2)))
  if [[ $i == 0 ]]; then 
	TRANSITIONS+="[${i}:v][$(($i+1)):v]xfade=transition=fade:duration=1:offset=${OFFSET}[v$(($i+1))]"
  else
	TRANSITIONS+=";[v$(($i))][$(($i+1)):v]xfade=transition=fade:duration=1:offset=${OFFSET}[v$(($i+1))]"
  fi
done

# Comando FFmpeg final
COMMAND="ffmpeg $FILTER_COMPLEX -filter_complex \"$TRANSITIONS\" -map \"[v$(($total))]\"  -c:v libx264 -r 30 -pix_fmt yuv420p -shortest temp_video.mp4"

# Imprimir y ejecutar el comando
echo "Ejecutando el siguiente comando:"
echo $COMMAND
eval $COMMAND

if [[ $2 != "no" ]]; then
	ffmpeg -i temp_video.mp4 -i "$AUDIO_FILE" -c:v libx264 -c:a aac -shortest -strict -2 "$OUTPUT_VIDEO"
	rm -f temp_video.mp4
else
	mv temp_video.mp4 "$OUTPUT_VIDEO"
fi

echo "¡Video creado exitosamente: $OUTPUT_VIDEO!"

