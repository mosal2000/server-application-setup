#!/bin/bash

# This script installs and configures RDP server

# install the necessary packages:
sudo yum install -y epel-release

if [ "$?" -eq "0" ]
then
    sudo yum install -y xrdp

    if [ "$?" -eq "0" ]
    then
        sudo systemctl enable xrdp
        sudo systemctl start xrdp

        # open port 3389/TCP for RDP if it's not opened yet.
        sudo firewall-cmd --list-all | grep 3389 > /dev/null

        # Set the firewall if it's not done yet.
        if [ "$?" -ne "0" ]
        then
            sudo firewall-cmd --add-port=3389/tcp --permanent
            sudo firewall-cmd --reload
        fi

        # Install Gnome Desktop Environment
        sudo yum groupinstall "GNOME DESKTOP" -y

        if [ "$?" -eq "0" ]
        then
            sudo systemctl set-default graphical.target
            sudo systemctl isolate graphical.target
        else
            echo "Failed to install GNOME DESKTOP service"
            exit 1
        fi

    else
        echo "Failed to install XRDP service"
        exit 1
    fi

    echo "RDP Server is successfully installed!"

else
    echo "Failed to install epel-release service"
    exit 1
fi
