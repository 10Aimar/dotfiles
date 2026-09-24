#!/usr/bin/env bash
set -euo pipefail

echo "==> Configuring Flathub..."

flatpak remote-delete fedora --force 2>/dev/null || true

flatpak remote-add \
    --if-not-exists \
    flathub \
    https://flathub.org/repo/flathub.flatpakrepo
