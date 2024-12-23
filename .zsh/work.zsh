export PATH="$PATH:$HOME/go/bin:/usr/local/sbin:/Applications/Sublime Text.app/Contents/SharedSupport/bin:/Applications/IntelliJ IDEA.app/Contents/MacOS"
export VAULT_ADDR=https://prod.vault.target.com:443
export GH_HOST="git.target.com"
export KUBE_EDITOR="nvim"
export OP_BIOMETRIC_UNLOCK_ENABLED=true
export DOCKER_HOST=unix://$HOME/.colima/default/docker.sock
export ZSH_DISABLE_COMPFIX=true
export GOPRIVATE=git.target.com
export GOPROXY=https://binrepo.target.com/artifactory/golang-remote
export KUBECONFIG="${HOME}/.kube/config:${HOME}/.kube/config-base:${HOME}/.kube/unimatrix:${HOME}/.kube/stores-0-config:${HOME}/.kube/stores-i-config"
export BIFROST_SERVER=https://bifrost-ca.target.com
export VELA_ADDR=https://vela.prod.target.com

kubectl() {
    unset -f kubectl
    source "$XDG_CONFIG_HOME/zsh-plugins/kubectl.plugin.zsh"
    source <(kubectl completion zsh)
    kubectl "$@"
}

lss() {
    ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/'
}

ctc() {
    if [ -z "$1" ]; then
        echo "No file path provided"
        return 1
    fi

    if [ ! -f "$1" ]; then
        return 1
    fi


    cat $1 | pbcopy
}

pr() {
  if type gh &> /dev/null; then
    gh pr view -w
  else
    echo "gh is not installed"
  fi
}


catr() {
    tail -n "+$1" $3 | head -n "$(($2 - $1 + 1))"
}

vl() {
    vault login -method=ldap username=z0044bf
}

decode() {
  echo "$1" | base64 -d ; echo
}


k8s() {
  local version="$1"
  local binary_path="/usr/local/bin"
  local binary_regex="kubectl(-v)?(-)?1\.${version}(\.[0-9]*)?"

  if [[ -z "$version" ]]; then
    echo "Povide a version number."
    return 1
  fi

  local binary=$(ls "$binary_path" | grep -E "$binary_regex" | sort -rn | head -1)
  echo "Using $binary"

  if [[ -z "$binary" ]]; then
      echo "kubectl-1.$version not found."
    binary="kubectl-1.9"
    if [[ ! -f "$binary_path/$binary" ]]; then
      echo "kubectl-1.$version not found."
      return 1
    fi
  fi

  echo "Symlinking $binary to $HOME/bin/kubectl"
  ln -sfv "$binary_path/$binary" "$HOME/bin/kubectl"
}


vpnl() {
    local password=$(op read "op://Target/TargetHQ/password")
    printf "%s\n%s\n" "$USER" "$password" | /opt/cisco/secureclient/bin/vpn -s connect TGT_VPN_MAC
}

# vpnl() {
#   expect -c "
#     set timeout 10
#     spawn /opt/cisco/secureclient/bin/vpn -s connect TGT_VPN_MAC
#     expect \"Username:\"
#     send \"$USER\r\"
#     expect \"Password:\"
#     send \"`op read "op://Target/TargetHQ/password"`\r\"
#     expect eof
#   "
# }

vpnd() {
  /opt/cisco/secureclient/bin/vpn -s disconnect
}


# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
