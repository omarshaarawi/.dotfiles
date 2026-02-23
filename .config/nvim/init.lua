-- Neovim Configuration
-- Using vim.pack.add() (built-in plugin manager) and vim.lsp.config()

-- Load core configuration modules
require("config.settings") -- Vim options and settings
require("config.keymaps")  -- Keybindings
require("config.autocmds") -- Autocommands
require("config.lsp")      -- LSP configuration

-- Plugin Management with vim.pack.add()
-- See :help vim.pack for details
-- Update all plugins with: :lua vim.pack.update()

-- Register and load plugins
vim.pack.add({
    -- Start time
    "https://github.com/dstein64/vim-startuptime",

    -- Dependencies
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/rafamadriz/friendly-snippets",

    -- Core plugins
    "https://github.com/nvim-telescope/telescope.nvim",
    "https://github.com/nvim-telescope/telescope-fzf-native.nvim",
    "https://github.com/nvim-treesitter/nvim-treesitter",
    "https://github.com/stevearc/oil.nvim",

    -- Git integration
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/tpope/vim-fugitive",

    -- Navigation & workflow
    "https://github.com/mbbill/undotree",
    "https://github.com/folke/trouble.nvim",

    -- Theme
    "https://github.com/vague-theme/vague.nvim",

    -- All in one
    "https://github.com/nvim-mini/mini.nvim.git",

    -- autocomplete
    "https://github.com/saghen/blink.cmp",

    -- Markdown
    "https://github.com/iamcco/markdown-preview.nvim",
    "https://github.com/MeanderingProgrammer/render-markdown.nvim",
}, { load = true })

-- Plugin Configurations

-- Treesitter (new API - nvim-treesitter main branch rewrite)
-- Install parsers with :TSInstall <lang> or programmatically below
-- Highlighting/indent now uses Neovim's built-in treesitter support
local ts_langs = { "lua", "vim", "vimdoc", "go", "rust", "javascript", "typescript", "markdown", "markdown_inline", "elixir", "heex" }

-- Auto-install parsers (async, won't block startup)
vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require('nvim-treesitter').install(ts_langs)
    end,
})

-- Enable treesitter highlighting and indent for all filetypes
vim.api.nvim_create_autocmd("FileType", {
    callback = function()
        pcall(vim.treesitter.start)
    end,
})

-- Telescope
local telescope = require('telescope')
telescope.setup {
    pickers = {
        find_files = {
            find_command = { 'rg', '--files', '--hidden', '--sortr=modified', '--glob', '!.git' },
        },
        git_files = {
            find_command = { 'rg', '--files', '--hidden', '--sortr=modified', '--glob', '!.git' },
        },
    },
    defaults = {
        mappings = {
            i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
            }
        }
    }
}

pcall(telescope.load_extension, 'fzf')

local builtin = require('telescope.builtin')
-- File finding
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Find files (project)' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Find git files' })

-- Search
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") })
end, { desc = 'Project search (grep)' })
vim.keymap.set('n', '<leader>pws', function()
    local word = vim.fn.expand("<cword>")
    builtin.grep_string({ search = word })
end, { desc = 'Search word under cursor' })
vim.keymap.set('n', '<leader>pWs', function()
    local word = vim.fn.expand("<cWORD>")
    builtin.grep_string({ search = word })
end, { desc = 'Search WORD under cursor' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Live grep' })

-- Other
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
vim.keymap.set('n', '<leader>vh', builtin.help_tags, { desc = 'Vim help tags' })

-- Oil.nvim
require("oil").setup({
    delete_to_trash = true,
    view_options = {
        show_hidden = true,
    },
    keymaps = {
        ["<C-h>"] = false,
    },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
vim.keymap.set("n", "<space>-", require("oil").toggle_float, { desc = "Open oil in floating window" })

-- Gitsigns
require('gitsigns').setup {
    signs = {
        add          = { text = '│' },
        change       = { text = '│' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
    },
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
            if vim.wo.diff then return ']c' end
            vim.schedule(function() gs.next_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = "Next hunk" })

        map('n', '[c', function()
            if vim.wo.diff then return '[c' end
            vim.schedule(function() gs.prev_hunk() end)
            return '<Ignore>'
        end, { expr = true, desc = "Previous hunk" })

        map('n', '<leader>hs', gs.stage_hunk, { desc = "Stage hunk" })
        map('n', '<leader>hr', gs.reset_hunk, { desc = "Reset hunk" })
        map('n', '<leader>hS', gs.stage_buffer, { desc = "Stage buffer" })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = "Undo stage hunk" })
        map('n', '<leader>hR', gs.reset_buffer, { desc = "Reset buffer" })
        map('n', '<leader>hp', gs.preview_hunk, { desc = "Preview hunk" })
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, { desc = "Blame line" })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = "Toggle line blame" })
        map('n', '<leader>hd', gs.diffthis, { desc = "Diff this" })
    end
}

-- Harpoon 2
-- local harpoon = require("harpoon")
-- harpoon:setup()
--
-- vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon: Add file" })
-- vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
--     { desc = "Harpoon: Toggle menu" })
-- vim.keymap.set("n", "<C-h>", function() harpoon:list():select(1) end, { desc = "Harpoon: File 1" })
-- vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = "Harpoon: File 2" })
-- vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = "Harpoon: File 3" })
-- vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = "Harpoon: File 4" })

-- Undotree (old-style plugin, no setup needed)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle Undotree" })

-- Trouble
local trouble_loaded = false
vim.keymap.set("n", "<leader>tt", function()
    if not trouble_loaded then
        require('trouble').setup({
            focus = true,
            indent_guides = true,
            follow = true,
            auto_refresh = true,
            auto_close = false,
            use_diagnostic_signs = true,
        })
        trouble_loaded = true
    end
    require('trouble').toggle({ mode = "diagnostics" })
end, { desc = "Toggle Trouble Diagnostics" })

vim.keymap.set("n", "<leader>tT", function()
    require('trouble').toggle({
        mode = "diagnostics",
        filter = { buf = vim.api.nvim_get_current_buf() },
    })
end, { desc = "Toggle Trouble (buffer)" })

vim.keymap.set("n", "[t", function()
    if require("trouble").is_open() then
        require("trouble").prev({ skip_groups = true, jump = true })
    else
        vim.cmd.cprev()
    end
end, { desc = "Previous trouble/quickfix item" })

vim.keymap.set("n", "]t", function()
    if require("trouble").is_open() then
        require("trouble").next({ skip_groups = true, jump = true })
    else
        vim.cmd.cnext()
    end
end, { desc = "Next trouble/quickfix item" })

-- Blink.cmp (Completion engine)
require('blink.cmp').setup({
    keymap = { preset = 'default' },
    appearance = {
        nerd_font_variant = 'mono'
    },
    signature = { enabled = true },
})

-- Mini
require("mini.pairs").setup()

-- Theme
require("vague").setup({
    transparent = true,
})
vim.cmd("colorscheme vague")

-- Markdown Preview (browser-based)
vim.g.mkdp_auto_close = 1
vim.g.mkdp_theme = "dark"

-- Render Markdown (in-buffer rendering)
require('render-markdown').setup({
    heading = {
        enabled = true,
        sign = false,
    },
    code = {
        enabled = true,
        sign = false,
        style = "full",
        border = "thin",
    },
})


-- Notes
--
-- Update all plugins: :lua vim.pack.update()
-- See installed plugins: :lua =vim.pack.get()
--
-- LSP configurations in lsp/*.lua are automatically loaded by config/lsp.lua
