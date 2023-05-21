#!/usr/bin/env bash

###############################################################################
# Script Name    : setup_nova.sh
# Description    : Link Nova extensions and preferences to
#                  `~/Library`
# Args           : None
# Author         : Doug Emery
# Email          : hummus.augment_0r@icloud.com
#
# See:
#
#   https://help.panic.com/nova/moving-data/
#
# Note this method does not handle code clips. For that the doc
# says:
#
# > Clips can be exported to a file from the Clips Sidebar by clicking the
# > gear icon at the bottom and choosing Export Clips… from the menu, and can
# > be imported from a file using the Import Clips… option in the same menu.
###############################################################################

shopt -s expand_aliases
source $(dirname $0)/functions.sh
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Nova Extensions
nova_folder="${HOME}/Library/Application Support/Nova/"
extensions="${nova_folder}/Extensions"
extensions_backup=${extensions}.$(tstamp)
source_extensions="${SCRIPT_DIR}/Library/Application Support/Nova/Extensions"

# Nova Preferences
prefs_folder="${HOME}/Library/Preferences"
nova_prefs="${prefs_folder}/com.panic.Nova.plist"
source_prefs="${SCRIPT_DIR}/Library/Preferences/com.panic.Nova.plist"

# quit if Nova isn't installed
if is_installed "Nova.app"
then
  msg "Nova is installed; proceeding"
else
  error "Please install Nova before running setup"
fi

# quit if Nova is running
if is_running "Nova.app.*/Nova$"
then
  error "Refusing to run setup while Nova is running"
fi

# quit if there's no Nova directory in Application Support
if [[ -e "${nova_folder}" ]]
then
  msg "Nova support directory found: ${nova_folder}"
else
 error "Nova support directory not found: ${nova_folder}"
fi

# quit if current Nova extensions dir is a symlink
[[ -L "${extensions}" ]] && error "Already symlinked: ${extensions}"

[[ -L "${nova_prefs}" ]] && error "Already symlinked: ${nova_prefs}"

which -s pip3 || error "Please install pip3"
msg "Installing the python-language-server"
pip3 install 'python-language-server[all]'
pip3 install pyls-mypy
pip3 install pyls-isort
pip3 install pyls-black

# backup current extensions directory and preferences
for thing in "${extensions}" "${nova_prefs}"
do
  timestamp=$(tstamp)
  if [[ -e "${thing}" ]]
  then
    thing_backup="${thing}.${timestamp}"
    msg "Backing up: ${thing}"
    mv "${thing}" "${thing_backup}" || error "Unable to to backup ${thing}"
    msg "Backed up ${thing_backup}"
  fi
done

##
# link local Nova Preferences to ~/Library/Preferences
##
msg "Create symlink: ${nova_prefs} ->"
msg "        ${source_prefs}"
(
  cd "${prefs_folder}"
  ln -s "${source_prefs}"
)
if ls -l "${nova_prefs}"
then
  msg "Nove Preferences are now available"
else
  error "Something went wrong; Nova Preferences not installed"
fi

##
# link local Nova Extensions dir to Nova support dir
##
msg "Create symlink: ${extensions} ->"
msg "        ${source_extensions}"
(
  cd "${nova_folder}"
  ln -s "${source_extensions}"
)
if ls -l "${extensions}" >/dev/null
then
  msg "Nova Extensions are now available"
else
  error "Something went wrong; Nova Extensions not installed"
fi

