#!/usr/bin/env bash
set -euo pipefail

GREETD_CONF="/etc/greetd/config.toml"
GREETER_SESSION="$(command -v noctalia-greeter-session || true)"
SETUP_SCRIPT="/usr/share/noctalia-greeter/setup_greeter_system.sh"

echo "=================================================="
echo " Noctalia Greeter setup"
echo "=================================================="

if [[ -z "$GREETER_SESSION" ]]; then
    printf '%s\n' \
        "ERROR: noctalia-greeter-session was not found." \
        "Install the noctalia-greeter package first." >&2
    exit 1
fi

if [[ ! -f "$GREETD_CONF" ]]; then
    printf 'ERROR: %s does not exist.\n' "$GREETD_CONF" >&2
    printf '%s\n' "Install greetd first." >&2
    exit 1
fi

echo "==> Greeter session: $GREETER_SESSION"

GREETER_USER="$(
    awk '
        /^\[default_session\]/ {
            in_section=1
            next
        }

        /^\[/ {
            in_section=0
        }

        in_section && /^[[:space:]]*user[[:space:]]*=/ {
            value=$0
            sub(/^[^=]*=/, "", value)
            gsub(/[[:space:]]|" /, "", value)
            print value
            exit
        }
    ' "$GREETD_CONF"
)"

if [[ -z "$GREETER_USER" ]]; then
    if getent passwd greetd >/dev/null; then
        GREETER_USER="greetd"
    elif getent passwd greeter >/dev/null; then
        GREETER_USER="greeter"
    else
        printf '%s\n' \
            "ERROR: Could not determine a greetd session user." >&2
        exit 1
    fi
fi

echo "==> greetd session user: $GREETER_USER"

echo "==> Backing up greetd configuration..."
sudo cp "$GREETD_CONF" \
    "$GREETD_CONF.bak.$(date +%Y%m%d%H%M%S)"

echo "==> Configuring greetd default session..."

sudo python3 - "$GREETD_CONF" "$GREETER_SESSION" "$GREETER_USER" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
command = sys.argv[2]
user = sys.argv[3]

text = path.read_text()

pattern = re.compile(
    r"(?ms)^\[default_session\]\n.*?(?=^\[|\Z)"
)

match = pattern.search(text)

if match:
    section = match.group(0)

    if re.search(r"(?m)^\s*command\s*=", section):
        section = re.sub(
            r"(?m)^\s*command\s*=.*$",
            f'command = "{command}"',
            section,
            count=1,
        )
    else:
        section = (
            "[default_session]\n"
            f'command = "{command}"\n'
            + section[len("[default_session]\n"):]
        )

    if not re.search(r"(?m)^\s*user\s*=", section):
        section += f'user = "{user}"\n'

    text = text[:match.start()] + section + text[match.end():]

else:
    if text and not text.endswith("\n"):
        text += "\n"

    text += (
        "\n[default_session]\n"
        f'command = "{command}"\n'
        f'user = "{user}"\n'
    )

path.write_text(text)
PY

if [[ -x "$SETUP_SCRIPT" ]]; then
    echo "==> Running Noctalia Greeter system setup..."
    sudo "$SETUP_SCRIPT"
else
    echo "WARNING: Noctalia Greeter setup helper not found."
    echo "         Continuing without it."
fi

CURRENT_DM_STATE="$(
    systemctl show \
        -p LoadState \
        --value \
        display-manager.service 2>/dev/null || true
)"

if [[ "$CURRENT_DM_STATE" == "loaded" ]]; then
    CURRENT_DM="$(
        systemctl show \
            -p Id \
            --value \
            display-manager.service 2>/dev/null || true
    )"

    if [[ -n "$CURRENT_DM" && "$CURRENT_DM" != "greetd.service" ]]; then
        echo "==> Current display manager: $CURRENT_DM"
        echo "==> Disabling it for the next boot..."

        sudo systemctl disable "$CURRENT_DM"
    else
        echo "==> No other display manager needs disabling."
    fi
else
    echo "==> No existing display manager is configured."
fi

echo "==> Enabling greetd for the next boot..."
sudo systemctl enable greetd

echo "==> Ensuring graphical.target is the default..."
sudo systemctl set-default graphical.target

echo
echo "=================================================="
echo " Noctalia Greeter configured."
echo "=================================================="
echo
echo "The current graphical session was NOT stopped."
echo "After reboot, greetd should provide the Noctalia login screen."
