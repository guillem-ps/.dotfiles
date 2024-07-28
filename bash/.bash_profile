#!/bin/bash
# Bash configuration file
# Function to print lines safely
export PATH="$HOME/bin:$PATH"

if [ -f "$HOME/.bashrc" ]; then
    . ~/.bashrc
fi

declare last_failed_command # Declare a variable to store the last failed command

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

if oh-my-posh --version &> /dev/null; then
    OH_MY_POSH_THEMES_PATH="tokyo.omp.json" # Change this to the name of the theme file
    SHELL_ENVIRONMENT=$(oh-my-posh get shell) # Get the current shell environment
    POSH_THEMES_PATH="<Your_path_to_themes_of_oh_my_posh>"

    # Configure oh-my-posh based on the detected machine type
    case "${machine}" in
        Linux | Mac)
            # shellcheck disable=SC1090
            source <(oh-my-posh --init --shell "$SHELL_ENVIRONMENT" --config "$POSH_THEMES_PATH/$OH_MY_POSH_THEMES_PATH")
            ;;
        Cygwin | MinGw | Git)
            # shellcheck disable=SC1090
            source <(oh-my-posh --init --shell "$SHELL_ENVIRONMENT" --config "$POSH_THEMES_PATH/$OH_MY_POSH_THEMES_PATH")
            ;;
        *)
            echo "Unsupported OS:    ${machine}"
            return 1
            ;;
    esac
fi

SSH_KEY_NAME="<name_of_private_key>" # Change this to the name of your SSH key
SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME" # Change this to the path of your SSH key
SSH_KEY_TIMEOUT=3600 # 1 hour in seconds
SSH_ENV="$HOME/.ssh/agent-environment"
function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     # shellcheck disable=SC1090
     . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add -t "${SSH_KEY_TIMEOUT}" "${SSH_KEY_PATH}" > /dev/null;
}

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

echo "Welcome, $(whoami)! Your SSH agent is ready to use. 🚀"
echo "Next time you log in, you won't need to enter your SSH passphrase. until $(date -d "+${SSH_KEY_TIMEOUT} seconds")."

echo "Check the docs for more information: https://github.com/guillem-ps/easy-migration"