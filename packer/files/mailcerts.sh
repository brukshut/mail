#!/bin/bash

##
## mailcerts.sh
## fetch ssl certificates from encrypted s3 bucket
## 
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
BUCKET=secure.gturn.xyz

function die { echo "$*" 1>&2 && exit 1; }

function get_object {
  aws configure set s3.signature_version s3v4
  local key=$1
  local dirname=$2
  [[ -z $3 ]] && local filename=${key} || local filename=$3
  [[ -e "${dirname}/${filename}" ]] ||
    ( aws s3 cp --only-show-errors s3://${BUCKET}/${key} ${dirname}/${filename}
      chown root:root ${dirname}/${filename}
      chmod 600 ${dirname}/${filename} )
}

function dovecot_certs {
  local common_name=$1
  local cert_dir=$2
  certs_dir $cert_dir
  dovecot_pem $common_name $cert_dir
  get_object 'dhparam4096.pem' $cert_dir
}

function sendmail_certs {
  local common_name=$1
  local cert_dir=$2
  certs_dir $cert_dir
  for ext in crt key; do 
    [[ -e ${cert_dir}/${common_name}.${ext} ]] || 
      get_object ${common_name}.${ext} $cert_dir "sendmail.${ext}"
  done
  dkim_key gturn.xyz.private.key /etc/opendkim/keys
  dkim_key bitpusher.org.private.key /etc/opendkim/keys
  bundle_intermediate $cert_dir
  fetch_revoke_crl $cert_dir
}

function fetch_revoke_crl {
  local cert_dir=$1
  ## fetch revoke.crl
  [[ -e ${cert_dir}/revoke.crl ]] ||
    ( wget http://www.cacert.org/revoke.crl --output-document=/tmp/revoke.crl
      sudo mv /tmp/revoke.crl ${cert_dir}/revoke.crl
      sudo chmod 600 ${cert_dir}/revoke.crl
      sudo chown root:root ${cert_dir}/revoke.crl )
}

function dkim_key {
  local key_name=$1
  local cert_dir=$2/${key_name%.private.key}
  [[ -d ${cert_dir} ]] || sudo mkdir -p ${cert_dir}
  [[ -e ${cert_dir}/${key_name} ]] ||
    ( aws s3 cp --only-show-errors s3://${BUCKET}/${key_name} ${cert_dir}/${key_name}
      sudo chown opendkim:opendkim ${cert_dir}/${key_name}
      sudo chmod 0600 ${cert_dir}/${key_name} )
}

function dovecot_pem {
  local common_name=$1
  local cert_dir=$2
  certs_dir $cert_dir
  [[ -s ${cert_dir}/dovecot.pem ]] ||
    ( get_object ${common_name}.crt $cert_dir
      get_object ${common_name}.key $cert_dir
      cat ${cert_dir}/${common_name}.crt | tee -a ${cert_dir}/dovecot.pem
      cat ${cert_dir}/${common_name}.key | tee -a ${cert_dir}/dovecot.pem
      rm ${cert_dir}/${common_name}.crt ${cert_dir}/${common_name}.key
      bundle_intermediate $cert_dir
      cat ${cert_dir}/bundle.pem >> ${cert_dir}/dovecot.pem
      chown root:root ${cert_dir}/dovecot.pem
      chmod 600 ${cert_dir}/dovecot.pem )
}

function certs_dir {
  local cert_dir=$1
  ## ensure cert directory exists
  [[ -d $cert_dir ]] ||
    ( mkdir -p $cert_dir
      chown root:root $cert_dir
      chmod 600 $cert_dir )
}

function bundle_intermediate {
  local cert_dir=$1
  local intermediate_certs=(
    "USERTrustRSACertificationAuthority.crt"
    "USERTrustRSADomainValidationSecureServerCA.crt"
    "AddTrustExternalCARoot.crt"
  )
  ## build bundle if needed
  [[ -e ${cert_dir}/bundle.pem ]] ||
    ( for cert in ${intermediate_certs[@]}; do
      get_object $cert $cert_dir &&
        cat ${cert_dir}/${cert} | tee -a ${cert_dir}/bundle.pem
        rm ${cert_dir}/${cert}
      done
      chown root:root ${cert_dir}/bundle.pem
      chmod 600 ${cert_dir}/bundle.pem )
}

function usage { printf "%s\n" "Usage: $0 -c [common name] [-d] [-s]" ; exit 1;}
## end functions

## main
while getopts "c:sd" opt; do
  case $opt in
    c) common_name=$OPTARG ;;
    d) dovecot=true ;;
    s) sendmail=true ;;
    *) usage ;;
  esac
done

## require -c and -s or -d flags
[[ ! -z $common_name ]] &&
  ( [[ $sendmail ]] || [[ $dovecot ]] ) || usage

## handle sendmail certificates
[[ $sendmail == true ]] && sendmail_certs $common_name '/etc/mail/ssl'

## handle dovecot certificates
[[ $dovecot == true ]] && dovecot_certs $common_name '/etc/dovecot/ssl'

## end main

