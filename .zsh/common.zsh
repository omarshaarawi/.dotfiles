# Common settings for both personal and work environments
 typeset -U path
path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    $path
)
export EDITOR="nvim"
export DEFAULT_USER="$(whoami)"
export XDG_CONFIG_HOME="$HOME/.config"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
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
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"
alias tmux2clip='tmux capture-pane -pS - | clipwrite'

alias ll="ls -larht"
alias rm="rm -i"
alias cdd='cd "$HOME/Documents"'
alias history="history 1"

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

typeset -A configs
configs=(
    [git]="$XDG_CONFIG_HOME/git/config"
    [wezterm]="$HOME/.wezterm.lua"
    [ssh]="$HOME/.ssh/config"
    [zsh]="$HOME/.zshrc"
    [tmux]="$XDG_CONFIG_HOME/tmux/tmux.conf"
    [zellij]="$XDG_CONFIG_HOME/zellij/config.kdl"
    [ghostty]="$XDG_CONFIG_HOME/ghostty/config"
    [starship]="$STARSHIP_CONFIG"
)
for key value in ${(kv)configs}; do
    if [[ $key == "zsh" ]]
    then
        alias ${key}config="vi $value && source $value && echo '$value has been sourced'"
    elif [[ $key == "tmux" ]]
    then
        alias ${key}config="vi $value && tmux source-file $value && echo '$value has been sourced'"
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


tmux_auto() {
    [[ $- != *i* ]] && return
    if [[ -z "$TMUX" ]] && command -v tmux &> /dev/null; then
        tmux attach 2>/dev/null
        if [[ $? -ne 0 ]]; then
            if tmux ls 2>/dev/null | grep -v attached &>/dev/null; then
                echo "Detached sessions exist. Attach? (y/n)"
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    exec tmux attach
                else
                    exec tmux new-session
                fi
            else
                exec tmux new-session
            fi
        fi
    fi
}


tmux_auto
