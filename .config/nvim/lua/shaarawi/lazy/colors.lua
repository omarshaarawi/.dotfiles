return {
    {
        "rebelot/kanagawa.nvim",
        priority = 1000,
        config = function()
            require('kanagawa').setup({
                compile = false,
                undercurl = true,
                commentStyle = { italic = false },
                keywordStyle = { italic = false },
                statementStyle = { bold = true },
                transparent = true,
                dimInactive = false,
                terminalColors = true,
                theme = "dragon", -- The darkest variant
                background = {
                    dark = "dragon",
                    light = "lotus"
                },
            })

            vim.cmd("colorscheme kanagawa")

            -- Apply the same transparency settings
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
        end
    }
}
