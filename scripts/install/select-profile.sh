#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

PROFILE_DIR="$REPO_DIR/profiles"

PROFILE_NAMES=(
    "minimal-niri"
    "vm"
    "t480s"
    "desktop"
)

die() {
    printf 'ERROR: %s\n' "$*" >&2
    exit 1
}

validate_profile() {
    local profile="$1"

    [[ -f "$PROFILE_DIR/$profile.txt" ]] ||
        die "Unknown profile: $profile"
}

SELECTED_PROFILE=""

if [[ $# -eq 2 && "$1" == "--profile" ]]; then
    SELECTED_PROFILE="$2"

elif [[ $# -eq 0 ]]; then
    printf '%s\n' "Select installation profile:" >&2
    printf '\n' >&2

    select profile in "${PROFILE_NAMES[@]}"; do
        if [[ -n "${profile:-}" ]]; then
            SELECTED_PROFILE="$profile"
            break
        fi

        printf '%s\n' "Invalid selection. Choose one of the numbers above." >&2
    done

else
    printf 'Usage: %s [--profile NAME]\n' "$0" >&2
    printf 'Profiles: %s\n' "${PROFILE_NAMES[*]}" >&2
    exit 2
fi

validate_profile "$SELECTED_PROFILE"

printf '%s\n' "$SELECTED_PROFILE"
