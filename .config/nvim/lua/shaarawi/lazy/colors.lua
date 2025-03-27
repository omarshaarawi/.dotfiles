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
                colors = {
                    theme = {
                        all = {
                            ui = {
                                bg_gutter = "none"
                            }
                        }
                    }
                },
                overrides = function(colors)
                    local theme = colors.theme
                    local makeDiagnosticColor = function(color)
                        local c = require("kanagawa.lib.color")
                        return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
                    end
                    return {
                        TelescopeTitle             = { fg = theme.ui.special, bold = true },
                        TelescopePromptNormal      = { bg = theme.ui.bg_p1 },
                        TelescopePromptBorder      = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
                        TelescopeResultsNormal     = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },

                        TelescopeResultsBorder     = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
                        TelescopePreviewNormal     = { bg = theme.ui.bg_dim },
                        TelescopePreviewBorder     = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },

                        Pmenu                      = { fg = theme.ui.shade0, bg = theme.ui.bg_p1 }, -- add `blend = vim.o.pumblend` to enable transparency
                        PmenuSel                   = { fg = "NONE", bg = theme.ui.bg_p2 },
                        PmenuSbar                  = { bg = theme.ui.bg_m1 },
                        PmenuThumb                 = { bg = theme.ui.bg_p2 },

                        DiagnosticVirtualTextHint  = makeDiagnosticColor(theme.diag.hint),
                        DiagnosticVirtualTextInfo  = makeDiagnosticColor(theme.diag.info),
                        DiagnosticVirtualTextWarn  = makeDiagnosticColor(theme.diag.warning),
                        DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
                    }
                end,
                terminalColors = true,
                theme = "dragon", -- The darkest variant
                background = {
                    dark = "dragon",
                    light = "dragon"
                },
            })

            vim.cmd("colorscheme kanagawa")

            -- Apply the same transparency settings
            vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

            -- Enhance line number appearance to match theme
            vim.api.nvim_set_hl(0, "LineNr", { fg = "#54546D" })
            vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#C8C093", bold = true })

            -- Make sign column match background
            vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        end
    }
}
