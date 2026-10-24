-- vim.lsp.enable("bashls")
-- vim.lsp.enable("clangd")
-- vim.lsp.enable("kotlin_language_server")
-- vim.lsp.enable("lua_ls")
-- vim.lsp.enable("ruff")
-- vim.lsp.enable("vimls")
-- vim.lsp.enable("basedpyright")
local keymap = vim.keymap -- for conciseness
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf, silent = true }

    -- set keybinds
    opts.desc = "Show LSP references"
    keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

    opts.desc = "Go to declaration"
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

    opts.desc = "Show LSP definition"
    keymap.set("n", "gd", vim.lsp.buf.definition, opts) -- show lsp definition

    opts.desc = "Show LSP implementations"
    keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

    opts.desc = "Show LSP type definitions"
    keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

    opts.desc = "See available code actions"
    keymap.set({ "n", "v" }, "<leader>.", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

    opts.desc = "Smart rename"
    keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

    opts.desc = "Show buffer diagnostics"
    keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

    opts.desc = "Show line diagnostics"
    keymap.set("n", "gl", vim.diagnostic.open_float, opts) -- show diagnostics for line

    opts.desc = "Go to previous diagnostic"
    keymap.set("n", "[d", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end, opts) -- jump to previous diagnostic in buffer
    --
    opts.desc = "Go to next diagnostic"
    keymap.set("n", "]d", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end, opts) -- jump to next diagnostic in buffer

    opts.desc = "Show documentation for what is under cursor"
    keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

    opts.desc = "Restart LSP"
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
  end,
})

local severity = vim.diagnostic.severity

vim.diagnostic.config({
  signs = {
    text = {
      [severity.ERROR] = " ",
      [severity.WARN] = " ",
      [severity.HINT] = "󱍊 ",
      [severity.INFO] = " ",
    },
  },
})

-- DISABLED: auto-show line diagnostics in a hover float, no keypress needed.
-- Uncomment the block below to enable; it removes the need to press `gl`.
-- Fires once the cursor sits still for 'updatetime' (300ms, set in main.lua), and shows
-- only the diagnostics under the cursor. `focus = false` means it never steals the
-- cursor, and the float self-closes on the next cursor move or on entering insert mode.
-- Note: `gl` stays useful either way, for when you don't want to wait out the idle delay.
-- vim.api.nvim_create_autocmd("CursorHold", {
--   group = vim.api.nvim_create_augroup("UserDiagnosticFloat", { clear = true }),
--   callback = function()
--     vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
--   end,
-- })
