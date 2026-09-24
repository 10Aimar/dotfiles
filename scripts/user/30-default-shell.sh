#!/usr/bin/env bash
set -e
# 14. Set zsh as default shell
# -----------------------------
ZSH_BIN="$(command -v zsh)"

if [ "$SHELL" != "$ZSH_BIN" ]; then
    echo "==> Setting zsh as default shell..."
    sudo usermod -s "$ZSH_BIN" "$USER"
    echo "✓ Default shell set to $ZSH_BIN"
fi
