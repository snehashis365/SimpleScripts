#!/bin/bash
#This script will compile the files specified and generator object files with same name as the C file. For e.g:- example.c will give example.out
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
echo -e "${LGREEN}Multiple ${BLUE}C${NORMAL} files compiler by ${LGREEN}Snehashis${NORMAL}."
if [ $# -gt 0 ]
then
	count=$#
	while(($#))
	do
		echo -e "${BLUE}Compiling${NORMAL}.....$1"

		a=".c"
		cc $1 -o ${1/$a*/.out} -lm
		echo -e "${LGREEN}Done ${NORMAL}"
		shift
	done
	echo -e "Processed ${LGREEN} $count ${NORMAL}files."
	echo -e "${LGREEN}Object files should be generated${NORMAL} if no ${RED}errors${NORMAL} were encountered by ${BLUE}GCC compiler${LGREEN} ignore warnings${NORMAL}."
else
	echo -e "${RED}Need to spicify atleast one file. ${NORMAL}"
fi 
