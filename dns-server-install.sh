#!/bin/bash

# This script installs and configures DNS server

# User-defined variables:
CONFIG_FILE=/etc/named.conf

export FORWARD_NAME=forward.receiver1
export REVERSE_NAME=reverse.receiver1

HOST_NAME=$(hostname)
IP_ADDR=$(hostname -I)
# Remove IP Address after space
# IP_ADDR=$IP_ADDRS | cut -f1 -d" "

NETWORK=${IP_ADDR%.*}
REV_NETWORK=$(echo "${NETWORK}" | awk -F. '{print $3"." $2"."$1}')

FORWARD_CONFIG=$"zone \x22${HOST_NAME}\x22 IN {\n\
        type master;\n\
        file \x22${FORWARD_NAME}\x22;\n\
        allow-update { none; };\n\
};\n"

REVERSE_CONFIG=$"zone \x22${REV_NETWORK}.in-addr.arpa\x22 IN {\n\
        type master;\n\
        file \x22${REVERSE_NAME}\x22;\n\
        allow-update { none; };\n\
};\n"

export FORWARD_FILE=$"\$TTL 86400\n\
@   IN  SOA     ns1.${HOST_NAME}. root.${HOST_NAME}. (\n\
        2011071001  ;Serial\n\
        3600        ;Refresh\n\
        1800        ;Retry\n\
        604800      ;Expire\n\
        86400       ;Minimum TTL\n\
)\n\
@       IN  NS          ns1.${HOST_NAME}.\n\
@       IN  A           ${IP_ADDR}\n\
\n\
ns1     IN  A  ${IP_ADDR}\n"

export REVERSE_FILE=$"\$TTL 86400\n\
@   IN  SOA     ns1.${HOST_NAME}. root.${HOST_NAME}. (\n\
        2011071001  ;Serial\n\
        3600        ;Refresh\n\
        1800        ;Retry\n\
        604800      ;Expire\n\
        86400       ;Minimum TTL\n\
)\n\
@       IN  NS          ns1.${HOST_NAME}.\n\
@       IN  PTR         ${HOST_NAME}.\n\
\n\
ns1     IN  A  ${IP_ADDR}\n\
\n\
101     IN  PTR         ns1.${HOST_NAME}.\n"


sudo yum -y install bind bind-utils

if [ "$?" -eq "0" ]
then

    if [ -f "$CONFIG_FILE" ]
    then
        sudo sed -i "s/listen-on port 53 { 127.0.0.1; };/listen-on port 53 { 127.0.0.1; ${IP_ADDR}; };/" $CONFIG_FILE
        sudo sed -i "s/allow-query     { localhost; };/allow-query     { localhost; ${NETWORK}.0\/24; };/" $CONFIG_FILE
        sudo sed -i "s/recursion yes;/recursion no;/" $CONFIG_FILE

        # Insert configs before 'include "/etc/named.rfc1912.zones";'
        sudo sed -i "/^include \"\/etc\/named.rfc1912.zones\";/i $FORWARD_CONFIG" $CONFIG_FILE
        sudo sed -i "/^include \"\/etc\/named.rfc1912.zones\";/i $REVERSE_CONFIG" $CONFIG_FILE

        # Need to run this a root user
        sudo -E su -c 'echo -e "$FORWARD_FILE" > /var/named/${FORWARD_NAME}'
        sudo -E su -c 'echo -e "$REVERSE_FILE" > /var/named/${REVERSE_NAME}'

        sudo systemctl enable named
        sudo systemctl start named

        sudo systemctl status named | grep running > /dev/null

        # Check if named status is running
        if [ "$?" -eq "0" ]
        then
            sudo firewall-cmd --list-all  | grep 53 > /dev/null

            # Set the firewall if it's not done yet.
            if [ "$?" -ne "0" ]
            then
                echo "Open Port 53."
                sudo firewall-cmd --permanent --add-port=53/udp
                sudo firewall-cmd --permanent --add-port=53/tcp
                sudo firewall-cmd --reload
            fi
        else
            echo "ERROR: named service is not running!"
            exit 1
        fi

    else
        echo "ERROR: Cannot find $CONFIG_FILE config file!"
        exit 1
    fi

    echo "DNS Server Successfully Installed!!"

else
    echo "ERROR: Failed to install bind bind-utils service!"
    exit 1
fi
