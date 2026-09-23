#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo " Dotfiles install script"
echo "=================================================="

STAGES=(
    "10-repositories.sh"
    "20-packages.sh"
    "30-multimedia.sh"
    "40-system.sh"
    "50-user.sh"
)

for stage in "${STAGES[@]}"; do
    echo
    echo "==> Running $stage..."
    "$SCRIPT_DIR/$stage"
done

echo
echo "=================================================="
echo " install.sh done!"
echo ""
echo " - Log out and back in for the seat group + shell"
echo "   changes to take effect (or reboot)."
echo " - For the graphical login screen, run:"
echo "     ./install-greeter.sh"
echo "   Without it, you can still test manually with:"
echo "     niri"
echo "=================================================="
