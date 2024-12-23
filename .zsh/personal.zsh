# Personal-specific configurations
export PATH="$PATH:$HOME/go/bin:/usr/local/go/bin:$HOME/.scripts:/opt/homebrew/bin:/usr/local/bin"
export GITHUB_USERNAME="omarshaarawi"
PS1="%F{green}[PERSONAL]%f $PS1"

alias kamal='docker run -it --rm -v "${PWD}:/workdir" -v "/run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock" -e SSH_AUTH_SOCK="/run/host-services/ssh-auth.sock" -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/basecamp/kamal:latest'
