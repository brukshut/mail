#!/bin/bash -x

##
## create_users.sh
##
PATH=/bin:/sbin:/usr/bin:/usr/sbin

## functions
function die { echo "$*" 1>&2 && exit 1; }

function create_group {
  local user=$1
  local uid=$2
  [[ -z $(getent group ${user}) ]] && sudo groupadd -g ${uid} ${user}
}

function create_user {
  local user=$1
  local uid=$2
  local home=/home/${user}
  [[ -z $(getent passwd ${user}) ]] && 
    sudo useradd -u ${uid} -g ${uid} -d ${home} -m -s /bin/bash ${user}
}

function create_ssh_folder {
  local user=$1
  local home=/home/${user}
  [[ -d ${home} ]] &&
    ( sudo mkdir ${home}/.ssh
      sudo chmod 0700 ${home}/.ssh
      sudo chown ${user}:${user} ${home}/.ssh )
}

function copy_ssh_key {
  local user=$1
  local home=/home/${user}
  [[ -e /tmp/authorized_keys ]] && 
    ( sudo cp /tmp/authorized_keys ${home}/.ssh/
      sudo chown ${user}:${user} ${home}/.ssh/authorized_keys
      sudo chmod 600 ${home}/.ssh/authorized_keys ) || 
      die 'authorized_keys not found'
}

function grant_sudo_access {
  local user=$1
  [[ -e /etc/sudoers.d/11-${USER} ]] || 
    ( echo "${user} ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/11-${user}
    sudo chmod 0440 /etc/sudoers.d/11-${user} )
}

function create_new_user {
  local user=$1
  local uid=$2
  create_group $user $uid
  create_user $user $uid
  create_ssh_folder $user
  copy_ssh_key $user
  grant_sudo_access $user
  set_pw $user
}

function set_pw {
  local user=$1
  local file=/tmp/.pw
  [[ -e /tmp/.pw ]] && 
    ( local hash=$(sudo cat $file)
      printf "%s:%s" $user $hash | sudo chpasswd -e ) ||
      true
}
## end functions

## main
create_new_user cgough 501
create_new_user christian 600
create_new_user contact 601
## end main
