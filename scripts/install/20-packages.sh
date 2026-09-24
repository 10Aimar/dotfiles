#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

echo "==> Installing packages for profile: $DOTFILES_PROFILE"

PACKAGE_LIST="$(resolve_profile "$DOTFILES_PROFILE")"

if [[ -z "$PACKAGE_LIST" ]]; then
    printf 'ERROR: Profile resolved to an empty package set: %s\n' \
        "$DOTFILES_PROFILE" >&2
    exit 1
fi

mapfile -t RESOLVED_PACKAGES <<< "$PACKAGE_LIST"

NIRI_SELECTED=0
OTHER_PACKAGES=()

for package in "${RESOLVED_PACKAGES[@]}"; do
    [[ -n "$package" ]] || continue

    if [[ "$package" == "niri" ]]; then
        NIRI_SELECTED=1
    else
        OTHER_PACKAGES+=("$package")
    fi
done

if (( NIRI_SELECTED )); then
    echo "==> Installing Niri without weak dependencies..."
    sudo dnf install -y \
        --setopt=install_weak_deps=False \
        niri
fi

if ((${#OTHER_PACKAGES[@]})); then
    echo "==> Installing profile packages..."
    sudo dnf install -y "${OTHER_PACKAGES[@]}"
fi
