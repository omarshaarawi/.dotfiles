require("shaarawi.remap")
require("shaarawi.set")
require("shaarawi.lazy_init")
-- LSP system is now initialized via the Lazy plugin in lazy/lsp.lua
-- Server configurations are still in ~/.config/nvim/lsp/*.lua

local augroup = vim.api.nvim_create_augroup
local ShaarawiGroup = augroup('Shaarawi', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})


function R(name)
    require("plenary.reload").reload_module(name)
end

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})


autocmd({ "BufWritePre" }, {
    group = ShaarawiGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

-- Note: Core LSP keybindings are now set in lazy/lsp.lua
-- These are now redundant but kept for backward compatibility
-- These can be removed if there are no conflicts with those in lazy/lsp.lua
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, { desc = "Go to definition" })
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, { desc = "Show hover documentation" })
vim.keymap.set("n", "<C-k>", function() vim.lsp.buf.signature_help() end, { desc = "Show signature help" })
vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, { desc = "Show references" })
vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, { desc = "Go to implementation" })
vim.keymap.set("n", "gl", function() vim.diagnostic.open_float() end, { desc = "Show line diagnostics" })
vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })

-- Custom LSP keymaps that aren't provided by default
-- Note: Many of these mappings may now be redundant with those in lazy/lsp.lua
autocmd('LspAttach', {
    group = ShaarawiGroup,
    callback = function(e)
        local opts = { buffer = e.buf }
        
        -- Set only custom mappings not provided by default
        vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
        vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set("n", "<leader>vii", function() vim.lsp.buf.implementation() end, opts)
    end
})
