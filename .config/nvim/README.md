# My Neovim Config

- Built-in plugin manager
- Built-in LSP system

## Quick Start

### 1. Install Plugins

On first startup, Nvim will clone all plugins declared in `vim.pack.add()` to:

```
~/.local/share/nvim/site/pack/core/opt/
```

### 3. Install LSP Servers

Install language servers for the languages you use:

```bash
# Go
brew install gopls golangci-lint

# Lua
brew install lua-language-server

# Rust
rustup component add rust-analyzer

# JavaScript/TypeScript
npm install -g typescript-language-server

# Python
pip install pyright

# Zig
# (zls must be built from source or use zigup)

# See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
```

## Updating Plugins

Inside Nvim:
```vim
:lua vim.pack.update()
```

**View installed plugins:**
```vim
:lua =vim.pack.get()
```

**Manually remove a plugin:**
```vim
:lua vim.pack.del({'plugin-name'})
```
