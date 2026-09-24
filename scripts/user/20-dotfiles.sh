#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/config-profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

echo "==> Resolving configuration profile: $DOTFILES_PROFILE"

mapfile -t RESOLVED_STOW_PACKAGES < <(
    resolve_config_profile "$DOTFILES_PROFILE"
)

if ((${#RESOLVED_STOW_PACKAGES[@]} == 0)); then
    echo "==> No Stow packages selected; skipping."
    exit 0
fi

printf '==> Stowing: %s\n' "${RESOLVED_STOW_PACKAGES[*]}"

cd "$REPO_DIR"

stow "${RESOLVED_STOW_PACKAGES[@]}"

echo "✓ Dotfiles linked."
