#!/usr/bin/env bash

###############################################################################
# Script Name    : setup_homebrew.sh
# Description    : Install homebrew and basic packages (bash, rbenv, pyenv,
#                  etc.), upgraded existing packages if homebrew is already
#                  installed; installs the latest versions of ruby and python
# Args           : None
# Author         : Doug Emery
# Email          : hummus.augment_0r@icloud.com
###############################################################################

shopt -s expand_aliases
source $(dirname $0)/functions.sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

HOMEBREW_PACKAGES="rbenv ruby-build coreutils tree vim git bash bash-completion pyenv npm dos2unix ipython"

LATEST_PYTHON3=$(brew search /^python@3/ | gsort -Vr | head -1)

[[ -n "$LATEST_PYTHON3" ]] && HOMEBREW_PACKAGES="${HOMEBREW_PACKAGES} ${LATEST_PYTHON3}"

if which -s brew
then
  msg "Homebrew already installed"
else
  msg "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

packages_to_install=
installed=$(brew list)
for pkg in $HOMEBREW_PACKAGES
do
  echo "$installed" | egrep -q "\b$pkg\b" || packages_to_install="${packages_to_install} $pkg"
done

if [[ -n "${packages_to_install}" ]]
then
  msg "Installing ${packages_to_install}"
  brew install ${packages_to_install}
else
  msg "No packages to install"
fi

outdated=$(brew outdated)
if [[ -n "${outdated}" ]]
then
  msg "Upgrading outdated packages: $(echo ${outdated})"
  brew upgrade ${outdated}
else
  msg "No packages are outdated"
fi

# install the latest ruby
ruby_version=$(rbenv install --list | egrep "^\d" | tail -1)

if rbenv versions | grep -q ${ruby_version}
then
  msg "Ruby version ${ruby_version} already installed"
else
  msg "Installing Ruby version ${ruby_version}"
  rbenv install ${ruby_version}
fi

# set up python

# install the latest python
pyenv_install_python
python_version=$(latest_pyenv_version)
if [[ -n "${python_version}" ]]
then
  msg "Setting global python version to ${python_version}"
  pyenv global ${python_version}
fi
