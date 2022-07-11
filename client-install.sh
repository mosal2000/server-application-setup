
############################################################
############################################################
# Client applications installation                        #
############################################################
############################################################


echo "-------------------------------------"
echo "updating Linux"
echo "-------------------------------------"
echo
sudo yum -y update

if [ "$?" -eq "0" ]
then

    echo "-------------------------------------"
    echo "Install Expect"
    echo "-------------------------------------"
    echo

    sudo yum -y install expect

    [ "$?" -ne "0" ] && echo "  ERROR: Failed to install Expect!"

    echo "-------------------------------------"
    echo "Install client for FTP"
    echo "-------------------------------------"
    echo

    sudo yum -y install ftp

    [ "$?" -ne "0" ] && echo "  ERROR: Failed to install FTP Client!"

    echo "-------------------------------------"
    echo "Install client for FTPS"
    echo "-------------------------------------"
    echo

    sudo yum -y install lftp

    [ "$?" -ne "0" ] && echo "  ERROR: Failed to install LFTP Client!"

    echo "-------------------------------------"
    echo "Install client for RDP and VNC"
    echo "-------------------------------------"
    echo

    sudo yum -y install remmina remmina-plugins-*

    [ "$?" -ne "0" ] && echo "  ERROR: Failed to install Remmina!"

    echo "-------------------------------------"
    echo "Install client for SMB (Samba)"
    echo "-------------------------------------"
    echo

    sudo yum -y install install cifs-utils

    [ "$?" -ne "0" ] && echo "  ERROR: Failed to install CIFS-UTILS!"

else
    echo "Failed to install updates!"
fi
