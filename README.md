# dotfiles

Testing personal dotfiles and system setup for a minimal Fedora 44 install, running [niri](https://github.com/YaLTeR/niri) + [Noctalia](https://noctalia.dev) instead of a full desktop environment.

## What this sets up

- **niri** — Wayland tiling compositor
- **Noctalia** — bar, launcher, wallpaper, and shell, running on top of niri
- **noctalia-greeter** — matching login screen (built from source, no Fedora package yet)
- **Konsole** and **Ghostty** — two terminal options, matching Catppuccin Mocha theming
- **zsh** + **starship** — shell and prompt, with autosuggestions/syntax-highlighting/completions plugins
- RPM Fusion, full multimedia codecs, AMD hardware video acceleration, dual-boot clock fix, archive/AppImage support, full Flathub

## Managed with

- **GNU Stow** — symlinks config folders into place
- **Git** + **GitHub** — version control

## Repo structure

Each top-level folder is a Stow "package," mirroring the home directory structure it symlinks into:

```
dotfiles/
├── zsh/            # ~/.zshrc, .zsh/
├── starship/       # ~/.config/starship.toml
├── konsole/        # ~/.config/konsolerc, ~/.local/share/konsole/
├── ghostty/        # ~/.config/ghostty/config
├── niri/           # ~/.config/niri/
├── noctalia/       # ~/.config/noctalia/config.toml
├── install.sh          # Installs packages, sets up seatd, stows configs
├── install-greeter.sh  # Builds + installs noctalia-greeter, configures greetd
├── post-install.sh     # Pulls personal assets, prints manual-step reminders
├── bootstrap.sh         # One-liner entry point for a totally fresh machine
```

## Installation

### Option A: Fresh machine, nothing set up yet

```bash
curl -fsSL https://raw.githubusercontent.com/10Aimar/dotfiles/main/bootstrap.sh | bash
```

Installs git, clones this repo, then runs `install.sh` → `install-greeter.sh` → `post-install.sh` in sequence. Reboot when it finishes to land on the login screen.


```

## Multi-machine notes

- `niri/cfg/outputs.kdl` is shared across machines — niri matches blocks by connector name and ignores ones that don't exist on the current machine, so desktop (`DP-1`, `HDMI-A-1`) and laptop (`eDP-1`) blocks coexist in the same file with no conflict
- `noctalia/config.toml` currently has one desktop-specific hardcoded wallpaper path baked in from earlier manual edits — known limitation, not yet resolved for true multi-machine parity (deliberately left as-is for now)

