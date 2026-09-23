#!/usr/bin/env bash
set -e

# 1. Enable required COPR repos
# -----------------------------
echo "==> Enabling COPR repositories..."
# starship isn't in Fedora's default repos
sudo dnf copr enable -y atim/starship

# -----------------------------
# 1b. Enable Terra repo (for ghostty)
# -----------------------------
# ghostty has no official Fedora package yet. Using Terra instead of a
# single-maintainer COPR since it also provides ghostty-kio (Dolphin
# integration).
echo "==> Enabling Terra repository..."
sudo dnf install -y --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release

# -----------------------------
