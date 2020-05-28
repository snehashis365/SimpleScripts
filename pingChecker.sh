#!/bin/bash
#Function to handle Ctrl+C
function endScript ()
{
	#Handle Clean up here | Plans are to show a summary at script exit
	echo -e "\n************************************************************"
	exit 2
}
#Setting trap to call endScript function with SIGINT(2)
trap "endScript" 2
#This script will check ping with provided IP/domain/Default Google DNS and show the connection status
#Updated every 1s by default argument handling coming soon
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NORMAL='\033[0m'
BEEP='\007'
FLAG=true
IP='8.8.8.8'
echo -e "***********${LGREEN}Connection Status ${BLUE}notifier${NORMAL} by ${LGREEN}Snehashis${NORMAL}**********"
if [ $# -gt 0 ]
then
	if [ "$#" == 1 ]
	then
		IP=$1
		FLAG=false
	else
		#Argument handling here | Plans to make deadline and alert beep on or off as user settable
		echo -n
	fi
fi
if [ "$FLAG" = true ]
then
	echo -e "${LGREEN}Checking default Google DNS${NORMAL}"
fi	
echo -e "${BLUE}Pinging ${NORMAL}.....${LGREEN} ${IP}${NORMAL}\n"
while((1))
do
	OUTPUT=$(ping -w 1 ${IP} | grep "Destination Host Unreachable\|100% packet loss")
	if test -z "$OUTPUT"
	then
		echo -ne "\r${LGREEN}Connection OK${NORMAL} "
	else
		echo -ne "\r${RED}No Reply     ${NORMAL} ${BEEP}"
	fi
done
