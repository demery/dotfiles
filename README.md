dotfiles
========

Various configuration files, not just `~/.*` files

There are scripts here for MacOs installation and configuration.

- `setup_homebrew.sh` -- run this first; it installs homebrew, and numerous
  packages, including: bash, rbenv, pyenv

- `bash/setup.sh` -- run this second; it links `bash/bash_profle` to 
  `~/.bash_profle` and install `bash-it`

- `setup_sublime.sh` -- install Sublime Text first; links Sublime config to 
  `~/Library`

- `setup_nova.sh` -- install Nova.app first; links Nova preferences and config
  to `~/Library`


`bash_script.sh.template` has a default optarg template

`functions.sh` -- functions for scripts in `.dotfiles`

