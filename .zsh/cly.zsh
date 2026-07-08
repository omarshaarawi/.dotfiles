#!/usr/bin/env zsh

_set_title() {
    local title="$1"
    echo -ne "\033]0;${title}\007"
}

cly() {
    local dir_name="${PWD##*/}"
    local title="${dir_name}: $*"

    _set_title "$title"

    (
        while true; do
            sleep 1
            _set_title "$title"
        done
    ) &
    local bg_pid=$!

    claude --dangerously-skip-permissions "$@"
    local claude_exit_code=$?

    kill $bg_pid 2>/dev/null

    _set_title "$dir_name"

    return $claude_exit_code
}

_claude_precmd() {
    local dir_name="${PWD##*/}"
    _set_title "$dir_name"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _claude_precmd
