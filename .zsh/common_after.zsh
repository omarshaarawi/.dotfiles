source $ZSH/oh-my-zsh.sh
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(zellij setup --generate-auto-start zsh)"

# Load syntax highlighting if available (for work environment)
 source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load Cargo environment if available
source "$HOME/.cargo/env"

# Load SDKMAN if available
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
