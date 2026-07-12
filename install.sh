#!/bin/bash
set -Eeuo pipefail

# ============================================
# install.sh — Dotfiles bootstrap script
# Creates symlinks for all config components.
# Idempotent and interactive by default.
# ============================================

# === Paths ===
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BACKUP_SUFFIX=".bak.$(date +%Y%m%d)"

# === Defaults ===
DRY_RUN=false
YES=false

# === Logging ===
log_info()  { printf "\033[1;34m[INFO]\033[0m  %s\n" "$*" >&2; }
log_ok()    { printf "\033[1;32m[OK]\033[0m    %s\n" "$*" >&2; }
log_warn()  { printf "\033[1;33m[WARN]\033[0m  %s\n" "$*" >&2; }
log_error() { printf "\033[1;31m[ERROR]\033[0m %s\n" "$*" >&2; }

# === Help ===
usage() {
    cat <<EOF
Usage: install.sh [OPTIONS]

Install dotfiles by creating symbolic links in your home directory.

Options:
    -y, --yes       Non-interactive mode (install all without prompting)
    -n, --dry-run   Show what would be done without making changes
    -h, --help      Show this help message

Components:
    git, bash, extra, fzf, starship, bat, tmux, python
EOF
    exit "${1:-0}"
}

# === Argument parsing ===
while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)     YES=true; shift ;;
        -n|--dry-run) DRY_RUN=true; shift ;;
        -h|--help)    usage 0 ;;
        --)           shift; break ;;
        *)
            log_error "Unknown option: $1"
            usage 1
            ;;
    esac
done

# === Helpers ===
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        printf "[DRY-RUN] %s\n" "$*"
        return 0
    fi
    "$@"
}

confirm() {
    local prompt="$1"
    if [ "$YES" = true ]; then
        return 0
    fi
    local yn
    read -r -p "$prompt [y/N]: " yn
    case "$yn" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

# === Core: link file with backup ===
link_file() {
    local src="$1"
    local dest="$2"
    local skip_msg="${3:-}"

    if [ ! -e "$src" ]; then
        log_error "Source not found: $src"
        return 1
    fi

    # Already linked to correct target
    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        log_ok "Already linked: $dest"
        return 0
    fi

    # Destination exists — backup or skip
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -n "$skip_msg" ]; then
            log_warn "$skip_msg"
            return 0
        fi
        if ! confirm "Overwrite $dest?"; then
            log_info "Skipped: $dest"
            return 0
        fi
        local backup="${dest}${BACKUP_SUFFIX}"
        log_warn "Backing up: $dest → $backup"
        run_cmd mv "$dest" "$backup"
    fi

    run_cmd mkdir -p "$(dirname "$dest")"
    run_cmd ln -sf "$src" "$dest"
    log_ok "Linked: $dest → $src"
}

# === OS detection ===
detect_os() {
    local uname_out
    uname_out="$(uname -s)"
    case "${uname_out}" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
        *)       echo "unknown" ;;
    esac
}

# === Component installers ===

install_git() {
    log_info "--- Git ---"
    link_file "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig"
    link_file "$SCRIPT_DIR/git/.gitignore" "$HOME/.gitignore"
}

install_bash() {
    log_info "--- Bash ---"
    link_file "$SCRIPT_DIR/bash/.profile" "$HOME/.profile"
    link_file "$SCRIPT_DIR/bash/.bash_aliases" "$HOME/.bash_aliases" \
        "Skipping .bash_aliases (may contain customisations; overwrite manually if needed)"
}

install_extra() {
    log_info "--- Extra aliases (optional) ---"
    if confirm "Install optional extra aliases (~/.extra_alias)?"; then
        link_file "$SCRIPT_DIR/bash/plugins/.extra_alias" "$HOME/.extra_alias"
        if [ "$(detect_os)" = "linux" ] && confirm "Install exa/eza, bat and fzf packages via apt?"; then
            run_cmd bash "$SCRIPT_DIR/bash/plugins/plugins_installation.sh"
        fi
    else
        log_info "Skipped extra aliases"
    fi
}

install_fzf() {
    log_info "--- FZF ---"
    link_file "$SCRIPT_DIR/fzf/.fzf.sh" "$HOME/.fzf.sh"
}

install_starship() {
    log_info "--- Starship ---"
    link_file "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
}

install_bat() {
    log_info "--- Bat ---"
    link_file "$SCRIPT_DIR/bat/config" "$HOME/.config/bat/config"
}

install_tmux() {
    log_info "--- Tmux ---"
    link_file "$SCRIPT_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"
}

install_python() {
    log_info "--- Python ---"
    link_file "$SCRIPT_DIR/python/ruff.toml" "$HOME/.ruff.toml"
    if confirm "Install PyPI configuration (~/.pypirc)?"; then
        link_file "$SCRIPT_DIR/python/.pypirc" "$HOME/.pypirc"
    else
        log_info "Skipped .pypirc"
    fi
}

# === Info-only components ===
info_fonts() {
    log_info "--- Fonts ---"
    echo "  See: $SCRIPT_DIR/fonts/installation_guide.md" >&2
}

info_windows_terminal() {
    local os
    os="$(detect_os)"
    if [ "$os" = "windows" ]; then
        log_info "--- Windows Terminal ---"
        echo "  See: $SCRIPT_DIR/windows-terminal/terminal_settings.json" >&2
    fi
}

info_obsidian_breeze() {
    log_info "--- Obsidian Breeze (VS Code theme) ---"
    echo "  Install from marketplace: https://marketplace.visualstudio.com/items?itemName=guillem-ps.obsidian-breeze" >&2
    echo "  Or manually copy obsidian-breeze/ to ~/.vscode/extensions/" >&2
}

# === Main ===
main() {
    log_info "Dotfiles installer — $SCRIPT_DIR"
    echo "" >&2

    if [ "$DRY_RUN" = true ]; then
        log_warn "Dry-run mode — no changes will be made"
        echo "" >&2
    fi

    # Core configs
    if confirm "Install Git configuration?";        then install_git;    fi
    if confirm "Install Bash configuration?";       then install_bash;   fi
    if confirm "Install FZF configuration?";        then install_fzf;    fi
    if confirm "Install Starship configuration?";   then install_starship; fi
    if confirm "Install Bat configuration?";        then install_bat;    fi
    if confirm "Install Tmux configuration?";       then install_tmux;   fi
    if confirm "Install Python configuration?";     then install_python; fi

    # Optional extra
    install_extra

    # Info-only
    info_fonts
    info_windows_terminal
    info_obsidian_breeze

    echo "" >&2
    log_ok "Done!"
    echo "  Restart your shell or run: source ~/.bashrc" >&2
}

main "$@"
