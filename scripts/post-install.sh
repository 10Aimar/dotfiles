#!/usr/bin/env bash
# Prints reminders for manual steps that can't (or shouldn't) be
# automated. Meant to run LAST in bootstrap.sh, after install.sh and
# install-greeter.sh, so these don't get buried under their output.
#
# Also pulls the wallpaper file from the private secret-dotfiles repo,
# but only if GitHub CLI is already authenticated - safe to re-run
# later once you've done 'gh auth login' if it isn't yet.
#
# Safe to run on its own too: ./post-install.sh

SECRET_REPO="$HOME/mygithub/secret-dotfiles"
HOSTNAME_SHORT="$(hostname)"
WALLPAPER_FILE="$SECRET_REPO/wallpapers/$HOSTNAME_SHORT.png"
AVATAR_FILE="$SECRET_REPO/avatar/avatar.png"

if gh auth status &>/dev/null; then
    echo "==> GitHub CLI authenticated, pulling personal assets..."
    mkdir -p "$HOME/mygithub"

    if [ -d "$SECRET_REPO/.git" ]; then
        git -C "$SECRET_REPO" pull
    else
        gh repo clone 10Aimar/secret-dotfiles "$SECRET_REPO"
    fi

    if [ -f "$WALLPAPER_FILE" ]; then
        echo "✓ Wallpaper found for host '$HOSTNAME_SHORT': $WALLPAPER_FILE"
    else
        echo "!! No wallpaper found for hostname '$HOSTNAME_SHORT' at:"
        echo "     $WALLPAPER_FILE"
    fi
else
    echo "==> GitHub CLI not authenticated yet - skipping personal asset pull."
    echo "    Run 'gh auth login', then re-run this script:"
    echo "      ~/dotfiles/post-install.sh"
fi

echo "=================================================="
echo " All done! A few things left to do manually:"
echo "=================================================="
echo ""
echo " 1. Authenticate GitHub CLI (needed for private repos):"
echo "      gh auth login"
echo ""
echo " 2. Set your wallpaper (config.toml gets overwritten by"
echo "    Noctalia's own welcome wizard on first login anyway, so"
echo "    this has to be a manual pick regardless of automation):"
echo "    In the welcome wizard, click Browse and select:"
echo "      $WALLPAPER_FILE"
echo ""
echo " 3. Set your avatar (requires polkit auth, not safely"
echo "    automatable - run this once, in a real terminal session):"
echo "      USER_PATH=\$(dbus-send --system --print-reply --dest=org.freedesktop.Accounts \\"
echo "        /org/freedesktop/Accounts org.freedesktop.Accounts.FindUserByName \\"
echo "        string:\"\$USER\" | grep -o '/org/freedesktop/Accounts/User[0-9]*')"
echo "      dbus-send --system --print-reply --dest=org.freedesktop.Accounts \\"
echo "        \"\$USER_PATH\" org.freedesktop.Accounts.User.SetIconFile \\"
echo "        string:\"$AVATAR_FILE\""
echo ""
echo " 4. Reboot to land on the noctalia-greeter login screen:"
echo "      sudo reboot"
echo ""
echo "=================================================="
