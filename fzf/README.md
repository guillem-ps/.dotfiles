# FZF configuration

FZF is a fuzzy finder for the command line.

## Installation

```bash
# Debian/Ubuntu
sudo apt install fzf
```

## Configuration

Copy the config file:

```bash
cp ~/.dotfiles/fzf/.fzf.sh ~/.fzf.sh
```

Then source it from your shell configuration (`.bash_aliases` does this automatically if the file exists).

### Keybindings

| Shortcut | Action |
|----------|--------|
| `Ctrl+T` | Search for files/directories and paste the path |
| `Ctrl+R` | Search through command history |
| `Alt+C`  | Fuzzy cd into subdirectories |

The color scheme is based on TokyoNight, designed to be consistent with the terminal's palette.
