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
        })

        -- Set up handlers for LSP servers
        local lspconfig = require('lspconfig')

        -- Set up Lua LSP
        lspconfig.lua_ls.setup({
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = "Lua 5.1" },
                    diagnostics = {
                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                    }
                }
            }
        })

        -- Set up Go LSP
        lspconfig.gopls.setup({
            capabilities = capabilities,
            cmd = { "gopls" },
            filetypes = { "go", "gomod", "gowork", "gotmpl" },
            settings = {
                gopls = {
                    completeUnimported = true,
                    usePlaceholders = true,
                    analyses = {
                        unusedparams = true,
                        shadow = true,
                        nilness = true,
                        unusedwrite = true,
                        useany = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                    semanticTokens = true,
                    codelenses = {
                        gc_details = true,
                        generate = true,
                        regenerate_cgo = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vendor = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
            root_dir = lspconfig.util.root_pattern("go.mod", ".git"),
        })

        -- Setup for other language servers (using the default handler)
        local servers = {
            "rust_analyzer", "html", "htmx", "tailwindcss", "zls", "templ",
            "pyright", "jsonls", "yamlls", "cssls", "bashls"
        }
        for _, server in ipairs(servers) do
            lspconfig[server].setup({
                capabilities = capabilities,
            })
        end

        -- Configure diagnostics with new virtual lines (Neovim 0.11 feature)
        vim.diagnostic.config({
            -- Virtual text is disabled since we're using virtual lines
            virtual_text = false,
            -- Use the new virtual_lines feature in Neovim 0.11
            virtual_lines = {
                -- Only show virtual lines for the current line by default
                -- Can be toggled with <leader>vl
                current_line = true,
            },
            float = {
                border = "rounded",
                source = "always",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Set up autocompletion
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
            -- Enable fuzzy completion (new in Neovim 0.11)
            completion = {
                completeopt = "menu,menuone,noinsert"
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

        -- Set up fuzzy completion in completeopt (Neovim 0.11 feature)
        vim.opt.completeopt:append("fuzzy")

        -- Go-specific configuration
        local go_group = vim.api.nvim_create_augroup('GoConfiguration', { clear = true })

        -- Set up format on save
        local format_group = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            pattern = { "*.go", "*.rs", "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx" },
            callback = function() vim.lsp.buf.format() end,
        })

        -- Enable inlay hints if supported
        if vim.lsp.inlay_hint then
            vim.keymap.set("n", "<leader>ih", function()
                local enabled = vim.lsp.inlay_hint.is_enabled()
                vim.lsp.inlay_hint.enable(not enabled)
            end, { desc = "Toggle Inlay Hints" })
        end

        -- Setup auto-completion from LSP (Neovim 0.11 feature)
        vim.api.nvim_create_autocmd('LspAttach', {
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                
                -- Enable inlay hints for any language that supports it
                if client and client:supports_method('textDocument/inlayHint') and vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                end
            end,
        })

        -- Set up Go-specific keymappings on LSP attach for Go files
        vim.api.nvim_create_autocmd('LspAttach', {
            group = go_group,
            callback = function(ev)
                -- Check if the attached buffer is a Go file and the client is gopls
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client or client.name ~= "gopls" then return end

                local bufnr = ev.buf
                local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
                if filetype ~= 'go' then return end

                local opts = { buffer = bufnr, silent = true }

                -- Go-specific keymappings
                vim.keymap.set('n', '<leader>gfs', function()
                    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } } })
                end, vim.tbl_extend('force', opts, { desc = 'Organize Imports' }))

                vim.keymap.set('n', '<leader>gt', function()
                    vim.cmd('split | terminal go test ./...')
                end, vim.tbl_extend('force', opts, { desc = 'Run Go tests' }))

                vim.keymap.set('n', '<leader>gtf', function()
                    vim.cmd('split | terminal go test -v ' .. vim.fn.expand('%:p:h'))
                end, vim.tbl_extend('force', opts, { desc = 'Run Go tests in current file dir' }))

                vim.keymap.set('n', '<leader>gr', function()
                    vim.cmd('split | terminal go run .')
                end, vim.tbl_extend('force', opts, { desc = 'Run Go program' }))

                -- Toggle inlay hints for Go files
                if vim.lsp.inlay_hint then
                    -- Enable inlay hints by default for Go files
                    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
                end
            end,
        })

        -- Add keybindings to toggle diagnostic display
        vim.keymap.set("n", "<leader>vl", function()
            local config = vim.diagnostic.config()
            local current_line_only = config.virtual_lines and config.virtual_lines.current_line == true

            vim.diagnostic.config({
                virtual_lines = {
                    current_line = not current_line_only
                }
            })

            vim.notify(
                "Virtual lines: " .. (not current_line_only and "current line only" or "all lines"),
                vim.log.levels.INFO
            )
        end, { desc = "Toggle diagnostic virtual lines" })

        -- Keybinding to switch between virtual_text and virtual_lines
        vim.keymap.set("n", "<leader>vt", function()
            local config = vim.diagnostic.config()
            local using_virtual_lines = config.virtual_lines ~= nil

            if using_virtual_lines then
                vim.diagnostic.config({
                    virtual_lines = nil,
                    virtual_text = {
                        prefix = '●',
                        source = "if_many",
                    }
                })
                vim.notify("Using virtual text for diagnostics", vim.log.levels.INFO)
            else
                vim.diagnostic.config({
                    virtual_text = false,
                    virtual_lines = {
                        current_line = true
                    }
                })
                vim.notify("Using virtual lines for diagnostics", vim.log.levels.INFO)
            end
        end, { desc = "Toggle between virtual text and virtual lines" })

        -- Change diagnostic symbols in the sign column
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end

        -- Add rounded borders to hover windows (since the global handler override no longer works in 0.11)
        vim.o.winborder = "rounded"
    end
}
