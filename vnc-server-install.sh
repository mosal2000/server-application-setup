#!/bin/bash

# This script installs and configures VNC server
# Requirements: 
#     - Setup vnc-inputs file to answer vncpasswd questions
# Usage: $ ./vnc-server-install.sh < vnc-inputs

# User-defined variables:
ORIG_CONFIG_FILE=/lib/systemd/system/vncserver@.service
VNC_CONFIG_FILE=/etc/systemd/system/vncserver@:1.service


# install the necessary package:
sudo yum -y install tigervnc-server

if [ "$?" -eq "0" ]
then
    vncpasswd

    # Delete VNC config file if exist
    [ -f "$VNC_CONFIG_FILE" ] && sudo rm $VNC_CONFIG_FILE

    sudo cp $ORIG_CONFIG_FILE $VNC_CONFIG_FILE

    sudo sed -i "s/<USER>/tip/" $VNC_CONFIG_FILE

    sudo systemctl daemon-reload
    sudo systemctl start vncserver@:1

    sudo systemctl status vncserver@:1 | grep running > /dev/null
    # vncserver status is running
    if [ "$?" -eq "0" ]
    then
        sudo systemctl enable vncserver@:1

        sudo firewall-cmd --list-all | grep vnc-server > /dev/null

        # Set the firewall if it's not done yet.
        if [ "$?" -ne "0" ]
        then
            sudo firewall-cmd --permanent --zone=public --add-service vnc-server
            sudo firewall-cmd --add-port=5901/tcp --permanent
            sudo firewall-cmd --reload
        fi
    else
        echo "ERROR: vncserver@:1 is not running!"
        exit 1
    fi

    echo "VNC Server is successfully installed!"

else
    echo "ERROR: Failed to install tigervnc-server service"
    exit 1
fi

