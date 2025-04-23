return {
    cmd = { "zls" },
    filetypes = { "zig" },
    root_markers = { "build.zig", ".git" },
    settings = {
        zig = {
            warn_style = true,
            enable_argument_placeholders = false,
            -- highlzyight_global_var_declarations = true,
            -- enable_snippets = true,
            -- enable_autofix = true,
            -- enable_inlay_hints = true,
            -- inlay_hints_show_builtin = true,
            -- inlay_hints_exclude_single_argument = true,
            -- inlay_hints_hide_redundant_param_names = true,
            -- inlay_hints_hide_redundant_param_names_last_token = true,
            -- skip_std_references = false,
            -- record_session = true,
        },
    },
}
