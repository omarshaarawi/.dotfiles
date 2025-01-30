typeset -U path
path=(
    "$HOME/go/bin"
    "/usr/local/sbin"
    "/Applications/Sublime Text.app/Contents/SharedSupport/bin"
    "/Applications/IntelliJ IDEA.app/Contents/MacOS"
    $path
)
export VAULT_ADDR=https://prod.vault.target.com:443
export GH_HOST="git.target.com"
export KUBE_EDITOR="nvim"
export OP_BIOMETRIC_UNLOCK_ENABLED=true
#export DOCKER_HOST="unix://$HOME/.colima/default/docker.sock"
export ZSH_DISABLE_COMPFIX=true
export GOPRIVATE=git.target.com
export GOPROXY=https://binrepo.target.com/artifactory/golang-remote
export KUBECONFIG="${HOME}/.kube/config:${HOME}/.kube/config-base:${HOME}/.kube/unimatrix:${HOME}/.kube/stores-0-config:${HOME}/.kube/stores-i-config"
export BIFROST_SERVER=https://bifrost-ca.target.com
export VELA_ADDR=https://vela.prod.target.com

kversion() {
    local VERSION_DIR="/usr/local/bin"
    local KUBECTL_LINK="/usr/local/bin/kubectl"

    case "$1" in
        "")
            # Show current version and target
            echo "Current kubectl symlink points to:"
            ls -l $KUBECTL_LINK || echo "No kubectl symlink found"
            echo "\nCurrent version:"
            kubectl version --client
            echo "\nAvailable versions:"
            ls -1 $VERSION_DIR | grep "kubectl-" | sed 's/kubectl-//'
            ;;
        "ls"|"list")
            # List available versions
            echo "Available kubectl versions:"
            ls -1 $VERSION_DIR | grep "kubectl-" | sed 's/kubectl-//'
            ;;
        *)
            # Switch version
            local TARGET="$VERSION_DIR/kubectl-$1"
            if [[ -f "$TARGET" ]]; then
                echo "Switching to kubectl version $1"
                sudo rm -f "$KUBECTL_LINK"
                sudo ln -sf "$TARGET" "$KUBECTL_LINK"
                if [[ $? -eq 0 ]]; then
                    hash -r  # Clear hash table of command locations
                    # Force shell to forget old location of kubectl
                    unset -f kubectl
                    # Clear zsh command hash
                    rehash
                    echo "Successfully switched to kubectl version $1"
                    kubectl version --client

                    # Update shell completion
                    source <(kubectl completion zsh)
                else
                    echo "Failed to switch kubectl version"
                    return 1
                fi
            else
                echo "Version $1 not found. Available versions:"
                ls -1 $VERSION_DIR | grep "kubectl-" | sed 's/kubectl-//'
                return 1
            fi
            ;;
    esac
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

vpnl() {
    local password=$(op read "op://Target/TargetHQ/password")
    printf "%s\n%s\n" "$USER" "$password" | /opt/cisco/secureclient/bin/vpn -s connect TGT_VPN_MAC
}

vpnd() {
  /opt/cisco/secureclient/bin/vpn -s disconnect
}

k8s_restart_reason() {
    local namespace="" pod_pattern="" store_number="$CURRENT_STORE"

    if [[ -z "$store_number" ]]; then
        echo "No store set. Use 'store <store_number>' first"
        return 1
    fi

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -A|--all-namespaces)
                namespace="-A"
                shift
                ;;
            -n|--namespace)
                namespace="-n $2"
                shift 2
                ;;
            *)
                pod_pattern="$1"
                shift
                ;;
        esac
    done

    if [[ -z "$namespace" ]]; then
        namespace="-n kube-system"
    fi

    local cmd="storectl sk8 $store_number get pods $namespace -o jsonpath='{range .items[*]}{.metadata.name}{\"\n\"}{range .status.containerStatuses[*]}  Container: {.name}{\"\n\"}  Last State: {.lastState}{\"\n\"}{end}{\"----------\n\"}{end}'"

    if [[ -n "$pod_pattern" ]]; then
        eval "$cmd" | rg -A 3 "${pod_pattern}"
    else
        eval "$cmd"
    fi
}

[[ -z "$KUBECTL_BINARY" ]] && export KUBECTL_BINARY="$HOME/.kubectl-versions/kubectl-latest"
