#!/usr/bin/env bash
# Builds and installs noctalia-greeter from source, then wires it into
# greetd. No Fedora package exists for this yet, so it must be compiled.
#
# Run this AFTER install.sh (needs niri + noctalia already installed to
# be useful, though it will build fine on its own).
#
# Usage:
#   ./install-greeter.sh
#
# Safe to re-run: re-building/re-installing is harmless. Editing
# /etc/greetd/config.toml is skipped if it's already pointed at
# noctalia-greeter-session, so this won't stomp on manual changes
# you've made to that file since the last run.

set -e

GREETER_SRC="$HOME/noctalia-greeter"
GREETD_CONF="/etc/greetd/config.toml"

echo "=================================================="
echo " noctalia-greeter build + greetd setup"
echo "=================================================="

# -----------------------------
# 1. Build dependencies
# -----------------------------
echo "==> Installing build dependencies..."
sudo dnf install -y meson gcc-c++ just \
  greetd dbus \
  wayland-devel wayland-protocols-devel wlroots-devel \
  libEGL-devel mesa-libGLES-devel \
  freetype-devel fontconfig-devel \
  cairo-devel pango-devel harfbuzz-devel \
  libxkbcommon-devel glib2-devel \
  tomlplusplus-devel json-devel stb_image_resize2-devel \
  libwebp-devel librsvg2-devel

# -----------------------------
# 2. Avatar support
# -----------------------------
# noctalia-greeter reads each user's avatar via org.freedesktop.Accounts.
# Without accounts-daemon running, the login picker just falls back to
# a generic placeholder icon instead of your actual avatar.
echo "==> Installing accountsservice (for login screen avatars)..."
sudo dnf install -y accountsservice
sudo systemctl enable --now accounts-daemon

# -----------------------------
# 3. Clone or update source
# -----------------------------
if [ -d "$GREETER_SRC/.git" ]; then
    echo "==> noctalia-greeter source already present, pulling latest..."
    git -C "$GREETER_SRC" pull
else
    echo "==> Cloning noctalia-greeter..."
    git clone https://github.com/noctalia-dev/noctalia-greeter.git "$GREETER_SRC"
fi
cd "$GREETER_SRC"

# -----------------------------
# 4. Build and install
# -----------------------------
echo "==> Configuring release build..."
just configure-release

echo "==> Building (this can take a few minutes)..."
just build-release

echo "==> Installing compiled binaries..."
sudo meson install -C build-release

# -----------------------------
# 5. State directory setup
# -----------------------------
# The project's own scripts/setup_greeter_system.sh has a bug where it
# mis-parses the configured greetd user from debug log output, so we do
# this step manually instead. Also handles the case where the greetd
# user isn't literally named "greeter" (ours is "greetd", matching the
# Fedora package's default /etc/greetd/config.toml).
GREETD_USER="$(grep -E '^user' "$GREETD_CONF" | sed -E 's/user\s*=\s*"(.*)"/\1/')"
if [ -z "$GREETD_USER" ]; then
    echo "!! Could not detect greetd user from $GREETD_CONF, defaulting to 'greetd'"
    GREETD_USER="greetd"
fi
echo "==> Preparing /var/lib/noctalia-greeter for user '$GREETD_USER'..."
sudo mkdir -p /var/lib/noctalia-greeter
sudo chown "$GREETD_USER:$GREETD_USER" /var/lib/noctalia-greeter

# -----------------------------
# 6. Point greetd at the greeter
# -----------------------------
SESSION_BIN="$(which noctalia-greeter-session)"
if [ -z "$SESSION_BIN" ]; then
    echo "!! noctalia-greeter-session not found on PATH after install, aborting."
    exit 1
fi

if grep -q "noctalia-greeter-session" "$GREETD_CONF"; then
    echo "==> $GREETD_CONF already points at noctalia-greeter-session, leaving it as-is."
else
    echo "==> Backing up $GREETD_CONF..."
    sudo cp "$GREETD_CONF" "$GREETD_CONF.bak.$(date +%Y%m%d%H%M%S)"

    echo "==> Updating command= line in $GREETD_CONF..."
    sudo sed -i "s|^command = .*|command = \"$SESSION_BIN\"|" "$GREETD_CONF"
fi

# -----------------------------
# 7. Enable greetd + graphical boot target
# -----------------------------
echo "==> Enabling greetd..."
sudo systemctl enable greetd

echo "==> Setting default boot target to graphical.target..."
# greetd's unit is pulled in by graphical.target. On a minimal/Custom
# Fedora install this is usually still set to multi-user.target
# (text boot) since no desktop environment was selected at install time.
sudo systemctl set-default graphical.target

echo "=================================================="
echo " Done! Reboot to land on the noctalia-greeter"
echo " login screen:"
echo "     sudo reboot"
echo ""
echo " Optional: set a default user (skip the user list,"
echo " go straight to password) by adding to"
echo " /var/lib/noctalia-greeter/greeter.toml:"
echo "     [user]"
echo "     default = \"$USER\""
echo "=================================================="
