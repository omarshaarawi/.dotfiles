return {
    -- Use nvim-cmp as the main plugin
    "hrsh7th/nvim-cmp",
    -- Using Neovim 0.11's built-in LSP APIs, only need cmp-related plugins
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        { "L3MON4D3/LuaSnip", build = "make install_jsregexp" },
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
        "hrsh7th/cmp-nvim-lua", -- Add Lua API completion
        "hrsh7th/cmp-calc",     -- Add calculator completion
        "hrsh7th/cmp-emoji",    -- Add emoji completion
        -- Mason for server installation
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim", -- Still useful for server installation
    },

    config = function()
        -- ==========================================
        -- 1. Set up LSP servers using Neovim 0.11 APIs
        -- ==========================================

        -- Define the LSP servers we want to use
        local servers = {
            'lua_ls',
            'rust_analyzer',
            'gopls',
            'html',
            "svelte",
            'tailwindcss',
            'zls',
            'templ',
            'pyright',
            'jsonls',
            'yamlls',
            'cssls',
            'bashls',
            'ts_ls',

        }

        -- Set up Mason first (server installer)
        require("mason").setup()

        -- Tell Mason which servers to install
        require("mason-lspconfig").setup({
            ensure_installed = servers,
        })

        -- Set up progress UI
        require("fidget").setup({})

        -- Get default capabilities
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_nvim_lsp.default_capabilities()
        )

        -- Set default config for all servers
        vim.lsp.config('*', {
            capabilities = capabilities,
            flags = {
                debounce_text_changes = 150,
            },
        })

        -- Enable all configured servers
        vim.lsp.enable(servers)

        -- Configure diagnostics with virtual lines (new in Neovim 0.11)
        vim.diagnostic.config({
            virtual_text = false,
            virtual_lines = {
                current_line = true,
            },
            float = {
                border = "rounded",
                source = "always",
            },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN] = " ",
                    [vim.diagnostic.severity.HINT] = " ",
                    [vim.diagnostic.severity.INFO] = " ",
                },
                numhl = {
                    [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                    [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                    [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                    [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                },
                texthl = {
                    [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
                    [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
                    [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
                    [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
                },
            },
            underline = true,
            update_in_insert = false,
            severity_sort = true,
        })

        -- Add rounded borders to hover windows
        vim.o.winborder = "rounded"

        -- ==========================================
        -- 2. Set up LSP keymaps
        -- ==========================================
        -- General LSP keymappings
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to Definition' })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Go to References' })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to Implementation' })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover Documentation' })
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename Symbol' })
        vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code Action' })
        vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, { desc = 'Type Definition' })
        vim.keymap.set('n', '<leader>ds', vim.lsp.buf.document_symbol, { desc = 'Document Symbols' })
        vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, { desc = 'Workspace Symbols' })
        vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, { desc = 'Previous Diagnostic' })
        vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, { desc = 'Next Diagnostic' })
        vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Diagnostics List' })
        vim.keymap.set('n', '<leader>df', vim.lsp.buf.format, { desc = 'Format Document' })

        -- Enable inlay hints if supported
        if vim.lsp.inlay_hint then
            vim.keymap.set("n", "<leader>ih", function()
                local enabled = vim.lsp.inlay_hint.is_enabled()
                vim.lsp.inlay_hint.enable(not enabled)
            end, { desc = "Toggle Inlay Hints" })
        end

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

        -- ==========================================
        -- 3. Set up format on save
        -- ==========================================
        local format_group = vim.api.nvim_create_augroup("LspFormatting", {})
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = format_group,
            pattern = { "*.go", "*.rs", "*.lua", "*.js", "*.ts", "*.jsx", "*.tsx" },
            callback = function() vim.lsp.buf.format() end,
        })

        -- ==========================================
        -- 4. Set up LSP-specific features on attach
        -- ==========================================
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('LspAttachConfiguration', { clear = true }),
            callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then return end

                -- Enable inlay hints for this buffer if supported
                if client:supports_method('textDocument/inlayHint') and vim.lsp.inlay_hint then
                    vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
                end

                -- Set omnifunc for basic completion
                vim.api.nvim_buf_set_option(ev.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Notify when LSP attaches (helpful for debugging)
                vim.notify("LSP " .. client.name .. " attached to buffer " .. ev.buf, vim.log.levels.INFO)
            end,
        })

        -- Set up Go-specific keymappings on LSP attach for Go files
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('GoConfiguration', { clear = true }),
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
            end,
        })

        -- ==========================================
        -- 5. Set up completion with nvim-cmp
        -- ==========================================
        local cmp = require('cmp')
        local luasnip = require("luasnip")

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
            -- Enable completion options
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

        -- Use buffer source for `/` and `?`
        cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = 'buffer' }
            }
        })

        -- Use cmdline & path source for ':'
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
    end
}
