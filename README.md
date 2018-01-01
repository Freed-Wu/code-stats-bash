# [Code::Stats](https://codestats.net/) plugin for [Zsh](http://www.zsh.org/)

Code-stats-zsh hooks onto Zsh, counts characters as you type and saves your statistics in Code::Stats. You'll receive XP for the language `Terminal (Zsh)` for each character, backspace/delete and enter you type.

This plugin is an early beta, so expect some rough edges.

## Installation

1. Ensure you have [`curl`](https://curl.haxx.se/).
1. Get your personal API key from https://codestats.net/my/machines and set environment variable in e.g. `.zshrc`.
    ```
    CODESTATS_API_KEY="<api key here>"
    ```
1. Install and source the script in one of the following ways (in `.zshrc` after the environment variable):

### Zgen

```
zgen load https://gitlab.com/code-stats/code-stats-zsh.git
```

Add a line for the plugin, run `zgen update`, then restart the shell by e.g. `exec zsh`.

### Manual installation

Clone this git repo and source the script directly.

```
source codestats.plugin.zsh
```

### Other plugin managers (Zplug, Antigen, ...)

Probably just pointing to the git repo will work.

### Running on Windows Subsystem for Linux

If you are running Zsh on Windows and see this message:

```
_codestats_send_pulse:23: nice(5) failed: operation not permitted
```

This is caused due to WSL not supporting `nice` and Zsh using it by default for
backgrounded processes. As a workaround, in your `.zshrc`, set:

```
unsetopt BG_NICE
```

See the discussion in this related issue: https://github.com/Microsoft/WSL/issues/1887

## Options

- `CODESTATS_API_KEY`: the API key used when submitting pulses. Required.
- `CODESTATS_API_URL`: the base URL to the Code::Stats API. Only set this if you know what you're doing! :)
- `CODESTATS_LOG_FILE`: a log file for debugging. Must exist and be writable.

## Other plugins

Plugins that wrap ZLE widgets should probably be loaded after `code-stats-zsh`. For example, [`zsh-syntax-highlighting`](https://github.com/zsh-users/zsh-syntax-highlighting) needs to be loaded after `code-stats-zsh` for it to work properly.
