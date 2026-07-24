#!/usr/bin/env bash
# Dotfiles bootstrap script for Fedora 44 KDE + niri + noctalia
# Usage: run from anywhere, e.g.:
#   git clone https://github.com/10Aimar/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   chmod +x install.sh
#   ./install.sh
#
# For the noctalia-greeter login screen (compiled from source, no Fedora
# package exists yet), run install-greeter.sh separately after this script.

set -e  # stop immediately if any command fails

echo "=================================================="
echo " Dotfiles install script"
echo "=================================================="

# -----------------------------
# 1. Enable required COPR repos
# -----------------------------
echo "==> Enabling COPR repositories..."
# starship isn't in Fedora's default repos
sudo dnf copr enable -y atim/starship

# -----------------------------
# 2. Install packages
# -----------------------------
echo "==> Installing packages..."

# --setopt=install_weak_deps=False on niri specifically, since noctalia
# already provides the launcher/bar functionality niri would otherwise
# pull in (alacritty, fuzzel, waybar, swaylock) as weak/recommended deps.
# niri itself is in Fedora's official repos as of F44 - no COPR needed.
sudo dnf install -y --setopt=install_weak_deps=False niri

sudo dnf install -y \
    git \
    gh \
    stow \
    zsh \
    starship \
    noctalia \
    konsole \
    dolphin \
    kdeconnectd \
    pipewire \
    pipewire-pulseaudio \
    wireplumber \
    dbus-broker \
    polkit \
    seatd \
    xdg-desktop-portal \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-gtk \
    NetworkManager \
    playerctl

# NOTE: xwayland-satellite is intentionally NOT installed here.
# It's only needed if you run legacy X11-only apps (niri auto-spawns
# it on demand if it's present). OBS screen recording works fine
# without it (uses PipeWire + xdg-desktop-portal instead).
# To add it later if needed:
#   sudo dnf install xwayland-satellite

# -----------------------------
# 3. seatd: group + service
# -----------------------------
# niri needs access to seatd to manage input/GPU devices without root.
echo "==> Configuring seatd..."
sudo usermod -aG seat "$USER"
sudo systemctl enable --now seatd

# -----------------------------
# 4. Trim a common boot-time delay
# -----------------------------
# NetworkManager-wait-online can add up to ~90s to boot waiting to
# confirm full connectivity. NetworkManager itself still connects fine
# in the background without this - only the artificial boot-blocking
# wait is removed.
echo "==> Disabling NetworkManager-wait-online (boot speed)..."
sudo systemctl disable NetworkManager-wait-online.service || true

# -----------------------------
# 5. Install zsh plugins
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
# 6. Clone dotfiles repo (skip if already here, e.g. running locally)
# -----------------------------
DOTFILES_DIR="$HOME/dotfiles"

if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "==> Cloning dotfiles repo..."
    git clone https://github.com/10Aimar/dotfiles.git "$DOTFILES_DIR"
else
    echo "==> Dotfiles repo already present at $DOTFILES_DIR, skipping clone."
fi

# -----------------------------
# 7. Symlink configs with stow
# -----------------------------
echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow zsh starship konsole niri noctalia

# -----------------------------
# 8. Set zsh as default shell (optional but likely wanted)
# -----------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "==> Setting zsh as default shell..."
    chsh -s "$(which zsh)"
fi

echo "=================================================="
echo " Done!"
echo ""
echo " - Log out and back in for the seat group + shell"
echo "   changes to take effect (or reboot)."
echo " - For the graphical login screen, run:"
echo "     ./install-greeter.sh"
echo "   Without it, you can still test manually with:"
echo "     niri"
echo "=================================================="
