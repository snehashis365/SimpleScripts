#!/bin/bash
#This script will print the files specified and generate pdf files with same name as the C file. For e.g:- example.c will give example.out
#Requirements: ghostscript,
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
echo -e "${LGREEN}Multiple ${BLUE}C${NORMAL} files printer by ${LGREEN}Snehashis${NORMAL}."
if [ $# -gt 0 ]
then
	count=$#
	while(($#))
	do
		echo -e "${BLUE}Printing to PDF${NORMAL}.....$1"

		a=".c"
		a2ps -R  $1 -o ${1/$a*/.ps} -B -1
		ps2pdf ${1/$a*/.ps}
		#cc $1 -o ${1/$a*/.out} -lm
		echo -e "${LGREEN}Done ${NORMAL}"
              rm ${1/$a*/.ps}
		shift
	done
	echo -e "Printed ${LGREEN} $count ${NORMAL}files."
	echo -e "${LGREEN}PDF files should be generated${NORMAL} if no ${RED}errors${NORMAL} were encountered by ${BLUE}the packages used${NORMAL}."
else
	echo -e "${RED}Need to spicify atleast one file. ${NORMAL}"
fi
