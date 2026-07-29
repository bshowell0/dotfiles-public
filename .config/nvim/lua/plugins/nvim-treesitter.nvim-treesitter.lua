return {
   "nvim-treesitter/nvim-treesitter",
   build = ":TSUpdate",
   config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter")

      -- configure treesitter
      treesitter.setup({ -- enable syntax highlighting
         highlight = {
            enable = true,
            disable = { "latex" },
            additional_vim_regex_highlighting = false,
         },
         -- enable indentation
         indent = { enable = true },
         -- ensure these language parsers are installed
         ensure_installed = {
             "agda",
             "c",
             "cpp",
             "css",
             "csv",
             "diff",
             "dockerfile",
             "fish",
             "git_config",
             "gitcommit",
             "gitignore",
             "html",
             "java",
             "javascript",
             "json",
             "kotlin",
             "latex",
             "lua",
             "markdown",
             "markdown_inline",
             "python",
             "racket",
             "sql",
             "tmux",
             "typescript",
             "xml"
         },
         incremental_selection = {
           enable=true,
           keymaps = {
           init_selection = "<C-space>",
           node_incremental = "<C-space>",
           scope_incremental = false,
           node_decremental = "<bs>",
           },
        },
      })
   end,
}
