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
