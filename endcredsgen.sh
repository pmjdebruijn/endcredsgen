#!/bin/bash
#
# Copyright (c) 2019 Pascal de Bruijn
#
# SPDX-License-Identifier: MIT
#



if [[ $# -ne 1 ]]; then
  echo "$0 credits.csv"
  exit 1
fi

INPUT=$1



TEMPFILE=$(tempfile -d "." -p "scrol" -s ".svg")
exittrap() { rm ${TEMPFILE}; }
trap exittrap EXIT



SCROLLSPEED=4

FRAMERATE=30

VIDEO_WIDTH=3840
VIDEO_HEIGHT=2160

GUTTER=60

DEFAULT_FONT_FAMILY="Roboto Condensed"
DEFAULT_FONT_HEIGHT=64
LEADING=32


SECT_X=$(( ${VIDEO_WIDTH} / 2 ))
ROLE_X=$(( ( ${VIDEO_WIDTH} - ${GUTTER} ) / 2 ))
NAME_X=$(( ( ${VIDEO_WIDTH} + ${GUTTER} ) / 2 ))



echo "<svg viewBox=\"0 0 ${VIDEO_WIDTH} 32767\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\">" > ${TEMPFILE}

echo "<rect x=\"-1%\" y=\"-1%\" width=\"102%\" height=\"102%\" fill=\"black\"/>" >> ${TEMPFILE}



Y=${VIDEO_HEIGHT}



while IFS=';' read ROLE NAME LINE_HEIGHT FONT_FAMILY; do

  [[ "${LINE_HEIGHT}" == "" ]] && LINE_HEIGHT=${DEFAULT_FONT_HEIGHT}
  [[ "${FONT_FAMILY}" == "" ]] && FONT_FAMILY=${DEFAULT_FONT_FAMILY}

  if [[ "${ROLE}" == "_IMAGE" ]]; then

    case "${NAME##*.}" in
      svg) NAME="data:image/svg+xml;base64,$(cat ${NAME} | base64 -w 0)" ;;
      png) NAME="data:image/png;base64,$(cat ${NAME} | base64 -w 0)" ;;
      jpg) NAME="data:image/jpeg;base64,$(cat ${NAME} | base64 -w 0)" ;;
      *) echo "WARNING: ${NAME} unrecognized image format, will fail to render!" ;;
    esac

    echo "<image x=\"0\" y=\"${Y}\" width=\"${VIDEO_WIDTH}\" height=\"${LINE_HEIGHT}\" xlink:href=\"${NAME}\"/>" >> ${TEMPFILE}

    Y=$(( ${Y} + ${LINE_HEIGHT} ))
  else
    Y=$(( ${Y} + ${LINE_HEIGHT} ))

    NAME=$(echo ${NAME} | tr 'a-z' 'A-Z')

    if [[ -z "${NAME}" ]]; then
      echo "<text text-anchor=\"middle\" x=\"${SECT_X}\" y=\"${Y}\" style=\"font-family: ${FONT_FAMILY}; font-weight: bold; font-size: ${LINE_HEIGHT}px; fill: white;\">${ROLE}</text>" >> ${TEMPFILE}
    else
      echo "<text text-anchor=\"end\"    x=\"${ROLE_X}\" y=\"${Y}\" style=\"font-family: ${FONT_FAMILY}; font-weight: bold; font-size: ${LINE_HEIGHT}px; fill: white;\">${ROLE}</text>" >> ${TEMPFILE}
      echo "<text text-anchor=\"start\"  x=\"${NAME_X}\" y=\"${Y}\" style=\"font-family: ${FONT_FAMILY}; font-weight: bold; font-size: ${LINE_HEIGHT}px; fill: white;\">${NAME}</text>" >> ${TEMPFILE}
    fi
  fi

  Y=$(( ${Y} + ${LEADING} ))

done <<< $(cat ${INPUT})

echo '</svg>' >> ${TEMPFILE}



FRAMES=$(( ( ${Y} + ${DEFAULT_FONT_HEIGHT} ) / ${SCROLLSPEED} ))



ffmpeg -r ${FRAMERATE} -loop 1 -i ${TEMPFILE} -filter:v "crop=${VIDEO_WIDTH}:${VIDEO_HEIGHT}:0:n*${SCROLLSPEED}" -frames:v ${FRAMES} -c:v libx264 -preset ultrafast -tune fastdecode -crf 0 -g ${FRAMERATE} -movflags faststart ${INPUT}.mp4
