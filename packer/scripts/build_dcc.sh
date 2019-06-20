#!/bin/bash -x

##
## build_dcc.sh
## Distributed Checksum Clearinghouse
## makes spamassassin more efficient
## 

## functions
function cleanup_src {
  local name=dcc
  local version=$1
  local srcdir=/usr/local/src
  sudo rm -rf ${srcdir}/${name}-${version}
}

function fetch_src {
  local name=$1
  local version=$2
  local srcdir=/usr/local/src
  local tarball=${name}.tar.Z
  local src=${name}-${version}
  local url=https://www.dcc-servers.net/dcc/source/${tarball}
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

function link_dcc_home {
  sudo chown -R dcc:dcc /var/dcc
  sudo rsync -av /var/dcc /export/home
  sudo mv /var/dcc /var/.dcc
  sudo ln -s /export/home/dcc /var/dcc
}

function create_dcc_users {
  ## create dcc user and group
  sudo groupadd -g 199 dcc
  sudo useradd -u 199 -g dcc -d /var/dcc -s /bin/false dcc
}

function build_src {
  local name=$1
  local version=$2
  ## fetch src
  fetch_src $name $version
  CC=/usr/bin/gcc
  CXX=/usr/bin/g++
  LD=/usr/bin/ld
  AS=/usr/bin/as
  AR=/usr/bin/ar
  CFLAGS="-I/usr/local/lib"
  LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
  export PATH CC CXX LD AS AR CFLAGS LDFLAGS
  cd /usr/local/src
  [[ -d /usr/local/src/${name}-${version} ]] &&
    ( cd ${name}-${version}
      sudo ./configure \
      --homedir=/var/dcc \
      --bindir=/usr/local/bin \
      --libexecdir=/usr/local/libexec \
      --mandir=/usr/local/man \
      --with-rundir=/var/dcc \
      --disable-IPv6 \
      --disable-server \
      --disable-dccm \
      --disable-dccifd \
      --with-uid=555
      sudo /usr/bin/make
      sudo /usr/bin/make install
     link_dcc_home
     cleanup_src $name $version )
}
## end functions

## main
NAME=dcc
VERSION=1.3.163
create_dcc_users
build_src $NAME $VERSION

## end main
