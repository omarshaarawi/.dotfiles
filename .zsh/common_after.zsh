# Load syntax highlighting if available (for work environment)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

cargo() {
    unset -f cargo
    source "$HOME/.cargo/env"
    cargo "$@"
}

sdk() {
    unset -f sdk
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
}

eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

