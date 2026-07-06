# dotfiles

## Requirements

- [Ghostty](https://ghostty.org) (tip channel) - Terminal Emulator
- [Neovim](https://neovim.io) 0.11+ - Code Editor
- [zmx](https://github.com/neurosnap/zmx) - Session Persistence
- Zsh - Shell
- [Starship](https://starship.rs) - Prompt

## Installation

```bash
git clone git@github.com:omarshaarawi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
just setup
```

```bash
just link      # create symlinks
just unlink    # remove symlinks
just check     # validate symlinks
```

## Claude Code config

The global Claude Code config lives under `.claude/` and is symlinked into `~/.claude/` by `just link`:

- `.claude/CLAUDE.md` -> `~/.claude/CLAUDE.md` (global instructions)
- `.claude/skills/*` -> `~/.claude/skills/*` (personal, hand-authored skills)

### Work / personal skill gate

Skills are split into three lists in the `justfile`, gated on `~/.is_work_machine` (the same
flag `just set-work` / `just set-personal` toggle for the zsh split):

- `claude_skills` - linked on every machine
- `claude_skills_personal` - linked only on personal machines (skipped on work)
- `claude_skills_work` - linked only on work machines

So e.g. `android-cli` and `x` live in `claude_skills_personal` and never land on a work machine.
`CLAUDE.md` is linked on every machine. Move a skill between the lists to change where it lands;
after switching a machine's type, run `just unlink && just link` to resync (a stale symlink from
the previous type is not auto-pruned by `link` alone).

`just link` is non-destructive: it only creates a symlink where nothing real exists yet (a
fresh machine), and **skips** any existing real `~/.claude/CLAUDE.md` or skill dir rather than
overwriting it. To adopt the dotfiles copy on a machine that already has a real one (e.g. to
replace a machine-specific `CLAUDE.md`), remove the real target first, then re-run `just link`:

```bash
rm ~/.claude/CLAUDE.md
rm -rf ~/.claude/skills/gameplan   # per skill you want to adopt
just link
```

Anything not listed in `claude_files` / `claude_skills` is left untouched. Marketplace skills
(installed via the skills CLI into `~/.agents/skills` and symlinked into `~/.claude/skills`) are
intentionally *not* managed here, so they keep updating themselves. The rest of `~/.claude/`
(sessions, history, credentials, plugins) is machine-local and never symlinked.

## zmx workflow

zmx provides session persistence without a multiplexer. Ghostty handles splits and tabs natively.

### Quick start

```bash
nic                     # create nvim + claude + terminal sessions for cwd
nic ~/projects/foo      # for a specific directory
nic -a opencode         # use opencode instead of claude
```

Then open Ghostty splits (`super+/` right, `super+.` down) and attach:

```bash
za nvim                 # attach to nvim session
za ai                   # attach to ai session
za term                 # attach to terminal session
```

### Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `za`  | `zmx attach` | Attach to a session |
| `zl`  | `zmx list` | List active sessions |
| `zk`  | `zmx kill` | Kill a session |
| `zd`  | `zmx detach` | Detach from current session |

### Session lifecycle

Sessions survive terminal closes. Reopen Ghostty splits and `za <name>` to pick up where you left off. If a program exits (nvim, claude), the session drops to a shell in the project directory.

`gp` (fzf project switcher) auto-updates `ZMX_SESSION_PREFIX` so zmx commands scope to the current project.

### Ghostty keybinds

| Keybind | Action |
|---------|--------|
| `super+/` | Split right |
| `super+.` | Split down |
| `ctrl+super+h/j/k/l` | Navigate splits |
| `ctrl+f` | Zoom split |
| `ctrl+super+=` | Equalize splits |
| `super+ctrl+arrows` | Resize splits |
| `alt+v` | Enter vim scrollback mode |
