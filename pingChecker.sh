#!/bin/bash
#Declaring required variables
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
BEEP='' #Alarm off by default
DEFAULT_IP_FLAG=true
IP='8.8.8.8'
DELAY='1'
#Function to handle Ctrl+C
function endScript ()
{
	#Handle Clean up here | Plans are to show a summary at script exit
	echo -e "\n****************************************************"
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
if [ "$DELAY" -ne "1" ]
then
	echo -e "\n${LGREEN}Delay ${BLUE}manually set${NORMAL} to ${RED}${DELAY}"
fi
if [ $# -gt 0 ]
then
	if [ "$#" == 1 ]
	then
		IP=$1
		DEFAULT_IP_FLAG=false
	else
		#Argument handling here | Plans to make deadline and alert beep on or off as user settable
		echo -n
	fi
fi
if [ "$DEFAULT_IP_FLAG" = true ]
then
	echo -e "${LGREEN}Checking default Google DNS${NORMAL}"
fi	
echo -e "${BLUE}Pinging ${NORMAL}.....${LGREEN} ${IP}${NORMAL}\n"
while((1)) #The scipt rus infinitely unless control break(Ctrl+c) occurs
do
	OUTPUT=$(ping -w ${DELAY} ${IP} | grep "Destination Host Unreachable\|100% packet loss")
	if test -z "$OUTPUT"
	then
		echo -ne "\r${LGREEN}Connection OK${NORMAL} "
	else
		echo -ne "\r${RED}No Reply     ${NORMAL} ${BEEP}"
	fi
done