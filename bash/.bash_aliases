
# Alias: 

# Help Section
alias \?='echo -e "\
-- Alias --\n\
alias\? : Display all aliases\n\
-- Python --\n\
py? : Display all python aliases\n\
-- Network --\n\
net? : Display all network aliases\n\
-- Help --\n\
"'

alias alias?='
show_python_aliases
show_network_aliases
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
alias notssh='deactivate_ssh_agent'

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
    echo -e "\
-- Python Aliases --\n\
py : python\n\
python3 : python\n\
create : new_pyvenv\n\
activate : set_pyvenv_active\n\
remove : remove_pyvenv\n\
install : install_dev_requirements\n\
installr : install_requirements\n\
installd : install_dev_requirements\n\
pipi : pip install\n\
pipu : pip uninstall\n\
pips : pip show\n\
pipl : pip list\n\
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
    local venv_name="$1"
    if [ -z "$venv_name" ]; then
        venv_name=".venv"
    fi

    if [ -d "$venv_name" ]; then
        return
    fi

    python -m venv "$venv_name"
    set_pyvenv_active "$venv_name"
    python -m pip install --upgrade pip
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

alias pipi='pip install'
alias pipu='pip uninstall'
alias pips='pip show'
alias pipl='pip list'


# Network Section

function show_network_aliases() {
    echo -e "\
-- Network Aliases --\n\
myip : get_ip_address\n\
localip : get_local_ip_address\n\
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

# Extra aliases
alias myip='get_ip_address'
alias localip='get_local_ip_address'

# Source extra aliases if the file exists
if [ -f ~/.extra_alias ]; then
    source ~/.extra_alias
fi