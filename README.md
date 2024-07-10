# Easy Migration Configurations

> Nothing like home 🏡

This private repository contains basic configuration files for different applications to facilitate easy migration across devices. The configurations included are specifically tailored for personal use and are not intended for public distribution or use.

## Repository Contents

- **bash/**: Contains configurations for the Bash shell, including `.bashrc` and other related scripts.
- **windows-terminal/**: Holds configuration files for Windows Terminal, such as `settings.json` for terminal profiles and appearances.

## Purpose

The sole purpose of this repository is to store and sync personal configuration files across multiple devices. It ensures a consistent development environment and makes it easier to set up new machines.

## Usage

1. Clone the repository to your local machine:
    ```bash
    git clone https://github.com/your-username/easy-migration.git
    ```

2. Navigate to the cloned directory:
    ```bash
    cd easy-migration
    ```

3. Copy the desired configuration files to their respective locations. For example:
    - For Bash configurations:
      ```bash
      cp bash/.bashrc ~/
      source ~/.bashrc
      ```

    - For VS Code settings:
      ```bash
      cp -r vscode/* ~/.config/Code/User/
      ```

    - For Windows Terminal configurations:
      ```bash
      cp windows-terminal/settings.json /path/to/Windows/Terminal/
      ```

## Note

- These configurations are customized for personal use. Adjust them as needed to fit your requirements.
- This repository is private and intended only for personal use to manage and sync configurations. It is not meant for public distribution.

## Contributions

Since this is a private repository for personal configurations, contributions are not expected or required.

## License

This repository does not contain code intended for distribution, so no licensing is provided. It is purely for storing personal configuration files. 

