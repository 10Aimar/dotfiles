#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"

declare -A CONFIG_FILES=()
declare -A STOW_PACKAGES=()

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

load_config_manifest() {
    local relative_path="$1"
    local full_path="$DOTFILES_DIR/$relative_path"
    local line

    [[ -f "$full_path" ]] || die "Config manifest not found: $relative_path"

    [[ -n "${CONFIG_FILES[$relative_path]+x}" ]] && return
    CONFIG_FILES["$relative_path"]=1

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"

        [[ -z "$line" ]] && continue

        case "$line" in
            config-profiles/*.txt)
                load_config_manifest "$line"
                ;;
            stow/*.txt)
                load_stow_manifest "$line"
                ;;
            *)
                printf 'ERROR: Invalid config manifest entry in %s: %s\n' \
                    "$relative_path" "$line" >&2
                return 1
                ;;
        esac
    done < "$full_path"
}

load_stow_manifest() {
    local relative_path="$1"
    local full_path="$DOTFILES_DIR/$relative_path"
    local line

    [[ -f "$full_path" ]] || die "Stow manifest not found: $relative_path"

    [[ -n "${CONFIG_FILES[$relative_path]+x}" ]] && return
    CONFIG_FILES["$relative_path"]=1

    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line%%#*}"
        line="$(trim "$line")"

        [[ -z "$line" ]] && continue

        STOW_PACKAGES["$line"]=1
    done < "$full_path"
}

resolve_config_profile() {
    local profile="$1"

    case "$profile" in
        config-profiles/*.txt)
            ;;
        *)
            profile="config-profiles/$profile.txt"
            ;;
    esac

    load_config_manifest "$profile"

    if ((${#STOW_PACKAGES[@]})); then
        printf '%s\n' "${!STOW_PACKAGES[@]}" | LC_ALL=C sort
    fi
}
