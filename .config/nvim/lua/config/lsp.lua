-- LSP Configuration Loader
-- Uses Nvim 0.11+ built-in LSP system with vim.lsp.config()

-- Your LSP configs are in ~/.config/nvim/lsp/*.lua
-- Each file should return a table with: cmd, filetypes, root_markers, settings

-- List of LSP servers to enable
-- Add or remove servers as needed
local servers = {
    'bashls',
    'cssls',
    'docker_compose_language_service',
    'dockerls',
    'elixirls',
    'golangci_lint_ls',
    'gopls',
    'html',
    'jsonls',
    'lua_ls',
    'pyright',
    'rust_analyzer',
    'svelte',
    'tailwindcss',
    'ts_ls',
    'yamlls',
    'zls',
    'swiftls',
}

-- Enable each LSP server
for _, server in ipairs(servers) do
    -- vim.lsp.enable() will automatically look for lsp/<server>.lua files
    -- in your runtimepath and merge them with vim.lsp.config()
    vim.lsp.enable(server)
end

-- Get blink.cmp capabilities for LSP
local capabilities = nil
pcall(function()
    capabilities = require('blink.cmp').get_lsp_capabilities()
end)

-- Global LSP configuration (applies to all servers)
vim.lsp.config('*', {
    -- Common root markers (will be merged with server-specific ones)
    root_markers = { '.git' },

    -- Blink.cmp capabilities (includes snippet support and more)
    capabilities = capabilities,
})

-- Note: Server-specific configurations are automatically loaded from lsp/*.lua files
-- The configs will be merged in this order:
--   1. Global '*' config (above)
--   2. Config from lsp/<server>.lua files
--   3. Any explicit vim.lsp.config() calls

-- Example of how to override a specific server config if needed:
-- vim.lsp.config('gopls', {
--     settings = {
--         gopls = {
--             gofumpt = false, -- Override the setting from lsp/gopls.lua
--         }
--     }
-- })
