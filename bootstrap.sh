#!/usr/bin/env bash
# One-liner bootstrap for a fresh Fedora install with nothing set up yet.
# Usage (from a fresh TTY or terminal):
#   curl -fsSL https://raw.githubusercontent.com/10Aimar/dotfiles/main/bootstrap.sh | bash
#
# This script does the bare minimum to get git + the dotfiles repo onto
# disk, then hands off to install.sh for everything else (packages,
# zsh plugins, stow symlinks).

set -e  # stop immediately if any command fails

echo "=================================================="
echo " Dotfiles bootstrap"
echo "=================================================="

DOTFILES_DIR="$HOME/dotfiles"

# -----------------------------
# 1. Install git (needed to clone the real repo)
# -----------------------------
if ! command -v git >/dev/null 2>&1; then
    echo "==> Installing git..."
    sudo dnf install -y git
else
    echo "==> git already installed, skipping."
fi

# -----------------------------
# 2. Clone the dotfiles repo
# -----------------------------
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Cloning dotfiles repo..."
    git clone https://github.com/10Aimar/dotfiles.git "$DOTFILES_DIR"
else
    echo "==> Dotfiles repo already present at $DOTFILES_DIR, skipping clone."
fi

# -----------------------------
# 3. Hand off to install.sh
# -----------------------------
echo "==> Running install.sh..."
cd "$DOTFILES_DIR"
chmod +x install.sh
./install.sh
