#!/bin/bash

# This script will modify the sudo config to extend the time the sudo password will need to be reentered


############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Extend sudo timeout utility"
   echo
   echo "Syntax: scriptTemplate [-r|t|h]"
   echo "options:"
   echo "r     reset to default timeout"
   echo "t     specify the timeout in minutes" 
   echo "h     Display help"
   echo
}


DOWNLOAD_DEST=/opt/tmp/download/$APP_NAME
############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
option_set=false
while getopts ":hrt:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      r) # Reset the timeout
         selected=true
         RESET=true
         echo "Specified to reset timeout";;
      t) # set the timeout to the specified time
         selected=true
         if [[ $OPTARG != "" ]]; then
             TIMEOUT=$OPTARG  
         fi
         echo "Specified to set timeout to: $TIMEOUT";;
     \?) # Invalid option
         echo "Error: Invalid option"
         Help
         exit 1;;
   esac
done

if [[ $selected != "true" ]]; then
    echo "You must specify an option!"
    Help
    exit 1
fi

SUDO_FILE=/etc/sudoers.d/$USER

if [[ "$RESET" == "true" ]]; then
    echo "Reseting the timeout"
    sudo rm -f $SUDO_FILE
    sudo -Kk
    #sudo service sudo restart
    newgrp 
fi

if [[ "$TIMEOUT" != "" ]]; then
    echo "Setting the sudo timeout to '$TIMEOUT' minutes."
    re='^([0-9]+$|-1)'
    if ! [[ $TIMEOUT =~ $re ]] ; then
        echo "error: $TIMEOUT is not an allowed value. Enter a value >= -1" >&2; exit 1
    fi
    sudo rm -f $SUDO_FILE
    sudo echo "Defaults timestamp_timeout=$TIMEOUT" | sudo tee -a $SUDO_FILE >/dev/null
    sudo -Kk
    #sudo service sudo restart
else
   echo No changes made
fi


