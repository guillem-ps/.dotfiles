
# Alias:

# Help Section

alias \?='echo -e "
\033[1;34m-- Alias --\033[0m
alias? : Display all aliases\n\
\033[1;34m-- Generic --\033[0m
generic? : Display all generic aliases\n\
\033[1;34m-- Python --\\033[0m
py? : Display all python aliases\n\
\033[1;34m-- Network --\033[0m
net? : Display all network aliases\n\
\033[1;34m-- Plugins --\033[0m
plugins? : Check installed plugins and explain aliases\n\
For more information, check the docs: .dotfiles/bash/plugins readme.md file\n\
"'

alias alias?='
show_generic_alises
show_python_aliases
show_network_aliases
plugins?
'

# SSH section

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

# Function to start the SSH agent
start_agent() {
    echo "Initialising new SSH agent..."
    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
    echo succeeded
    chmod 600 "${SSH_ENV}"
    # shellcheck disable=SC1090
    . "${SSH_ENV}" > /dev/null
    /usr/bin/ssh-add -t "${SSH_KEY_TIMEOUT}" "${SSH_KEY_PATH}" > /dev/null;
}

alias notssh='deactivate_ssh_agent'
# Alias to reload SSH service, execute notssh, and start the SSH agent
alias reloadssh='notssh && start_agent'

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
alias ssh?='status_ssh_agent'

# Python functions

# Function to display Python aliases
function show_python_aliases() {
echo -e "\033[1;34m-- Python Aliases --\033[0m"
    echo -e "\
py : python\n\
python3 : python\n\
create : new_pyvenv\n\
activate : set_pyvenv_active\n\
remove : remove_pyvenv\n\
install : install_dev_requirements\n\
installr : install_requirements\n\
installd : install_dev_requirements\n\
installD : install_docs_requirements\n\
pipi : pip install\n\
pipu : pip uninstall\n\
pips : pip show\n\
pipl : pip list\n\
pipf : search_dependencies\n\
"
}

# Alias to call the function
alias py\?='show_python_aliases'

function set_pyvenv_active() {
    local venv_name="$1"
    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
        echo "Usage:    set_pyvenv_active <venv_name>"
        echo "This function activates a Python virtual environment located at the specified path."
        echo
        echo "Arguments:   "
        echo "  <venv_name>    The name of the virtual environment directory."
        echo
        echo "Examples:   "
        echo "  set_pyvenv_active /path/to/your/project"
        echo "  set_pyvenv_active ."
        return 0
    fi

    if [ -z "$venv_name" ]; then
        venv_name=".venv"
    fi

    source "$venv_name/bin/activate"

    pip --version
    return 0
}
function new_pyvenv() {
    local version=""
    local venv_name=""
    local py_command

    if [[ "$1" == "--help" || "$1" == "-h" || "$2" == "--help" || "$2" == "-h" ]]; then
        echo "Usage:    new_pyvenv [version] [venv_name]"
        echo "This function creates a Python virtual environment using the specified Python version."
        echo
        echo "Arguments:   "
        echo "  [version]      The Python version to use (e.g., 3.11). If not specified, the latest version will be used."
        echo "  [venv_name]    The name of the virtual environment directory. If not specified, '.venv' will be used."
        echo
        echo "Examples:   "
        echo "  new_pyvenv 3.11 myenv"
        echo "  new_pyvenv 3 myenv"
        echo "  new_pyvenv myenv"
        echo "  new_pyvenv"
        return 0
    fi

    if [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        version="$1"
        venv_name="$2"
    else
        venv_name="$1"
    fi

    # If version is not specified, get the latest Python version
    if [ -z "$version" ]; then
        py_command=$(compgen -c | grep -E "^python[0-9]+\.[0-9]+$" | sort -V | tail -n 1)
    else
        py_command=$(compgen -c | grep -E "^python${version}(\.[0-9]+)?$")
    fi

    if [[ -z $py_command ]]; then
        echo "Python version $version not found."
        return 1
    fi

    py_command=$(echo "$py_command" | sort -V | tail -n 1)

    # If venv_name is not specified, use the default name ".venv"
    venv_name="${venv_name:-.venv}"

    $py_command -m venv "$venv_name"
    if [ $? -ne 0 ]; then
        echo "Failed to create virtual environment using $py_command"
        return 1
    fi

    source "$venv_name/bin/activate"
    if [ $? -ne 0 ]; then
        echo "Failed to activate virtual environment"
        return 1
    fi

    if ! command -v pip &> /dev/null; then
        echo "pip not found, installing pip..."
        curl -sS https://bootstrap.pypa.io/get-pip.py | $py_command
    fi

    pip install --upgrade pip
    echo "Virtual environment named $venv_name created using $py_command"
    return 0
}

function remove_pyvenv() {
    local venv_name="$1"
    if [ -z "$venv_name" ]; then
        venv_name=".venv"
    fi

    if [ ! -d "$venv_name" ]; then
        return
    fi

    if command -v deactivate &> /dev/null; then
        deactivate
    fi

    rm -rf "$venv_name"
}

function install_requirements() {
    local requirements_file="$1"
    if [ -z "$requirements_file" ]; then
        requirements_file="requirements.txt"
    fi

    pip install -r "$requirements_file"
}

function install_dev_requirements() {
    install_requirements "requirements_dev.txt"
}

function install_docs_requirements() {
    install_requirements "requirements_docs.txt"
}

function search_dependencies() {
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: pipf <search_string>"
        echo "Filter the output of 'pip freeze' based on the provided search string."
        echo "Options:"
        echo "  -h, --help    Show this help message and exit"
        return 0
    fi

    if [ -z "$1" ]; then
        echo "Usage: pipf <search_string>"
        return 1
    fi

    # Run pip freeze and filter the output with colors
    pip freeze | \
        # Exclude editable installations
        grep -v "^\-e" | \
        # Filter based on user-provided string with color
        GREP_COLOR='1;33' grep --color=auto "$1"
}

# Python aliases
alias py='python'
alias python3='python'

alias create='new_pyvenv'
alias activate='set_pyvenv_active'
# deactivate is a built-in command in Python
alias remove='remove_pyvenv'

alias install='install_dev_requirements'
alias installr='install_requirements'
alias installd='install_dev_requirements'
alias installD='install_docs_requirements'

alias pipi='pip install'
alias pipu='pip uninstall'
alias pips='pip show'
alias pipl='pip list'
alias pipf='search_dependencies'


# Network Section

function show_network_aliases() {
echo -e "\033[1;34m-- Network Aliases --\033[0m"
echo -e "\
myip : get_ip_address\n\
localip : get_local_ip_address\n\
"
echo -e "\033[1;34m-- SSH Aliases -- \033[0m"
echo -e "\
notssh : deactivate_ssh_agent\n\
ssh? : status_ssh_agent\n\
reloadssh : notssh && start_agent\n\
start_agent : start_agent\n\
"
}

alias net\?='show_network_aliases'

function get_ip_address() {
    dig +short myip.opendns.com @resolver1.opendns.com
}

function get_local_ip_address() {
    interfaces_to_check=("wlan0" "eth0")  # Add more interfaces if needed

    for interface in "${interfaces_to_check[@]}"; do
        ip=$(ip -4 addr show "$interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [[ -n $ip ]]; then
            echo "$ip"
            return
        fi
    done
}

# Network aliases
alias myip='get_ip_address'
alias localip='get_local_ip_address'

# Extra section

# Source extra aliases if the file exists
if [ -f ~/.extra_alias ]; then
    source ~/.extra_alias
fi

# Alias to check installed plugins and explain aliases
function show_plugins() {
    echo -e "\033[1;34m-- Installed Plugins --\033[0m"
    echo "Checking installed plugins and explaining aliases..."

    echo -e "\033[1;32m--- Exa ---\033[0m"
    if command -v exa &> /dev/null; then
        exa_version=$(exa --version | awk 'NR==2 {print $1}')
        echo "exa is installed: $exa_version"
        echo "Aliases for exa:"
        echo "  l  - exa with icons"
        echo "  la - exa with all files"
        echo "  ll - exa with long format and human-readable sizes"
        echo "  ls - exa with icons"
        echo "  lr - exa recursively with icons"
    else
        echo "exa is not installed."
    fi

    echo -e "\033[1;32m--- Bat ---\033[0m"
    if command -v batcat &> /dev/null; then
        batcat_version=$(batcat --version | head -n 1)
        echo -e "batcat is installed: $batcat_version"
        echo "Alias for batcat:"
        echo "  bat - batcat (for Ubuntu/Debian based systems)"
    else
        echo "batcat is not installed."
    fi

    echo -e "\033[1;32m--- Fzf ---\033[0m"
    if command -v fzf &> /dev/null; then
        fzf_version=$(fzf --version | head -n 1)
        echo -e "fzf is installed: $fzf_version"
        echo "Function for fzf:"
        echo "  batman - Uses fzf with bat for preview and opens selected file in vim"
    else
        echo "fzf is not installed."
    fi
}

alias plugins?='show_plugins'

# Generic aliases for system operations

alias 2mimir='sudo apt update && sudo apt upgrade -y && read -p "Do you want to shut down the system? [y/N]: " choice && [[ "$choice" == "y" || "$choice" == "Y" ]] && sudo shutdown now || echo "Shutdown canceled."'

show_generic_alises() {
    echo -e "\033[1;34m-- Generic Aliases --\033[0m"
    echo -e "\
2mimir : update and upgrade the system and optionally shut down. Needs sudo privileges.\n\
    "
}

# Alias to call the function
alias generic\?='show_generic_alises'