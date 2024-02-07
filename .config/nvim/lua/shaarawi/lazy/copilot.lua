return {
    {
        "github/copilot.vim",
        config = function()
            vim.g.copilot_filetypes = {
                ["TelescopePrompt"] = false,
            }

            local opts = { silent = true }
            vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", opts)
            vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", opts)
            vim.keymap.set("i", "<C-l>", "<Plug>(copilot-suggest)", opts)
        end,
    },
}
