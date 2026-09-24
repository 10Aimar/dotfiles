#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

PACKAGE_LIST="$(resolve_profile "$DOTFILES_PROFILE")"

has_package() {
    printf '%s\n' "$PACKAGE_LIST" | grep -Fxq "$1"
}

HAS_MULTIMEDIA=0
HAS_AMD_GPU=0

if has_package 'openh264'; then
    HAS_MULTIMEDIA=1
fi

if has_package 'p7zip'; then
    HAS_MULTIMEDIA=1
fi

if has_package 'mesa-va-drivers-freeworld'; then
    HAS_AMD_GPU=1
fi

if (( ! HAS_MULTIMEDIA && ! HAS_AMD_GPU )); then
    echo "==> No multimedia or GPU-specific packages selected; skipping."
    exit 0
fi

if (( HAS_MULTIMEDIA )); then
    echo "==> Installing multimedia support..."

    echo "==> Replacing ffmpeg-free with RPM Fusion ffmpeg..."
    sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing

    echo "==> Enabling Fedora Cisco OpenH264 repository..."
    sudo dnf config-manager setopt fedora-cisco-openh264.enabled=1

    MULTIMEDIA_PACKAGES=()

    while IFS= read -r package; do
        [[ -z "$package" ]] && continue

        case "$package" in
            openh264|gstreamer1-plugin-openh264|mozilla-openh264|p7zip|p7zip-plugins|unrar|unzip|fuse|fuse-libs)
                MULTIMEDIA_PACKAGES+=("$package")
                ;;
        esac
    done <<< "$PACKAGE_LIST"

    if ((${#MULTIMEDIA_PACKAGES[@]})); then
        sudo dnf install -y "${MULTIMEDIA_PACKAGES[@]}"
    fi
fi

if (( HAS_AMD_GPU )); then
    echo "==> Installing AMD Freeworld video acceleration..."

    sudo dnf swap -y \
        mesa-va-drivers \
        mesa-va-drivers-freeworld

    sudo dnf swap -y \
        mesa-vdpau-drivers \
        mesa-vdpau-drivers-freeworld
fi
