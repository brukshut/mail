#!/bin/bash

##
## configure_sendmail.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

function generate_sendmail_conf {
  ## macro files require src under /usr/local/src
  for file in sendmail submit; do
    [[ -e /tmp/${file}.mc ]] &&
      ( sudo mv /tmp/${file}.mc /etc/mail
        m4 /etc/mail/${file}.mc | sudo tee /etc/mail/${file}.cf
        sudo chown root:root /etc/mail/*.mc /etc/mail/*.cf ) ||
    true
  done
}

function configure_saslauthd {
  local sendmail_conf=/etc/sasl2/Sendmail.conf
  [[ -d /etc/sasl2 ]] || sudo mkdir /etc/sasl2
  printf "%s\n" "pwcheck_method: saslauthd" | sudo tee $sendmail_conf
  printf "%s\n" "mech_list: PLAIN LOGIN" | sudo tee -a $sendmail_conf
  [[ -e /etc/default/saslauthd ]] &&
    sudo perl -i -pe 's/START=no/START=yes/' /etc/default/saslauthd
  [[ -e /.dockerenv ]] && true ||
    ( sudo systemctl enable saslauthd
      sudo systemctl start saslauthd )
}

function configure_rsyslog {
  ## rsyslog rules
  [[ -e /tmp/25-sendmail.conf ]] &&
    [[ -e /etc/rsyslog.d ]] &&
      ( sudo mv /tmp/25-sendmail.conf /etc/rsyslog.d
        sudo chmod 600 /etc/rsyslog.d/25-sendmail.conf
        sudo chown root:root /etc/rsyslog.d/25-sendmail.conf
        [[ -e /.dockerenv ]] || sudo systemctl restart rsyslog ) 
}
## end functions

## main
generate_sendmail_conf
configure_saslauthd
configure_rsyslog
## end main
