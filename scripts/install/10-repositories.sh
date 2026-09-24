#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

echo "==> Configuring repositories for profile: $DOTFILES_PROFILE"

PACKAGE_LIST="$(resolve_profile "$DOTFILES_PROFILE")"

if printf '%s\n' "$PACKAGE_LIST" | grep -Eq \
    '^(unrar|mesa-va-drivers-freeworld|mesa-vdpau-drivers-freeworld)$'
then
    echo "==> Enabling RPM Fusion..."

    sudo dnf install -y \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

    sudo dnf install -y \
        rpmfusion-free-appstream-data \
        rpmfusion-nonfree-appstream-data
fi

if printf '%s\n' "$PACKAGE_LIST" | grep -Fxq 'starship'; then
    echo "==> Enabling Starship COPR..."
    sudo dnf copr enable -y atim/starship
fi

if printf '%s\n' "$PACKAGE_LIST" |
    grep -Eq '^(ghostty|noctalia-greeter)$'
then
    echo "==> Enabling Terra repository..."

    sudo dnf install -y \
        --nogpgcheck \
        --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
        terra-release
fi
