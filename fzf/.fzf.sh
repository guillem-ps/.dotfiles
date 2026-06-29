# Set up fzf keybindings and autocompletion for bash
# Tries multiple methods for cross-distro compatibility

if command -v fzf &> /dev/null; then
    # Method 1: built-in --bash option (newer versions)
    if fzf --bash &> /dev/null; then
        source <(fzf --bash)
    # Method 2: system-installed key bindings (Debian/Ubuntu apt)
    elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
        [ -f /usr/share/doc/fzf/examples/completion.bash ] && \
            source /usr/share/doc/fzf/examples/completion.bash
    # Method 3: user-local config (created by fzf installer)
    elif [ -f ~/.fzf.bash ]; then
        source ~/.fzf.bash
    fi
fi

# FZF colors (TokyoNight-inspired)
export FZF_DEFAULT_OPTS=" \
  --color=fg:#c0caf5,fg+:#ffffff,bg:#1a1b26,bg+:#292e42 \
  --color=hl:#bb9af7,hl+:#bb9af7,info:#7aa2f7,marker:#9ece6a \
  --color=prompt:#7dcfff,spinner:#bb9af7,pointer:#bb9af7,header:#73daca \
  --color=border:#565f89,label:#a9b1d6,query:#c0caf5"
