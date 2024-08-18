#!/bin/bash

# Function to prompt user for installation
install_plugin() {
    local plugin_name=$1
    local install_command=$2

    read -p "Do you want to install $plugin_name? (Y/N): " response
    if [[ "$response" == "Y" || "$response" == "y" ]]; then
        echo "Installing $plugin_name..."
        sudo apt install -y $install_command
    else
        echo "Skipping $plugin_name."
    fi
}

# List of plugins and their install commands
declare -A plugins=(
    ["bat"]="bat"
    ["exa"]="exa"
    ["fzf"]="fzf"
)

# Iterate over plugins and prompt for installation
for plugin in "${!plugins[@]}"; do
    install_plugin "$plugin" "${plugins[$plugin]}"
done


# On Debian and Ubuntu, the bat command is named batcat by default due to a conflict with the existing bacula-console-qt package. 
# To solve this, create a symbolic link to batcat as bat in the ~/.local/bin directory:
# Source: https://www.linode.com/docs/guides/how-to-install-and-use-the-bat-command-on-linux/
if [ -f $(which batcat) ]; then 
    mkdir -p ~/.local/bin
    if [ ! -L ~/.local/bin/bat ]; then
        ln -s /usr/bin/batcat ~/.local/bin/bat
    else
        echo "Symbolic link ~/.local/bin/bat already exists."
    fi
fi