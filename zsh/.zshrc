# Starship prompt
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# ----- Plugins -----

# Autosuggestions
if [[ -f ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source ~/.zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# Syntax highlighting
if [[ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Extra completions
if [[ -d ~/.zsh/plugins/zsh-completions/src ]]; then
    fpath+=(~/.zsh/plugins/zsh-completions/src)
fi

# ----- History -----

HISTFILE="$HOME/.zsh_history"
HISTSIZE=5000
SAVEHIST=5000

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt EXTENDED_HISTORY

# ----- Key bindings -----

# Fix Delete key
bindkey '^[[3~' delete-char

# ----- Environment -----

export LIBVIRT_DEFAULT_URI="qemu:///system"

export PATH="$HOME/.spicetify:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

# Added by pipx
export PATH="$PATH:$HOME/.local/bin"

# Enable '#' as comments in interactive shell
setopt interactivecomments
