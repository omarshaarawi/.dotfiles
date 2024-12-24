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
            })
        end,
    },
}
