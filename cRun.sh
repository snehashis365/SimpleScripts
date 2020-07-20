#!/bin/bash
VERSION='0.7.20.4'
#This script will compile the files specified and generator object files with same name as the C file and Execute them in the other named.
#For e.g:- example.c will give example.out and execute example.out
LGREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
LBLUE='\033[0;36m'
NORMAL='\033[0m'
BEEP='\007'
MAKE_MENU=false
SINGLE_FILE=false
COMPILE=true
RUN=true
DEL_OBJ=false
SHOW_TIME=false
OS=$(uname -o)
COMPILER=''
COMPILER_INSTALLED=false
INSTALL_SUPPORT=true
INSTALL_DIR="/usr/local/bin"
INSTALL_ACCESS="sudo "
PACKAGE_INSTALL="sudo apt install -y gcc"

#Adjust parameters
if [ "$OS" == "Android" ]; then
  TERMUX_CHECK=$(echo "$PREFIX" | grep -o "com.termux")
  if [ "$?" == "0" ]; then #Tweak Install parameters for termux
    echo -e "${LGREEN}Found Termux Environtment...$NORMAL"
    INSTALL_DIR="$HOME/../usr/bin"
    INSTALL_ACCESS=""
    PACKAGE_INSTALL="pkg install -y clang"
  else
    echo -e "${RED}Install is not supported for your OS/Environment"
    INSTALL_SUPPORT=false
  fi
fi

#Pre-requisite check
command -v cc >/dev/null 2>&1
if [ "$?" == "0" ]; then
  COMPILER_INSTALLED=true #Just for referrence in case needed in future for now is redundant
  COMPILER=$(cc --version | grep clang)
  if [ -z "$COMPILER" ]; then
    COMPILER=$(gcc --version | grep gcc)
  fi
else
  echo -e "${RED}No Compiler found\n$NORMAL"
  while true; do
    echo -n "Do you want to auto install compiler from your package manager(Debian Systems/Termux only)? [Y/n] "
    read yn
    case $yn in
      [Yy]*)
        "$PACKAGE_INSTALL"
        COMPILER=$(cc --version | grep clang)
        if [ -z "$COMPILER" ]; then
          COMPILER=$(gcc --version | grep gcc)
        else
          echo "Run the script again"
          exit 2
        fi
        break
        ;;
      [Nn]*)
        echo "Please install gcc/clang whichever you prefer before running script again"
        exit 2
        ;;
      *) echo "Please answer [Y/y/yes] or [N/n/no]" ;;
    esac
  done
fi

#Download latest script from github repo
function download() {
  echo -e "'git pull' recommended if repo is cloned on system\nCreating Directory"
  dVERSION=''
  mkdir Downloaded_script
  echo "Downloading..."
  curl https://raw.githubusercontent.com/snehashis365/SimpleScripts/master/cRun.sh >Downloaded_script/cRun.sh
  if [ "$?" == "0" ]; then
    echo "File saved in $PWD/Downloaded_script/"
  else
    echo "Failed to download"
  fi
}

#Install the script to local bin
function install() {
  if [ "$INSTALL_SUPPORT" = false ]; then
    echo "Aborting"
  fi
  INSTALLED=false
  COPIED=false
  PERMISSION=false
  VERSION_PASS=false
  srcVERSION=''
  if test -f "$INSTALL_DIR/cRun"; then
    echo -e "Found cRun at $INSTALL_DIR/\nLooking for cRun.sh in current directory...\n"
    INSTALLED=true
    if test -f "cRun.sh"; then
      echo -n "Found script | Version : "
      srcVERSION=$(cat cRun.sh | sed '2!d' | grep -o "'.*'" | sed "s/'//g")
      if test -z "$srcVERSION"; then
        echo "UNKNOWN"
        echo -e "\nNot Supported aborting\nRemove you current cRun script and try reinstalling\nHere are the steps:\n"
        echo -e "Run this: '${INSTALL_ACCESS}rm $INSTALL_DIR/cRun'\nThen navigate to directory where the script is and Run this: './cRun.sh -i."
        exit 2
      else
        echo "$srcVERSION"
      fi
      HIGHER_VERSION=$(echo -ne "$VERSION\n$srcVERSION\n" | sort -V | tail -n -1)
      if [ "$srcVERSION" != "$HIGHER_VERSION" ]; then
        while true; do
          echo -ne "${RED}This is an older version of the script.$NORMAL Do you want to continue anyway(Not Recommended)?[Y/n] "
          read yn
          case $yn in
            [Yy]*)
              VERSION_PASS=true
              break
              ;;
            [Nn]*)
              exit 2
              ;;
            *) echo "Please answer [Y/y/yes] or [N/n/no]" ;;
          esac
        done
      elif [ "$VERSION" == "$srcVERSION" ]; then
        while true; do
          echo -ne "${BLUE}Both the scripts are same version.$NORMAL Do you want to overwrite?[Y/n] "
          read yn
          case $yn in
            [Yy]*)
              VERSION_PASS=true
              break
              ;;
            [Nn]*)
              exit 2
              ;;
            *) echo "Please answer [Y/y/yes] or [N/n/no]" ;;
          esac
        done
      else
        VERSION_PASS=true
      fi
    else
      echo -e "${RED}No Script Found...$NORMAL"
      exit 2
    fi
  fi
  if [ "$INSTALLED" = false ]; then
    echo -e "${RED}For LINUX/WSL/Termux Environment only\n${NORMAL}After this you can run the script from any directory without having to copy it manually\nTo update script run the install option from the newer script file pulled\nor from same directory as the newer script\n"
  elif [ "$VERSION_PASS" = true ]; then
    echo -e "Attempting Update (Any manual modifications to local bin copy will be undone)"
    echo -e "$BLUE$VERSION $LGREEN-> $srcVERSION$NORMAL"
  fi
  echo -e "${BLUE}Checking Access..."
  if [ "$EUID" -ne 0 -a "$OS" != "Android" ]; then
    echo -e "${RED}Root Access Required\n${NORMAL}Attempting 'sudo'"
    ${INSTALL_ACCESS}echo
  else
    echo -e "${LGREEN}Access Granted...$NORMAL\n"
    INSTALL_ACCESS=""
  fi
  echo -ne "${BLUE}Copying Script to local bin....$NORMAL"
  ${INSTALL_ACCESS}cp cRun.sh "$INSTALL_DIR"/cRun
  if [ $? -ne 0 ]; then
    if [ "$INSTALLED" = false ]; then
      echo -e "\n${RED}Failed to copy$NORMAL\nTry Manually Copying the script to \n$BLUE/user/local/bin/\n${NORMAL}And remove the .sh extension\n"
    else
      echo -e "\nNo cRun script found in curent directory\n"
    fi
  else
    echo -e "${LGREEN}Success$NORMAL"
    COPIED=true
  fi
  echo -ne "${BLUE}Setting permission......$NORMAL"
  ${INSTALL_ACCESS}chmod +x "$INSTALL_DIR"/cRun
  if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to set executable permission$NORMAL\nTry to Manually set permission for \n$BLUE/user/local/bin/cRun\n$NORMAL"
  else
    echo -e "${LGREEN}Success$NORMAL"
    PERMISSION=true
  fi
  if [ "$COPIED" = true -a "$PERMISSION" = true ]; then
    echo -e "${LGREEN}Install Success$NORMAL"
  fi
  endScript
}

function banner() {
  clear
  echo -ne "$LBLUE"
  cat <<"EOF"
                 ____                __  __
          _____ / __ \ __  __ ____   \ \ \ \
         / ___// /_/ // / / // __ \   \ \ \ \
        / /__ / _, _// /_/ // / / /   / / / /
        \___//_/ |_| \__,_//_/ /_/   /_/ /_/

EOF
  echo -e "$LGREEN                          - by snehashis365$NORMAL"
  echo -e "Version : $LGREEN$VERSION$NORMAL"
  echo -e "Compiler : $LBLUE$COMPILER$NORMAL"
  echo -n "Re-Compile : "
  if [ "$COMPILE" = true ]; then
    echo -e "${BLUE}On$NORMAL"
  else
    echo -e "${LGREEN}Off$NORMAL"
  fi
  echo -n "Compile only : "
  if [ "$RUN" = false ]; then
    echo -e "${BLUE}Yes$NORMAL"
  else
    echo -e "${LGREEN}No$NORMAL"
  fi
  echo -n "Auto cleanup : "
  if [ "$DEL_OBJ" = true ]; then
    echo -e "${RED}On$NORMAL"
  else
    echo -e "${LGREEN}Off$NORMAL"
  fi
  echo -n "Build Menu : "
  if [ "$MAKE_MENU" = true ]; then
    echo -e "${BLUE}On$NORMAL"
  else
    echo -e "${LGREEN}Off$NORMAL"
  fi
  echo -n "Show time : "
  if [ "$SHOW_TIME" = true ]; then
    echo -e "${LGREEN}On$NORMAL"
  else
    echo -e "${BLUE}Off$NORMAL"
  fi
  echo

}

#Function to convert and show seconds to more understandable time format
function showTime() {
  echo -ne "\n${BLUE}Script executed for : $NORMAL"
  num=$1
  min=0
  hour=0
  day=0
  if ((num > 59)); then
    let "sec=num%60"
    let "num=num/60"
    if ((num > 59)); then
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

function endScript() {
  #Handle Clean up here
  echo -e "\nExiting....."
  if [ "$SHOW_TIME" = true ]; then
    showTime "$SECONDS"
  fi
  exit 0
}

function compile() {
  ERROR_COUNT=0
  while (($#)); do
    if [ -f "${1/.c*/.out}" ]; then
      echo -e "${BLUE}Re-Compiling$NORMAL.....$1\n"
    else
      echo -e "${BLUE}Compiling$NORMAL.....$1\n"
    fi
    cc "$1" -o "${1/.c*/.out}" -lm
    if [ $? -ne 0 ]; then
      let "ERROR_COUNT=ERROR_COUNT+1"
    fi
    echo -e "\n${LGREEN}Done $NORMAL"
    shift
  done
  if [ "$ERROR_COUNT" -gt 0 ]; then
    echo -e "$RED$ERROR_COUNT Errors$NORMAL were encountered by ${BLUE}GCC compiler$LGREEN ignoring warnings$NORMAL."
    return "$ERROR_COUNT"
  else
    echo -e "${LGREEN}Object files generated$NORMAL"
  fi
  if [ "$RUN" = false ]; then
    echo -e "\nCompile Output will be cleared Press ctrl+c to exit the script and keep output otherwise\n"
    read -r -s -p $'Press escape to continue...\n' -d $'\e'
  fi
}

function run() {
  COMPILE_ERROR=false
  while (($#)); do
    if [ -f "${1/.c*/.out}" -o "$COMPILE" = true ]; then
      compile "$1"
      if [ $? -ne 0 ]; then
        COMPILE_ERROR=true
      else
        COMPILE_ERROR=false
      fi
    fi
    if [ "$COMPILE_ERROR" = false ]; then
      echo -e "${BLUE}Executing$NORMAL.....$1\n"
      ./"${1/.c*/.out}"
      if [ "$DEL_OBJ" = true ]; then
        echo -e "${RED}Removing Object File$NORMAL......$1"
        rm "${1/.c*/.out}"
      fi
      echo -e "\n${LGREEN}Done $NORMAL"
    else
      echo -e "\n${RED}Cannot Run$NORMAL.....$1"
    fi
    shift
  done
  echo -e "\nOutput will be cleared Press ctrl+c to exit the script and keep output otherwise\n"
  read -r -s -p $'Press escape to continue...\n' -d $'\e'
}

function buildSubMenu() {
  while ((1)); do
    banner
    echo -e "${BLUE}Selected ->$LGREEN $1 $NORMAL"
    echo -e "1. ${LGREEN}Run $NORMAL(Auto compile)"
    echo -e "2. ${BLUE}Compile Only $NORMAL\n"
    if [ "$SINGLE_FILE" = false ]; then
      echo -e "9. Return to Main Menu"
    fi
    echo -e "0. Exit"
    read -p "Select : " CHOICE
    if ((CHOICE == 1)); then
      run "$1"
    elif ((CHOICE == 2)); then
      RUN=false
      compile "$1"
      RUN=true
    elif ((CHOICE == 9)); then
      return 2
    elif ((CHOICE == 0)); then
      endScript
    else
      banner
      echo -e "${RED}Invalid Option$NORMAL\nPlease Try Again"
      echo -e "${BLUE}Selected ->$LGREEN $1 $NORMAL"
      buildSubMenu "$1"
    fi
  done
}

function buildMenu() {
  banner
  if [ "$1" = "*.c" ]; then
    echo -e "${BLUE}No .c file in current directory\n$NORMAL"
    endScript
  fi
  if [ "$#" = "1" ]; then
    SINGLE_FILE=true
    buildSubMenu "$1"
    clear
    return 2
  fi
  INDEX=1
  declare -a ITEM
  ITEM[0]="Item_List" #Occuying 1st index just cause I want to don't question this it's unecessary
  while (($#)); do
    COMPILE_STATUS='\033[0;31m'
    if [ -f "${1/.c*/.out}" ]; then
      COMPILE_STATUS='\033[1;32m'
    fi
    echo -en "$INDEX. $COMPILE_STATUS$1 $NORMAL"
    ITEM[$((INDEX++))]="$1"
    echo
    shift
  done
  echo
  echo -e "0. ${LGREEN}Exit $NORMAL"
  read -p "Select : " CHOICE
  if [ "$CHOICE" -gt 0 -a "$CHOICE" -le "$INDEX" ]; then
    buildSubMenu "${ITEM[$CHOICE]}"
    clear
  elif [ "$CHOICE" -eq 0 ]; then
    endScript
  fi
}

#Function to show help message
function help() {
  echo "This script will compile the files specified and generator object files with same name as the C file and Execute them in the other named."
  echo
  echo "Syntax: ./cRun.sh [-h|c|r|m|t|d|i]"
  echo "options:"
  echo "h     Print this Help"
  echo "c     Compile only/Recompile(If object file present)"
  echo "r     Run relevant object file without recompiling(Automatically compile if object file missing)"
  echo "v     Show Version"
  echo "m     Build a menu with the provided files"
  echo "t     Show total time taken to execute the script"
  echo "d     Delete Object file after it has been execued"
  echo "s     Run as root (WSL 2 Users might want to use this if facing access denied)"
  echo "i     Install the script to local bin to run from any directory"
  echo "d     Download latest script from repository and save to a separate directory not affecting current script"
  echo
}

#Setting trap to call endScript function with SIGINT(2)
trap "endScript" 2

#Options and options arguments handling:-
while getopts ":hcrmtvdsiu" opt; do
  case $opt in
    h) #Display Help message
      help
      exit 0
      ;;
    c) #Compile/Re-compile
      COMPILE=true
      RUN=false
      ;;
    r) #Run without re-compiling
      if [ "$RUN" = false ]; then
        echo -e "${BLUE}No need to specify both -r and -c$NORMAL(They are enabled by default prefer these 2 are prefered to be used exclusively)"
      else
        COMPILE=false #To avoid re-compilaion
      fi
      RUN=true
      ;;
    m)
      MAKE_MENU=true
      ;;
    t) #Show shell execution duration
      SHOW_TIME=true
      ;;
    v) #Show Version
      echo -e "${LBLUE}cRun ${LGREEN}$VERSION ${RED}by snehashis365${NORMAL}"
      exit 0
      ;;
    d) #Delete Object file after running the program
      echo -e "Object Files will be ${RED}DELETED$BLUE After Execution$NORMAL"
      DEL_OBJ=true
      ;;
    s) #Superuser aka root access
      if [ "$OS" != "Android" ]; then
        echo -e "Checking user.....\n"
        if [ "$EUID" -ne 0 ]; then
          echo -e "$RED\n${NORMAL}Attempting 'sudo'"
          sudo "$0"
          exit 0
        else
          echo -e "${LGREEN}Already Root...$NORMAL\n"
        fi
      else
        echo -e "${RED}Not supported for your environment$NORMAL\nDont Run as Superuser"
        exit 2
      fi
      ;;
    i) #Install
      if [ "$INSTALL_SUPPORT" = true ]; then
        install
      else
        echo "Aborting..."
        exit 2
      fi
      ;;
    u) #Download latest script from repo
      download
      exit 1
      ;;
    \?)
      echo "Invalid option: $OPTARG" 1>&2
      exit 2
      ;;
  esac
done
shift $((OPTIND - 1))

clear

if [ $# -gt 0 ]; then
  count=$#
  if [ "$MAKE_MENU" = true ]; then
    while ((1)); do
      buildMenu "$@"
    done
  elif [ "$RUN" = true ]; then
    banner
    run "$@"
  elif [ "$COMPILE" = true ]; then
    banner
    compile "$@"
  fi
  echo -e "Processed $LGREEN $count ${NORMAL}files."
else
  while ((1)); do
    MAKE_MENU=true
    buildMenu *.c
  done
fi
