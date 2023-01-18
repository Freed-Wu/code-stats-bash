# [Code::Stats](https://codestats.net/) plugin for [bash](http://www.bash.org/)

[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/Freed-Wu/code-stats-bash/main.svg)](https://results.pre-commit.ci/latest/github/Freed-Wu/code-stats-bash/main)

[![github/downloads](https://shields.io/github/downloads/Freed-Wu/code-stats-bash/total)](https://github.com/Freed-Wu/code-stats-bash/releases)
[![github/downloads/latest](https://shields.io/github/downloads/Freed-Wu/code-stats-bash/latest/total)](https://github.com/Freed-Wu/code-stats-bash/releases/latest)
[![github/issues](https://shields.io/github/issues/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/issues)
[![github/issues-closed](https://shields.io/github/issues-closed/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/issues?q=is%3Aissue+is%3Aclosed)
[![github/issues-pr](https://shields.io/github/issues-pr/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/pulls)
[![github/issues-pr-closed](https://shields.io/github/issues-pr-closed/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/pulls?q=is%3Apr+is%3Aclosed)
[![github/discussions](https://shields.io/github/discussions/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/discussions)
[![github/milestones](https://shields.io/github/milestones/all/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/milestones)
[![github/forks](https://shields.io/github/forks/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/network/members)
[![github/stars](https://shields.io/github/stars/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/stargazers)
[![github/watchers](https://shields.io/github/watchers/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/watchers)
[![github/contributors](https://shields.io/github/contributors/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/graphs/contributors)
[![github/commit-activity](https://shields.io/github/commit-activity/w/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/graphs/commit-activity)
[![github/last-commit](https://shields.io/github/last-commit/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/commits)
[![github/release-date](https://shields.io/github/release-date/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/releases/latest)

[![github/license](https://shields.io/github/license/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash/blob/main/LICENSE)
[![github/languages](https://shields.io/github/languages/count/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)
[![github/languages/top](https://shields.io/github/languages/top/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)
[![github/directory-file-count](https://shields.io/github/directory-file-count/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)
[![github/code-size](https://shields.io/github/languages/code-size/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)
[![github/repo-size](https://shields.io/github/repo-size/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)
[![github/v](https://shields.io/github/v/release/Freed-Wu/code-stats-bash)](https://github.com/Freed-Wu/code-stats-bash)

Code-stats-bash hooks onto bash, counts characters as you type and saves your
statistics in Code::Stats. You'll receive XP for the language `Terminal (Bash)`
for each character, backspace/delete and enter you type.

## Installation

1. Ensure you have [`curl`](https://curl.haxx.se/).
2. Get your personal API key from <https://codestats.net/my/machines> and set
   environment variable in e.g. `.bashrc`.
3. Install and source the script in one of the following ways (in `.bashrc`
   after the environment variable):

### [AUR](aur.archlinux.org/packages/code-stats-bash)

```bash
yay -S codestats-bash
```

### Manual installation

Clone this git repo and source the script directly.

```bash
source codestats.sh
```

## Options

- `CODESTATS_API_KEY`: the API key used when submitting pulses. Required.
- `CODESTATS_API_URL`: the base URL to the Code::Stats API. Only set this if
  you know what you're doing! :)
- `CODESTATS_LOG_FILE`: a log file for debugging. Must exist and be writable.
