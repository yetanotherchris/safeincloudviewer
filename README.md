# SafeInCloud Viewer

Decrypt and view SafeInCloud password database files in the terminal. As there is no Linux client, this app is intended for Linux use.

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
