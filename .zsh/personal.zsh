# Personal-specific configurations
typeset -U path
path=(
    "$HOME/go/bin"
    "/usr/local/go/bin"
    "/opt/homebrew/bin"
    "/usr/local/bin"
    "$HOME/.turso"
    "$HOME/.bun/bin"
    $path
)
export GITHUB_USERNAME="omarshaarawi"
export SSH_AUTH_SOCK=~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

alias kamal='docker run -it --rm -v "${PWD}:/workdir" -v "/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock" -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal:latest'
# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
