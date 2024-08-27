return { {
    'stevearc/oil.nvim',
    config = function()
        require("oil").setup({
            delete_to_trash = true,
            view_options = {
                show_hidden = true,
            },

            keymaps = {
                ["<C-h>"] = false,
                ["<M-h>"] = "actions.select_split",
            },

        })
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
        vim.keymap.set("n", "<space>-", require("oil").toggle_float)
    end
},
}
