#!/usr/bin/env bash
#
# setup-zsh.sh — non-interactive zsh + oh-my-zsh setup for Debian / Ubuntu.
# Installs zsh, oh-my-zsh, zsh-autosuggestions, zsh-syntax-highlighting,
# and makes zsh the default shell.
#
# Usage: ./setup-zsh.sh   (run as your normal user, NOT with sudo)

set -euo pipefail

GREEN='\033[0;32m'
RESET='\033[0m'

# Absolute path to this file, resolved before anything else runs.
# Empty when the script is piped into bash, in which case there is nothing
# on disk to delete later.
SCRIPT_PATH=""
if [ -f "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
fi

# Everything installs into $HOME, so running as root would set up the wrong user.
if [ "$(id -u)" -eq 0 ]; then
    echo "Please run this as your normal user, not root or sudo." >&2
    exit 1
fi

# --- 1. Update the system -----------------------------------------------------
export DEBIAN_FRONTEND=noninteractive
sudo apt update

# --- 2. Install zsh and its dependencies --------------------------------------
sudo apt install zsh git curl -y

# --- 3. Install oh-my-zsh -----------------------------------------------------
# --unattended: don't run zsh and don't call chsh (we handle the shell below).
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "oh-my-zsh already installed, skipping."
fi

# --- 4. Install the plugins ---------------------------------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# --- 5. Activate the plugins in ~/.zshrc ---------------------------------------
# zsh-syntax-highlighting must be sourced last, so keep it last in the list.
PLUGINS_LINE='plugins=(zsh-autosuggestions zsh-syntax-highlighting)'

if grep -q '^plugins=(' "$HOME/.zshrc"; then
    sed -i "s/^plugins=(.*)$/$PLUGINS_LINE/" "$HOME/.zshrc"
else
    echo "$PLUGINS_LINE" >> "$HOME/.zshrc"
fi

# --- 6. Make zsh the default shell --------------------------------------------
# Done via sudo so it doesn't prompt for a password interactively.
sudo chsh -s "$(which zsh)" "$USER"

# --- 7. Self-destruct ---------------------------------------------------------
# Reached only if every step above succeeded, since `set -e` aborts on failure.
# A failed run therefore leaves the script in place so you can re-run it.
if [ -n "$SCRIPT_PATH" ]; then
    echo "Removing $SCRIPT_PATH"
    rm -- "$SCRIPT_PATH"
fi

# --- 8. Done ------------------------------------------------------------------
printf "%bzsh setup complete. Run 'exec zsh' or open a new terminal to start using it.%b\n" \
    "$GREEN" "$RESET"
