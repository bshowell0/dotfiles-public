return {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
        terminal = {
            provider = "snacks",
            split_side = "right",
            split_width_percentage = 0.65,
        },
        diff_opts = {
            layout = "vertical",
        },
    },
    cmd = {
        "ClaudeCode",
        "ClaudeCodeFocus",
        "ClaudeCodeSelectModel",
        "ClaudeCodeAdd",
        "ClaudeCodeSend",
        "ClaudeCodeTreeAdd",
        "ClaudeCodeStatus",
        "ClaudeCodeDiffAccept",
        "ClaudeCodeDiffDeny",
    },
    keys = {
        { "<leader>c", nil, desc = "Claude Code" },
        { "<leader>cc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
        { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
        { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
        { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
        { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
        { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
        { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
        { "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Add file", ft = { "netrw", "oil" } },
        { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
        { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
}
