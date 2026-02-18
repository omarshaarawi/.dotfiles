return {
    cmd = { vim.fn.expand("~/.local/share/elixir-ls/language_server.sh") },
    filetypes = { "elixir", "eelixir", "heex", "surface" },
    root_markers = { "mix.exs" },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = fname })
        local child_or_root_path, maybe_umbrella_path = unpack(matches)
        local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

        on_dir(root_dir)
    end,
}
