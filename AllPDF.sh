#!/bin/bash
#This script will generate pdf files for all the files in the current directory. For e.g:- ./AllPDF.sh will give pdf for all the files inside the directory compatible withb text editable files only
#Requirements: ghostscript,a2ps.
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
echo -e "******************${LGREEN}PDF Generator${NORMAL} by ${LGREEN}Snehashis${NORMAL}******************"
declare -i count=0
	for f in *.*; do
			echo -e "${BLUE}Printing to PDF${NORMAL}.....$1"
			file=${f/.*}
			a2ps -R  $f -o $file.ps -B -1
			echo -e ${BLUE}Coverting $file.ps to ${LGREEN}PDF
			ps2pdf $file.ps
			echo -e ${LGREEN}$file.pdf Generated.
			echo -e ${BLUE}Removing generated .ps file......
			echo -e $file.ps ${RED}deleted${NORMAL}
			rm $file.ps
			echo -e ${LGREEN}________________
			echo -e ______Done______${NORMAL}
			count=$((count +1))
		done
	echo -e "Printed ${LGREEN} $count ${NORMAL}files."
echo "**************************************************************"
