# Server Application Setup

This repo is intended for automatting the setup of server applications used for a traffic generator or other purposes.

## Usage

Run the **application-install.sh** script with desired options. A help menu will appear if no options are specified. To install all applications, include all options. For example:

    ./application-install.sh -abcde

The option above installed the following applications:

- Install FTP server
- Install RDP server
- Install VNC server
- Install DNS server
- Install SMB server

You will be prompted for you **sudo** password 2 times initially. The first will disable the sudo timeout and the second it to create an a new sudo session timestamp. After the installation the sudo timeout will be reset to normal. View the **extend-sudo-time.sh** script to understand what is happening.

## Alternate usage

Run each install script individually

## Client Installation

Run the **client-install.sh** script on the machine where the traffic generator is intended to be run. This script is to help you install the necessary client applications needed to run the traffic generator.
