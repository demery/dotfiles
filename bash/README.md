# Bash

Zsh is bad.  Here's how to make Bash the login shell on MacOS Monterey/Ventura. Instructions adapted from 

. https://www.cyberciti.biz/faq/change-default-shell-to-bash-on-macos-catalina/

_After_ bash is installed using `./setup.sh` in this directory. Find out where Homebrew installed `bash` and get that path.

Open `/etc/shells` in vim:

```
sudo vi /etc/shells
```

Add the path for Homebrew bash to this file.

Use `chsh` to update your shell:

```
chsh -s <PATH_TO_HOMEBREW_BASH>
```

Close terminal app.

Open the terminal app again and verify that bash is your default shell.
