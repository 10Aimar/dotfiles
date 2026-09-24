#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

source "$REPO_DIR/scripts/lib/profile.sh"

usage() {
    cat <<USAGE
Usage:
  $0
  $0 --profile NAME
  $0 --profile NAME --dry-run
  $0 --dry-run

Profiles:
  minimal-niri
  vm
  t480s
  desktop
USAGE
}

PROFILE_ARGS=()
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile)
            [[ $# -ge 2 ]] || {
                printf '%s\n' 'ERROR: --profile requires a profile name.' >&2
                exit 2
            }
            PROFILE_ARGS+=(--profile "$2")
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            printf 'ERROR: unknown option: %s\n' "$1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

PROFILE="$("$SCRIPT_DIR/select-profile.sh" "${PROFILE_ARGS[@]}")"

printf '%s\n' "=================================================="
printf '%s\n' " Dotfiles install script"
printf '%s\n' "=================================================="
printf 'Selected profile: %s\n' "$PROFILE"

printf '\n%s\n' 'Package set:'
resolve_profile "$PROFILE" | sed 's/^/  /'

if (( DRY_RUN )); then
    printf '\n%s\n' 'Dry run: no installation stages executed.'
    exit 0
fi

export DOTFILES_PROFILE="$PROFILE"

STAGES=(
    "10-repositories.sh"
    "20-packages.sh"
    "30-multimedia.sh"
    "40-system.sh"
    "50-user.sh"
)

for stage in "${STAGES[@]}"; do
    printf '\n==> Running %s...\n' "$stage"
    "$SCRIPT_DIR/$stage"
done

printf '\n==> Configuring Noctalia Greeter...\n'
"$REPO_DIR/scripts/greeter/install.sh"

printf '\n%s\n' "=================================================="
printf '%s\n' " install.sh done!"
printf '%s\n' "=================================================="
printf '%s\n' ""
printf '%s\n' "The current session was left running."
printf '%s\n' "Reboot to enter Noctalia Greeter."
