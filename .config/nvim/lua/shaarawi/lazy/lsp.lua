return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "hrsh7th/cmp-nvim-lua", -- Add Lua API completion
        "hrsh7th/cmp-calc",     -- Add calculator completion
        "hrsh7th/cmp-emoji",    -- Add emoji completion
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local luasnip = require("luasnip")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        -- Helper function to check if words exist before cursor
        local has_words_before = function()
            local line, col = unpack(vim.api.nvim_win_get_cursor(0))
            return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
        end

        -- Helper function to check if we're on a work machine
        local function is_work_machine()
            local file = io.open(os.getenv("HOME") .. "/.is_work_machine")
            if file then
                file:close()
                return true
            end
            return false
        end

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "html",
                "htmx",
                "tailwindcss",
                "zls",
                "templ",
                "pyright", -- Python
                "jsonls",  -- JSON
                "yamlls",  -- YAML
                "cssls",   -- CSS
                "bashls",  -- Bash
            },
            handlers = {
                function(server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
                templ = function()
                    require 'lspconfig'.templ.setup({
                        version = '0.2.476',
                        cmd = { 'templ', 'lsp' },
                        cmd_env = { TEMPL_EXPERIMENT = 'rawgo', TEST = "false" },
                    })
                end,
                html = function()
                    require 'lspconfig'.html.setup({
                        filetypes = { 'html', 'templ' },
                        capabilities = capabilities,
                    })
                end,
                htmx = function()
                    require 'lspconfig'.htmx.setup({
                        filetypes = { 'html', 'templ' },
                        capabilities = capabilities,
                    })
                end,
                tailwindcss = function()
                    require 'lspconfig'.tailwindcss.setup({
                        filetypes = { "templ", "astro", "javascript", "typescript", "react", "svelte" },
                        settings = {
                            tailwindCSS = {
                                includeLanguages = {
                                    templ = "html",
                                },
                            },
                        },
                    })
                end,
                zls = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.zls.setup({
                        root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                        settings = {
                            zls = {
                                enable_inlay_hints = true,
                                enable_snippets = true,
                                warn_style = true,
                            },
                        },
                    })
                    vim.g.zig_fmt_parse_errors = 0
                    vim.g.zig_fmt_autosave = 0
                end,
                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                runtime = { version = "Lua 5.1" },
                                diagnostics = {
                                    globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            window = {
                completion = {
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                    winhighlight = "Normal:CmpNormal",
                },
                documentation = {
                    border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
                    winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
                    max_width = 80,
                    max_height = 20,
                },
            },
            mapping = cmp.mapping.preset.insert({
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_locally_jumpable() then
                        luasnip.expand_or_jump()
                    elseif has_words_before() then
                        cmp.complete()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
            }),
            sources = (function()
                local sources = {}

                -- Environment-specific sources
                if is_work_machine() then
                    table.insert(sources, { name = 'copilot' })
                else
                    table.insert(sources, { name = 'supermaven' })
                end

                -- Base sources that are always included
                local base_sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'path' },
                    { name = 'nvim_lua' },
                }

                -- Add the base sources
                for _, source in ipairs(base_sources) do
                    table.insert(sources, source)
                end

                return cmp.config.sources(
                    sources,
                    {
                        { name = 'buffer' },
                        { name = 'calc' },
                        { name = 'emoji' },
                    }
                )
            end)(),
            formatting = {
                format = function(entry, vim_item)
                    -- Set a name for each source
                    vim_item.menu = ({
                        copilot = "[CP]",
                        supermaven = "[SM]",
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snippet]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                        nvim_lua = "[Lua]",
                        calc = "[Calc]",
                        emoji = "[Emoji]",
                    })[entry.source.name]
                    return vim_item
                end
            },
        })

        -- Set configuration for specific filetype.
        cmp.setup.filetype('gitcommit', {
            sources = cmp.config.sources({
                { name = 'git' },
            }, {
                { name = 'buffer' },
            })
        })

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
        cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = 'path' }
            }, {
                { name = 'cmdline' }
            })
        })

        -- Setup lspconfig.
        local format_group = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            pattern = { "*.go", "*.rs", "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx" },
            callback = function() vim.lsp.buf.format() end,
        })

        -- Enable inlay hints if supported
        if vim.lsp.inlay_hint then
            vim.keymap.set("n", "<leader>ih", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, { desc = "Toggle Inlay Hints" })
        end

        vim.diagnostic.config({
            virtual_text = {
                prefix = '●', -- Could be '■', '▎', 'x'
                source = "if_many",
            },
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Change diagnostic symbols in the sign column
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
    end
}
