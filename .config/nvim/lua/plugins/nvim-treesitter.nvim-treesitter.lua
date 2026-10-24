-- The pinned main branch manages parsers through install()/update().
-- The legacy highlight, indent, ensure_installed, and incremental_selection
-- options below do not enable those features or install parsers on this branch.
--
-- Parsers installed separately live in Neovim's machine-local data directory;
-- their presence cannot be inferred from this configuration or the lockfile.
-- The FileType autocmd in config/main.lua starts highlighting when a parser is
-- available. colors/mine.lua also styles legacy syntax for files without one.
--
-- TODO: migrate the language list to require("nvim-treesitter").install(), use
-- the main-branch indentexpr API, and replace the old incremental-selection maps.
return {
   "nvim-treesitter/nvim-treesitter",
   build = ":TSUpdate",
   config = function()
      -- import nvim-treesitter plugin
      local treesitter = require("nvim-treesitter")

      -- Legacy configuration retained pending the main-branch migration above.
      treesitter.setup({ -- These legacy options are inactive on main.
         highlight = {
            enable = true,
            disable = { "latex" },
            additional_vim_regex_highlighting = false,
         },
         -- Legacy indentation options.
         indent = { enable = true },
         -- Desired parser list; this option does not install them on main.
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
