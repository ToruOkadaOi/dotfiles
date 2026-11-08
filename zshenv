# Support the optional user-local Ubuntu Zsh installed by scripts/setup.sh.
# This file also runs for non-interactive Zsh, so keep it quiet and minimal.
if [[ -d $HOME/.local/share/dotfiles-deps/usr/lib ]]; then
    module_path=("$HOME"/.local/share/dotfiles-deps/usr/lib/*/zsh/*(N/) $module_path)
    fpath=("$HOME"/.local/share/dotfiles-deps/usr/share/zsh/functions/**/*(N/) $fpath)
fi
