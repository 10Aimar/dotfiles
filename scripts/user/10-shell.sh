#!/usr/bin/env bash
set -e
# 11. Install zsh plugins
# -----------------------------
echo "==> Installing zsh plugins..."
mkdir -p ~/.zsh/plugins

clone_or_update() {
    local repo_url="$1"
    local dest="$2"
    if [ -d "$dest/.git" ]; then
        echo "   $dest already exists, pulling latest..."
        git -C "$dest" pull
    else
        git clone --depth 1 "$repo_url" "$dest"
    fi
}

clone_or_update https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/plugins/zsh-autosuggestions
clone_or_update https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
clone_or_update https://github.com/zsh-users/zsh-completions ~/.zsh/plugins/zsh-completions
