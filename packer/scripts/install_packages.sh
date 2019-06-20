#!/bin/bash

##
## install_packages.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin
DEBIAN_FRONTEND=noninteractive

## for sendmail
sudo apt-get install m4 -y
sudo apt-get install man -y
sudo apt-get install libsasl2-dev -y
sudo apt-get install sasl2-bin -y
sudo apt-get install libdb5.3-dev -y
sudo apt-get install libpam0g-dev -y

## opendkim
sudo apt-get install opendkim -y
sudo apt-get install opendkim-tools -y

