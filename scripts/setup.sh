#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
backup="$HOME/.local/state/dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
export PATH="$HOME/.local/bin:/opt/homebrew/bin:$PATH"
mkdir -p "$HOME/.local/bin" "$HOME/.config"

link_config() {
    local source=$1 target=$2
    if [[ -L $target && $(readlink "$target") == "$source" ]]; then return; fi
    if [[ -e $target || -L $target ]]; then
        mkdir -p "$backup"
        mv "$target" "$backup/$(basename "$target")"
    fi
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    printf 'Linked %s\n' "$target"
}

install_tools=0
upgrade_tools=0
ssh_zsh=0
for option in "$@"; do
    case "$option" in
        --install) install_tools=1 ;;
        --upgrade) install_tools=1; upgrade_tools=1 ;;
        --ssh-zsh) ssh_zsh=1 ;;
        *) echo "Unknown option: $option" >&2; exit 1 ;;
    esac
done

if [[ $install_tools == 1 ]]; then
    # The shell remains an OS dependency. Keep the existing no-sudo Ubuntu option.
    if ! command -v zsh >/dev/null; then
        command -v apt-get >/dev/null || { echo 'Install Zsh with your OS package manager first.' >&2; exit 1; }
        deps="$HOME/.local/share/dotfiles-deps"
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        (cd "$tmp" && apt-get download zsh zsh-common)
        mkdir -p "$deps"
        for package in "$tmp"/*.deb; do dpkg-deb -x "$package" "$deps"; done
        if [[ -x $deps/bin/zsh ]]; then
            ln -s "$deps/bin/zsh" "$HOME/.local/bin/zsh"
        else
            ln -s "$deps/usr/bin/zsh" "$HOME/.local/bin/zsh"
        fi
    fi
    if ! command -v mise >/dev/null; then
        mise_installer=$(mktemp)
        curl -fsSL https://mise.run -o "$mise_installer"
        sh "$mise_installer"
        rm -f "$mise_installer"
    fi
    link_config "$repo/mise.toml" "$HOME/.config/mise/config.toml"
    (cd "$repo" && mise install)
    if [[ $upgrade_tools == 1 ]]; then (cd "$repo" && mise upgrade --yes); fi
    export PATH="$HOME/.local/share/mise/shims:$PATH"
    if [[ ! -d $HOME/.oh-my-zsh ]]; then
        git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    fi
    custom=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
        if [[ ! -d $custom/plugins/$plugin ]]; then
            git clone --depth 1 "https://github.com/zsh-users/$plugin.git" "$custom/plugins/$plugin"
        fi
    done
fi

link_config "$repo/zshenv" "$HOME/.zshenv"
link_config "$repo/zshrc" "$HOME/.zshrc"
link_config "$repo/starship.toml" "$HOME/.config/starship.toml"
link_config "$repo/gitconfig" "$HOME/.config/git/config"
link_config "$repo/tmux.conf" "$HOME/.tmux.conf"
link_config "$repo/nanorc" "$HOME/.nanorc"
link_config "$repo/lazygit-config.yml" "$HOME/.config/lazygit/config.yml"
link_config "$repo/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"

# Make the first interactive directory search useful on a fresh installation.
if command -v zoxide >/dev/null && ! zoxide query --list >/dev/null 2>&1; then
    zoxide add "$repo" "$HOME"
fi

if [[ $ssh_zsh == 1 ]]; then
    command -v zsh >/dev/null || { echo 'Zsh is required.' >&2; exit 1; }
    # Preserve the account shell and non-interactive SSH/scp behavior.
    if ! grep -qF '# dotfiles: interactive Zsh' "$HOME/.bashrc" 2>/dev/null; then
        mkdir -p "$backup"
        [[ ! -f $HOME/.bashrc ]] || cp "$HOME/.bashrc" "$backup/bashrc"
        cat >> "$HOME/.bashrc" <<'EOF'

# dotfiles: interactive Zsh
if [[ $- == *i* && -z ${ZSH_VERSION:-} ]]; then
    export PATH="$HOME/.local/bin:$PATH"
    command -v zsh >/dev/null && exec zsh
fi
EOF
    fi
fi
printf 'Done. Backups (if any): %s\n' "$backup"
