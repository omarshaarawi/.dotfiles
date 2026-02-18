# Work-specific configurations
# To activate: touch ~/.is_work_machine
typeset -U path
path=(
    "$HOME/go/bin"
    "/usr/local/sbin"
    $path
)

PS1="%F{yellow}[WORK]%f $PS1"
