#!/bin/bash -x

##
## build_maildrop.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
NAME=maildrop
VERSION=3.0.0
URL=https://cfhcable.dl.sourceforge.net/project/courier/maildrop/${VERSION}/maildrop-${VERSION}.tar.bz2
CC=/usr/bin/gcc
CXX=/usr/bin/g++
LD=/usr/bin/ld
AS=/usr/bin/as
AR=/usr/bin/ar
CFLAGS="-I/usr/local/include"
LDFLAGS="-Wl,-L/usr/local/lib -Wl,-rpath=/usr/local/lib"
export PATH CC LD AS AR CFLAGS LDFLAGS

## install required libraries
sudo apt-get install libpcre3-dev -y
sudo apt-get install libidn11-dev -y

## fetch and unpack tarball
wget $URL
tar xvf ${URL##*/}
cd ${NAME}-${VERSION}
./configure --prefix=/usr \
--enable-sendmail=/usr/local/sbin/sendmail \
--enable-shared \
--disable-static \
--disable-tempdir \
--enable-syslog=1 \
--enable-restrict-trusted=1 \
--enable-trusted-users='root mail cgough christian contact' \
--enable-maildrop-uid=root \
--enable-maildrop-gid=mail \
--disable-authlib
/usr/bin/make
sudo /usr/bin/make install

## cleanup
cd ..
#rm ${URL##*/}
#rm -rf ${NAME}-${VERSION}

## /etc/mail/access
cat <<EOF > /tmp/maildroprc
##
## /etc/maildroprc
##
SHELL="/bin/bash"
SENDMAIL="/usr/local/sbin/sendmail -oi -t"
DEFAULT="\$HOME/Maildir/"
#logfile "/var/log/maildrop.log"
EOF
sudo mv /tmp/maildroprc /etc/maildroprc
