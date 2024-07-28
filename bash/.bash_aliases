
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
