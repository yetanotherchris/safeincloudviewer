# SafeInCloud Viewer

[![GitHub Release](https://img.shields.io/github/v/release/yetanotherchris/safeincloudviewer?logo=github&sort=semver)](https://github.com/yetanotherchris/safeincloudviewer/releases/latest/)

Decrypt and view SafeInCloud password database files in the terminal. As there is no Linux client, this app is intended for Linux use.

## Installation

### Scoop (Windows)

```
scoop bucket add safeincloudviewer https://github.com/yetanotherchris/safeincloudviewer
scoop install safeincloudviewer
```

### Homebrew (macOS/Linux)

```
brew tap yetanotherchris/safeincloudviewer https://github.com/yetanotherchris/safeincloudviewer
brew install safeincloudviewer
```

## Usage

`safeincloudviewer` checks for a `SafeInCloud.db` file in the directory you're currently in.

```
safeincloudviewer
# prompts for your password
```

Or provide the password as a command line argument:

```
safeincloudviewer your_password
```

The tool will:
1. Decrypt the database using your password
2. Allow you to search for entries
3. Display details of selected entries
