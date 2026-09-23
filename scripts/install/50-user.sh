#!/usr/bin/env bash
set -e

# 11. Install zsh plugins
# -----------------------------
echo "==> Installing zsh plugins..."
mkdir -p ~/.zsh/plugins

clone_or_update() {
    local repo_url="$1"
    local dest="$2"
    if [ -d "$dest/.git" ]; then
        echo "   $dest already exists, pulling latest..."
        git -C "$dest" pull
    else
        git clone --depth 1 "$repo_url" "$dest"
    fi
}

clone_or_update https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
clone_or_update https://github.com/zsh-users/zsh-completions ~/.zsh/plugins/zsh-completions

# -----------------------------
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

# -----------------------------
# 14. Set zsh as default shell
# -----------------------------
ZSH_BIN="$(command -v zsh)"

if [ "$SHELL" != "$ZSH_BIN" ]; then
    echo "==> Setting zsh as default shell..."
    sudo usermod -s "$ZSH_BIN" "$USER"
    echo "✓ Default shell set to $ZSH_BIN"
fi

echo "=================================================="
echo " install.sh done!"
echo ""
echo " - Log out and back in for the seat group + shell"
echo "   changes to take effect (or reboot)."
echo " - For the graphical login screen, run:"
echo "     ./install-greeter.sh"
echo "   Without it, you can still test manually with:"
echo "     niri"
echo "=================================================="
