#!/bin/bash 

##
## build.sendmail.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

## functions
function fetch_sendmail_src {
  ## sendmail src is required for macros in sendmail.mc and submit.mc
  local version=$1
  local name=sendmail
  local srcdir=/usr/local/src
  local tarball=${name}.${version}.tar.gz
  local src=${name}-${version}
  local url=http://ftp.sendmail.org/${name}.${version}.tar.gz
  [[ -d ${srcdir} ]] || sudo mkdir -p ${srcdir}
  [[ -d ${srcdir}/${src} ]] ||
    ( [[ -e ${srcdir}/${tarball} ]] ||
      ( wget $url --output-document=/tmp/${tarball}
        sudo mv /tmp/${tarball} $srcdir
        sudo chown root:root ${srcdir}/${tarball}
        sudo tar xzvf ${srcdir}/${tarball} -C ${srcdir}
        sudo chown -R root:root ${srcdir}/${src} ))
}

function create_sendmail_dirs {
  ## create package directory structure
  for mydir in bin sbin lib include libexec share; do
    [[ ! -d /usr/local/${mydir} ]] && sudo mkdir -p /usr/local/${mydir}
  done
  ## configuration directory
  [[ -d /etc/mail ]] || sudo mkdir -p /etc/mail
  ## man folders
  for mandir in man1 man5 man8; do
    [[ ! -d /usr/local/share/man/${mandir} ]] &&
      sudo mkdir -p /usr/local/share/man/${mandir}
  done
}

function create_sendmail_users {
  ## create users and group
  [[ -z $(getent group floppy) ]] || sudo groupdel floppy
  sudo groupadd -g 25 smmsp
  sudo useradd -u 25 -g 25 -d /var/spool/clientmqueue -s /bin/false smmsp
  sudo mkdir /var/spool/mqueue
  sudo chmod 700 /var/spool/mqueue
}

function build_sendmail {
  local version=$1
  local sendmail_src=/usr/local/src/sendmail-${version}
  [[ -e /tmp/site.config.m4 ]] &&
    ( [[ -d $sendmail_src ]] && cd $sendmail_src
      sudo cp /tmp/site.config.m4 devtools/Site
      sudo ./Build 
      sudo ./Build install
      cd libmilter &&
      sudo ./Build
      sudo ./Build install )
}

function install_sendmail_man {
  local version=$1
  local sendmail_src=/usr/local/src/sendmail-${version}
  local mandir=/usr/local/share/man
  [[ -d $sendmail_src ]] && 
    ( cd $sendmail_src
      ## man pages
      for manpage in sendmail editmap mailstats makemap praliases smrsh; do
        sudo install -v -m644 ${manpage}/${manpage}.8 ${mandir}/man8
      done
      sudo install -v -m644 sendmail/aliases.5 ${mandir}/man5
      sudo install -v -m644 sendmail/mailq.1 ${mandir}/man1
      sudo install -v -m644 sendmail/newaliases.1 ${mandir}/man1
      sudo install -v -m644 vacation/vacation.1 ${mandir}/man1 )
}

function sendmail_systemd_services {
  ## sendmail.service and sendmail-runner.service
  [[ -e /.dockerenv ]] || 
    ( for name in sendmail sendmail-runner; do 
      [[ -e /tmp/${name}.service ]] &&
        ( sudo mv /tmp/${name}.service /lib/systemd/system
          sudo chown root:root /lib/systemd/system/${name}.service
          sudo chmod 644 /lib/systemd/system/${name}.service )
      sudo systemctl enable ${name}.service
      done
      sudo systemctl daemon-reload )
}
## end functions

## main
create_sendmail_users
create_sendmail_dirs
fetch_sendmail_src 8.15.2
build_sendmail 8.15.2
install_sendmail_man 8.15.2
sendmail_systemd_services
## end main
