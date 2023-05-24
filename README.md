dotfiles
========

Various configuration files, not just `~/.*` files

There are scripts here for MacOs installation and configuration.

Do these things to set up the system:

1. `setup_homebrew.sh` -- run this first; it installs homebrew, and numerous
  packages, including: bash, rbenv, pyenv

2. Follow the inscructions in '<./bash/README.md>' to make the Homebrew-installed bash the default login shell.

3. `bash/setup.sh` -- run this second; it links `bash/bash_profle` to
  `~/.bash_profle` and install `bash-it`

4. `setup_sublime.sh` -- install Sublime Text first; links Sublime config to
  `~/Library`

5. `setup_nova.sh` -- install Nova.app first; links Nova preferences and config
  to `~/Library`


`bash_script.sh.template` has a default optarg template

`functions.sh` -- functions for scripts in `.dotfiles`

