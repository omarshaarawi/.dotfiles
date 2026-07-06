dotfiles := env("HOME") / ".dotfiles"

# home directory files to symlink
home_files := ".zshrc .zlogin .gitconfig .gitconfig-personal .gitconfig-work .gitattributes .wezterm.lua"

# home directory directories to symlink
home_dirs := ".zsh .scripts"

# .config subdirectories to symlink
config_dirs := "aerospace ghostty nvim starship tmux zellij zsh-plugins"

# .config files to symlink (file-level, not directory-level)
config_files := "jj/config.toml"

# ~/.claude files to symlink (global Claude Code config)
claude_files := "CLAUDE.md"

# ~/.claude/skills subdirectories to symlink (personal, hand-authored skills;
# marketplace skills stay symlinked into ~/.agents/skills and are not managed here).
# Gated on ~/.is_work_machine (set by `just set-work`), same signal as the zsh split:
#   claude_skills          - linked on every machine
#   claude_skills_personal - linked only on personal machines (skipped on work)
#   claude_skills_work     - linked only on work machines
claude_skills := ""
claude_skills_personal := "android-cli design jj-vcs loom-extract make-responsive portless raycast-settings use-railway workos workos-widgets x"
claude_skills_work := ""

# work skills stored ENCRYPTED (age) in the public repo, decrypted only on a machine
# holding the private key. one tar+age blob per skill at .claude/skills-work/<name>.tgz.age.
# plaintext lives at ~/.claude/skills/<name> (the edit target) and is never committed.
claude_skills_work_encrypted := "gameplan pactima-playwright zoom-hub aws-bento snapdocs-pr"

# age identity (private, work machine only) + recipients file (public, committed)
age_key := env("HOME") / ".config/age/dotfiles-work.txt"
age_recipients := dotfiles / ".claude/skills-work/recipients.txt"

# show available recipes
default:
    @just --list

# link all dotfiles into place
link:
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "$HOME/.config"
    for f in {{home_files}}; do
        target="$HOME/$f"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  SKIP $f (real file exists, back it up or remove it first)"
            continue
        fi
        ln -sfn "{{dotfiles}}/$f" "$target"
        echo "  $f -> {{dotfiles}}/$f"
    done
    for d in {{home_dirs}}; do
        target="$HOME/$d"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  SKIP $d (real dir exists, back it up or remove it first)"
            continue
        fi
        ln -sfn "{{dotfiles}}/$d" "$target"
        echo "  $d -> {{dotfiles}}/$d"
    done
    for d in {{config_dirs}}; do
        target="$HOME/.config/$d"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  SKIP .config/$d (real dir exists, back it up or remove it first)"
            continue
        fi
        ln -sfn "{{dotfiles}}/.config/$d" "$target"
        echo "  .config/$d -> {{dotfiles}}/.config/$d"
    done
    for f in {{config_files}}; do
        target="$HOME/.config/$f"
        mkdir -p "$(dirname "$target")"
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            rm "$target"
        fi
        ln -sfn "{{dotfiles}}/.config/$f" "$target"
        echo "  .config/$f -> {{dotfiles}}/.config/$f"
    done
    mkdir -p "$HOME/.claude/skills"
    for f in {{claude_files}}; do
        src="{{dotfiles}}/.claude/$f"
        target="$HOME/.claude/$f"
        [ -e "$src" ] || { echo "  SKIP .claude/$f (not vendored in dotfiles)"; continue; }
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  SKIP .claude/$f (real file exists, remove it to adopt the dotfiles copy)"
            continue
        fi
        mkdir -p "$(dirname "$target")"
        ln -sfn "$src" "$target"
        echo "  .claude/$f -> $src"
    done
    skills="{{claude_skills}}"
    if [ -f "$HOME/.is_work_machine" ]; then
        skills="$skills {{claude_skills_work}}"
    else
        skills="$skills {{claude_skills_personal}}"
    fi
    for d in $skills; do
        src="{{dotfiles}}/.claude/skills/$d"
        target="$HOME/.claude/skills/$d"
        [ -e "$src" ] || { echo "  SKIP .claude/skills/$d (not vendored in dotfiles)"; continue; }
        if [ -e "$target" ] && [ ! -L "$target" ]; then
            echo "  SKIP .claude/skills/$d (real dir exists, remove it to adopt the dotfiles copy)"
            continue
        fi
        ln -sfn "$src" "$target"
        echo "  .claude/skills/$d -> $src"
    done
    if [ -f "$HOME/.is_work_machine" ]; then
        for name in {{claude_skills_work_encrypted}}; do
            target="$HOME/.claude/skills/$name"
            blob="{{dotfiles}}/.claude/skills-work/$name.tgz.age"
            [ -f "$blob" ] || { echo "  SKIP .claude/skills/$name (no encrypted blob)"; continue; }
            if [ -e "$target" ]; then
                echo "  .claude/skills/$name (present; 'just decrypt-work' to refresh from repo)"
                continue
            fi
            if [ ! -f "{{age_key}}" ]; then
                echo "  SKIP .claude/skills/$name (encrypted; no age key at {{age_key}})"
                continue
            fi
            age -d -i "{{age_key}}" "$blob" | tar xzf - -C "$HOME/.claude/skills"
            echo "  .claude/skills/$name (decrypted from repo)"
        done
    fi
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
    for f in {{config_files}}; do
        [ -L "$HOME/.config/$f" ] && rm "$HOME/.config/$f" && echo "  removed ~/.config/$f"
    done
    for f in {{claude_files}}; do
        [ -L "$HOME/.claude/$f" ] && rm "$HOME/.claude/$f" && echo "  removed ~/.claude/$f"
    done
    for d in {{claude_skills}} {{claude_skills_personal}} {{claude_skills_work}}; do
        [ -L "$HOME/.claude/skills/$d" ] && rm "$HOME/.claude/skills/$d" && echo "  removed ~/.claude/skills/$d"
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
    for f in {{config_files}}; do
        if [ -L "$HOME/.config/$f" ]; then
            echo "  ok  ~/.config/$f"
            ((ok++))
        else
            echo "  MISSING  ~/.config/$f"
            ((bad++))
        fi
    done
    for f in {{claude_files}}; do
        if [ -L "$HOME/.claude/$f" ]; then
            echo "  ok  ~/.claude/$f"
            ((ok++))
        else
            echo "  MISSING  ~/.claude/$f"
            ((bad++))
        fi
    done
    skills="{{claude_skills}}"
    if [ -f "$HOME/.is_work_machine" ]; then
        skills="$skills {{claude_skills_work}}"
    else
        skills="$skills {{claude_skills_personal}}"
    fi
    for d in $skills; do
        if [ -L "$HOME/.claude/skills/$d" ]; then
            echo "  ok  ~/.claude/skills/$d"
            ((ok++))
        else
            echo "  MISSING  ~/.claude/skills/$d"
            ((bad++))
        fi
    done
    if [ -f "$HOME/.is_work_machine" ]; then
        for name in {{claude_skills_work_encrypted}}; do
            if [ -d "$HOME/.claude/skills/$name" ]; then
                echo "  ok  ~/.claude/skills/$name (decrypted)"
                ((ok++))
            else
                echo "  MISSING  ~/.claude/skills/$name (run 'just decrypt-work')"
                ((bad++))
            fi
        done
    fi
    echo ""
    echo "$ok ok, $bad missing"
    [ "$bad" -eq 0 ]

# re-encrypt work skills into committed age blobs. `just encrypt-work` re-encrypts all;
# `just encrypt-work <name>` does just one (avoids churning the others, since age is non-deterministic).
encrypt-work name="":
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p "{{dotfiles}}/.claude/skills-work"
    names="{{name}}"; [ -n "$names" ] || names="{{claude_skills_work_encrypted}}"
    for name in $names; do
        src="$HOME/.claude/skills/$name"
        if [ ! -d "$src" ]; then
            echo "  SKIP $name (no plaintext at $src)"
            continue
        fi
        out="{{dotfiles}}/.claude/skills-work/$name.tgz.age"
        tar czf - -C "$HOME/.claude/skills" "$name" | age -R "{{age_recipients}}" -o "$out"
        echo "  encrypted $name -> .claude/skills-work/$name.tgz.age"
    done
    echo "done. commit the .tgz.age blobs."

# decrypt work skills from committed age blobs into ~/.claude/skills (needs the private key)
decrypt-work:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ ! -f "{{age_key}}" ]; then
        echo "  no age key at {{age_key}} — cannot decrypt work skills."
        echo "  restore it from 1Password onto this machine, then re-run."
        exit 1
    fi
    mkdir -p "$HOME/.claude/skills"
    for name in {{claude_skills_work_encrypted}}; do
        blob="{{dotfiles}}/.claude/skills-work/$name.tgz.age"
        [ -f "$blob" ] || { echo "  SKIP $name (no blob at $blob)"; continue; }
        rm -rf "$HOME/.claude/skills/$name"
        age -d -i "{{age_key}}" "$blob" | tar xzf - -C "$HOME/.claude/skills"
        echo "  decrypted $name -> ~/.claude/skills/$name"
    done
    echo "done."

# mark this as a work machine (sources .zsh/work.zsh instead of personal.zsh)
set-work:
    #!/usr/bin/env bash
    set -euo pipefail
    touch ~/.is_work_machine
    if [ ! -f "{{dotfiles}}/.zsh/work.zsh" ]; then
        cp "{{dotfiles}}/.zsh/work.zsh.example" "{{dotfiles}}/.zsh/work.zsh"
        echo "created .zsh/work.zsh from template, edit it with your work config."
    fi
    echo "this machine is now set to work. restart your shell."

# mark this as a personal machine
set-personal:
    rm -f ~/.is_work_machine
    @echo "this machine is now set to personal. restart your shell."

# full setup for a fresh machine
setup:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "initializing submodules..."
    git -C "{{dotfiles}}" submodule update --init --recursive
    echo ""
    just link
    echo ""
    echo "next steps:"
    echo "  - run 'just set-work' or 'just set-personal'"
    echo "  - restart your shell"
