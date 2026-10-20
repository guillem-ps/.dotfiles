# dotfiles ☕

> Nothing like home 🏡

<p align="center">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT">
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/shell-Bash-4EAA25?logo=gnubash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/VS%20Code-Obsidian%20Breeze-7385bc" alt="VS Code Theme">
  <img src="https://img.shields.io/github/last-commit/guillem-ps/.dotfiles" alt="Last Commit">
</p>

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
- **bat/**: Bat configuration using ANSI theme for terminal color consistency.
- **fonts/**: Contains font files and installation guides.
- **fzf/**: Fuzzy finder configuration with keybindings and custom colors.
- **git/**: Holds Git configuration files, including `.gitconfig`, `.gitignore`, and profiles for different environments.
  - **profiles/**: Contains different Git profiles.
- **obsidian-breeze/**: Contains a custom VS Code theme, including `package.json`, `README.md`, and theme configuration files.
  - **themes/**: Contains theme configuration files.
- **python/**: Contains Python-related configuration files, including `.pypirc.template` and `ruff.toml`.
- **starship/**: Cross-shell prompt configuration (Starship).
- **tmux/**: Contains configuration files for tmux, including `tmux.conf`.
- **windows-terminal/**: Holds configuration files for Windows Terminal, such as `terminal_settings.json`.

## Installation

### Quick start (recommended)

```bash
git clone https://github.com/guillem-ps/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer will guide you through each component interactively (git, bash, fzf, starship, bat, tmux, python, plus optional extra aliases). Use `-y` for non-interactive mode, `-n` to dry-run.

> [!NOTE]
> `~/.profile` is **copied**, not symlinked, since it can hold local edits. Per-machine SSH key settings (`SSH_KEY_NAME`, optionally `SSH_KEY_TIMEOUT`) go in `~/.ssh_env_local` (untracked, create it yourself — see comment in `bash/.profile`). Re-running the installer won't overwrite your copy without asking first.

### Manual installation

1. Clone the repository:
    Using SSH:
    ```bash
    git clone git@github.com:guillem-ps/.dotfiles.git ~/.dotfiles
    ```

    Using HTTPS:
    ```bash
    git clone https://github.com/guillem-ps/.dotfiles.git ~/.dotfiles
    ```

2. Navigate to the cloned directory:
    ```bash
    cd ~/.dotfiles
    ```

3. Copy the desired configuration files to their respective locations.

> [!IMPORTANT]
> Please read the README file in the plugins directory before copying.

### For example:

> [!WARNING]
> The .profile file uses Starship as the default prompt, with oh-my-posh as fallback.

- For Git:
    ```bash
    # Copied, not symlinked: user.name/username/email are per-machine values.
    # A symlink would put your real identity inside this repo's tracked file.
    cp git/.gitconfig ~/.gitconfig
    git config -f ~/.gitconfig user.name "Your Name"
    git config -f ~/.gitconfig user.username "your-username"
    git config -f ~/.gitconfig user.email "your-email@example.com"
    ln -s "$(pwd)/git/.gitignore" ~/.gitignore
    ```

- For Bash configurations:
    ```bash
    cp bash/.profile ~/.profile
    cp bash/.bash_aliases ~/.bash_aliases
    ln -s "$(pwd)/bash/plugins/.extra_alias" ~/.extra_alias # OPTIONAL
    source ~/.bashrc
    ```

    `.bash_aliases` is copied so it can be customized locally. Re-copy it after
    updating this repository if you want to pick up upstream changes.

    Set your SSH key name in `~/.ssh_env_local` (untracked, create it yourself):
    ```bash
    echo 'SSH_KEY_NAME="your_key_name"' > ~/.ssh_env_local
    ```

- For Starship prompt:
    ```bash
    ln -s "$(pwd)/starship/starship.toml" ~/.config/starship.toml
    ```

- For FZF (fuzzy finder):
    ```bash
    ln -s "$(pwd)/fzf/.fzf.sh" ~/.fzf.sh
    ```

- For Bat (syntax highlighting):
    ```bash
    mkdir -p ~/.config/bat
    ln -s "$(pwd)/bat/config" ~/.config/bat/config
    ```

- For Tmux:
    ```bash
    mkdir -p ~/.config/tmux
    ln -s "$(pwd)/tmux/tmux.conf" ~/.config/tmux/tmux.conf
    ```

- For Python (ruff, PyPI config):
    ```bash
    ln -s "$(pwd)/python/ruff.toml" ~/.ruff.toml
    # Copied, not symlinked: ~/.pypirc holds an API token. A symlink would
    # put that token inside this repo's tracked file. # OPTIONAL
    cp python/.pypirc.template ~/.pypirc
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

- For more details on the custom VS Code theme, refer to the [`My theme`](/obsidian-breeze/), or install it directly from the [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=guillem-ps.obsidian-breeze).
- For useful terminal plugins and their installation, refer to the [`bash/plugins`](/bash/plugins/).
- For tmux custom configuration with the Wilt color palette, refer to the [`tmux`](/tmux/).
- For the Starship prompt configuration, refer to [`starship/starship.toml`](/starship/starship.toml).
