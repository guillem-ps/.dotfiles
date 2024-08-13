#!/bin/bash

# Extra aliases
# Paste theme in to .bash_aliases file to use it
# If you want to use it, consider to check the readme and execute the plugin_installation.sh script

## Exa alias:
if [ -f $(which exa) ]; then
    alias l='exa --icons'
    alias la='exa -a'
    alias ll='exa -lah'
    alias ls='exa --icons'
    alias lr='exa -R --icons'
fi 

# Fzf alias:

if [ -f $(which batcat) ]; then 
    alias bat='batcat' # Use bat for Ubuntu/Debian based systems    
fi

# Function 🦇 to use fzf with bat for preview and open selected file in vim
if [ -f $(which fzf) ] && [ -f $(which bat) ]; then # fzf with bat
    function batman() { 
        file=$(fzf --preview='bat --color=always --style=numbers {}'); [ -f "$file" ] && vim $file || true 
    }
elif [ -f $(which fzf) ] && [ ! -f $(which bat) ]; then # fzf without bat    
    function batman(){ 
        file=$(fzf --preview='bat --color=always --style=numbers {}'); [ -f "$file" ] && vim $file || true 
    }
fi