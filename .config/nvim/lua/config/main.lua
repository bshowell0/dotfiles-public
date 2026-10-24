do
  -- Prefer Nvim's bundled Lua parser over stale plugin-installed parsers.
  local bundled_lua_parser = vim.env.VIMRUNTIME and (vim.env.VIMRUNTIME .. "/parser/lua.so")
  if bundled_lua_parser and vim.uv.fs_stat(bundled_lua_parser) then
    vim.treesitter.language.add("lua", { path = bundled_lua_parser })
  end
end

-- theme & transparency
-- "mine" is the local scheme in colors/mine.lua, built from the same palette as
-- ~/.config/fish/themes/mine.theme. It handles transparency itself, so the
-- Normal/NormalNC/EndOfBuffer overrides that used to live here are gone.
-- See the comment block at the top of colors/mine.lua for every tunable.
-- Any role accepts any palette name: cyan blue sky | pale rose hot neon |
-- purple lilac violet peri | mint amber gold orange green olive red | fg dim mute
vim.g.mine = {
  variables = "sky", -- + "params" | "plain" to narrow or disable
  builtins = "lilac", -- self / this
  paths = "cyan", -- path and URL strings, links, directories
  functions = "orange",
  keywords = "rose", -- def / class / try / return
  imports = "hot", -- import / from, decorators, macros
  numbers = "amber",
  types = "purple",
  operators = "fg",
  properties = "blue",
  delimiters = "dim",
  brackets = "dim",
  visual = "muted", -- "muted" | "amber"
  picker = "muted", -- selected row: "muted" | "amber"
  menu = "dim", -- completion menu text: "dim" | "fg"
  search = "mint", -- current match: "mint" | "magenta" | "amber"
  italic = true,
  transparent = true,
  terminal = true,
}
vim.cmd.colorscheme("mine")

-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = false
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.breakindentopt = "shift:1"
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { trail = "•", tab = "▸ " }
vim.opt.sidescrolloff = 9

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = ""
vim.opt.showmatch = true
vim.opt.matchtime = 2
vim.opt.cmdheight = 1
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.showmode = true
vim.opt.pumheight = 10
vim.opt.pumblend = 10
vim.opt.winblend = 0
vim.opt.conceallevel = 0
vim.opt.concealcursor = ""
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 300

-- File handling
vim.opt.backup = false
vim.opt.writebackup = true
vim.opt.swapfile = true
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false

-- Behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.backspace = "indent,eol,start"
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "inclusive"
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- Folding settings
vim.opt.foldmethod = "expr"
-- vim.wo.vim.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Normal mode mappings

vim.keymap.set("n", "<leader>/", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "Delete without yanking" })

-- Don't yank with x
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 'X', '"_X', { noremap = true })
vim.keymap.set('n', '<leader>x', '"xx', { noremap = true })
vim.keymap.set('n', '<leader>X', '"xX', { noremap = true })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { desc = "Delete buffer" })
vim.keymap.set("n", "<leader>bc", ":enew<CR>", { desc = "Create new empty buffer" })
vim.keymap.set("n", "<leader>bl", ":ls<CR>", { desc = "List buffers" })

-- Splitting & Resizing
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Better window navigation
vim.keymap.set({ "n", "x" }, "<C-h>", "<C-w>h", { desc = "Move to left window" })
vim.keymap.set({ "n", "x" }, "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
vim.keymap.set({ "n", "x" }, "<C-k>", "<C-w>k", { desc = "Move to top window" })
vim.keymap.set({ "n", "x" }, "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Same, from inside a terminal (Claude, yazi): leave terminal mode first.
-- Note this takes these keys away from the program running in the terminal,
-- e.g. <C-l> no longer clears the screen in a shell.
vim.keymap.set("t", "<C-h>", "<C-\\><C-n><C-w>h", { desc = "Move to left window" })
vim.keymap.set("t", "<C-j>", "<C-\\><C-n><C-w>j", { desc = "Move to bottom window" })
vim.keymap.set("t", "<C-k>", "<C-\\><C-n><C-w>k", { desc = "Move to top window" })
vim.keymap.set("t", "<C-l>", "<C-\\><C-n><C-w>l", { desc = "Move to right window" })

-- Move lines up/down
vim.keymap.set("n", "<A-j>", ":m .+1<CR>", { desc = "Move line down" })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>", { desc = "Move line up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv", { desc = "Move selection down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv", { desc = "Move selection up" })

-- Open blank line below / above without entering insert mode
vim.keymap.set("n", "<leader>o", ":put _<CR>", { silent = true })
vim.keymap.set("n", "<leader>O", ":put! _<CR>", { silent = true })

-- Better indenting in visual mode
vim.keymap.set("v", "<Tab>", ">gv", { desc = "Indent and reselect" })
vim.keymap.set("v", "<S-Tab>", "<gv", { desc = "Unindent and reselect" })

-- Quick file navigation
-- <leader>e opens yazi (see plugins/mikavilpas.yazi.nvim.lua), which disables netrw
-- <leader>f* are Telescope pickers (see plugins/nvim-telescope.telescope.nvim.lua)

-- Quick config editing
vim.keymap.set("n", "<leader>rc", ":e ~/.config/nvim/lua/config/main.lua<CR>", { desc = "Edit config" })

-- Custom line-wise movement
vim.opt.smoothscroll = true

-- custom soft scrolloff
vim.opt.scrolloff = 0
local SOFT = 9

local CY = vim.api.nvim_replace_termcodes("<C-y>", true, false, true)
local CE = vim.api.nvim_replace_termcodes("<C-e>", true, false, true)

local function soft_scrolloff()
  local h = vim.api.nvim_win_get_height(0)
  local row = vim.fn.winline() -- screen row (wrap-aware), 1..h

  local top_min = SOFT + 1
  local bot_max = h - SOFT
  if bot_max < top_min then
    return -- window too small for that margin
  end

  if row < top_min then
    local n = top_min - row
    vim.api.nvim_feedkeys(string.rep(CY, n), "nx", false)
  elseif row > bot_max then
    local n = row - bot_max
    vim.api.nvim_feedkeys(string.rep(CE, n), "nx", false)
  end
end

-- No globals: expose as a user command instead of _G
vim.api.nvim_create_user_command("SoftScrolloff", soft_scrolloff, {})

-- j/k: screen-lines when no count; real lines when count
-- (No operator-pending mode, so dj stays real-lines)
vim.keymap.set({ "n", "x" }, "j", function()
  if vim.v.count == 0 then
    return "gj<Cmd>SoftScrolloff<CR>"
  end
  return "j"
end, { expr = true, silent = true })

vim.keymap.set({ "n", "x" }, "k", function()
  if vim.v.count == 0 then
    return "gk<Cmd>SoftScrolloff<CR>"
  end
  return "k"
end, { expr = true, silent = true })

-- optional: keep “gj/gk are real-line” preference
vim.keymap.set({ "n", "x" }, "gj", "j", { silent = true })
vim.keymap.set({ "n", "x" }, "gk", "k", { silent = true })



-- -- Move by wrapped (screen) lines unless count is provided
-- -- This is swapping the behavior of j/k and gj/gk
-- vim.keymap.set('n', 'j', function()
--   return vim.v.count == 0 and 'gj' or 'j'
-- end, { expr = true, silent = true })
-- 
-- vim.keymap.set('n', 'k', function()
--   return vim.v.count == 0 and 'gk' or 'k'
-- end, { expr = true, silent = true })
-- 
-- vim.keymap.set('v', 'j', function()
--   return vim.v.count == 0 and 'gj' or 'j'
-- end, { expr = true, silent = true })
-- 
-- vim.keymap.set('v', 'k', function()
--   return vim.v.count == 0 and 'gk' or 'k'
-- end, { expr = true, silent = true })
-- 
-- -- Keep access to real-line motions on gj/gk
-- vim.keymap.set({ 'n', 'v' }, 'gj', 'j', { silent = true })
-- vim.keymap.set({ 'n', 'v' }, 'gk', 'k', { silent = true })

-- ============================================================================
-- USEFUL FUNCTIONS
-- ============================================================================

-- Automatically start treesitter
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    if vim.tbl_contains({ "tex", "plaintex", "latex" }, vim.bo[args.buf].filetype) then
      return
    end

    pcall(vim.treesitter.start, args.buf)
  end,
})

-- Copy Full File-Path
vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)


local augroup = vim.api.nvim_create_augroup("UserConfig", {})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})


-- Set conceallevel for latex files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "latex" },
  callback = function()
    vim.opt_local.conceallevel = 2
    vim.opt_local.concealcursor = ""
  end,
})


-- Don't show trailing whitespace while in insert mode
local grp = vim.api.nvim_create_augroup("ToggleListWhileTyping", { clear = true })

vim.api.nvim_create_autocmd("InsertEnter", {
  group = grp,
  callback = function()
    vim.opt_local.list = false
  end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
  group = grp,
  callback = function()
    vim.opt_local.list = true
  end,
})
