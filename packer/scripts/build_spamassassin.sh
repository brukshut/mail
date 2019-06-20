#!/bin/bash

##
## build_spamassassin.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

## functions

## create debian-spamd user
function create_sa_users {
  ## create debian-spamd user and group
  sudo groupadd -g 555 debian-spamd
  sudo useradd -u 555 -g debian-spamd -d /var/lib/spamassassin -s /bin/sh debian-spamd
}

function install_pkgs {
  local pkgs=( \
    libhtml-html5-parser-perl \
    libnet-dns-perl \
    libnetaddr-ip-perl \
    libdbi-perl \
    libmail-spf-perl \
    libnet-cidr-lite-perl \
    libnet-patricia-perl \
    libmail-dkim-perl \
    libencode-detect-perl \
    libgeo-ip-perl \
    pyzor \
    razor \
    spamassassin)
  for pkg in "${pkgs[@]}"; do
    sudo apt-get install ${pkg} -y
  done
}

function configure_sa {
  local files=(local.cf v310.pre)
  for file in "${files[@]}"; do
    [[ -e /tmp/${file} ]] &&
      ( sudo mv /tmp/${file} /etc/spamassassin/${file}
        sudo chown -R root:root /etc/mail/spamassassin ) || true
  done
}

function install_digest_sha1 {
  ## mimedefang wants this perl module which debian does not provide
  local name=Digest-SHA1
  local srcdir=/usr/local/src
  local version=2.13
  local tarball=${name}-${version}.tar.gz
  local src=${name}-${version}
  local url=https://cpan.metacpan.org/authors/id/G/GA/GAAS/${name}-${version}.tar.gz
  [[ -d ${srcdir} ]] || sudo mkdir -p ${srcdir}
    ( [[ -d ${srcdir}/${src} ]] ||
      ( wget $url --output-document=/tmp/${tarball}
        sudo mv /tmp/${tarball} $srcdir
        sudo tar xzvf ${srcdir}/${tarball} -C ${srcdir}
        sudo chown -R root:root ${srcdir}/${src}
        cd ${srcdir}/${src}
        sudo perl Makefile.PL
        sudo make
        sudo make install
        cd ${srcdir}
        sudo rm ${tarball}
        sudo rm -rf ${name}-${version} ))
}
## end functions

## main
create_sa_users
install_digest_sha1
install_pkgs
configure_sa
## end main
