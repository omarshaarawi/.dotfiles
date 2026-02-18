dotfiles := env("HOME") / ".dotfiles"

# home directory files to symlink
home_files := ".zshrc .zlogin .gitconfig .gitconfig-personal .gitconfig-work .gitattributes .wezterm.lua"

# home directory directories to symlink
home_dirs := ".zsh .scripts"

# .config subdirectories to symlink
config_dirs := "aerospace ghostty nvim starship tmux zellij zsh-plugins"

# show available recipes
default:
    @just --list

# link all dotfiles into place
link:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "$HOME/.config"
    for f in {{home_files}}; do
        ln -sfn "{{dotfiles}}/$f" "$HOME/$f"
        echo "  $f -> {{dotfiles}}/$f"
    done
    for d in {{home_dirs}}; do
        ln -sfn "{{dotfiles}}/$d" "$HOME/$d"
        echo "  $d -> {{dotfiles}}/$d"
    done
    for d in {{config_dirs}}; do
        ln -sfn "{{dotfiles}}/.config/$d" "$HOME/.config/$d"
        echo "  .config/$d -> {{dotfiles}}/.config/$d"
    done
    echo "done."

# remove all managed symlinks
unlink:
    #!/usr/bin/env bash
    set -euo pipefail
    for f in {{home_files}}; do
        [ -L "$HOME/$f" ] && rm "$HOME/$f" && echo "  removed ~/$f"
    done
    for d in {{home_dirs}}; do
        [ -L "$HOME/$d" ] && rm "$HOME/$d" && echo "  removed ~/$d"
    done
    for d in {{config_dirs}}; do
        [ -L "$HOME/.config/$d" ] && rm "$HOME/.config/$d" && echo "  removed ~/.config/$d"
    done
    echo "done."

# check that all symlinks are in place
check:
    #!/usr/bin/env bash
    ok=0; bad=0
    for f in {{home_files}}; do
        if [ -L "$HOME/$f" ]; then
            echo "  ok  ~/$f"
            ((ok++))
        else
            echo "  MISSING  ~/$f"
            ((bad++))
        fi
    done
    for d in {{home_dirs}}; do
        if [ -L "$HOME/$d" ]; then
            echo "  ok  ~/$d"
            ((ok++))
        else
            echo "  MISSING  ~/$d"
            ((bad++))
        fi
    done
    for d in {{config_dirs}}; do
        if [ -L "$HOME/.config/$d" ]; then
            echo "  ok  ~/.config/$d"
            ((ok++))
        else
            echo "  MISSING  ~/.config/$d"
            ((bad++))
        fi
    done
    echo ""
    echo "$ok ok, $bad missing"
    [ "$bad" -eq 0 ]

# mark this as a work machine (sources .zsh/work.zsh instead of personal.zsh)
set-work:
    touch ~/.is_work_machine
    @echo "this machine is now set to work. restart your shell."

# mark this as a personal machine
set-personal:
    rm -f ~/.is_work_machine
    @echo "this machine is now set to personal. restart your shell."

# full setup for a fresh machine
setup:
    just link
    @echo ""
    @echo "next steps:"
    @echo "  - run 'just set-work' or 'just set-personal'"
    @echo "  - restart your shell"
