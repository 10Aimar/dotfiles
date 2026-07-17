#!/usr/bin/env bash
# Dotfiles bootstrap script for Fedora 44 KDE + niri + noctalia
# Usage: run from anywhere, e.g.:
#   git clone https://github.com/10Aimar/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   chmod +x install.sh
#   ./install.sh

set -e  # stop immediately if any command fails

echo "=================================================="
echo " Dotfiles install script"
echo "=================================================="

# -----------------------------
# 1. Enable required COPR repos
# -----------------------------
echo "==> Enabling COPR repositories..."
sudo dnf copr enable -y yalter/niri

# -----------------------------
# 2. Install packages
# -----------------------------
echo "==> Installing packages..."

# --setopt=install_weak_deps=False on niri specifically, since noctalia
# already provides the launcher/bar functionality niri would otherwise
# pull in (alacritty, fuzzel, waybar) as weak/recommended deps.
sudo dnf install -y --setopt=install_weak_deps=False niri

sudo dnf install -y \
    git \
    gh \
    stow \
    zsh \
    starship \
    noctalia \
    konsole \
    pipewire \
    wireplumber \
    xdg-desktop-portal-gnome \
    playerctl

# NOTE: xwayland-satellite is intentionally NOT installed here.
# It's only needed if you run legacy X11-only apps (niri auto-spawns
# it on demand if it's present). OBS screen recording works fine
# without it (uses PipeWire + xdg-desktop-portal instead).
# To add it later if needed:
#   sudo dnf install xwayland-satellite

# -----------------------------
# 3. Install zsh plugins
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
# 4. Clone dotfiles repo (skip if already here, e.g. running locally)
# -----------------------------
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Cloning dotfiles repo..."
    git clone https://github.com/10Aimar/dotfiles.git "$DOTFILES_DIR"
else
    echo "==> Dotfiles repo already present at $DOTFILES_DIR, skipping clone."
fi

# -----------------------------
# 5. Symlink configs with stow
# -----------------------------
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow zsh starship konsole niri noctalia

# -----------------------------
# 6. Set zsh as default shell (optional but likely wanted)
# -----------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo "=================================================="
echo " Done! Log out and select niri from your display"
echo " manager, or reboot."
echo "=================================================="
