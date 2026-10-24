return {
    "nvim-telescope/telescope.nvim",
    -- also load on :Telescope, since config/lsp.lua calls it directly (gR, gi, gt, <leader>D)
    cmd = "Telescope",
    dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
        { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
        { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
    },
    config = function()
        local telescope = require("telescope")
        telescope.setup({})
        telescope.load_extension("fzf")
    end,
}
