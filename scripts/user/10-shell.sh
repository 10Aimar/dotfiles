#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/config-profile.sh"

: "${DOTFILES_PROFILE:?DOTFILES_PROFILE must be set by the installer}"

if ! resolve_config_profile "$DOTFILES_PROFILE" | grep -Fxq 'zsh'; then
    echo "==> Zsh not selected; skipping Zsh plugins."
    exit 0
fi

echo "==> Installing Zsh plugins..."

mkdir -p "$HOME/.zsh/plugins"

clone_or_update() {
    local repo_url="$1"
    local dest="$2"

    if [[ -d "$dest/.git" ]]; then
        echo "   $dest already exists, pulling latest..."
        git -C "$dest" pull
    else
        git clone --depth 1 "$repo_url" "$dest"
    fi
}

clone_or_update \
    https://github.com/zsh-users/zsh-autosuggestions \
    "$HOME/.zsh/plugins/zsh-autosuggestions"

clone_or_update \
    https://github.com/zsh-users/zsh-syntax-highlighting \
    "$HOME/.zsh/plugins/zsh-syntax-highlighting"

clone_or_update \
    https://github.com/zsh-users/zsh-completions \
    "$HOME/.zsh/plugins/zsh-completions"
