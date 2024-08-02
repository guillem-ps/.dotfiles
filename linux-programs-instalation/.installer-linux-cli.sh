#!/bin/bash
# This script only install programs for terminal use

# Check this file before running it
# This script installs the following programs:
# - oh-my-posh
# - nerd-fonts
# - fastfetch

# Plugin nnn installation
# docs: https://github.com/jarun/nnn/blob/master/plugins/README.md
# Use this env variable to the installation


# Create a file to add plugins to nnn
touch ~/.config/nnn/plugins

# Function to install nerd-fonts
install_nerd_fonts() {
    echo "Installing nerd-fonts..."
    sudo apt-get install fonts-firacode
}

# Check if fontconfig is installed
# fontconfig is required for fc-list to work, used to check if nerd-fonts is installed
if ! command -v fc-list &> /dev/null; then
    echo "fontconfig is not installed. Installing fontconfig..."
    sudo apt-get install fontconfig
fi

# Check if nerd-fonts is installed
if ! fc-list | grep -i "nerd"; then
    echo "nerd-fonts is not installed."
    read -p "Do you want to install nerd-fonts? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        install_nerd_fonts
        O_NERD=1
    else
        echo "Skipping nerd-fonts installation."
        O_NERD=0
    fi
else
    echo "nerd-fonts is already installed."
fi

# Function to install oh-my-posh
install_oh_my_posh() {
    echo "Installing oh-my-posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s
}

# Check if oh-my-posh is installed
if ! command -v oh-my-posh &> /dev/null; then
    echo "oh-my-posh is not installed."
    read -p "Do you want to install oh-my-posh? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        install_oh_my_posh
    else
        echo "Skipping oh-my-posh installation."
    fi
else
    echo "oh-my-posh is already installed."
fi

# fastfetch (A command-line system information tool written in bash)
# website: https://launchpad.net/~zhangsongcui3371/+archive/ubuntu/fastfetch
install_fastfetch() {
    echo "Installing fastfetch..."
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
    sudo apt-get update
    sudo apt-get install fastfetch
}

# Check if fastfetch is installed
if ! command -v fastfetch &> /dev/null; then
    echo "fastfetch is not installed."
    read -p "Do you want to install fastfetch? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        install_fastfetch
    else
        echo "Skipping fastfetch installation."
    fi
else
    echo "fastfetch is already installed."
fi