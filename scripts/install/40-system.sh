#!/usr/bin/env bash
set -e

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
