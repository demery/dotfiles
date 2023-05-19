
if basename "$0" >/dev/null 2>&1
then
  cmd=$(basename $0)
else
  cmd=$(basename $SHELL)
fi

alias tstamp="date +%Y%m%dT%H%M%S"

function msg {
  echo "[$cmd] $1"
}

function error {
  msg "ERROR: $1"
  exit 1
}

function is_installed {
  ii_application="$1"

  mdfind "kMDItemKind == 'Application'" | \
    grep -q "$ii_application"

  return $?
}
