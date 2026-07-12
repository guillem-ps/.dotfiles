#!/bin/bash

declare last_failed_command # Declare a variable to store the last failed command

# Function to print lines safely
println() {
    printf "%s\n" "$*"
}

# Function to handle errors safely
error() {
    local error_code=$?
    printf '\e[31mError (%d): %s\e[m\n' "$error_code" "${@:2}" >&2
    printf 'Last command executed: %s\n' "$last_failed_command" >&2
}

# Trap ERR to capture the last failed command and call error handler
trap 'last_failed_command=$BASH_COMMAND; error_code=$?; if [[ $error_code -ne 0 ]]; then error 1234 "Something went wrong."; fi' ERR
# Example command that will fail
false

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
            source <(oh-my-posh --init --shell "$SHELL_ENVIRONMENT" --config "$POSH_THEMES_PATH/$OH_MY_POSH_THEMES_PATH")
            ;;
        *)
            echo "Unsupported OS: ${machine}"
            return 1
            ;;
    esac
fi

# Source bash_aliases early so start_agent (used below) is defined
if [ -f "$HOME/.bash_aliases" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.bash_aliases"
fi

# SSH configuration
SSH_KEY_NAME="<name_of_private_key>" # Change this to the name of your SSH key
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME" # Change this to the path of your SSH key
SSH_KEY_TIMEOUT=3600 # 1 hour in seconds
SSH_ENV="$HOME/.ssh/agent-environment"

# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
     # shellcheck disable=SC1090
     . "${SSH_ENV}" > /dev/null
     
     # shellcheck disable=SC2009
     ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi

# tat: tmux attach
function tat {
  name=$(basename `pwd` | sed -e 's/\.//g')

  if tmux ls 2>&1 | grep "$name"; then
    tmux attach -t "$name"
  elif [ -f .envrc ]; then
    direnv exec / tmux new-session -s "$name"
  else
    tmux new-session -s "$name"
  fi
}

if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

echo "Welcome, $(whoami)! Your SSH agent is ready to use. 🚀"
echo "Next time you log in, you won't need to enter your SSH passphrase. until $(date -d "+${SSH_KEY_TIMEOUT} seconds")."

echo "Check the docs for more information: https://github.com/guillem-ps/.dotfiles"
