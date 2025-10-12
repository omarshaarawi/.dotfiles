-- Neovim Autocommands

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
local yank_group = augroup('HighlightYank', { clear = true })
autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
    desc = "Briefly highlight yanked text"
})

-- Trim trailing whitespace on save
local trim_group = augroup('TrimWhitespace', { clear = true })
autocmd({ "BufWritePre" }, {
    group = trim_group,
    pattern = "*",
    command = [[%s/\s\+$//e]],
    desc = "Remove trailing whitespace on save"
})

-- LSP Attach configuration
local lsp_group = augroup('LspConfig', { clear = true })
autocmd('LspAttach', {
    group = lsp_group,
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        -- LSP keymaps
        local opts = { buffer = bufnr }

        -- Go to definition/declaration/type definition
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", opts, { desc = "Go to definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("force", opts, { desc = "Go to declaration" }))
        vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, vim.tbl_extend("force", opts, { desc = "Go to type definition" }))

        -- Hover documentation
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

        -- Signature help
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("force", opts, { desc = "Signature help" }))

        -- Workspace symbol search
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

        -- Diagnostics
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)

        -- Code action (also available as 'gra' by default in Nvim 0.11+)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)

        -- Additional reference/implementation shortcuts
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>vii", vim.lsp.buf.implementation, opts)
        -- Auto-format on save (optional, commented out by default)
        -- Uncomment if you want auto-formatting
        -- if client and client.supports_method('textDocument/formatting') then
        --     autocmd('BufWritePre', {
        --         group = lsp_group,
        --         buffer = bufnr,
        --         callback = function()
        --             vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
        --         end,
        --     })
        -- end
    end,
    desc = "Configure LSP keymaps and features on attach"
})
