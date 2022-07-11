#!/bin/bash

# find the script's directory
SCRIPT_DIR="$( cd "$( dirname "$BASH_SOURCE" )" &> /dev/null && pwd )"

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Run application installations for Traffic Generator!"
   echo
   echo "Syntax: ./application-install.sh [-a|b|c|d|e|h]"
   echo "options:"
   echo "a     Install FTP server"
   echo "b     Install RDP server"
   echo "c     Install VNC server"
   echo "d     Install DNS server"
   echo "e     Install SMB server"
   echo "h     Display help"
   echo
}


############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options
option_set=false
while getopts ":habcdefh:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      a) # Install FTP server
         install_ftp=true
         option_set=true;;  
      b) # Install RDP server
         install_rdp=true
         option_set=true;;  
      c) # Install VNC server
         install_vnc=true
         option_set=true;;  
      d) # Install DNS server
         install_dns=true
         option_set=true;;  
      e) # Install SMB server
         install_smb=true
         option_set=true;;  
     \?) # Invalid option
         echo "Error: Invalid option"
         Help
         exit;;
   esac
done

if [[ $option_set == "false" ]]; then
    echo ERROR: You must set at least one option!
    Help
    exit;
fi

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

sh $SCRIPT_DIR/extend-sudo-time.sh -t -5

# -----------------------------------------------------
# Base Setup
# -----------------------------------------------------
echo ---------------------------------------------------
echo Installing Base setup and applications    
echo ---------------------------------------------------
echo

# make sure update is run before any installations
echo "-------------------------------------"
echo "updating yum"
echo "-------------------------------------"
echo
sudo yum -y update


echo
echo ---------------------------------------------------
echo Completed Base setup and applications install
echo ---------------------------------------------------
echo

# -----------------------------------------------------
# FTP Server installation
# -----------------------------------------------------
if [[ $install_ftp == "true" ]]; then
    echo ---------------------------------------------------
    echo Installing FTP Server Installation    
    echo ---------------------------------------------------
    echo

    sh $SCRIPT_DIR/ftp-server-install.sh
    sh $SCRIPT_DIR/ftps-server-install.sh < $SCRIPT_DIR/ftps-inputs

    echo
    echo ---------------------------------------------------
    echo Completed FTP Server Installation
    echo ---------------------------------------------------
    echo
fi

# -----------------------------------------------------
# DNS Server installation
# -----------------------------------------------------
if [[ $install_dns == "true" ]]; then
    echo ---------------------------------------------------
    echo Installing DNS Server Installation    
    echo ---------------------------------------------------
    echo

    sh $SCRIPT_DIR/dns-server-install.sh

    echo
    echo ---------------------------------------------------
    echo Completed DNS Server Installation
    echo ---------------------------------------------------
    echo
fi

# -----------------------------------------------------
# SMB Server installation
# -----------------------------------------------------
if [[ $install_smb == "true" ]]; then
    echo ---------------------------------------------------
    echo Installing SMB Server Installation    
    echo ---------------------------------------------------
    echo

    sh $SCRIPT_DIR/smb-server-install.sh

    echo
    echo ---------------------------------------------------
    echo Completed SMB Server Installation
    echo ---------------------------------------------------
    echo
fi

# -----------------------------------------------------
# RDP Server installation
# -----------------------------------------------------
if [[ $install_rdp == "true" ]]; then
    echo ---------------------------------------------------
    echo Installing RDP Server Installation    
    echo ---------------------------------------------------
    echo

    sh $SCRIPT_DIR/rdp-server-install.sh

    echo
    echo ---------------------------------------------------
    echo Completed RDP Server Installation
    echo ---------------------------------------------------
    echo
fi

# -----------------------------------------------------
# VNC Server installation
# -----------------------------------------------------
if [[ $install_vnc == "true" ]]; then
    echo ---------------------------------------------------
    echo Installing VNC Server Installation    
    echo ---------------------------------------------------
    echo

    sh $SCRIPT_DIR/vnc-server-install.sh < vnc-inputs

    echo
    echo ---------------------------------------------------
    echo Completed VNC Server Installation
    echo ---------------------------------------------------
    echo
fi


sh $SCRIPT_DIR/extend-sudo-time.sh -r
