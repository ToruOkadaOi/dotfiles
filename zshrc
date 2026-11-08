# performance optimizations
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
)
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -r ${ZSH_CUSTOM:-$ZSH/custom}/plugins/$plugin/$plugin.plugin.zsh ]] && plugins+=($plugin)
done
unset plugin

if [[ -r $ZSH/oh-my-zsh.sh ]]; then
    source "$ZSH/oh-my-zsh.sh"
else
    autoload -Uz compinit
    compinit
fi

# autosuggest settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# jump into directories
setopt autocd

# prevent accidental terminal freeze
[[ -t 0 ]] && stty stop undef

# completion interface - interactive menu
zstyle ':completion:*' menu select
zmodload zsh/complist

# paths
typeset -U path PATH
for bin_dir in /opt/homebrew/bin /home/linuxbrew/.linuxbrew/bin \
    "$HOME/anaconda3/bin" "$HOME/bin" "$HOME/.local/bin" \
    "${GOPATH:-$HOME/go}/bin" "$HOME/.opencode/bin" "$HOME/.kimi-code/bin" \
    "$HOME/.lmstudio/bin" "$HOME/.antigravity-ide/antigravity-ide/bin"; do
    [[ -d $bin_dir ]] && path=($bin_dir $path)
done
unset bin_dir

# language paths
if [[ $OSTYPE == darwin* && -d /opt/homebrew/lib/lua/5.4 ]]; then
    export LUA_CPATH="/opt/homebrew/lib/lua/5.4/?.so;;"
fi

# aliases

alias nz='nano ~/.zshrc'
alias sz='source ~/.zshrc'

# Remove the old aliases when reloading an existing shell.
unalias fd fe 2>/dev/null

# NUL-delimited pickers preserve spaces and newlines; Escape does nothing.
cdf() {
    local selected
    selected=$(
        find . -type d -name .git -prune -o -type d -print0 2>/dev/null |
            fzf --read0 --print0 --prompt='Directory > ' --query="$*"
    ) || return 0
    selected=${selected%$'\0'}
    [[ -n $selected ]] && builtin cd -- "$selected"
}

fe() {
    local selected
    local -a editor
    selected=$(
        find . -type d -name .git -prune -o -type f -print0 2>/dev/null |
            fzf --read0 --print0 --prompt='File > ' --query="$*"
    ) || return 0
    selected=${selected%$'\0'}
    editor=("${(@Q)${(z)${EDITOR:-nano}}}")
    "${editor[@]}" -- "$selected"
}

# fzf & run cmd from history
alias fh='eval "$(\fc -nl | fzf)"'

# Docker utilities
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'

# thefuck
(( $+commands[thefuck] )) && eval "$(thefuck --alias)"

# quiet
quiet() { "$@" >/dev/null 2>&1; }

# history
# increase history size
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# append whenever a command finishes
# share history across all sessions
setopt SHARE_HISTORY

# save duplicates but merge them
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# fzf key b
if (( $+commands[fzf] )); then
    # Older distro versions do not support `fzf --zsh`.
    if fzf --zsh >/dev/null 2>&1; then
        source <(fzf --zsh)
    else
        for fzf_bindings in /usr/share/doc/fzf/examples/key-bindings.zsh \
            "$HOME/.local/share/dotfiles-deps/usr/share/doc/fzf/examples/key-bindings.zsh"; do
            if [[ -r $fzf_bindings ]]; then
                source "$fzf_bindings"
                break
            fi
        done
        unset fzf_bindings
    fi
fi

# Machine-specific paths, aliases and overrides stay outside Git.
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# Resolve the tracked config through ~/.zshrc, which is symlinked to this repo.
export DOTFILES_DIR="${${(%):-%x}:A:h}"
export STARSHIP_CONFIG="$DOTFILES_DIR/starship.toml"

dotfiles-sync() {
    git -C "$DOTFILES_DIR" pull --ff-only &&
        bash "$DOTFILES_DIR/setup.sh" --install && exec zsh
}
if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
else
    PROMPT='%m %~ %D{%Y-%m-%d} %* %# '
fi
