# setup-zsh

A single non-interactive script that turns a fresh Debian or Ubuntu machine into a
working zsh setup, then deletes itself.

It does the following, in order:

1. `apt update && apt upgrade -y`
2. Installs `zsh`, `git`, and `curl`
3. Installs [oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh) unattended
4. Clones [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) and
   [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
5. Enables both plugins in `~/.zshrc`
6. Sets zsh as the default login shell
7. Removes itself from disk

## Requirements

- Debian, Ubuntu, or an apt-based derivative
- A normal user account with sudo rights — **do not run the script as root or with
  `sudo`**, since oh-my-zsh and the plugins install into the invoking user's `$HOME`
- Network access to `github.com` and your apt mirrors

## Quick start

Paste this into a terminal:

```sh
curl -fsSL https://raw.githubusercontent.com/bjcpu01/zsh-installer/main/setup-zsh.sh -o setup-zsh.sh && chmod +x setup-zsh.sh && ./setup-zsh.sh
```

The script deletes itself on success, so this leaves nothing behind in your working
directory.

You will be prompted once for your sudo password, near the start.

## Running a local copy

```sh
chmod +x setup-zsh.sh
./setup-zsh.sh
```

Use `bash setup-zsh.sh` if you prefer not to mark it executable. Do not run it with
`sh` — it relies on bash-specific features.

## After it finishes

The script prints a green confirmation line but cannot switch your current shell for
you. Start zsh in the session you are already in:

```sh
exec zsh
```

Or just open a new terminal. Confirm the default shell took effect with:

```sh
echo $SHELL      # expect /usr/bin/zsh or /bin/zsh
```

The `chsh` change applies to new login sessions, so over SSH you may need to log out
and back in before `$SHELL` reflects it.

## Notes

- **Read it before you run it.** This applies to any script you pipe in from the
  internet, including this one.
- **Self-destruct only happens on success.** The script uses `set -euo pipefail`, so
  any failing step aborts before the removal, leaving the file in place to fix and
  re-run. If you pipe the script directly into bash (`curl ... | bash`), there is no
  file on disk and the removal step is skipped.
- **Re-running is safe** as long as the script is still around: it skips oh-my-zsh and
  each plugin if they are already present.
- **Plugin order matters.** `zsh-syntax-highlighting` must be sourced last, so it stays
  at the end of the `plugins=(...)` line. Adding new plugins before it is fine; adding
  them after it is not.
- **Your existing `~/.zshrc` gets backed up** by the oh-my-zsh installer to
  `~/.zshrc.pre-oh-my-zsh`, and is then replaced with the oh-my-zsh template.
- **The plugins line is rewritten with `sed`,** which matches a single-line
  `plugins=(...)`. If you later reformat that into a multi-line array, a re-run will
  not match it and will append a second `plugins=` line instead.
