#!/usr/bin/env bash
set -euo pipefail

for tool in git curl; do
    command -v "$tool" >/dev/null || { printf 'Install %s first, then rerun this command.\n' "$tool" >&2; exit 1; }
done

repo=${DOTFILES_DIR:-$HOME/dotfiles}
if [[ -z ${DOTFILES_DIR:-} && -L $HOME/.zshrc ]]; then
    target=$(readlink "$HOME/.zshrc")
    if [[ $target == /* && -f ${target%/*}/scripts/setup.sh ]]; then
        repo=${target%/*}
    fi
fi

if [[ -d $repo/.git ]]; then
    origin=$(git -C "$repo" remote get-url origin)
    case "$origin" in
        https://github.com/ToruOkadaOi/dotfiles.git|https://github.com/ToruOkadaOi/dotfiles|git@github.com:ToruOkadaOi/dotfiles.git) ;;
        *) printf 'Unexpected repository at %s; choose another DOTFILES_DIR.\n' "$repo" >&2; exit 1 ;;
    esac
    git -C "$repo" pull --ff-only
else
    git clone https://github.com/ToruOkadaOi/dotfiles.git "$repo"
fi

login_shell=${SHELL:-}
if [[ ${login_shell##*/} == bash ]]; then
    bash "$repo/scripts/setup.sh" --install --ssh-zsh
else
    bash "$repo/scripts/setup.sh" --install
fi
printf '\nReady. Open a new terminal or reconnect. Future updates: dotfiles-sync\n'
