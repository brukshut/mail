#!/bin/bash

##
## dotfiles.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin

## functions
function die { echo "$*" 1>&2 && exit 1; }

function clone_dotfiles {
  local user=$1
  local home=/home/${user}
  ## clone .dotfiles repo
  [[ -d ${home} ]] && cd ${home} || die "${home} does not exist"
  sudo su ${user} -c "git clone git://github.com/brukshut/dotfiles.git .dotfiles" || 
    die "can't clone dotfiles into ${home}"
}

function link_dotfiles {
  local user=$1
  local home=/home/${user}
  cd ${home} && 
    ( sudo rm .bashrc
      for dotfile in .bash_profile .bashrc .emacs .gitconfig .vimrc .mailfilter; do 
        sudo su ${user} -c "ln -s .dotfiles/${dotfile} $dotfile"
        [[ $dotfile == '.mailfilter' ]] && sudo chmod 600 $dotfile
      done ) || die
}
## end functions

## main
for user in cgough contact christian; do
  clone_dotfiles ${user}
  link_dotfiles ${user}
done
## end main
