# Common settings for both personal and work environments
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
export EDITOR="nvim"
export DEFAULT_USER="$(whoami)"
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"

# Aliases
alias vim='nvim'
alias vi='nvim'

plugins=(
  zsh-autosuggestions
  z
  brew
)

declare -x -A configs
configs=(
    git "$HOME/.config/git/config"
    wezterm "$HOME/.wezterm.lua"
    ssh "$HOME/.ssh/config"
    zsh "$HOME/.zshrc"
    tmux "$HOME/.tmux.conf"
    zellij "$HOME/.config/zellij/config.kdl"
    ghostty "$HOME/.config/ghostty/config"
)
for key value in ${(kv)configs}; do
    if [[ $key == "zsh" ]]
    then
        alias ${key}config="vi $value && source $value && echo '$value has been sourced'"
    else
        alias ${key}config="vi $value"
    fi
done

