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

# === Core: link or copy a file, with backup-on-overwrite ===
# "note" means different things per mode: for link, a skip message shown
# instead of prompting; for copy, the "e.g. ..." example of what's at stake
# in the overwrite prompt (defaults to "your local edits").
install_file() {
    local mode="$1" src="$2" dest="$3" note="${4:-}"

    if [ ! -e "$src" ]; then
        log_error "Source not found: $src"
        return 1
    fi

    # Already linked to correct target (link mode only — copies are never "already correct")
    if [ "$mode" = link ] && [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        log_ok "Already linked: $dest"
        return 0
    fi

    # Destination exists — backup or skip
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ "$mode" = link ] && [ -n "$note" ]; then
            log_warn "$note"
            return 0
        fi
        local example="${note:-your local edits}"
        local prompt="Overwrite $dest?"
        [ "$mode" = copy ] && prompt="Overwrite $dest? (local edits, e.g. $example, will be lost)"
        if ! confirm "$prompt"; then
            log_info "Skipped: $dest"
            # Only copy mode's callers (install_git) care to distinguish a
            # decline from a fresh write; link mode keeps its old return 0
            # so the many bare link_file call sites don't abort under set -e.
            [ "$mode" = copy ] && return 2
            return 0
        fi
        local backup="${dest}${BACKUP_SUFFIX}"
        if [ "$DRY_RUN" = true ]; then
            log_warn "Would back up: $dest → $backup"
        else
            log_warn "Backing up: $dest → $backup"
        fi
        run_cmd mv "$dest" "$backup"
    fi

    run_cmd mkdir -p "$(dirname "$dest")"
    if [ "$mode" = link ]; then
        run_cmd ln -sf "$src" "$dest"
        if [ "$DRY_RUN" = true ]; then
            log_info "Would link: $dest → $src"
        else
            log_ok "Linked: $dest → $src"
        fi
    else
        run_cmd cp "$src" "$dest"
        local example="${note:-your local edits}"
        if [ "$DRY_RUN" = true ]; then
            log_info "Would copy: $src → $dest"
        else
            log_ok "Copied: $dest (edit it locally, e.g. $example — it won't be overwritten by re-running this script without confirmation)"
        fi
    fi
}

link_file() { install_file link "$1" "$2" "${3:-}"; }
copy_file() { install_file copy "$1" "$2" "${3:-}"; }

# === Core: ask for a value that cannot be left blank ===
prompt_required() {
    local prompt="$1"
    local value=""
    while [ -z "$value" ]; do
        if ! read -r -p "$prompt: " value; then
            log_error "No input available for: $prompt"
            return 1
        fi
        [ -z "$value" ] && log_warn "This value is required."
    done
    printf '%s' "$value"
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
    # Copied (not symlinked): user.name/username/email are per-machine values,
    # so ~/.gitconfig must be an independent file, not a link back into the repo.
    local copy_status=0
    copy_file "$SCRIPT_DIR/git/.gitconfig" "$HOME/.gitconfig" "user.name/username/email" || copy_status=$?
    if [ "$copy_status" -eq 0 ]; then
        log_info "Git identity (name, username, email are always asked — they have no safe default):"
        local git_name git_username git_email
        git_name="$(prompt_required "  Name")" || return 1
        git_username="$(prompt_required "  Username")" || return 1
        git_email="$(prompt_required "  Email")" || return 1

        run_cmd git config -f "$HOME/.gitconfig" user.name "$git_name"
        run_cmd git config -f "$HOME/.gitconfig" user.username "$git_username"
        run_cmd git config -f "$HOME/.gitconfig" user.email "$git_email"
        log_ok "Git identity set: $git_name <$git_email>"
    elif [ "$copy_status" -ne 2 ]; then
        return "$copy_status"
    fi
    link_file "$SCRIPT_DIR/git/.gitignore" "$HOME/.gitignore"
}

install_bash() {
    log_info "--- Bash ---"
    copy_file "$SCRIPT_DIR/bash/.profile" "$HOME/.profile" || true
    log_info "Remember to set SSH_KEY_NAME in ~/.ssh_env_local (untracked) to your own key"
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
    # Copied, never linked: ~/.pypirc holds an API token. A symlink would put
    # that token inside this public repo, in a tracked file.
    if confirm "Install PyPI configuration (~/.pypirc)?"; then
        copy_file "$SCRIPT_DIR/python/.pypirc.template" "$HOME/.pypirc" || true
    else
        log_info "Skipped .pypirc"
    fi
}

# === Info-only components ===
info_line() {
    local title="$1"
    shift
    log_info "--- $title ---"
    local line
    for line in "$@"; do
        echo "  $line" >&2
    done
}

info_fonts() {
    info_line "Fonts" "See: $SCRIPT_DIR/fonts/installation_guide.md"
}

info_windows_terminal() {
    [ "$(detect_os)" = "windows" ] || return 0
    info_line "Windows Terminal" "See: $SCRIPT_DIR/windows-terminal/terminal_settings.json"
}

info_obsidian_breeze() {
    info_line "Obsidian Breeze (VS Code theme)" \
        "Install from marketplace: https://marketplace.visualstudio.com/items?itemName=guillem-ps.obsidian-breeze" \
        "Or manually copy obsidian-breeze/ to ~/.vscode/extensions/"
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
    local components=(
        "Git|install_git"
        "Bash|install_bash"
        "FZF|install_fzf"
        "Starship|install_starship"
        "Bat|install_bat"
        "Tmux|install_tmux"
        "Python|install_python"
    )
    local c label fn
    for c in "${components[@]}"; do
        label="${c%%|*}"
        fn="${c##*|}"
        if confirm "Install $label configuration?"; then
            "$fn" || log_warn "$label configuration incomplete"
        fi
    done

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
