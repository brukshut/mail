#!/bin/bash -x

##
## build_mailutils.sh
## builds and installs gnu mailutils
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
  MU_DEFAULT_SCHEME=maildir
  EMACS=/usr/local/bin/emacs
  export PATH CC LD AS AR CFLAGS LDFLAGS MU_DEFAULT_SCHEME EMACS
  [[ -d /usr/local/src/${name}-${version} ]] &&
    ( cd /usr/local/src/${name}-${version}
      sudo ./configure --prefix=/usr/local \
      --enable-build-clients \
      --disable-build-servers \
      --disable-pop \
      --disable-build-pop3d \
      --disable-mh \
      --disable-build-mh \
      --with-gnutls \
      --with-berkeley-db \
      --with-readline \
      --with-pic
      sudo /usr/bin/make -j2
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
## required packages
sudo apt-get install libreadline-dev -y
sudo apt-get install libgnutls28-dev -y

## build mailutils
NAME=mailutils
VERSION=3.6
URL=https://ftp.gnu.org/gnu/mailutils/${NAME}-${VERSION}.tar.gz
build_src ${NAME} ${VERSION} ${URL}
## end main
