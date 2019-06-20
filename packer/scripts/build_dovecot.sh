#!/bin/bash -x

##
## build_dovecot.sh
## we will build dovecot ourselves, rather than use debian packages
## for example, we don't need exim4 and mysql to use dovecot
##

## functions
function build_src {
  local name=$1
  local version=$2
  local url=$3
  ## fetch src
  fetch_src $name $version $url
  CC=/usr/bin/gcc
  CXX=/usr/bin/g++
  LD=/usr/bin/ld
  AS=/usr/bin/as
  AR=/usr/bin/ar
  CFLAGS="-I/usr/local/include -I/usr/local/include/openssl"
  LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
  export PATH CC LD AS AR CFLAGS LDFLAGS
  [[ -d /usr/local/src/${name}-${version} ]] &&
    ( cd /usr/local/src/${name}-${version}
      sudo ./configure --prefix=/usr/local \
      --localstatedir=/var/dovecot \
      --sysconfdir=/etc \
      --with-ssl=openssl \
      --with-gnu-ld \
      --with-pam \
      --with-shadow \
      --localstatedir=/var
      sudo /usr/bin/make -j2
      sudo /usr/bin/make install )
}

function cleanup_src {
  local name=$1
  local version=$2
  local srcdir=/usr/local/src
  sudo rm -rf ${srcdir}/${name}-${version}
}

function configure_dovecot {
  ## create configuration directory
  ## copy base configuration files
  [[ -d /etc/dovecot ]] || sudo mkdir /etc/dovecot
  sudo rsync -av /usr/local/share/doc/dovecot/example-config/ /etc/dovecot
  ## dovecot state folder
  [[ -d /var/dovecot ]] ||
    ( sudo mkdir /var/dovecot
      sudo chown dovecot:dovecot /var/dovecot)
  ## dovecot configuration
  [[ -e /tmp/dovecot.conf ]] &&
    ( sudo mv /tmp/dovecot.conf /etc/dovecot/dovecot.conf
      sudo chown dovecot:dovecot /etc/dovecot/dovecot.conf )
  ## dovecot ssl configuration
  [[ -e /tmp/10-ssl.conf ]] &&
    ( sudo mv /tmp/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf
      sudo perl -i -pe 's/#log_path = syslog/log_path = stderr/' /etc/dovecot/conf.d/10-logging.conf )
  ## dovecot systemd
  configure_dovecot_services
}

function configure_dovecot_services {
  ## dovecot systemd service description
  [[ -e /tmp/dovecot.service ]] &&
    ( sudo mv /tmp/dovecot.service /lib/systemd/system/dovecot.service
      sudo chown root:root /lib/systemd/system/dovecot.service )
  ## dovecot systemd socket description
  [[ -e /tmp/dovecot.socket ]] &&
    ( sudo mv /tmp/dovecot.socket /lib/systemd/system/dovecot.socket
      sudo chown root:root /lib/systemd/system/dovecot.socket )
  sudo systemctl daemon-reload
  sudo systemctl enable dovecot
}

function create_dovecot_users {
  ## create dovecot users
  sudo groupadd -g 143 dovecot
  sudo useradd -u 143 -g dovecot -d /usr/local/share/dovecot -s /bin/false dovecot
  sudo groupadd -g 144 dovenull
  sudo useradd -u 144 -g dovenull -d /nonexistent -s /bin/false dovenull
}

function fetch_src {
  local name=$1
  local version=$2
  local url=$3
  local srcdir=/usr/local/src
  local tarball=${name}.${version}.tar.gz
  local src=${name}-${version}
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
## end functions

## main
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
NAME=dovecot
VERSION=2.3.6
URL=https://dovecot.org/releases/2.3/${NAME}-${VERSION}.tar.gz

## build dovecot
create_dovecot_users
build_src $NAME $VERSION $URL
configure_dovecot
cleanup_src $NAME $VERSION

## end main
