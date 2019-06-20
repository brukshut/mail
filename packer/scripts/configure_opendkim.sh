#!/bin/bash

##
## configure_opendkim.sh
##
PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:/usr/local/sbin

## /etc/opendkim/TrustedHosts
cat <<EOF > /tmp/TrustedHosts
##
## /etc/opendkim/TrustedHosts
##
127.0.0.1
gturn.xyz
bitpusher.org
EOF

## /etc/opendkim/SigningTable
cat <<EOF > /tmp/SigningTable
##
## /etc/opendkim/SigningTable
##
*@bitpusher.org default._domainkey.bitpusher.org
*@gturn.xyz default._domainkey.gturn.xyz
EOF

## /etc/opendkim/KeyTable
cat <<EOF > /tmp/KeyTable
##
## /etc/opendkim/KeyTable
##
default._domainkey.bitpusher.org bitpusher.org:default:/etc/opendkim/keys/bitpusher.org/bitpusher.org.private.key
default._domainkey.gturn.xyz gturn.xyz:default:/etc/opendkim/keys/gturn.xyz/gturn.xyz.private.key
EOF

## keys 
[[ -d /etc/opendkim ]] ||
  ( sudo mkdir -p /etc/opendkim/keys
    sudo chown -R opendkim:opendkim /etc/opendkim )

## opendkim.conf
for file in KeyTable SigningTable TrustedHosts; do 
  [[ -e /tmp/${file} ]] &&
    ( sudo mv /tmp/${file} /etc/opendkim/${file}
      sudo chown opendkim:opendkim /etc/opendkim/${file} )
done

## opendkim.conf
[[ -e /tmp/opendkim.conf ]] && 
  ( sudo mv /tmp/opendkim.conf /etc/opendkim.conf
    sudo chown opendkim:opendkim /etc/opendkim.conf )

## restart opendkim
sudo systemctl stop opendkim.service
sudo systemctl start opendkim.service
