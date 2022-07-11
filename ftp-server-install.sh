#!/bin/bash

# This script installs and configures FTP server

# User-defined variables:
CONFIG_FILE=/etc/vsftpd/vsftpd.conf
BACKUP_FILE="${CONFIG_FILE}.default"

# install VSFTPD service
sudo yum -y install vsftpd

if [ "$?" -eq "0" ]
then
    sudo systemctl start vsftpd
    sudo systemctl enable vsftpd

    # Delete Backup file if exist
    [ -f "$BACKUP_FILE" ] && sudo rm $BACKUP_FILE

    if [ -f "$CONFIG_FILE" ]
    then
        sudo cp $CONFIG_FILE $BACKUP_FILE

        sudo sed -i "s/#write_enable=YES/write_enable=YES/" $CONFIG_FILE
        sudo sed -i "s/#local_umask=022/local_umask=022/" $CONFIG_FILE
        sudo sed -i "s/anonymous_enable=YES/anonymous_enable=NO/" $CONFIG_FILE

        sudo systemctl restart vsftpd
    else
        echo "ERROR: Cannot find $CONFIG_FILE config file!"
        exit 1
    fi
    
    sudo firewall-cmd --list-all | grep ftp > /dev/null

    # Set the firewall if it's not done yet.
    if [ "$?" -ne "0" ]
    then
        sudo firewall-cmd --zone=public --permanent --add-port=21/tcp
        sudo firewall-cmd --zone=public --permanent --add-service=ftp
        sudo firewall-cmd --reload
    fi

    echo "FTP Server is successfully installed!"

else
    echo "Failed to install VSFTPD service"
    exit 1
fi
