# performance optimizations
DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

# cache completions aggressively
autoload -Uz compinit
if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' ~/.zcompdump 2>/dev/null)" ]; then
    compinit
else
    compinit -C
fi

# Oh My Zsh path
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="fino-time"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# autosuggest settings
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=245"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
ZSH_AUTOSUGGEST_USE_ASYNC=1

# jump into directories
setopt autocd

# prevent accidental terminal freeze
stty stop undef

# completion interface - interactive menu
zstyle ':completion:*' menu select
zmodload zsh/complist

# paths
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/anaconda3/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$(go env GOPATH)/bin"
export PATH="$HOME/.local/bin:$PATH"

# language paths
export LUA_CPATH="/opt/homebrew/lib/lua/5.4/?.so;;"

# aliases

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

alias nz='nano ~/.zshrc'
alias sz='source ~/.zshrc'

# fzf & cd
alias fd='cd $(find . -type d 2>/dev/null | fzf)' # super useful

# fzf & open with editor
alias fe='${EDITOR:-nano} $(fzf)'

# fzf & run cmd from history
alias fh='eval "$(\fc -nl | fzf)"'

# Docker utilities
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'

# thefuck
eval "$(thefuck --alias)"

# quiet
quiet() { "$@" >/dev/null 2>&1; }

# history
# increase history size
HISTSIZE=50000
SAVEHIST=50000
HISTFILE=~/.zsh_history

# append whenever a command finishes
setopt INC_APPEND_HISTORY

# share history across all sessions
setopt SHARE_HISTORY

# save duplicates but merge them
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# fzf key b
source <(fzf --zsh)

# Background jobs indicator: [N jobs]
JOB_INDICATOR='%(1j.%F{magenta}[%j jobs]%f .)'

# Exit code indicator: shows ✗ + code only if failed
EXIT_INDICATOR='%(?..%F{red}✗ %?)'

PROMPT="$PROMPT $JOB_INDICATOR $EXIT_INDICATOR "