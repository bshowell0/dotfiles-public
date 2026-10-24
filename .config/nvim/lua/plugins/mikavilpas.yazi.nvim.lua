return {
    "mikavilpas/yazi.nvim",
    version = "*",
    -- VeryLazy, not just `keys`, so the plugin is loaded in time to catch `nvim <dir>`
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
        { "<leader>e", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Open yazi at current file" },
        { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Open yazi in nvim's cwd" },
        { "<leader><C-e>", "<cmd>Yazi toggle<cr>", desc = "Resume last yazi session" },
    },
    opts = {
        -- yazi fully replaces netrw as the file explorer
        open_for_directories = true,
        keymaps = {
            show_help = "<f1>",
        },
    },
    init = function()
        vim.g.loaded_netrwPlugin = 1
    end,
}
