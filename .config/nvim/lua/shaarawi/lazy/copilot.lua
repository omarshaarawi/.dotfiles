return {
    {
        "github/copilot.vim",
        enabled = function()
            local file = io.open(os.getenv("HOME") .. "/.is_work_machine")
            if file then
                file:close()
                return false
            end
            return false
        end,
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
