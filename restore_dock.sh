#!/usr/bin/env bash

##
# Script to copy preferred dock configuration to the user's
# Library/Preferences directory.
#
# In order to apply the update dock preferences, you have
# to log out and back in
##

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

[[ -d ~/Library/Preferences ]] || { echo "ERROR: No Library/Preferences folder. Is this a Mac?"; exit 1; }

cp -v ~/Library/Preferences/com.apple.dock.plist ~/Library/Preferences/com.apple.dock.plist.$(date +%Y%m%dT%H%M%S-%Z)
cp -v ${SCRIPT_DIR}/Library/Preferences/com.apple.dock.plist ~/Library/Preferences/com.apple.dock.plist

echo ""
echo "Dock config has been copied to ${HOME}/Library/Preferences"
echo ""
echo "To apply the the changes, log out and back in"
echo ""
