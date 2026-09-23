#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"

declare -A PROFILE_FILES=()
declare -A PACKAGES=()

die() {
    printf 'ERROR: %s\n' "$*" >&2
    return 1
}

trim() {
    local value="$1"

    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"

    printf '%s' "$value"
}

load_manifest() {
    local relative_path="$1"
    local full_path="$DOTFILES_DIR/$relative_path"
    local line

    [[ -f "$full_path" ]] || die "Manifest not found: $relative_path"

    # Already loaded: avoids duplicates and also prevents recursive
    # profile references from looping forever.
    [[ -n "${PROFILE_FILES[$relative_path]+x}" ]] && return
    PROFILE_FILES["$relative_path"]=1

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"

        [[ -z "$line" ]] && continue

        case "$line" in
            profiles/*.txt|packages/*.txt)
                load_manifest "$line"
                ;;
            *)
                PACKAGES["$line"]=1
                ;;
        esac
    done < "$full_path"
}

resolve_profile() {
    local profile="$1"

    case "$profile" in
        profiles/*.txt)
            ;;
        *)
            profile="profiles/$profile.txt"
            ;;
    esac

    load_manifest "$profile"

    if ((${#PACKAGES[@]})); then
        printf '%s\n' "${!PACKAGES[@]}" | LC_ALL=C sort
    fi
}
