#!/usr/bin/env bash
# Prints reminders for manual steps that can't (or shouldn't) be
# automated. Meant to run LAST in bootstrap.sh, after install.sh and
# install-greeter.sh, so these don't get buried under their output.
#
# Safe to run on its own too: ./post-install.sh

echo "=================================================="
echo " All done! A few things left to do manually:"
echo "=================================================="
echo ""
echo " 1. Authenticate GitHub CLI (needed for private repos):"
echo "      gh auth login"
echo ""
echo ""
echo " git clone https://github.com/10Aimar/repo.git"
echo " mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Avatars"" 
echo " cp -r "path/." "$HOME/Pictures/Wallpapers""
echo " cp -r "path/." "$HOME/Pictures/Avatars""
echo ""
echo " 2. Reboot to land on the noctalia-greeter login screen:"
echo "      sudo reboot"
echo ""
echo "=================================================="
