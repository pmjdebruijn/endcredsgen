#!/bin/bash
#
# Copyright (c) 2019 Pascal de Bruijn
#
# SPDX-License-Identifier: MIT
#



if [[ $# -ne 1 ]]; then
  echo "$0 card.csv"
  exit 1
fi

INPUT=$1



TEMPFILE=$(echo ${INPUT} | awk -F '.' '{print $1 ".svg"}')



WIDTH=3840
HEIGHT=2160

GUTTER=60

FONTSIZE=64
LINEHEIGHT=96


SECT_X=$(( ${WIDTH} / 2 ))
ROLE_X=$(( ( ${WIDTH} - ${GUTTER} ) / 2 ))
NAME_X=$(( ( ${WIDTH} + ${GUTTER} ) / 2 ))



echo "<svg viewBox=\"0 0 ${WIDTH} ${HEIGHT}\">"									 > ${TEMPFILE}
echo "<style>"													>> ${TEMPFILE}
echo ".sect { font-family: Roboto Condensed; font-weight: bold; font-size: ${FONTSIZE}px; fill: white; }"       >> ${TEMPFILE}
echo ".role { font-family: Roboto Condensed; font-weight: bold; font-size: ${FONTSIZE}px; fill: white; }"	>> ${TEMPFILE}
echo ".name { font-family: Roboto Condensed; font-weight: bold; font-size: ${FONTSIZE}px; fill: white; }"	>> ${TEMPFILE}
echo "</style>"													>> ${TEMPFILE}

echo "<rect x=\"-1%\" y=\"-1%\" width=\"102%\" height=\"102%\" fill=\"black\"/>"				>> ${TEMPFILE}



Y=$(( ( ${HEIGHT} - ( $(cat ${INPUT} | wc -l) * ${LINEHEIGHT} ) ) / 2 ))



while IFS=';' read ROLE NAME; do

  Y=$(( ${Y} + ${LINEHEIGHT} ))

  NAME=$(echo ${NAME} | tr 'a-z' 'A-Z')

  if [[ -z "${NAME}" ]]; then
    echo "echo <text text-anchor=\"middle\" x=\"${SECT_X}\" y=\"${Y}\" class=\"sect\">${ROLE}</text>"		>> ${TEMPFILE}
  else
    echo "echo <text text-anchor=\"end\"    x=\"${ROLE_X}\" y=\"${Y}\" class=\"role\">${ROLE}</text>"		>> ${TEMPFILE}
    echo "echo <text text-anchor=\"start\"  x=\"${NAME_X}\" y=\"${Y}\" class=\"name\">${NAME}</text>"		>> ${TEMPFILE}
  fi

done <<< $(cat ${INPUT})

echo '</svg>'													>> ${TEMPFILE}

