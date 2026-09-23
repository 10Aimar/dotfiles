#!/usr/bin/env bash
set -e

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
    ghostty-kio \
    qt6ct \
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
