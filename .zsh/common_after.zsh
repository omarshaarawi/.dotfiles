[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

sdk() {
    unset -f sdk
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
}

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
