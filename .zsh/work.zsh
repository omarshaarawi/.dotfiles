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

plugins+=(asdf kubectl)

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
  expect -c "
    set timeout 10
    spawn /opt/cisco/anyconnect/bin/vpn -s connect TGT_VPN_MAC
    expect \"Username:\"
    send \"$USER\r\"
    expect \"Password:\"
    send \"`security find-generic-password -l 'target_lan_password' -w`\r\"
    expect eof
  "
}

vpnd() {
  /opt/cisco/anyconnect/bin/vpn -s disconnect
}

