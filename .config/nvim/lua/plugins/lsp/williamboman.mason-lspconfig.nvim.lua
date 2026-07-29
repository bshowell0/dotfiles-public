return {
    "mason-org/mason-lspconfig.nvim",
    opts = {
        ensure_installed = {
            "basedpyright",
            "bashls",
            "clangd",
            "kotlin_language_server",
            "lua_ls",
            "ruff",
            "vimls",
        },
    },
    dependencies = {
        {
            "mason-org/mason.nvim",
            opts = {
                ui = {
                    icons = {
                        package_installed = "✓",
                        package_pending = "➜",
                        package_uninstalled = "✗",
                    },
                },
            },
        },
        "neovim/nvim-lspconfig",
    },
}

