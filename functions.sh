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
function msg {
  echo "[$cmd] $1"
}

##
# Print an ERROR message and quit with an error status (`1`)
function error {
  msg "ERROR: $1"
  exit 1
}

function error_no_exit {
  msg "ERROR: $1"
}

##
# See if the named application is installed (MacOS)
function is_installed {
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
function is_running {
  ir_application="$1"

  ps -ef | sed /grep/d | grep -q "${ir_application}"

  status=$?
  return $status
}

function homebrew_bin_dir {
  if ! which -s brew
  then
    error_no_exit "Homebrew not installed or not in PATH; homebrew prefix not found"
    return 1
  fi

  dirname $(which brew)
}

function brew_install_python {
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

##
# Find the latest pip3.x
function find_pip3x {
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
function find_python3x {
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
