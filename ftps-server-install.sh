#!/bin/bash

# This script installs and configures FTPS server
# Requirements: 
#     - FTP server need to be installed first before running this script
#     - Setup ftps-inputs file to answer openssl questions
# Usage: $ ./ftps-server-install.sh < ftps-inputs

# User-defined variables:
CONFIG_FILE=/etc/vsftpd/vsftpd.conf

FTPS_CONFIG=$"# SSL configuration (TLS v1.2)\n\
ssl_enable=YES\n\
ssl_tlsv1_2=YES\n\
ssl_sslv2=NO\n\
ssl_sslv3=NO\n\
\n\
# configure the location of the SSL certificate and key file\n\
rsa_cert_file=/etc/ssl/private/vsftpd-selfsigned.pem\n\
rsa_private_key_file=/etc/ssl/private/vsftpd-selfsigned.pem\n\
\n\
# prevent anonymous users from using SSL\n\
allow_anon_ssl=NO\n\
# force all non-anonymous logins to use SSL for data transfer\n\
force_local_data_ssl=YES\n\
\n\
# force all non-anonymous logins to use SSL to send passwords\n\
force_local_logins_ssl=YES\n\
\n\
# Select the SSL ciphers VSFTPD will permit for encrypted SSL connections with the ssl_ciphers option.\n\
ssl_ciphers=HIGH\n\
\n\
# turn off SSL reuse\n\
require_ssl_reuse=NO\n\
pasv_min_port=40001\n\
pasv_max_port=40100\n\
\n\
# For debug Purpose\n\
debug_ssl=YES"

SSL_DIR=/etc/ssl/private
SSL_FILE="${SSL_DIR}/vsftpd-selfsigned.pem"

# Setup SSL and ports for VSFTPD service

if [ -f "$CONFIG_FILE" ]
then

    # Create SSL Direcdtory if it does not exist
    [ -d "$SSL_DIR" ] || sudo mkdir $SSL_DIR

    # Delete SSL file if exist 
    [ -e "$SSL_FILE" ] && sudo rm $SSL_FILE

    sudo openssl req -x509 -nodes -keyout $SSL_FILE -out $SSL_FILE -days 365 -newkey rsa:2048


    # Check if port 990 has been previously opened. 
    sudo firewall-cmd --list-all | grep 990 > /dev/null
    
    # Open the ports if it has not been done.
    if [ "$?" -ne "0" ]
    then
        sudo firewall-cmd --zone=public --add-port=990/tcp --permanent
    
        # For passive mode
        sudo firewall-cmd --zone=public --add-port=40001-40100/tcp --permanent
        
        # Apply the changes
        sudo firewall-cmd --reload
    fi

    # Insert SSL configuration at the end of vsftpd.conf
    sudo sed -i '$a\'"${FTPS_CONFIG}"'' $CONFIG_FILE

    echo "FTPS Server is successfully installed!"

else
    echo "FTP server is not installed. Please install FTP server first before installing FTPS server"
    exit 1
fi
