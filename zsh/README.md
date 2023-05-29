# ZSH config

Included for completeness. I don't use zsh, but here's my configuration, copied from my retired Intel MBP, which was retired 2023-05.

If used, `zshrc` would be linked to home preceded with a dot: `.zshrc`. 

The zsh file assumes zpresto and zplug (?). The latest versions of these should be installed and `zshrc` adjusted as needed. 

Some things I don't like about zsh and this configuration:

- Zsh is not POSIX compliant, which is primarily a problem for me because stdout and stdin don't work as expected. I can't just print stderr to `/dev/null` (`2>/dev/null)`. To hide stderr I have to do all kinds of stuff. WTF?
- What's with this `%` sign zsh prints at the end of output? It's just junk I have to deal with.
- Zsh doesn't split input on white space and getting it to do so requires doing something like `${=var}`, which took me hours to find.
- Zsh, or this configuration at least, is too opinionated about path tab completion. AFAICT, if zsh (or zsh under this config) doesn't know that a flag or command takes a path argument, tab completion won't work. I have to stop what I'm doing and and figure out what the path is and copy or type it out by hand to do my work. It's like having someone flick a pencil out my hand while I'm writing.

There are probably ways to address these complaints. I just haven't done so yet.

One thing I do like is being able to type part of a command, like in VIM, and key up to see previous commands that contain that string. That is awesome. I'm pretty sure zsh doesn't do this out of the box.
