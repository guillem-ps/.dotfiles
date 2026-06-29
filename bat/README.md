# Bat configuration

Bat is a `cat` clone with syntax highlighting and Git integration.

## Installation

```bash
# Debian/Ubuntu
sudo apt install bat

# Create symlink if batcat is used instead of bat
ln -s /usr/bin/batcat ~/.local/bin/bat
```

## Configuration

Copy the config file:

```bash
mkdir -p ~/.config/bat
cp ~/.dotfiles/bat/config ~/.config/bat/config
```

The config sets `--theme="ansi"` so Bat uses your terminal's 16 ANSI colors, keeping the look consistent with your terminal theme.
