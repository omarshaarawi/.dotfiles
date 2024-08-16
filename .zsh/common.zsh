# Common settings for both personal and work environments
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export DEFAULT_USER="$(whoami)"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"
export XDG_CONFIG_HOME="$HOME/.config"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"

# Aliases
alias vim='nvim'
alias vi='nvim'
alias tn="tmux new -s"
alias ta="tmux attach -t"
alias tl="tmux list-sessions"
alias tk="tmux kill-session -t"

plugins=(
  zsh-autosuggestions
  z
  brew
)

declare -x -A configs
configs=(
    git "$XDG_CONFIG_HOME/git/config"
    wezterm "$HOME/.wezterm.lua"
    ssh "$HOME/.ssh/config"
    zsh "$HOME/.zshrc"
    tmux "$XDG_CONFIG_HOME/tmux/tmux.conf"
    zellij "$XDG_CONFIG_HOME/zellij/config.kdl"
    ghostty "$XDG_CONFIG_HOME/ghostty/config"
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
