#!/bin/bash
#This script will compile the files specified and generator object files with same name as the C file and Execute them in the other named.
#For e.g:- example.c will give example.out and execute example.out
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
BEEP='\007'
MAKE_MENU=false
COMPILE=true
RUN=true
SHOW_TIME=false
function buildMenu ()
{
	INDEX=1
	declare -a ITEM
	ITEM[0]="Exiting"
	while(($#))
	do
		echo -en "${INDEX}.   ${LGREEN}$1 ${NORMAL}"
		ITEM[$((INDEX++))]=$1
		echo
		shift
	done
	echo
	echo -e "0. ${LGREEN}Exit ${NORMAL}"
	read -p "Select : " CHOICE
	if [ $CHOICE -gt 0 -a $CHOICE -le $INDEX ]
	then
		clear
		echo -e "${BLUE}Selected ->${LGREEN} ${ITEM[$CHOICE]} ${NORMAL}"
	fi

}

#Function to convert and show seconds to more understandable time format
function showTime () 
{
	echo -ne "\n\n${BLUE}Script executed for : ${NORMAL}"
    num=$1
    min=0
    hour=0
    day=0
    if((num>59));then
        let "sec=num%60"
        let "num=num/60"
        if((num>59));then
            let "min=num%60"
            let "num=num/60"
            let "hour=num"
			echo -e "$hour hour(s), $min minute(s) and $sec second(s)\n"
        else
            let "min=num"
			echo -e "$min minute(s) and $sec second(s)\n"
        fi
    else
        let "sec=num"
		echo -e "$sec second(s)\n"
    fi
}

#Function to show help message
function help ()
{
	echo "This script will compile the files specified and generator object files with same name as the C file and Execute them in the other named."
   echo
   echo "Syntax: ./cRun.sh [-h|c|r|m|t|i]"
   echo "options:"
   echo "h     Print this Help."
   echo "c	   Compile/Re-compile"
   echo "r     Run relevant object file without recompiling"
   #echo "v     Verbose mode."
   echo "m     Build a menu with the provided files"
   echo "t     Show total time taken to execute the script"
   echo "i     Install the script to /usr/local/bin to ease"
   echo
}
#Options and options arguments handling:-
while getopts ":hcrmti" opt; do
	case ${opt} in
		h ) #Display Help message
			help
			exit 2
			;;
		c ) #Compile/Re-compile
			COMPILE=true
			RUN=false
			;;
		r ) #Run without re-compiling
			RUN=true
			;;
		m )
			MAKE_MENU=true
			;;
		t ) #Show shell execution duration
			SHOW_TIME=true
			;;
		i ) #Install
			echo -e "${RED}For LINUX/WSL Systems only\n${BLUE}Coming Soon..."
			exit 2
			;;
		\? )
			echo "Invalid option: $OPTARG" 1>&2
			exit 2
			;;
	esac
done
shift $((OPTIND -1))

clear
echo -e "${LGREEN}Multiple ${BLUE}C${NORMAL} files compiler by ${LGREEN}Snehashis${NORMAL}."
if [ $# -gt 0 ]
then
	count=$#
	while(($#))
	do
		echo -e "${BLUE}Compiling${NORMAL}.....$1"

		DOT_C=".c"
		cc $1 -o ${1/$DOT_C*/.out} -lm
		echo -e "${LGREEN}Done ${NORMAL}"
		shift
	done
	echo -e "Processed ${LGREEN} $count ${NORMAL}files."
	echo -e "${LGREEN}Object files should be generated${NORMAL} if no ${RED}errors${NORMAL} were encountered by ${BLUE}GCC compiler${LGREEN} ignore warnings${NORMAL}."
else
	echo -e "${RED}Experimental!!!\n${NORMAL}Building Menu...\n"
	buildMenu *.c
fi
if [ $SHOW_TIME = true ]
then
	showTime $SECONDS
fi