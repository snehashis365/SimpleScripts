#!/bin/bash
#Declaring required variables
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
DEL_LINE='\033[2K' #Escape sequence to delete the content of the line
BEEP='' #Alarm off by default
DEFAULT_IP_FLAG=true
NO_REPLY=false #To help handle connection status change
DOT_COUNT=0
IP='8.8.8.8' #Default IP to be tested
DELAY=1
#Function to handle Ctrl+C
function endScript ()
{
	#Handle Clean up here | Plans are to show a summary at script exit | Exit message added
	echo -e "\nDetected Control Break\nExiting....."
	echo -e "****************************************************"
	exit 2
}
#Setting trap to call endScript function with SIGINT(2)
trap "endScript" 2
#This script will check ping with provided IP/domain/Default Google DNS and show the connection status
#Updated every 1s by default| Options and option argument handling added still a prorotype

#Options and options arguments handling:-
while getopts ":at:" opt; do
	case ${opt} in
		a ) #Turn on the alarm on no reply
			BEEP='\007'
			;;
		t ) #Manually set delay
			if [[ "$OPTARG" == *"."* ]]; then
				echo -e "${RED}Invalid option:${NORMAL} '$OPTARG' is not an INTEGER" 1>&2
				exit 2
			else
				DELAY=$OPTARG
			fi
			;;
		\? )
			echo "Invalid option: $OPTARG" 1>&2
			exit 2
			;;
		: ) 
			echo -e "${RED}Invalid option:${NORMAL} -$OPTARG requires an argument <INTEGER>"
			exit 2
      		;;
	esac
done
shift $((OPTIND -1))


echo -e "******${LGREEN}Connection Status ${BLUE}notifier${NORMAL} by ${LGREEN}Snehashis${NORMAL}*******"
echo -e "${BLUE}Delay: ${RED}${DELAY}s"
echo -ne "${BLUE}Alarm: "
if test -z "$BEEP"
then
	echo -e "${LGREEN}Off"
else
	echo -e "${RED}On"
fi
echo -ne "${NORMAL}"
if [ $# -gt 0 ]
then
	IP=$1
	DEFAULT_IP_FLAG=false
fi
if [ "$DEFAULT_IP_FLAG" = true ]
then
	echo "Checking default Google DNS"
fi	
echo -e "${BLUE}Pinging${NORMAL}.....${LGREEN}${IP}${NORMAL}\n"
while((1)) #The scipt rus infinitely unless control break(Ctrl+c) occurs
do
	OUTPUT=$(ping -w ${DELAY} ${IP} | grep "Destination Host Unreachable\|100% packet loss")
	if test -z "$OUTPUT"
	then
		if [ "$NO_REPLY" = true ]
		then
			echo -ne "\n${BLUE}Connection Restored!${NORMAL}"
			NO_REPLY=false
			DOT_COUNT=0
			#Convert the seconds to easy to understand time format
			if (( $SECONDS > 3600 )) ; then
				let "hours=SECONDS/3600"
				let "minutes=(SECONDS%3600)/60"
				let "seconds=(SECONDS%3600)%60"
				echo -e "\nApprox ${RED}down${NORMAL} time:${LGREEN} $hours hour(s), $minutes minute(s) and $seconds second(s)\n" 
			elif (( $SECONDS > 60 )) ; then
				let "minutes=(SECONDS%3600)/60"
				let "seconds=(SECONDS%3600)%60"
				echo -e "\nApprox ${RED}down${NORMAL} time:${LGREEN} $minutes minute(s) and $seconds second(s)\n"
			else
				echo -e "\nApprox ${RED}down${NORMAL} time:${LGREEN} $SECONDS second(s)\n"
			fi
		fi
		if [ $DOT_COUNT -gt 0 -a $DOT_COUNT -le 5 ] #To avoid flooding with '.'
		then
			echo -ne "."
		else
			echo -ne "${DEL_LINE}\r${LGREEN}Connection OK${NORMAL}"
			DOT_COUNT=0
		fi
		let "DOT_COUNT=DOT_COUNT+1" #Increment the counter
	else
		if [ "$NO_REPLY" = false ]
		then
			echo -e "\n${BLUE}Connection Lost!${NORMAL}\n"
			NO_REPLY=true
			SECONDS=0
			DOT_COUNT=0
		fi
		if [ $DOT_COUNT -gt 0 -a $DOT_COUNT -le 5 ]
		then
			echo -ne ".${BEEP}"
		else
			echo -ne "${DEL_LINE}\r${RED}No Reply${NORMAL}${BEEP}"
			DOT_COUNT=0
		fi
		let "DOT_COUNT=DOT_COUNT+1"
	fi
done
