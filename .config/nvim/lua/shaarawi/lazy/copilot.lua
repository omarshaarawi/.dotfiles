return {
    {
        "github/copilot.vim",
        config = function()
            -- Disable Copilot by default
            vim.g.copilot_enabled = 0

            vim.g.copilot_filetypes = {
                ["TelescopePrompt"] = false,
            }
            local opts = { silent = true }
            vim.keymap.set("i", "<C-j>", "<Plug>(copilot-next)", opts)
            vim.keymap.set("i", "<C-k>", "<Plug>(copilot-previous)", opts)
            vim.keymap.set("i", "<C-l>", "<Plug>(copilot-suggest)", opts)

            -- Add a command to toggle Copilot
            vim.api.nvim_create_user_command("CopilotToggle", function()
                vim.g.copilot_enabled = not vim.g.copilot_enabled
                print("Copilot " .. (vim.g.copilot_enabled and "enabled" or "disabled"))
            end, {})
        end,
    },
}
