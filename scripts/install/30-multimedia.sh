#!/usr/bin/env bash
set -e

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
