#!/bin/bash -x

##
## build_courier_unicode.sh
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
  CFLAGS="-I/usr/local/include"
  LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
  export PATH CC LD AS AR CFLAGS LDFLAGS
  [[ -d /usr/local/src/${name}-${version} ]] &&
    ( cd /usr/local/src/${name}-${version}
      sudo ./configure --prefix=/usr/local
      sudo /usr/bin/make
      sudo /usr/bin/make install )
      #cleanup_src $name $version )
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
  local tarball=${name}.${version}.tar.bz2
  local src=${name}-${version}
  [[ -d ${srcdir} ]] || sudo mkdir -p ${srcdir}
  [[ -d ${srcdir}/${src} ]] && true ||
    ( [[ -e ${srcdir}/${tarball} ]] ||
      ( wget $url --output-document=/tmp/${tarball}
        sudo cp /tmp/${tarball} $srcdir
        sudo chown root:root ${srcdir}/${tarball} ))
  cd ${srcdir} &&
    ( sudo tar xvf ${srcdir}/${tarball} -C ${srcdir}
      sudo rm ${srcdir}/${tarball}
      sudo chown -R root:root ${srcdir}/${src} )
}
## end functions

## main

## build courier-unicode
NAME=courier-unicode
VERSION=2.1
URL="https://downloads.sourceforge.net/project/courier/courier-unicode/2.1/${NAME}-${VERSION}.tar.bz2"

build_src $NAME $VERSION $URL

## end main
