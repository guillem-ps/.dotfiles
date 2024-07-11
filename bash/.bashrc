#!/bin/bash
# Bash configuration file
# Function to print lines safely
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

# Alias: 

# activate
# Activate Python virtual environment  
WINDOWS_SOURCE_VENV_SCRIPT=".venv/Scripts/activate" # Change this to the path of the activate script on Windows
LINUX_SOURCE_VENV_SCRIPT=".venv/bin/activate" # Change this to the path of the activate script on Linux

activate_venv() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage:    activate <path>"
        echo "This function activates a Python virtual environment located at the specified path."
        echo
        echo "Arguments:   "
        echo "  <path>    The path to the directory containing the .venv directory."
        echo
        echo "Examples:   "
        echo "  activate /path/to/your/project"
        echo "  activate ."
        return 0
    fi

    if [ -z "$1" ]; then
        echo "Usage:    activate <path>"
        return 1
    fi

    if [ ! -d "$1/.venv" ]; then
        echo "No .venv directory found in $1"
        return 1
    fi

    # shellcheck disable=SC1090
    if [ -f "$1/$WINDOWS_SOURCE_VENV_SCRIPT" ]; then
        source "$1/$WINDOWS_SOURCE_VENV_SCRIPT"
    elif [ -f "$1/$LINUX_SOURCE_VENV_SCRIPT" ]; then
        source "$1/$LINUX_SOURCE_VENV_SCRIPT"
    else
        echo "No activate script found in $1/.venv"
        return 1
    fi

    pip --version
    return 0
}

# deactivate_ssh_agent
# Deactivate the running ssh-agent session
deactivate_ssh_agent() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage:    deactivate_ssh_agent"
        echo "Deactivates the running ssh-agent session."
        echo
        echo "No arguments are needed. The function checks if an ssh-agent session is active and deactivates it."
        echo
        echo "Examples:   "
        echo "  deactivate_ssh_agent"
        return 0
    fi

    if [ -n "$SSH_AUTH_SOCK" ] ; then
        eval "$(ssh-agent -k)"
        echo "SSH agent session deactivated."
    else
        echo "No active SSH agent session found."
        return 1
    fi
    
    return 0
}

# ssh_agent_status
# Check the status of the running SSH agent
status_ssh_agent() {
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage:    ssh_agent_status"
        echo "Check the status of the running SSH agent."
        echo
        echo "No arguments are needed. The function checks if an ssh-agent session is active and prints the status."
        echo
        echo "Examples:   "
        echo "  ssh_agent_status"
        return 0
    fi


    echo "SSH Agent PID: $SSH_AGENT_PID"
    if [ -n "$SSH_AGENT_PID" ]; then
        ssh-add -l
    else
        echo "SSH Agent is not running."
        return 1
    fi

    return 0
}
