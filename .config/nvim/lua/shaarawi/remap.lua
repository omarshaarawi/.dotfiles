vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("n", "<leader>vwm", function()
    require("vim-with-me").StartVimWithMe()
end)
vim.keymap.set("n", "<leader>svwm", function()
    require("vim-with-me").StopVimWithMe()
end)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })


vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end)

-- File navigation
-- vim.keymap.set("n", "<leader>ff", require('telescope.builtin').find_files, {})

vim.keymap.set("n", "<leader>ws", "<cmd>split<CR>")  -- Split window horizontally
vim.keymap.set("n", "<leader>wv", "<cmd>vsplit<CR>") -- Split window vertically

-- Navigate between splits using Alt + {h,j,k,l}
vim.keymap.set("n", "<M-h>", "<C-w>h")
vim.keymap.set("n", "<M-j>", "<C-w>j")
vim.keymap.set("n", "<M-k>", "<C-w>k")
vim.keymap.set("n", "<M-l>", "<C-w>l")
--vim.keymap.set("n", "<leader>c", "<cmd>q<CR>")

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", "<cmd>bn<CR>")                -- Next buffer
vim.keymap.set("n", "<leader>bp", "<cmd>bp<CR>")                -- Previous buffer
vim.keymap.set("n", "<leader>bd", "<cmd>bd<CR>")                -- Delete buffer
vim.keymap.set("n", "<leader>bf", "<cmd>Telescope buffers<CR>") -- List buffers


vim.keymap.set("n", "<leader>tn", "<cmd>tabnew<CR>")   -- New tab
vim.keymap.set("n", "<leader>tc", "<cmd>tabclose<CR>") -- Close ta


vim.keymap.set("n", "<leader>gs", vim.cmd.Git) -- Git status


vim.keymap.set(
    "n",
    "<leader>ee",
    "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)
