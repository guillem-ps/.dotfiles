# dotfiles ☕

> Nothing like home 🏡

This repository contains basic configuration files for different applications to facilitate easy migration across devices. 

## Table of Contents
- [Structure](#structure)
- [Installation](#installation)
<br><br>

## Structure

- **bash/**: Contains configurations for the Bash shell, including `.bash_aliases`, `.profile`, and plugins.
  - **plugins/**: Contains additional plugins and scripts for Bash.
    - `.extra_alias`: Optional extra aliases for Bash.
    - `plugins_installation.sh`: Script to install plugins.
- **fonts/**: Contains font files and installation guides.
- **git/**: Holds Git configuration files, including `.gitconfig`, `.gitignore`, and profiles for different environments.
  - **profiles/**: Contains different Git profiles.
- **mytheme/**: Contains a custom VS Code theme, including `package.json`, `README.md`, and theme configuration files.
  - **themes/**: Contains theme configuration files.
- **python/**: Contains Python-related configuration files, including `.pypirc` and `ruff.toml`.
- **tmux/**: Contains configuration files for tmux, including `tmux.conf`.
- **windows-terminal/**: Holds configuration files for Windows Terminal, such as `terminal_settings.json`.

## Installation
1. Clone the repository to your local machine:
    Using SSH:
    ```bash
    git clone git@github.com:guillem_ps/dotfiles.git ~/.dotfiles
    ```

    Using HTTPS:
    ```bash
    git clone https://github.com/guillem_ps/dotfiles.git ~/.dotfiles
    ```

2. Navigate to the cloned directory:
    ```bash
    cd ~/.dotfiles
    ```

3. Copy the desired configuration files to their respective locations. 

> [!IMPORTANT]
> Please read the README file in the plugins directory before copying.

### For example:
- For Bash configurations:
    ```bash
    cp bash/.bashrc ~/
    cp bash/.profile ~/
    cp bash/.bash_aliases ~/
    cp bash/plugins/.extra_alias ~/.extra_alias # OPTIONAL
    source ~/.bashrc
    ```

- For Windows Terminal configurations:
    In Command Prompt:
    ```cmd
    copy windows-terminal\terminal_settings.json <path\to\Windows\Terminal\>
    ```

    In PowerShell:
    ```powershell
    Copy-Item -Path "windows-terminal\terminal_settings.json" -Destination "<path\to\Windows\Terminal\>"
    ```

## Additional Information

- For more details on the custom VS Code theme, refer to the [`mytheme`](/mytheme/).
- For useful terminal plugins and their installation, refer to the [`bash/plugins`](/bash/plugins/).
- For tmux custom configuration, refer to the [`tmux`](/tmux/)
