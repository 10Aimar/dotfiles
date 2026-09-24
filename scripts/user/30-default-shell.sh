#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/config-profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

if ! resolve_config_profile "$DOTFILES_PROFILE" | grep -Fxq 'zsh'; then
    echo "==> Zsh not selected; keeping current login shell."
    exit 0
fi

ZSH_BIN="$(command -v zsh)"

if [[ "${SHELL:-}" != "$ZSH_BIN" ]]; then
    echo "==> Setting Zsh as default shell..."
    sudo usermod -s "$ZSH_BIN" "$USER"
    echo "✓ Default shell set to $ZSH_BIN"
else
    echo "==> Zsh is already the default shell."
fi
