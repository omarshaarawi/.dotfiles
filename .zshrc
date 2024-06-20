# Path
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:/usr/local/go/bin:$HOME/.scripts:/opt/homebrew/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/homebrew/sbin"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"

# User
export DEFAULT_USER="$(whoami)"

# Editor
export EDITOR="vim"

# Colors
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# GitHub
export GITHUB_USERNAME="omarshaarawi"

# Aliases
alias ez='vim ~/.zshrc'
alias sz='source ~/.zshrc'
alias vim=nvim
alias vi=nvim
alias mv='mv -i'
alias rm='rm -I'
alias python=/usr/local/bin/python3

# Plugins
plugins=(
  git
  zsh-autosuggestions
  brew
  z
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Syntax Highlighting
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Config Aliases
configs=(
  git:"$HOME/.config/git/config"
  nvim:"$HOME/.config/nvim/lua/shaarawi/packer.lua"
  wezterm:"$HOME/.wezterm.lua"
  zsh:"$HOME/.zshrc"
)

for key value in ${(kv)configs}; do
  case $key in
    zsh)
      alias ${key}config="nvim $value && sz && echo '$value has been sourced'"
      ;;
    *)
      alias ${key}config="nvim $value"
      ;;
  esac
done

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
