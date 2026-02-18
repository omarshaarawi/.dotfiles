-- Neovim Settings
-- Minimal configuration with sensible defaults

-- Leader key (must be set before any keymaps)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Line wrapping
vim.opt.wrap = false

-- Backup and undo
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Colors
vim.opt.termguicolors = true

-- Scrolling
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"

-- Updates
vim.opt.updatetime = 50

-- Visual guides
vim.opt.colorcolumn = "80"

-- File name patterns
vim.opt.isfname:append("@-@")

-- Cursor (blinking in normal mode)
vim.opt.guicursor = "n-v-c:block-blinkon500-blinkoff500"

-- Clipboard (OSC 52 for remote SSH support)
if os.getenv("SSH_TTY") then
    vim.g.clipboard = {
        name = 'OSC 52',
        copy = {
            ['+'] = require('vim.ui.clipboard.osc52').copy '+',
            ['*'] = require('vim.ui.clipboard.osc52').copy '*',
        },
        paste = {
            ['+'] = require('vim.ui.clipboard.osc52').paste '+',
            ['*'] = require('vim.ui.clipboard.osc52').paste '*',
        },
    }
end

-- Disable whitespace characters display
vim.opt.list = false

-- Disable netrw (using oil.nvim instead)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
