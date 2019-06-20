#!/bin/bash -x

##
## build_mimedefang.sh
## installing after spamassassin handles many dependencies
## 
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

## functions

function build_mimedefang {
  local version=$1
  fetch_mimedefang_src $version
  local mimedefang_src=/usr/local/src/mimedefang-${version}
  [[ -d ${mimedefang_src} ]] && 
    cd ${mimedefang_src}
    CFLAGS="-I/usr/local/include"
    LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
    LD_RUN_PATH="/usr/local/lib"
    export PATH CFLAGS LDFLAGS LD_RUN_PATH
    sudo ./configure --prefix=/usr/local \
      --with-sendmail=/usr/local/sbin/sendmail \
      --with-user=defang \
      --with-milterlib=/usr/local/lib \
      --with-milterinc=/usr/local/include/libmilter \
      --enable-clamav
    sudo /usr/bin/make
    sudo /usr/bin/make install
    systemd_units
    cleanup_src mimedefang 2.84
}

function cleanup_src {
  local name=$1
  local version=$2
  local srcdir=/usr/local/src
  sudo rm -rf ${srcdir}/${name}-${version}
}

function configure_mimedefang {
  ## mimedefang configuration file
  [[ -e /tmp/mimedefang-filter.pl ]] &&
    ( sudo mv /tmp/mimedefang-filter.pl /etc/mail/mimedefang-filter
      sudo chown defang:defang /etc/mail/mimedefang-filter )
  ## spamassassin configuration
  [[ -e /etc/spamassassin/local.cf ]] &&
    sudo cp /etc/spamassassin/local.cf /etc/mail/sa-mimedefang.cf
  ## permissions
  sudo chgrp defang /etc/mail
  sudo chown -R defang:defang /etc/spamassassin
  sudo usermod -G mail defang
  ## enable systemd
  sudo systemctl daemon-reload
  sudo systemctl enable mimedefang
  sudo systemctl start mimedefang
}

function create_users {
  ## defang
  sudo groupadd -g 777 defang
  sudo useradd -u 777 -g defang -d /var/mimedefang -s /bin/bash defang
  ## clamav 
  sudo groupadd -g 666 clamav
  sudo useradd -u 666 -g 666 -d /var/lib/clamav -s /bin/false clamav
  ## group membership
  sudo usermod -G clamav defang
  sudo usermod -G defang clamav
  sudo usermod -G defang mail
}
 
function fetch_mimedefang_src {
  ## sendmail src is required for macros in sendmail.mc and submit.mc
  local version=$1
  local name=mimedefang
  local srcdir=/usr/local/src
  local tarball=${name}.${version}.tar.gz
  local src=${name}-${version}
  local url=https://mimedefang.org/static/${name}-${version}.tar.gz
  [[ -d ${srcdir} ]] || sudo mkdir -p ${srcdir}
  [[ -d ${srcdir}/${src} ]] && true ||
    ( [[ -e ${srcdir}/${tarball} ]] ||
      ( wget $url --output-document=/tmp/${tarball}
        sudo mv /tmp/${tarball} $srcdir
        sudo chown root:root ${srcdir}/${tarball} ))
  cd ${srcdir} &&
    ( sudo tar xzvf ${srcdir}/${tarball} -C ${srcdir}
      sudo rm ${srcdir}/${tarball}
      sudo chown -R root:root ${srcdir}/${src} )
}

function install_pkgs {
  sudo apt-get install libmime-tools-perl -y
  sudo apt-get install clamav -y
}
 
function systemd_units {
  ## systemd units
  sudo perl -p -i -e 's!/usr/bin/mime!/usr/local/bin/mime!' systemd-units/mimedefang*
  sudo cp systemd-units/mimedefang-multiplexor.service /lib/systemd/system/
  sudo cp systemd-units/mimedefang.service /lib/systemd/system/
}
## end functions

## main
create_users
install_pkgs
build_mimedefang 2.84
configure_mimedefang
## end main

