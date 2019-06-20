#!/bin/bash

##
## sendmail_files.sh
## distribute sendmail configuration files
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

## /etc/mail/access
cat <<EOF > /tmp/access
##
## /etc/mail/access
##
127.0.0.1 RELAY
127.0.1.1 RELAY
localhost RELAY
EOF

## /etc/mail/aliases
cat <<EOF > /tmp/aliases
##
## /etc/mail/aliases
##

## thou shalt receive mail
root:           cgough
abuse:          cgough

## Other
postmaster:     root
MAILER-DAEMON:  postmaster

mail:           root
daemon:         root
bin:            root
sys:            root
adm:            root
EOF

## /etc/mail/genericstable
cat <<EOF > /tmp/genericstable
##
## /etc/mail/genericstable
##
EOF

## /etc/mail/local-host-names
cat <<EOF > /tmp/local-host-names
##
## /etc/mail/local-host-names
##
localhost
bitpusher.org
gturn.xyz
mail.bitpusher.org
mail.gturn.xyz
mail.gturn.nt
EOF

## /etc/mail/virtusertable
cat <<EOF > /tmp/virtusertable
##
## /etc/mail/virtusertable
##
christian@bitpusher.org christian
christian@gturn.xyz cgough
EOF

## main
for file in access aliases genericstable local-host-names virtusertable; do
  [[ -e /tmp/${file} ]] && 
    ( sudo mv /tmp/${file} /etc/mail/${file}
      sudo chown root:root /etc/mail/${file}
      sudo chmod 644 /etc/mail/${file} )
done

## generate sendmail database maps
for map in access genericstable virtusertable; do 
  sudo cat /etc/mail/${map} | sudo makemap hash /etc/mail/${map}.db
done

## generate aliases
sudo newaliases

## end main
