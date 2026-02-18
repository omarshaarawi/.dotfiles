# Personal-specific configurations
typeset -U path
path=(
    "$HOME/go/bin"
    "/usr/local/go/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
    "/Users/Shaarawi/git/roc/roc_nightly-macos_apple_silicon-2025-03-22-c47a8e9cdac"
    "/Users/Shaarawi/git/zhistory/zhistory/target/release"
    "$HOME/.bun/bin"
    $path
)
export GITHUB_USERNAME="omarshaarawi"
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock
PS1="%F{green}[PERSONAL]%f $PS1"

alias kamal='docker run -it --rm -v "${PWD}:/workdir" -v "/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock" -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal:latest'

# bun completions
[ -s "/Users/Shaarawi/.bun/_bun" ] && source "/Users/Shaarawi/.bun/_bun"

[ -f ~/.zsh/cly.zsh ] && source ~/.zsh/cly.zsh
