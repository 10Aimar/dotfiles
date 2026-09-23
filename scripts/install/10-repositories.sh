#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

echo "==> Configuring repositories for profile: $DOTFILES_PROFILE"

if resolve_profile "$DOTFILES_PROFILE" | grep -Fxq 'starship'; then
    echo "==> Enabling Starship COPR..."
    sudo dnf copr enable -y atim/starship
fi

if resolve_profile "$DOTFILES_PROFILE" | grep -Fxq 'ghostty'; then
    echo "==> Enabling Terra repository..."
    sudo dnf install -y \
        --nogpgcheck \
        --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' \
        terra-release
fi
