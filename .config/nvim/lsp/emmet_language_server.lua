return {
    cmd = { "emmet-language-server", "--stdio" },
    filetypes = {
        "html", "css", "scss", "sass", "less",
        "svelte", "vue", "astro",
        "javascriptreact", "typescriptreact",
    },
    root_markers = { "package.json", ".git" },
    init_options = {
        showAbbreviationSuggestions = true,
        showExpandedAbbreviation = "always",
    },
}
