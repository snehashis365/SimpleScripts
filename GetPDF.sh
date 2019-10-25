#!/bin/bash
#This script will generate pdf files for specified files. For e.g:- ./EasyPDF.sh example.c example1.java will give example.pdf, example1.pdf
#Requirements: ghostscript,a2ps.
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
echo -e "******************${LGREEN}PDF Generator${NORMAL} by ${LGREEN}Snehashis${NORMAL}******************"
if [ $# -gt 0 ]
then
	count=$#
	while(($#))
	do
		echo -e "${BLUE}Printing to PDF${NORMAL}.....$1"
		file=${1/.*}
		a2ps -R  $1 -o $file.ps -B -1
		echo -e ${BLUE}Coverting $file.ps to ${LGREEN}PDF
		ps2pdf $file.ps
		echo -e ${LGREEN}$file.pdf Generated.
		echo -e ${BLUE}Removing generated .ps file......
		echo -e $file.ps ${RED}deleted${NORMAL}
		rm $file.ps
		echo -e ${LGREEN}________________
		echo -e ______Done______${NORMAL}
		shift
	done
	echo -e "Printed ${LGREEN} $count ${NORMAL}files."
	echo "**************************************************************"
else
	echo -e "${RED}Need to spicify atleast one file. ${NORMAL}"
fi
