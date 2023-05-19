#!/usr/bin/env bash

shopt -s expand_aliases
source $(dirname $0)/functions.sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

packages="${HOME}/Library/Application Support/Sublime Text/packages"
user_packages="${packages}/User"
user_packages_backup=${user_packages}.$(tstamp)
source_packages="${SCRIPT_DIR}/Library/Application Support/Sublime Text/packages/User"

# quit if sublime isn't installed
if is_installed "Sublime Text"
then
  msg "Sublime Text is installed; proceeding"
else
  error "Please install Sublime Text before running setup"
fi

# quit if sublime is running
if ps -ef | sed /grep/d | grep -q "Sublime Text"
then
  error "Refusing to setup while Sublime Text is running"
fi

# quit if there's no Packages directory
if [[ -e "${packages}" ]]
then
  msg "Package directory found: ${packages}"
else
 error "Package directory not found: ${packages}"
fi

# quit if current sublime user package dir is a symlink
[[ -L "${user_packages}" ]] && error "Already symlinked: ${user_packages}"

# mv current sublime user package dir to User.old
if [[ -e "${user_packages}" ]]
then
  msg "Backing up User packages: ${user_packages}"
  mv "${user_packages}" "${user_packages_backup}" || error "Unable to to back up User packages"
  msg "User packages backed up to ${user_packages_backup}"
fi


# link local sublime user packages dir to User
msg "Create symlink: ${user_packages} ->"
msg "        ${source_packages}"
(
  cd "${packages}"
  ln -s "${source_packages}"
)
if ls -l "${user_packages}" >/dev/null
then
  msg "Sublime Text settings are now available"
else
  error "Something went wrong; Sublime Text settings not installed"
fi
