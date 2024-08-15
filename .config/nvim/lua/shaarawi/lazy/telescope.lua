return {
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'kdheepak/lazygit.nvim',
        'nvim-telescope/telescope-ui-select.nvim', {

        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
            return vim.fn.executable 'make' == 1
        end
    }
    },

    config = function()
        local telescope = require('telescope')
        local builtin = require("telescope.builtin")
        local themes = require("telescope.themes")
        local trouble = require("trouble.sources.telescope")

        telescope.setup({

            pickers = {
                find_files = {
                    find_command = { 'rg', '--files', '--hidden', '--sortr=modified', '--glob', '!.git' },
                },
                git_files = {
                    find_command = { 'rg', '--files', '--hidden', '--sortr=modified', '--glob', '!.git' },
                },
            },
            defaults = {
                mappings = {
                    i = { ["<C-t>"] = trouble.open },
                    n = { ["<C-t>"] = trouble.open },
                },
            },
            extensions = {
                ["ui-select"] = { themes.get_dropdown {} },
            }
        })

        telescope.load_extension('lazygit')
        telescope.load_extension('ui-select')
        vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set('n', '<leader>ps', function()
            builtin.grep_string({ search = vim.fn.input("Grep > ") });
        end)
        vim.keymap.set('n', '<leader>vh', builtin.help_tags, {})
        vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
        vim.keymap.set('n', '<leader>pws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>pWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
    end
}
