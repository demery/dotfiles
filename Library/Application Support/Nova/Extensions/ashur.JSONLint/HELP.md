## Troubleshooting

If you see the following error message:

>  JSONLint requires NPM and Node.js. Please download and install the latest version of Node.js, or verify that NPM can be found on $PATH.

the JSONLint extension can't find NPM on your system. There are a few reasons this might be happening.

### Verify NPM Is Installed

Open a **Local Terminal** tab in Nova (or macOS's **Terminal.app**) and run the following command:

```
npm --version
```

If the result is a version number:

```
$ npm --version
6.13.6
```

NPM is installed and ready to go! If you see an error message:

```
$ npm --version
npm: command not found
```

you might need to download and install the [latest version of Node.js and NPM][node] before continuing.

### NPM Is Installed, but Can’t Be Found

If you've ensured that NPM is installed but you're still seeing the error:

1. Open Nova Preferences
1. Switch to the **Tools** pane
1. Enable the _Automatically request environment from login shell_ option

This ensures that JSONLint and other extensions can access information about where tools like NPM are installed on your system.

#### Advanced

Nova's option to request environment variables from your login shell does not include variables set in an interactive shell (i.e., a standard terminal session).

If NPM's location is added to your `$PATH` by a shell command or script (ex., [NVM][nvm]), you can copy or move the relevant invocation to a startup file sourced by login shells:

- `~/.bash_profile`, `~/.bash_login`, or `~/.profile` for **Bash**
- `~/.zprofile` or `~/.zlogin` for **ZSH**

> 💡 Startup files like `.bashrc` and `.zshrc` are sourced in interactive shells; modifications to `$PATH` made in those files won't be reflected in Nova.

[node]: https://nodejs.org
[nvm]: https://github.com/nvm-sh/nvm
