#!/usr/bin/env bash

###################################################################
# Script Name    : setup.sh
# Description    : Link bash_profile to ${HOME}/.bash_profile; and
#                  install bash-it
# Args           : None
# Author         : Doug Emery
# Email          : hummus.augment_0r@icloud.com
###################################################################

CMD=$(basename $0)
THIS_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
TIMESTAMP=$(date +"%Y-%m-%d")
BASH_PROFILE=${HOME}/.bash_profile
BASH_IT_DIR=${HOME}/.bash_it
BASH_IT_OPTS=
HOMEBREW_PACKAGES="bash-completion"

msg() {
  echo "[${CMD}] $1"
}

usage() {
  echo "Usage: ${CMD} [-h] [-b|-u]"
}

description() {
  cat <<EOF

Description:
------------
Setup bash configuration

- link ~/.bash_profile to ${THIS_DIR}/bash_profile
- install Bash It
- optionally install or upgrade Homebew package(s):
    - ${HOMEBREW_PACKAGES}

Options:
-------------------
-h          Print this help message and exit
-b          Install homebrew packages
-u          Install or upgrade homebrew packages
EOF
}

install_pkg() {
  ip_pkg=$1
  ip_upgrade=$2
  if brew list | egrep -q "\b${ip_pkg}\b"
  then
    msg "Package already installed: ${pkg}"
    if [[ -n ${ip_upgrade} ]]
    then
      msg "Upgrade requested; upgrading: ${pkg}"
      brew upgrade ${pkg}
    fi
  else
    brew install ${pkg}
  fi
}

homebrew=
homebrew_upgrade=
while getopts "hbu" opt; do
  case "$opt" in
    h)
      usage
      description
      exit 0
      ;;
    b)
      homebrew=true
      ;;
    u)
      homebrew=true
      homebrew_upgrade=true
      ;;
    ?)
      usage
      echo "Error: did not recognize option, ${OPTARG}."
      echo "Please try -h for help."
      exit 1
      ;;
  esac
done

if [[ -L ${BASH_PROFILE} ]]
then
  if cmp ${BASH_PROFILE} ${THIS_DIR}/bash_profile
  then
    msg "Already linked: '${BASH_PROFILE}'; skipping"
  else
    msg "WARNING: ${BASH_PROFILE} is linked but not to here"
    msg "WARNING: If you want to install this bash_profile; please unlink ${BASH_PROFILE}"
    msg "WARNING: Quitting"
    exit 1
  fi
else
  backup_file=${BASH_PROFILE}-${TIMESTAMP}-$$ # in case run more than 1x in a day
  msg "Backing up current '${BASH_PROFILE}' to '${backup_file}'"
  mv -v ${BASH_PROFILE} ${backup_file}

  msg "Linking bash_profile"
  ln -sv ${THIS_DIR}/bash_profile ${BASH_PROFILE}
fi

# Install bash_it
msg "Install bash-it"
if [[ -e ${BASH_IT_DIR} ]]
then
  msg "Bash-it already installed: ${BASH_IT_DIR}"
  msg "Updating bash-it"
  (
    cd ${BASH_IT_DIR}
    if git status
    then
      git pull
    else
      msg "${BASH_IT_DIR} has modifications; refusing to update"
    fi
  )
else
  git clone --depth=1 https://github.com/Bash-it/bash-it.git ${BASH_IT_DIR}
  if grep -q BASH_IT ${BASH_PROFILE}; then
    msg="WARNING: Not modifying ${BASH_PROFILE}; bash-it templates already added"
    BASH_IT_OPTS="--no-modify-config"
  fi
  ${BASH_IT_DIR}/install.sh ${BASH_IT_OPTS}
  bash_it enable alias git
fi

# Install homebrew packages
if [[ -n ${homebrew} ]]
then
  msg "Installing homebrew packages: ${HOMEBREW_PACKAGES}"
  if which -s brew
  then
    for pkg in ${HOMEBREW_PACKAGES}
    do
      install_pkg ${pkg} ${homebrew_upgrade}
    done
  else
    msg "WARNING: Homebrew not found"
    msg "WARNING: No packages installed"
    msg "Please install homebrew and add it to your path"
  fi
fi

msg "Done"
