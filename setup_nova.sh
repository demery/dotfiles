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

# link extensions and preferences is needed
timestamp=$(tstamp)
if [[ -L "${extensions}" ]]
then
  warning "Already symlinked: ${extensions}"
else
  # backup the extensions
  if [[ -e "${extensions}" ]]
  then
    thing_backup="${extensions}.${timestamp}"
    msg "Backing up: ${extensions}"
    mv "${extensions}" "${thing_backup}" || error "Unable to to backup ${extensions}"
    msg "Backed up ${thing_backup}"
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
fi

##
# Install the python language server stuff
##
# make sure homebrew bin directory is the first in the path
msg "Installing the python-language-server"
pip3 install 'python-language-server[all]'
packages="pyls-mypy pyls-isort pyls-black"
pip3 install ${packages}
msg "SUCCESS! Python language server installed"
msg
msg "Add the following to Nova.app Python extension prefs:"
msg
msg "   $(which python3)"
msg "   $(which pyls)"
msg

## We can't symlink preferences. Nova writes prefs directly
# the file and overwrites in symlinks.
#
# Just check to see which is newer.
if [[ ${nova_prefs} -nt ${source_prefs} ]]
then
  warning "Nova preferences are out of sync:"
  warning "${nova_prefs}"
  warning "  is newer than: ${source_prefs}"
  msg "To update this repo's version run:"
  cat << EOF

     cp ${nova_prefs} ${source_prefs}
     cd ${HOME}/.dotfiles
     git add ${source_prefs}
     git commit -m "Udating Nova prefs"
EOF
else
  warning "Nova preferences are out of sync:"
  warning "${source_prefs}"
  warning "   is new than: ${source_prefs}"
  msg "Run the following to update your Nova preferences"
  cat <<EOF

    cp ${source_prefs} ${nova_prefs}
EOF
fi
