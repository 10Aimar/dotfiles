#!/usr/bin/env bash

SECRET_REPO="$HOME/mygithub/secret-dotfiles"
HOSTNAME_SHORT="$(hostname)"
WALLPAPER_FILE="$SECRET_REPO/wallpapers/$HOSTNAME_SHORT.png"
AVATAR_FILE="$SECRET_REPO/avatar/avatar.png"

echo "=================================================="
echo " Installation complete."
echo " Remaining steps are manual."
echo "=================================================="
echo

echo "1. Authenticate GitHub CLI:"
echo "     gh auth login"
echo

echo "2. Clone your private dotfiles repository:"
echo "     mkdir -p \"$HOME/mygithub\""
echo "     gh repo clone 10Aimar/secret-dotfiles \"$SECRET_REPO\""
echo

echo "3. Set your wallpaper in Noctalia."
echo "   After cloning the private repository, use:"
echo "     $WALLPAPER_FILE"
echo "   The Noctalia welcome wizard can be used to select it."
echo

echo "4. Set your avatar manually:"
echo
echo '     USER_PATH=$(dbus-send --system --print-reply --dest=org.freedesktop.Accounts \'
echo '       /org/freedesktop/Accounts org.freedesktop.Accounts.FindUserByName \'
echo '       string:"$USER" | grep -o '\''/org/freedesktop/Accounts/User[0-9]*'\'')'
echo '     dbus-send --system --print-reply --dest=org.freedesktop.Accounts \'
echo '       "$USER_PATH" org.freedesktop.Accounts.User.SetIconFile \'
echo '       string:"'"$AVATAR_FILE"'"'
echo

echo "5. Reboot to use Noctalia Greeter:"
echo "     sudo reboot"
echo

echo "=================================================="
