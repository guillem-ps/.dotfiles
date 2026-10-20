#!/bin/bash

# System check and configuration based on sanitized input
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine='Linux';;
    Darwin*)    machine='Mac';;
    CYGWIN*)    machine='Cygwin';;
    MINGW*)     machine='MinGw';;
    MSYS_NT*)   machine='Git';;
    *)          machine="UNKNOWN:   ${unameOut}"
esac

# Prompt: prefer Starship, fall back to oh-my-posh
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
elif command -v oh-my-posh &> /dev/null; then
    POSH_PATH_INSTALLATION="$HOME/.local/bin"
    if [ -f "$POSH_PATH_INSTALLATION/oh-my-posh" ] && ! echo "$PATH" | grep -q "$POSH_PATH_INSTALLATION"; then
        PATH="$POSH_PATH_INSTALLATION:$PATH"
    fi

    OH_MY_POSH_THEMES_PATH="amro.omp.json"
    SHELL_ENVIRONMENT=$(oh-my-posh get shell)
    POSH_THEMES_PATH="$HOME/.cache/oh-my-posh/themes"

    case "${machine}" in
        Linux | Mac | Cygwin | MinGw | Git)
            # shellcheck disable=SC1090
            source <(oh-my-posh --init --shell "$SHELL_ENVIRONMENT" --config "$POSH_THEMES_PATH/$OH_MY_POSH_THEMES_PATH")
            ;;
        *)
            echo "Unsupported OS: ${machine}"
            return 1
            ;;
    esac
fi

# Per-machine SSH key customization: put SSH_KEY_NAME (and optionally
# SSH_KEY_TIMEOUT) in ~/.ssh_env_local (untracked, create it yourself, e.g.
# `echo 'SSH_KEY_NAME="my_key"' > ~/.ssh_env_local`). Picked up automatically
# below by .bash_aliases.

# Source bash_aliases early: defines start_agent and the SSH_KEY_PATH /
# SSH_KEY_TIMEOUT / SSH_ENV vars (needed for both login and non-login shells)
if [ -f "$HOME/.bash_aliases" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.bash_aliases"
fi

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
     # shellcheck disable=SC1090
     . "${SSH_ENV}" > /dev/null

     # ssh-add -l exit codes: 0 = identity loaded, 1 = agent alive but has
     # no identities (key never loaded or expired via ssh-add -t timeout),
     # 2 = agent unreachable/dead.
     /usr/bin/ssh-add -l > /dev/null 2>&1
     case $? in
         0) ;;
         1) _ssh_add_key ;;
         2) start_agent ;;
     esac
else
     start_agent
fi

# tat: tmux attach
function tat {
  name=$(basename "$(pwd)" | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}

if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    # shellcheck disable=SC1090,SC1091
    . "$HOME/.bashrc"
fi

echo "Welcome, $(whoami)! Your SSH agent is ready to use. 🚀"
echo "Next time you log in, you won't need to enter your SSH passphrase. until $(date -d "+${SSH_KEY_TIMEOUT} seconds")."

echo "Check the docs for more information: https://github.com/guillem-ps/.dotfiles"
