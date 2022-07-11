#!/bin/bash

# This script installs and configures SMB server

# User-defined variables:
CONFIG_FILE=/etc/samba/smb.conf

SAMBA_SHARE_DIR=/samba/anonymous_share

HOST_NAME=$(hostname)

GLOBAL_SETTING=$"\\\tserver string = Samba Server %v\n\
\tnetbios name = ${HOST_NAME}\n\
\tmap to guest = bad user\n\
\tdns proxy = no\n\
\tmin protocol = SMB2"

SHARE_DEFINITIONS=$"[Anonymous]\n\
\tpath = /samba/anonymous_share\n\
\tbrowsable =yes\n\
\twritable = yes\n\
\tguest ok = yes\n\
\tread only = no\n\
\tcomment = Test Anonymous\n\
\tpublic = yes\n\
\tcreate mask = 0664\n\
\tforce create mode = 0664\n\
\tdirectory mask = 0775\n\
\tforce directory mode = 0775\n"

sudo yum remove samba*
sudo yum install samba* -y

if [ "$?" -eq "0" ]
then

    # Configure a fully accessed anonymous share
    sudo mkdir -p $SAMBA_SHARE_DIR
    sudo chmod -R 0777 $SAMBA_SHARE_DIR

    if [ -f "$CONFIG_FILE" ]
    then
        # Change the to windows default workgroup
        sudo sed -i "s/workgroup = SAMBA/workgroup = WORKGROUP/" $CONFIG_FILE

        # Add charset uder [global]
        sudo sed -i "/security = user/i $GLOBAL_SETTING" $CONFIG_FILE

        # Comment all under [homes]
        sudo sed -i "s/comment = Home Directories/# comment = Home Directories/" $CONFIG_FILE
        sudo sed -i "s/valid users =/# valid users =/" $CONFIG_FILE
        sudo sed -i "s/browseable = No/# browseable = No/" $CONFIG_FILE
        sudo sed -i "s/read only = No/# read only = No/" $CONFIG_FILE
        sudo sed -i "s/inherit acls = Yes/# inherit acls = Yes/" $CONFIG_FILE

        # Add Share Config at the end
        sudo sed -i '$a\'"${SHARE_DEFINITIONS}"'' $CONFIG_FILE

        sudo systemctl start smb
        sudo systemctl start nmb

        sudo systemctl enable smb
        sudo systemctl enable nmb

        sudo systemctl status smb | grep running > /dev/null
        # smb status is running
        if [ "$?" -eq "0" ]
        then

            sudo systemctl status nmb | grep running > /dev/null
            # smb status is running
            if [ "$?" -eq "0" ]
            then

                sudo firewall-cmd --list-all  | grep samba > /dev/null

                # Set the firewall if it's not done yet.
                if [ "$?" -ne "0" ]
                then

                    sudo firewall-cmd --permanent --zone=public --add-service=samba
                    sudo firewall-cmd --reload

                    sudo chown -R nobody:nobody $SAMBA_SHARE_DIR

                    semanage fcontext -a -t samba_share_t '${SAMBA_SHARE_DIR}(/.*)?'

                fi

            else
                echo "ERROR: nmb service is not running!"
                exit 1
            fi

        else
            echo "ERROR: smb service is not running!"
            exit 1
        fi

    else
        echo "ERROR: Config File not found!"
        exit 1
    fi

    echo "SMB Server is successfully installed!"

else
    echo "Failed to install samba service"
    exit 1
fi


