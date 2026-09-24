#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

STAGES=(
    "../user/10-shell.sh"
    "../user/20-dotfiles.sh"
    "../user/30-default-shell.sh"
)

for stage in "${STAGES[@]}"; do
    printf '\n==> Running user stage: %s...\n' "$stage"
    "$SCRIPT_DIR/$stage"
done

printf '\n%s\n' "=================================================="
printf '%s\n' " User setup done!"
printf '%s\n' "=================================================="
