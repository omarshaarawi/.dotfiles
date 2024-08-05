# My dotfiles

This repository contains the dotfiles for my system, managed using GNU Stow.

## Requirements

### GNU Stow

To manage these dotfiles, you need to have GNU Stow installed. On macOS, you can install it using Homebrew:

```bash
brew install stow
```

### Tools Configured (Currently in use)

- Neovim - Code Editor
- Zsh - Shell
- Zellij - Terminal Multiplexer
- Ghostty - Terminal Emulator

## Installation

1. Clone the dotfiles repository to your home directory:

```bash
git clone git@github.com:omarshaarawi/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

2. Use the Makefile to manage your dotfiles:

- To see available dotfiles:
  ```bash
  make list
  ```
- To stow all dotfiles (includes backing up existing configurations):
  ```bash
  make stow
  ```
- To remove all symlinks:
  ```bash
  make unstow
  ```
- To restow all dotfiles:
  ```bash
  make restow
  ```
- To backup existing configurations without stowing:
  ```bash
  make backup
  ```
- To validate stowed symlinks:
  ```bash
  make validate
  ```
- To see all available commands:
  ```bash
  make help
  ```
