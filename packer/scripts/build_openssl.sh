#!/bin/bash

##
## build_openssl.sh
## build openssl 1.0.2 which is required for sendmail
## this is going to be EOL'ed september 2019
## sendmail source will have to handle 1.1.x
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
  CFLAGS="-I/usr/local/lib"
  LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
  export PATH CC CXX LD AS AR CFLAGS LDFLAGS
  [[ -d /usr/local/src/${name}-${version} ]] &&
    ( cd /usr/local/src/${name}-${version}
      sudo ./config --prefix=/usr/local shared
      sudo /usr/bin/make
      sudo /usr/bin/make install
      cleanup_src $name $version )
}

function cleanup_src {
  local name=$1
  local version=$2
  local srcdir=/usr/local/src
  sudo rm -rf ${srcdir}/${name}-${version}
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
VERSION=1.0.2r
NAME=openssl
URL=https://www.openssl.org/source/${NAME}-${VERSION}.tar.gz

## build openssl
build_src $NAME $VERSION $URL
## end main
