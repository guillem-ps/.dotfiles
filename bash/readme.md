# Dotfiles

This directory contains various bash scripts and configurations for enhancing your command line experience.

- `.profile`: This file contains the SSH initialization agent, which helps manage SSH keys and configurations.

> [!IMPORTANT]
>To initialize the SSH key, make  sure to specify the name of the private SSH key file in the bash file. 
>
>Otherwise if you don't need this functionality you can easily comment this section 
>
> In **.profile** file:
>```bash
># SSH configuration
>SSH_KEY_NAME="<name_of_private_key>" # Change this to the name of your SSH key
>SSH_KEY_PATH="$HOME/.ssh/$SSH_KEY_NAME" # Change this to the path of your SSH key
>SSH_KEY_TIMEOUT=3600 # 1 hour in seconds
>SSH_ENV="$HOME/.ssh/agent-environment"
>
># Source SSH settings, if applicable
>if [ -f "${SSH_ENV}" ]; then
>     # shellcheck disable=SC1090
>     . "${SSH_ENV}" > /dev/null
>
>     # shellcheck disable=SC2009
>     ps -ef | grep "${SSH_AGENT_PID}" | grep ssh-agent$ > /dev/null || {
>         start_agent;
>     }
>else
>     start_agent;
>fi
>```
>
> In **.bash_alias** file:
>```bash
># Function to start the SSH agent
>start_agent() {
>     echo "Initialising new SSH agent..."
>     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
>     echo succeeded
>     chmod 600 "${SSH_ENV}"
>     # shellcheck disable=SC1090
>     . "${SSH_ENV}" > /dev/null
>    /usr/bin/ssh-add -t "${SSH_KEY_TIMEOUT}" "${SSH_KEY_PATH}" > /dev/null;
>}
>
>alias notssh='deactivate_ssh_agent'
># Alias to reload SSH service, execute notssh, and start the SSH agent
>alias reloadssh='notssh && start_agent'
>
># ssh_agent_status
># Check the status of the running SSH agent
>status_ssh_agent() {
>    if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
>        echo "Usage:    ssh_agent_status"
>        echo "Check the status of the running SSH agent."
>        echo
>        echo "No arguments are needed. The function checks if an ssh-agent session is active and prints the status."
>        echo
>        echo "Examples:   "
>        echo "  ssh_agent_status"
>        return 0
>    fi
>
>
>    echo "SSH Agent PID: $SSH_AGENT_PID"
>    if [ -n "$SSH_AGENT_PID" ]; then
>        ssh-add -l
>    else
>        echo "SSH Agent is not running."
>        return 1
>    fi
>
>    return 0
>}
>alias ssh?='status_ssh_agent'
>```

- `.bash_alias` file: This file contains aliases for easily accessing multiple commands, making your workflow more efficient.


Additionally, there is a `plugins` directory that contains multiple applications that may be of interest. Please refer to the readme file in the plugins directory for more information.
