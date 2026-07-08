[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

sdk() {
    unset -f sdk
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk "$@"
}

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# claude wrapper + terminal-title helper (loaded on every machine)
[ -f ~/.zsh/cly.zsh ] && source ~/.zsh/cly.zsh
