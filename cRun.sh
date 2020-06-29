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
DEL_OBJ=false
SHOW_TIME=false

#Install the script to local bin
function install ()
{
	INSTALLED=false
	COPIED=false
	PERMISSION=false
	if [ -f "/usr/local/bin/cRun" ]
	then
		echo -e "cRun Already present at local bin\nTo update script run the install option from the newer script file pulled\nor from same directory as the newer script\n\nLooking for cRun.sh in current directory\n"
		INSTALLED=true
	fi
	if [ "$INSTALLED" = false ]; then
		echo -e "${RED}For LINUX System/WSL Environment only\n${NORMAL}After this you can run the script from any directory without having to copy it manually\n${BLUE}Checking Root..."
	else
		echo -e "Attempting Update (Any manual modification will be reverted)"
	fi
	if [ $EUID -ne 0 ]
	then
		echo -e "${RED}Root Access Required\n${NORMAL}Attempting 'sudo'\n"
	else
		echo -e "${LGREEN}Root Access Granted...${NORMAL}\n"
	fi
	echo -ne "${BLUE}Copying Script to local bin....${NORMAL}"
	sudo cp cRun.sh /usr/local/bin/cRun
	if [ $? -ne 0 ]
	then
		if [ "$INSTALLED" = false ]; then
			echo -e "\n${RED}Failed to copy${NORMAL}\nTry Manuallu Copying the script to \n${BLUE}/user/local/bin/\n${NORMAL}And remove the .sh extension\n"
		else
			echo -e "\nNo cRun script found in curent directory\n"
		fi
	else
		echo -e "${LGREEN}Success${NORMAL}"
		COPIED=true
	fi
	echo -ne "${BLUE}Setting permission......${NORMAL}"
	sudo chmod +x /usr/local/bin/cRun
	if [ $? -ne 0 ]
	then
		echo -e "${RED}Failed to set executable permission${NORMAL}\nTry to Manually set permission for \n${BLUE}/user/local/bin/cRun\n${NORMAL}"
	else
		echo -e "${LGREEN}Success${NORMAL}"
		PERMISSION=true
	fi
	if [ "$COPIED" = true -a "$PERMISSION" = true ]; then
		echo -e "${LGREEN}Install Success${NORMAL}"
	fi
	endScript
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

function endScript ()
{
	#Handle Clean up here
	echo -e "\nExiting....."
	if [ $SHOW_TIME = true ]
	then
		showTime $SECONDS
	fi
	echo -e "***************************************************"
	exit 2
}

function compile ()
{
	ERROR_COUNT=0
	while(($#))
	do
		if [ -f ${1/.c*/.out} ]
		then
			echo -e "${BLUE}Re-Compiling${NORMAL}.....$1"
		else	
			echo -e "${BLUE}Compiling${NORMAL}.....$1"
		fi
		if [ $? -ne 0 ]
		then
			(($ERROR_COUNT++))
		fi
		cc $1 -o ${1/.c*/.out} -lm
		echo -e "${LGREEN}Done ${NORMAL}"
		shift
	done
	#echo -e "Processed ${LGREEN} $count ${NORMAL}files."
	echo -e "${LGREEN}Object files generated${NORMAL}"
	if [ $ERROR_COUNT -gt 0 ]
	then
		echo -e "${RED}${ERROR_COUNT} Errors${NORMAL} were encountered by ${BLUE}GCC compiler${LGREEN} ignoring warnings${NORMAL}."
		return $ERROR_COUNT
	fi
	if [ "$RUN" = false ]
	then
		echo -e "Compile Output will be cleared Press ctrl+c to exit the script and keep output otherwise\n"
		read -r -s -p $'Press escape to continue...\n' -d $'\e'
	fi
}

function run ()
{
	COMPILE_ERROR=false
	while(($#))
	do
		if [ -f ${1/.c*/.out} -o "$COMPILE" = true ]
		then
			compile $1
			if [ $? -ne 0 ]
			then
				COMPILE_ERROR=true
			else
				COMPILE_ERROR=false
			fi
		fi
		if [ COMPILE_ERROR=false ]
		then
			echo -e "${BLUE}Executing${NORMAL}.....$1"
			./${1/.c*/.out}
			if [ "$DEL_OBJ" = true ]
			then
				echo -e "${RED}Removing Object File${NORMAL}......$1"
				rm ${1/.c*/.out}
			fi
			echo -e "${LGREEN}Done ${NORMAL}"
		else
			echo -e "${RED}Cannot Run${NORMAL}.....$1"
		fi
		shift
	done
	echo -e "Output will be cleared Press ctrl+c to exit the script and keep output otherwise\n"
	read -r -s -p $'Press escape to continue...\n' -d $'\e'
}

function buildSubMenu ()
{
	while((1))
	do
		clear
		echo -e "\n*************${LGREEN}c${BLUE}Run${NORMAL} by ${LGREEN}snehashis365${NORMAL}***************\n\n"
		echo -e "${BLUE}Selected ->${LGREEN} $1 ${NORMAL}"
		echo -e "1. ${LGREEN}Run ${NORMAL}(Automatically compile if object file missing)"
		echo -e "2. ${BLUE}Compile Only ${NORMAL}"
		echo -e  "\n9. Return to Main Menu"
		read -p "Select : " CHOICE
		if((CHOICE==1));then
			run $1
		elif((CHOICE==2));then
			RUN=false
			compile $1
			RUN=true
		elif((CHOICE==9));then
			return 2
		else
			clear
			echo -e "\n*************${LGREEN}c${BLUE}Run${NORMAL} by ${LGREEN}snehashis365${NORMAL}***************\n\n"
			echo -e "${RED}Invalid Option${NORMAL}\nPlease Try Again"
			echo -e "${BLUE}Selected ->${LGREEN} $1 ${NORMAL}"
			buildSubMenu $1
		fi
	done
}

function buildMenu ()
{
	INDEX=1
	declare -a ITEM
	ITEM[0]="Item_List" #Occuying 1st index just cause I want to don't question this it's unecessary
	while(($#))
	do
		COMPILE_STATUS='\033[0;31m'
		if [ -f ${1/.c*/.out} ]
		then
			COMPILE_STATUS='\033[1;32m'
		fi
		echo -en "${INDEX}. ${COMPILE_STATUS}$1 ${NORMAL}"
		ITEM[$((INDEX++))]=$1
		echo
		shift
	done
	echo
	echo -e "0. ${LGREEN}Exit ${NORMAL}"
	read -p "Select : " CHOICE
	if [ $CHOICE -gt 0 -a $CHOICE -le $INDEX ]
	then
		buildSubMenu ${ITEM[$CHOICE]}
	elif [ $CHOICE -eq 0 ]
	then
		endScript
	fi
}

#Function to show help message
function help ()
{
	echo "This script will compile the files specified and generator object files with same name as the C file and Execute them in the other named."
	echo
	echo "Syntax: ./cRun.sh [-h|c|r|m|t|d|i]"
	echo "options:"
	echo "h     Print this Help."
	echo "c	    Compile only/Re-compile(If object file present)"
	echo "r     Run relevant object file without recompiling(Automatically compile if object file missing)"
	#echo "v     Verbose mode."
	echo "m     Build a menu with the provided files"
	echo "t     Show total time taken to execute the script"
	echo "d     Delete Object file after it has been execued"
	echo "i     Install the script to /usr/local/bin to ease"
	echo
}

#Setting trap to call endScript function with SIGINT(2)
trap "endScript" 2

#Options and options arguments handling:-
while getopts ":hcrmtdi" opt; do
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
			if [ "$RUN" = false ]
			then
				echo -e "${BLUE}No need to specify both -r and -c${NORMAL}(They are enabled by default prefer these 2 are prefered to be used exclusively)"
			else
				COMPILE=false #To avoid re-compilaion
			fi
			RUN=true
			;;
		m )
			MAKE_MENU=true
			;;
		t ) #Show shell execution duration
			SHOW_TIME=true
			;;
		d ) #Delete Object file after running the program
			echo -e "Object Files will be ${RED}DELETED${BLUE} After Execution${NORMAL}"
			DEL_OBJ=true
			;;
		i ) #Install
			install
			;;
		\? )
			echo "Invalid option: $OPTARG" 1>&2
			exit 2
			;;
	esac
done
shift $((OPTIND -1))

clear
echo -e "\n*************${LGREEN}c${BLUE}Run${NORMAL} by ${LGREEN}snehashis365${NORMAL}***************\n\n"
if [ $# -gt 0 ]
then
	count=$#
	while(($#))
	do
		if [ "$MAKE_MENU" = true ]
		then
			while((1))
			do
				buildMenu "$@"
				clear
				echo -e "\n*************${LGREEN}c${BLUE}Run${NORMAL} by ${LGREEN}snehashis365${NORMAL}***************\n\n"
			done
		elif [ "$RUN" = true ]
		then
			run "$@"
		elif [ "$COMPILE" = true ]
		then
			compile "$@"
		fi
		shift
	done
	echo -e "Processed ${LGREEN} $count ${NORMAL}files."
	echo -e "${LGREEN}Object files should be generated${NORMAL} if no ${RED}errors${NORMAL} were encountered by ${BLUE}GCC compiler${LGREEN} ignore warnings${NORMAL}."
else
	echo -e "${RED}Experimental!!!\n${NORMAL}Building Menu...\n"
	while((1))
	do
		buildMenu *.c
		clear
		echo -e "\n*************${LGREEN}c${BLUE}Run${NORMAL} by ${LGREEN}snehashis365${NORMAL}***************\n\n"
	done
fi
