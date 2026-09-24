#!/usr/bin/env bash
set -e
# 12. Clone dotfiles repo (skip if already here, e.g. running locally)
# -----------------------------
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Cloning dotfiles repo..."
    git clone https://github.com/10Aimar/dotfiles.git "$DOTFILES_DIR"
else
    echo "==> Dotfiles repo already present at $DOTFILES_DIR, skipping clone."
fi

# -----------------------------
# 13. Symlink configs with stow
# -----------------------------
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow zsh starship konsole ghostty niri noctalia
echo "✓ Dotfiles linked."
