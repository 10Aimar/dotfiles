# dotfiles

Personal dotfiles and system setup for Fedora 44, running [niri](https://github.com/YaLTeR/niri) + [Noctalia](https://noctalia.dev) instead of a full desktop environment. Previously ran Fedora KDE; Konsole, Dolphin, and KDE Connect are kept.

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
- A companion private repo, `secret-dotfiles`, holds personal assets (wallpaper) that shouldn't be public — see [Personal assets](#personal-assets) below

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

### Option B: Repo already cloned

```bash
git clone https://github.com/10Aimar/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Then, for the login screen specifically:

```bash
chmod +x install-greeter.sh
./install-greeter.sh
```

### Just the symlinks, no package installs

```bash
cd ~/dotfiles
stow zsh starship konsole ghostty niri noctalia
```

## Personal assets

Wallpaper (and, eventually, avatar) live in a separate **private** repo, `secret-dotfiles`, not this one — kept out of a public repo due to uncertain copyright origin.

- Wallpapers are named after each machine's exact `hostname`: `wallpapers/<hostname>.png`
- `post-install.sh` pulls this repo automatically, but only once `gh auth login` has been run (not automated — needs a real browser to approve)
- **Wallpaper still needs one manual click**: Noctalia's own first-login welcome wizard writes its own choice to `~/.local/state/noctalia/settings.toml`, which overrides anything pre-set in `config.toml` — so in the wizard, use **Browse** and select the file `post-install.sh` already placed at `~/mygithub/secret-dotfiles/wallpapers/<hostname>.png`
- **Avatar** requires a one-time D-Bus command (needs polkit auth, not safely automatable) — printed by `post-install.sh`

## Multi-machine notes

- `niri/cfg/outputs.kdl` is shared across machines — niri matches blocks by connector name and ignores ones that don't exist on the current machine, so desktop (`DP-1`, `HDMI-A-1`) and laptop (`eDP-1`) blocks coexist in the same file with no conflict
- `noctalia/config.toml` currently has one desktop-specific hardcoded wallpaper path baked in from earlier manual edits — known limitation, not yet resolved for true multi-machine parity (deliberately left as-is for now)

## Known limitations

- `noctalia-greeter` has a cosmetic bug: the mouse cursor renders upside-down on the login screen (likely a compositor-side bug in this beta project, not a config issue)
- Ghostty's `background-blur` only renders on KDE Plasma per Ghostty's own docs — won't show under niri, only `background-opacity` (plain transparency) will
