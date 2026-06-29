# Starship prompt configuration

Starship is a fast, customizable prompt for any shell.

## Installation

```bash
curl -sS https://starship.rs/install.sh | sh
```

## Configuration

Copy the config file:

```bash
mkdir -p ~/.config
cp ~/.dotfiles/starship/starship.toml ~/.config/starship.toml
```

The `.profile` file automatically initializes Starship if installed, with oh-my-posh as fallback.
