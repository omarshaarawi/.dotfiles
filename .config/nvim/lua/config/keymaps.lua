-- Neovim Keymaps

-- Note: Leader is set in settings.lua

-- Visual mode: move lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep cursor centered during navigation
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines, keep cursor position" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, centered" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result, centered" })

-- Clipboard operations
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking deleted text" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Escape alternative
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Alternative escape" })

-- Disable ex mode
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable ex mode" })

-- LSP format
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format buffer" })

-- Quickfix navigation (Note: <C-k> is used by LSP for signature help in LSP buffers)
vim.keymap.set("n", "<leader>qn", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
vim.keymap.set("n", "<leader>qp", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })

-- Location list navigation
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location item" })

-- Search and replace word under cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Search & replace word under cursor" })

-- Make file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- Reload config
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Source current file" })

-- Window management
vim.keymap.set("n", "<leader>ws", "<cmd>split<CR>", { desc = "Split horizontally" })
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "Split vertically" })

-- Navigate between splits
vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Navigate to left window" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Navigate to window below" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Navigate to window above" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Navigate to right window" })

-- Resize windows
vim.keymap.set("n", "=", [[<cmd>vertical resize +5<cr>]], { desc = "Increase window width" })
vim.keymap.set("n", "+", [[<cmd>horizontal resize +2<cr>]], { desc = "Increase window height" })
vim.keymap.set("n", "_", [[<cmd>horizontal resize -2<cr>]], { desc = "Decrease window height" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>", { desc = "Delete buffer" })

-- Tab management
vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "Close tab" })

-- Git (fugitive)
vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Git status" })

-- Fugitive buffer-specific keymaps
local Shaarawi_Fugitive = vim.api.nvim_create_augroup("Shaarawi_Fugitive", {})
vim.api.nvim_create_autocmd("BufWinEnter", {
    group = Shaarawi_Fugitive,
    pattern = "*",
    callback = function()
        if vim.bo.ft ~= "fugitive" then
            return
        end

        local bufnr = vim.api.nvim_get_current_buf()
        local opts = {buffer = bufnr, remap = false}
        vim.keymap.set("n", "<leader>p", function()
            vim.cmd.Git('push')
        end, vim.tbl_extend("force", opts, { desc = "Git push" }))

        vim.keymap.set("n", "<leader>P", function()
            vim.cmd.Git({'pull', '--rebase'})
        end, vim.tbl_extend("force", opts, { desc = "Git pull --rebase" }))

        vim.keymap.set("n", "<leader>t", ":Git push -u origin ", vim.tbl_extend("force", opts, { desc = "Git push -u origin" }))
    end,
})

-- Git merge conflict resolution
vim.keymap.set("n", "gu", "<cmd>diffget //2<CR>", { desc = "Get left side (ours) in merge" })
vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", { desc = "Get right side (theirs) in merge" })

-- Help
vim.keymap.set("n", "<leader>hf", ":help ", { desc = "Open help" })

-- Diagnostic keymaps (LSP)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })
