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
# ghostty has no official Fedora package yet either
sudo dnf copr enable -y scottames/ghostty

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
    which \
    zsh \
    starship \
    noctalia \
    konsole \
    ghostty \
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
# 3. RPM Fusion + full codecs
# -----------------------------
# Fedora ships without patent-encumbered codecs (H.264, HEVC, MP3
# encoding, etc.) by default. RPM Fusion's free+nonfree repos provide
# these, plus the full ffmpeg build and GStreamer plugins.
echo "==> Enabling RPM Fusion..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
sudo dnf install -y rpmfusion-free-appstream-data rpmfusion-nonfree-appstream-data

echo "==> Swapping to full ffmpeg and installing multimedia codecs..."
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
# 'group install' (not 'update') since this is a minimal system where
# the multimedia group was never installed in the first place.
sudo dnf group install -y multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf group install -y sound-and-video

# -----------------------------
# 4. AMD hardware video acceleration
# -----------------------------
# Fedora's default Mesa VA/VDPAU drivers dropped H.264/HEVC decode
# due to patent concerns. RPM Fusion's -freeworld builds restore it,
# offloading video decode from CPU to GPU (RX 6700 XT here).
echo "==> Installing AMD hardware video acceleration..."
sudo dnf swap -y mesa-va-drivers mesa-va-drivers-freeworld
sudo dnf swap -y mesa-vdpau-drivers mesa-vdpau-drivers-freeworld

# -----------------------------
# 5. OpenH264 for Firefox
# -----------------------------
echo "==> Installing OpenH264 for Firefox..."
sudo dnf install -y openh264 gstreamer1-plugin-openh264 mozilla-openh264
sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

# -----------------------------
# 6. Dual-boot clock fix
# -----------------------------
# Windows and Linux disagree by default on whether the hardware clock
# stores UTC or local time, causing the clock to look wrong after
# switching OSes. This tells Fedora to use UTC, matching the fix on
# the Windows side being to leave it as-is (Linux is the one that
# conventionally adapts here).
echo "==> Setting hardware clock to UTC (dual-boot fix)..."
sudo timedatectl set-local-rtc 0 --adjust-system-clock

# -----------------------------
# 7. Archive + AppImage support
# -----------------------------
echo "==> Installing archive and AppImage support..."
sudo dnf install -y p7zip p7zip-plugins unrar unzip fuse fuse-libs

# -----------------------------
# 8. Flathub (full repo)
# -----------------------------
# Fedora's default Flatpak remote is a filtered subset. This removes
# it and adds the full Flathub repo instead.
echo "==> Setting up full Flathub repo..."
sudo dnf install -y flatpak
flatpak remote-delete fedora --force 2>/dev/null || true
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# -----------------------------
# 9. seatd: group + service
# -----------------------------
# niri needs access to seatd to manage input/GPU devices without root.
echo "==> Configuring seatd..."
sudo usermod -aG seat "$USER"
sudo systemctl enable --now seatd

# -----------------------------
# 10. Trim a common boot-time delay
# -----------------------------
# NetworkManager-wait-online can add up to ~90s to boot waiting to
# confirm full connectivity. NetworkManager itself still connects fine
# in the background without this - only the artificial boot-blocking
# wait is removed.
echo "==> Disabling NetworkManager-wait-online (boot speed)..."
sudo systemctl disable NetworkManager-wait-online.service || true

# -----------------------------
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
stow zsh starship konsole ghostty niri
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
