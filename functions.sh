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
