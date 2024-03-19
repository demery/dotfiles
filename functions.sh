###############################################################################
# Script Name    : functions.sh
# Description    : Functions for use in `.dofiles` scripts
# Args           : None
# Author         : Doug Emery
# Email          : hummus.augment_0r@icloud.com
###############################################################################


##
# Set the variable `cmd` to the running script; to be used in messages
if basename "$0" >/dev/null 2>&1
then
  cmd=$(basename $0)
else
  cmd=$(basename $SHELL)
fi

##
# Alias to create a filename-suitable timestamp. Add the following to your
# script **before** sourcing this file to make the alias available in to your
# script.
#
#
# ```bash
# shopt -s expand_aliases
# source $(dirname $0)/functions.sh
# ```
alias tstamp="date +%Y%m%dT%H%M%S"

##
# Print a message preceded by the name of the current command
msg() {
  echo "[$cmd] $1"
}

##
# Print an ERROR message and quit with an error status (`1`)
error() {
  msg "ERROR: $1"
  exit 1
}

warning() {
  msg "WARNING: $1"
}

error_no_exit() {
  msg "ERROR: $1"
}

##
# See if the named application is installed (MacOS)
is_installed() {
  ii_application="$1"

  mdfind "kMDItemKind == 'Application'" | grep -q "$ii_application"

  status=$?
  return $status
}

##
# Return success status if the application is is running; error status
# otherwise.
#
# argument: the search string for the running application
#
is_running() {
  ir_application="$1"

  ps -ef | sed /grep/d | grep -q "${ir_application}"

  status=$?
  return $status
}

homebrew_bin_dir() {
  if ! which -s brew
  then
    error_no_exit "Homebrew not installed or not in PATH; homebrew prefix not found"
    return 1
  fi

  dirname $(which brew)
}

brew_install_python() {
  if ! homebrew_bin_dir
  then
    return 1
  else
    # something like python@3.11
    bip_python_keg=$(brew search /^python@3/ | gsort -Vr | head -1)
  fi
  PATH=$(homebrew_bin_dir):$PATH

  if [[ -n "${bip_python_keg}" ]]
  then
    # the python executable for python@3.11 will be python3.11
    bip_python=$(echo ${bip_python_keg} | awk -F '@' '{ print $1 $2 }')
    if which -s ${bip_python}
    then
      msg "Python already installed: $(which ${bip_python})"
    else
      brew install ${bip_python_keg}
    fi
  else
    error_no_exit "Unable to find hombrew package for any /^python@3/"
    return 1
  fi
}

update_pyenv() {
  if ! which -s brew
  then
    error_no_exit "Homebrew not found; please install homebrew or add it to your path"
    return 1
  fi
  brew upgrade pyenv
}

latest_pyenv_version() {
  if ! which -s pyenv
  then
    error_no_exit "PYENV not installed"
    return 1
  fi
  if update_pyenv
  then
    python_version=$(pyenv install --list | egrep "^\s+\d\.\d+\.\d+$" | tail -1)
    echo ${python_version}
  else
    return 1
  fi

}
pyenv_install_python() {
  python_version=$(latest_pyenv_version)
  if [[ -z "${python_version}" ]]
  then
     error_no_exit "Unable to get latest python version from pyenv"
     return 1
  fi

  if pyenv versions | grep -q ${python_version}
  then
    msg "Python version ${python_version} already installed"
  else
    msg "Installing Python version ${python_version}"
    pyenv install ${python_version}
  fi
}



##
# Find the latest pip3.x
find_pip()3x {
  bin_dir=$(homebrew_bin_dir)
  if [[ -n "${bin_dir}" ]]
  then
    fp_pip3x=$(ls ${bin_dir}/pip3.* | gsort -rV | head -1)
    if [[ -n "${fp_pip3x}" ]]
    then
      echo ${fp_pip3x}
    else
      error_no_exit "Unable to find pip3.x in ${bin_dir}"
      return 1
    fi
  else
    error_no_exit "Unable to find Homebrew bin directory"
    return 1
  fi
}


##
# Find the latest python3.x
find_python()3x {
  bin_dir=$(homebrew_bin_dir)
  if [[ -n "${bin_dir}" ]]
  then
    fp_python3x=$(ls ${bin_dir}/python3.* | grep "[0-9]$" | gsort -rV | head -1)
    if [[ -n "${fp_python3x}" ]]
    then
      echo ${fp_python3x}
    else
      error_no_exit "Unable to find python3.x in ${bin_dir}"
      return 1
    fi
  else
    error_no_exit "Unable to find Homebrew bin directory"
    return 1
  fi
}
