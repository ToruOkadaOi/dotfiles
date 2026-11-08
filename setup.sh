#!/usr/bin/env bash
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
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

if [[ ${1:-} == --install ]]; then
    if [[ $(uname -s) == Darwin ]]; then
        command -v brew >/dev/null || { echo 'Install Homebrew first.' >&2; exit 1; }
        brew install starship fzf
    elif command -v apt-get >/dev/null; then
        # Extract official distro packages into the user account; no sudo needed.
        deps="$HOME/.local/share/dotfiles-deps"
        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        packages=()
        if ! command -v zsh >/dev/null && [[ ! -x $deps/bin/zsh && ! -x $deps/usr/bin/zsh ]]; then
            packages+=(zsh zsh-common)
        fi
        command -v fzf >/dev/null || packages+=(fzf)
        if ((${#packages[@]})); then
            (cd "$tmp" && apt-get download "${packages[@]}")
            mkdir -p "$deps"
            for package in "$tmp"/*.deb; do dpkg-deb -x "$package" "$deps"; done
        fi
        for binary in zsh fzf; do
            if ! command -v "$binary" >/dev/null; then
                for package_bin in "$deps/usr/bin/$binary" "$deps/bin/$binary"; do
                    if [[ -x $package_bin ]]; then
                        ln -s "$package_bin" "$HOME/.local/bin/$binary"
                        break
                    fi
                done
            fi
        done
        if ! command -v starship >/dev/null; then
            curl -fsSL https://starship.rs/install.sh -o "$tmp/starship-install.sh"
            sh "$tmp/starship-install.sh" --bin-dir "$HOME/.local/bin" --yes
        fi
    else
        echo 'Install zsh, git, curl and starship with your package manager first.' >&2
        exit 1
    fi
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

if [[ ${2:-${1:-}} == --ssh-zsh ]]; then
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
