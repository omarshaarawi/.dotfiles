return {
    {
        "supermaven-inc/supermaven-nvim",
        enabled = function()
            local file = io.open(os.getenv("HOME") .. "/.is_work_machine")
            if file then
                file:close()
                return false
            end
            return true
        end,
        config = function()
            require("supermaven-nvim").setup({
                disable_keymaps = true,           -- Disable default keymaps
                disable_inline_completion = true, -- Use as cmp source instead

                -- Custom keymaps for SuperMaven functionality
                -- Add your own keymaps here
                keymaps = {
                    -- Example custom keymaps (uncomment and modify as needed)
                    accept_suggestion = "<C-y>",
                    next_suggestion = "<C-n>",
                    prev_suggestion = "<C-p>",
                    dismiss_suggestion = "<C-e>",
                },

                -- Configure SuperMaven behavior
                behavior = {
                    auto_trigger = true, -- Auto-trigger suggestions
                    trigger_chars = 3,   -- Number of chars to trigger suggestions
                    debounce_ms = 300,   -- Debounce time in milliseconds
                },

                -- Configure appearance
                ui = {
                    max_width = 80,     -- Maximum width of suggestion window
                    border = "rounded", -- Border style: 'none', 'single', 'double', 'rounded'
                },

                -- Configure which filetypes to enable/disable
                filetypes = {
                    -- Explicitly enable for these filetypes
                    enable = {
                        "lua", "python", "javascript", "typescript",
                        "go", "rust", "c", "cpp", "java", "kotlin", "bash", "zsh"
                    },
                    -- Explicitly disable for these filetypes
                    disable = {},
                },
            })

            -- Add custom keymaps for SuperMaven
            vim.keymap.set("i", "<C-s>", function()
                -- Check if supermaven has a function to manually trigger suggestions
                local ok, supermaven = pcall(require, "supermaven-nvim")
                if ok and supermaven.trigger_suggestion then
                    supermaven.trigger_suggestion()
                end
            end, { desc = "Trigger SuperMaven suggestion" })
        end,
    },
}

