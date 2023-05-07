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

function msg {
  echo "[${CMD}] $1"
}

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
fi

msg "Done"
