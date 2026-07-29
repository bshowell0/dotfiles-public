return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
        ensure_installed = {
            "stylua", -- lua formatter
            "shfmt", -- shell formatter
        },
    },
    dependencies = {
        "mason-org/mason.nvim",
    },
}

