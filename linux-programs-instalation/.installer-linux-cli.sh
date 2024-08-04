#!/bin/bash
# This script only install programs for terminal use

# Check this file before running it
# This script installs the following programs:
# - oh-my-posh
# - fastfetch

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