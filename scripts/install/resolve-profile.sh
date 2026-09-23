#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

if [[ $# -ne 1 ]]; then
    printf 'Usage: %s <profile>\n' "$0" >&2
    printf 'Profiles: minimal-niri, vm, t480s, desktop\n' >&2
    exit 2
fi

resolve_profile "$1"
