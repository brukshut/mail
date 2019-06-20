#!/bin/bash 

##
## configure_certs.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin
SCRIPT=mailcerts.sh
SERVICE=mailcerts.service

function die { echo "$*" 1>&2 && exit 1; }

function my_script {
  [ -e /tmp/${SCRIPT} ] && 
    ( sudo mv /tmp/${SCRIPT} /usr/local/sbin/${SCRIPT} && 
      sudo chmod 755 /usr/local/sbin/${SCRIPT} 
      sudo chown root:root /usr/local/sbin/${SCRIPT} ) ||
        die "no such file: /tmp/${SCRIPT}"
}

function my_service {
  [ -e /tmp/${SERVICE} ] &&
    ( sudo mv /tmp/${SERVICE} /lib/systemd/system/${SERVICE} &&
      sudo chown root:root /lib/systemd/system/${SERVICE} ) ||
        die "no such file: /tmp/${SERVICE}"
}
    
function reload_daemon {
  sudo systemctl daemon-reload && 
    sudo systemctl enable ${SERVICE}
}
function main {
  my_script && my_service && reload_daemon
}

main
