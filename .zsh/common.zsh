# Common settings for both personal and work environments
 typeset -U path
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.scripts"
    "$HOME/.rvm/bin"
    $path
)
export EDITOR="nvim"
export DEFAULT_USER="$(whoami)"
export XDG_CONFIG_HOME="$HOME/.config"
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
# fzf parameters used in all widgets - configure layout and wrapped the preview results (useful in large command rendering)
export FZF_DEFAULT_OPTS="--height 100% --layout reverse --preview-window=wrap"

# CTRL + R: put the selected history command in the preview window - "{}" will be replaced by item selected in fzf execution runtime
export FZF_CTRL_R_OPTS="--preview 'echo {}'"

# CTRL + T: set "fd-find" as search engine instead of "find" and exclude .git for the results
export FZF_CTRL_T_COMMAND="fd --exclude .git --ignore-file $HOME/.my-custom-zsh/.fd-fzf-ignore"

# CTRL + T: put the file content if item select is a file, or put tree command output if item selected is directory
export FZF_CTRL_T_OPTS="--preview '[ -d {} ] && tree -C {} || bat --color=always --style=numbers {}'"


# Aliases
alias vim='nvim'
alias vi='nvim'
alias za="zmx attach"
alias zl="zmx list"
alias zk="zmx kill"
alias zd="zmx detach"

alias ll="ls -larht"
alias rm="rm -i"
alias cdd='cd "$HOME/Documents"'
alias history="history 1"

alias ghe='GH_HOST=git.target.com gh'

stty -ixon
setopt INTERACTIVE_COMMENTS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

bindkey -e
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

if [[ "$OSTYPE" == "darwin"* ]]; then
  # >>> OPT + right arrow | OPT + left arrow
  bindkey "^[^[[C" forward-word
  bindkey "^[^[[D" backward-word
fi


bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# jump to the start and end of the command line
# >>> CTRL + A | CTRL + E
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
# >>> Home | End
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

# navigate menu for command output
zstyle ':completion:*:*:*:*:*' menu select
bindkey '^[[Z' reverse-menu-complete

# delete characters using the "delete" key
bindkey "^[[3~" delete-char

# fzf alias: CTRL + SPACE (gadget parameters configured in the FZF_CTRL_T_COMMAND environment variable)
bindkey "^@" fzf-file-widget

# >>> load ZSH plugin
source "$XDG_CONFIG_HOME/zsh-plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$XDG_CONFIG_HOME/zsh-plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Hindsight shell history
source /Users/Shaarawi/git/hindsight/shell/hindsight.zsh

typeset -A configs
configs=(
    [git]="$XDG_CONFIG_HOME/git/config"
    [wezterm]="$HOME/.wezterm.lua"
    [ssh]="$HOME/.ssh/config"
    [zsh]="$HOME/.zshrc"
    [zellij]="$XDG_CONFIG_HOME/zellij/config.kdl"
    [ghostty]="$XDG_CONFIG_HOME/ghostty/config"
    [starship]="$STARSHIP_CONFIG"
)
for key value in ${(kv)configs}; do
    if [[ $key == "zsh" ]]
    then
        alias ${key}config="vi $value && source $value && echo '$value has been sourced'"
    else
        alias ${key}config="vi $value"
    fi
done

tmp() {
    local ext=$1
    local file=$(mktemp /tmp/tmp.XXXXXXXXXX.$ext)
    $EDITOR $file
    rm $file
}

# Set zmx session prefix from git root or cwd
zmx_update_prefix() {
    local root
    root=$(git rev-parse --show-toplevel 2>/dev/null)
    export ZMX_SESSION_PREFIX="$(basename "${root:-$PWD}")-"
}

function gp() {
    local dir
    dir=$(find ~/git ~/git/vessel ~/ -mindepth 1 -maxdepth 1 -type d | fzf)
    if [[ -n $dir ]]; then
        cd "$dir"
        zmx_update_prefix
        clear
    fi
}

# Launch nvim + ai + terminal as zmx sessions for the current project
# usage: nic [dir] [-a claude|opencode]
nic() {
    local dir="$(pwd)"
    local agent="claude"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -a) agent="$2"; shift 2 ;;
            *)  dir="$1"; shift ;;
        esac
    done

    local name
    name=$(basename "$dir")

    zmx run "${name}-nvim" "cd $dir && nvim; exec zsh" 2>/dev/null
    zmx run "${name}-ai" "cd $dir && $agent; exec zsh" 2>/dev/null
    zmx run "${name}-term" "cd $dir && exec zsh" 2>/dev/null

    export ZMX_SESSION_PREFIX="${name}-"

    echo "zmx sessions:"
    zmx list
    echo ""
    echo "attach: za nvim | za ai | za term"
}


eval "$(zmx completions zsh)"
