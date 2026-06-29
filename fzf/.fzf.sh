# Set up fzf keybindings and autocompletion for bash
source <(fzf --bash)

# FZF colors (uses terminal's 16 ANSI colors for consistency)
export FZF_DEFAULT_OPTS=" \
  --color=fg:#c0caf5,fg+:#ffffff,bg:#1a1b26,bg+:#292e42 \
  --color=hl:#bb9af7,hl+:#bb9af7,info:#7aa2f7,marker:#9ece6a \
  --color=prompt:#7dcfff,spinner:#bb9af7,pointer:#bb9af7,header:#73daca \
  --color=border:#565f89,label:#a9b1d6,query:#c0caf5"
