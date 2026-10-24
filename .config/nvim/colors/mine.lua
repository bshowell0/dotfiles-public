-- mine.lua -- a Neovim colorscheme derived from ~/.config/fish/themes/mine.theme
--
-- Every colour is lifted verbatim from the fish theme (and its
-- zsh-syntax-highlighting port in ~/.zshrc), so the editor and the shell share
-- one palette. What differs is the assignment: a shell command line is short and
-- mostly paths, so fish can afford three near-identical blues for keyword, param
-- and cwd. A screen of code cannot -- they stop reading as different colours.
--
-- So the blues were split up by how often each role appears, rather than being
-- three interchangeable shades: #59C2FF on variables (dense), #00afff on object
-- members (frequent), #39BAE6 underlined on paths and URLs. The roles that used
-- to compete for a blue moved onto colours freed up elsewhere: functions took
-- orange, types took the purple functions vacated.
--
-- Three colours come from the prompt rather than the syntax theme: the path
-- pinks in ~/.config/zsh/p10k.zsh (POWERLEVEL9K_DIR_*_FOREGROUND), ported from
-- the tide fish prompt -- #ff99cc pale, #ff79c6 rose, #ff4da6 hot. Keywords use
-- rose and the `import` family uses hot, so the two stay distinguishable while
-- reading as related. fish_color_redirection's neon #ff5fff is retired from
-- syntax entirely; it survives only as ANSI magenta for :terminal buffers.
--
-- Tunables live in `vim.g.mine`, set BEFORE `:colorscheme mine`.
-- Every role below takes any name from the `named` table further down, so a
-- colour can be moved anywhere without editing highlight groups. The comments
-- list sensible candidates, not the only legal values.
--
--   vim.g.mine = {
--     variables   = "sky",     -- + "params" | "plain" to narrow or disable
--     builtins    = "lilac",   -- self / this
--     paths       = "cyan",    -- path and URL strings, links, directories
--     functions   = "orange",
--     keywords    = "rose",    -- def / class / try / return
--     imports     = "hot",     -- import / from, decorators, macros
--     numbers     = "amber",
--     types       = "purple",
--     operators   = "fg",
--     properties  = "blue",
--     delimiters  = "dim",
--     brackets    = "dim",
--     visual      = "muted",   -- "muted" | "amber"
--     picker      = "muted",   -- selected row: "muted" | "amber"
--     menu        = "dim",     -- completion menu text: "dim" | "fg"
--     search      = "mint",    -- current match: "mint" | "magenta" | "amber"
--     transparent = true,      -- let the ghostty background/blur show through
--     italic      = true,      -- italic comments (comments only)
--     terminal    = true,      -- restyle :terminal ANSI colours to match
--   }

local o = vim.tbl_extend("force", {
  variables = "sky",
  builtins = "lilac",
  paths = "cyan",
  functions = "orange",
  keywords = "rose",
  imports = "hot",
  numbers = "amber",
  types = "purple",
  operators = "fg",
  properties = "blue",
  delimiters = "dim",
  brackets = "dim",
  visual = "muted",
  picker = "muted",
  menu = "dim",
  search = "mint",
  transparent = true,
  italic = true,
  terminal = true,
}, vim.g.mine or {})

vim.cmd("highlight clear")
vim.g.colors_name = "mine"
vim.o.background = "dark"
vim.o.termguicolors = true

-- ---------------------------------------------------------------- palette --

local p = {
  -- straight from mine.theme
  fg = "#B3B1AD", -- fish_color_normal / option
  dim = "#878787", -- fish_color_autosuggestion
  purple = "#af87ff", -- fish_color_command
  cyan = "#39BAE6", -- fish_color_keyword
  blue = "#00afff", -- fish_color_param
  sky = "#59C2FF", -- fish_color_cwd
  green = "#66dd44", -- fish_color_quote
  olive = "#b4bd68", -- fish_color_comment
  amber = "#E6B450", -- fish_color_operator / globbing / search bg
  gold = "#B3A06D", -- fish_pager_color_description
  orange = "#ff8700", -- fish_color_end
  pink = "#ff5fff", -- fish_color_redirection; now only ANSI magenta
  mint = "#95E6CB", -- fish_color_escape
  red = "#FF3333", -- fish_color_error

  -- the prompt's path pinks, from ~/.config/zsh/p10k.zsh
  rose_pale = "#ff99cc", -- POWERLEVEL9K_DIR_SHORTENED_FOREGROUND
  rose = "#ff79c6", -- POWERLEVEL9K_DIR_FOREGROUND
  rose_hot = "#ff4da6", -- POWERLEVEL9K_DIR_ANCHOR_FOREGROUND

  -- Purples that are in neither config, added so `self`/`this` can differ from
  -- the type purple without leaving its family. violet and peri are xterm-256
  -- entries, the same well #af87ff, #00afff, #ff8700 and #878787 came from;
  -- lilac is xterm 183 (#d7afff) pulled a quarter of the way back toward the
  -- type purple, so it reads as a lighter relative of the class colour rather
  -- than a separate hue.
  lilac = "#cda5ff", -- 75% #d7afff + 25% #af87ff
  violet = "#d787ff", -- xterm 177: sits between the type purple and rose
  peri = "#8787ff", -- xterm 105: leans blue

  -- ghostty's background, plus shades derived from it for editor chrome
  bg = "#1c1c20",
  bg_dark = "#141417", -- gutter / inactive splits
  bg_soft = "#232329", -- floats, pmenu, statusline
  bg_hard = "#2c2c34", -- cursorline
  mute = "#4e4e55", -- line numbers, whitespace, non-text

  -- amber wash, for rows that must read as selected without shouting
  sel = "#403729",
  sel_hi = "#4d4230", -- one step brighter, for the picker's active row
  -- diff washes
  diff_add = "#273925",
  diff_del = "#3e1f23",
  diff_chg = "#182f3d",
  diff_txt = "#14455e",

  none = "NONE",
}

-- ------------------------------------------------------------- variants ---

local bg = o.transparent and p.none or p.bg
local float_bg = o.transparent and p.none or p.bg_soft

-- One name table for every role, so any colour can be moved to any job.
local named = {
  fg = p.fg,
  dim = p.dim,
  mute = p.mute,
  cyan = p.cyan,
  blue = p.blue,
  sky = p.sky,
  pale = p.rose_pale,
  rose = p.rose,
  hot = p.rose_hot,
  neon = p.pink,
  purple = p.purple,
  lilac = p.lilac,
  violet = p.violet,
  peri = p.peri,
  mint = p.mint,
  amber = p.amber,
  gold = p.gold,
  orange = p.orange,
  green = p.green,
  olive = p.olive,
  red = p.red,
}

local function pick(key, fallback)
  return named[o[key]] or named[fallback]
end

local c_fn = pick("functions", "orange")
-- language keywords only; the `import` family is its own role below
local c_kw = pick("keywords", "rose")
-- import / from / #include, decorators, macros, preprocessor directives
local c_import = pick("imports", "hot")
local c_number = pick("numbers", "amber")
local c_type = pick("types", "purple")
local c_op = pick("operators", "fg")
local c_prop = pick("properties", "blue")
local c_delim = pick("delimiters", "dim")
local c_brkt = pick("brackets", "dim")
local c_builtin = pick("builtins", "lilac")
local c_path = pick("paths", "cyan")
local c_menu = o.menu == "fg" and p.fg or p.dim

-- "params" narrows the colour to declared parameters only; "plain" turns it off
local c_var = named[o.variables] or p.fg
local c_param = o.variables == "plain" and p.fg or (named[o.variables] or p.sky)

local visual_bg = o.visual == "amber" and p.amber or p.sel
local visual_fg = o.visual == "amber" and p.bg or p.none
local cur_search = ({ mint = p.mint, magenta = p.rose_hot, amber = p.amber })[o.search]
local it = o.italic

-- Selected row in Telescope / snacks / the completion menu. "amber" is the
-- literal fish_pager_color_selected_background; "muted" is the same wash used
-- for visual selections, which keeps the row's syntax colours legible.
local pick_bg = o.picker == "amber" and p.amber or p.sel_hi
local pick_fg = o.picker == "amber" and p.bg or p.none

local function hl(groups)
  for name, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, name, spec)
  end
end

-- ------------------------------------------------------------ editor UI ---

hl({
  Normal = { fg = p.fg, bg = bg },
  NormalNC = { fg = p.fg, bg = bg },
  NormalFloat = { fg = p.fg, bg = float_bg },
  FloatBorder = { fg = p.mute, bg = float_bg },
  FloatTitle = { fg = p.amber, bg = float_bg, bold = true },
  FloatFooter = { fg = p.gold, bg = float_bg },
  EndOfBuffer = { fg = p.mute, bg = bg },

  Cursor = { fg = p.bg, bg = p.fg },
  lCursor = { fg = p.bg, bg = p.fg },
  TermCursor = { fg = p.bg, bg = p.fg },
  CursorLine = { bg = p.bg_hard },
  CursorColumn = { bg = p.bg_hard },
  ColorColumn = { bg = p.bg_soft },

  LineNr = { fg = p.mute },
  LineNrAbove = { fg = p.mute },
  LineNrBelow = { fg = p.mute },
  CursorLineNr = { fg = p.amber, bold = true },
  CursorLineSign = { bg = p.none },
  CursorLineFold = { bg = p.none },
  SignColumn = { fg = p.mute, bg = bg },
  FoldColumn = { fg = p.mute, bg = bg },
  Folded = { fg = p.gold, bg = p.bg_soft },

  Visual = { bg = visual_bg, fg = visual_fg, bold = o.visual == "amber" },
  VisualNOS = { bg = visual_bg, fg = visual_fg },
  -- amber for every match, exactly like fish_color_search_match; the match the
  -- cursor is sitting on flips to the escape colour so `n` is easy to follow
  Search = { fg = p.bg, bg = p.amber },
  IncSearch = { fg = p.bg, bg = cur_search, bold = true },
  CurSearch = { fg = p.bg, bg = cur_search, bold = true },
  Substitute = { fg = p.bg, bg = p.orange },
  MatchParen = { fg = p.amber, bold = true, underline = true },

  StatusLine = { fg = p.fg, bg = p.bg_soft },
  StatusLineNC = { fg = p.mute, bg = p.bg_dark },
  WinBar = { fg = p.fg, bg = bg, bold = true },
  WinBarNC = { fg = p.mute, bg = bg },
  WinSeparator = { fg = "#888888", bg = bg }, -- matches ghostty split-divider-color
  VertSplit = { fg = "#888888", bg = bg },

  TabLine = { fg = p.dim, bg = p.bg_dark },
  TabLineSel = { fg = p.amber, bg = p.bg_soft, bold = true },
  TabLineFill = { bg = p.bg_dark },

  -- unselected entries sit back at #878787 so the highlighted one reads as the
  -- only live row; the selection returns to full foreground on the amber wash
  Pmenu = { fg = c_menu, bg = p.bg_soft },
  PmenuSel = { fg = p.fg, bg = pick_bg, bold = true },
  PmenuKind = { fg = c_menu, bg = p.bg_soft },
  PmenuKindSel = { fg = c_fn, bg = pick_bg },
  PmenuExtra = { fg = p.mute, bg = p.bg_soft },
  PmenuExtraSel = { fg = p.gold, bg = pick_bg },
  PmenuSbar = { bg = p.bg_soft },
  PmenuThumb = { bg = p.mute },
  PmenuMatch = { fg = p.rose, bg = p.bg_soft, bold = true },
  PmenuMatchSel = { fg = p.rose, bg = pick_bg, bold = true },
  WildMenu = { fg = pick_fg, bg = pick_bg, bold = true },
  QuickFixLine = { bg = p.sel, bold = true },

  ModeMsg = { fg = p.amber, bold = true },
  MoreMsg = { fg = p.mint },
  Question = { fg = p.mint },
  MsgArea = { fg = p.fg },
  MsgSeparator = { fg = p.mute, bg = p.bg_soft },
  ErrorMsg = { fg = p.red, bold = true },
  WarningMsg = { fg = p.amber },

  -- fish_color_cwd, still marking the thing you are operating inside of
  Directory = { fg = c_path },
  Title = { fg = p.amber, bold = true },
  Conceal = { fg = p.mute },
  NonText = { fg = p.mute },
  SpecialKey = { fg = p.mute },
  Whitespace = { fg = p.mute },

  DiffAdd = { bg = p.diff_add },
  DiffChange = { bg = p.diff_chg },
  DiffDelete = { fg = p.red, bg = p.diff_del },
  DiffText = { bg = p.diff_txt, bold = true },
  Added = { fg = p.green },
  Changed = { fg = p.blue },
  Removed = { fg = p.red },

  SpellBad = { sp = p.red, undercurl = true },
  SpellCap = { sp = p.amber, undercurl = true },
  SpellLocal = { sp = p.cyan, undercurl = true },
  SpellRare = { sp = p.rose_hot, undercurl = true },

  Underlined = { underline = true },
  Ignore = { fg = p.mute },
  Error = { fg = p.red },
  Todo = { fg = p.bg, bg = p.amber, bold = true },
  Debug = { fg = c_fn },
})

-- ------------------------------------------------- legacy :syntax groups ---
-- Still load-bearing: any filetype without an installed treesitter parser is
-- highlighted by the bundled regex syntax files, which only speak these names.

hl({
  Comment = { fg = p.olive, italic = it },

  Constant = { fg = c_number },
  String = { fg = p.green },
  Character = { fg = p.green },
  Number = { fg = c_number },
  Boolean = { fg = c_number },
  Float = { fg = c_number },

  Identifier = { fg = c_var },
  Function = { fg = c_fn },

  Statement = { fg = c_kw },
  Conditional = { fg = c_kw },
  Repeat = { fg = c_kw },
  Label = { fg = c_kw },
  Operator = { fg = c_op },
  Keyword = { fg = c_kw },
  Exception = { fg = c_kw },

  PreProc = { fg = c_import },
  Include = { fg = c_import },
  Define = { fg = c_import },
  Macro = { fg = c_import },
  PreCondit = { fg = c_import },

  Type = { fg = c_type },
  StorageClass = { fg = c_kw },
  Structure = { fg = c_type },
  Typedef = { fg = c_type },

  Special = { fg = p.mint },
  SpecialChar = { fg = p.mint },
  Tag = { fg = c_type },
  Delimiter = { fg = c_delim },
  SpecialComment = { fg = p.gold, bold = true },
})

-- -------------------------------------------------------- treesitter (@) ---

hl({
  ["@variable"] = { fg = c_var },
  ["@variable.builtin"] = { fg = c_builtin }, -- self, this, vim
  ["@variable.parameter"] = { fg = c_param },
  ["@variable.parameter.builtin"] = { fg = c_param, bold = true },
  ["@variable.member"] = { fg = c_prop },

  ["@constant"] = { fg = c_number },
  ["@constant.builtin"] = { fg = c_number, bold = true },
  ["@constant.macro"] = { fg = c_import },

  ["@module"] = { fg = c_type },
  ["@module.builtin"] = { fg = c_type, bold = true },
  ["@label"] = { fg = c_kw },

  ["@string"] = { fg = p.green },
  ["@string.documentation"] = { fg = p.gold },
  ["@string.regexp"] = { fg = p.mint },
  ["@string.escape"] = { fg = p.mint, bold = true },
  ["@string.special"] = { fg = p.mint },
  ["@string.special.symbol"] = { fg = c_number },
  ["@string.special.path"] = { fg = c_path, underline = true },
  ["@string.special.url"] = { fg = c_path, underline = true },

  ["@character"] = { fg = p.green },
  ["@character.special"] = { fg = p.mint },

  ["@boolean"] = { fg = c_number },
  ["@number"] = { fg = c_number },
  ["@number.float"] = { fg = c_number },

  ["@type"] = { fg = c_type },
  ["@type.builtin"] = { fg = c_type },
  ["@type.definition"] = { fg = c_type, bold = true },
  ["@attribute"] = { fg = c_import },
  ["@attribute.builtin"] = { fg = c_import },
  ["@property"] = { fg = c_prop },

  ["@function"] = { fg = c_fn },
  -- deliberately not italic: `italic` is a comment setting, and letting it leak
  -- here puts `open`/`enumerate`/`print` in italics all over a Python buffer
  ["@function.builtin"] = { fg = c_fn },
  ["@function.call"] = { fg = c_fn },
  ["@function.macro"] = { fg = c_import },
  ["@function.method"] = { fg = c_fn },
  ["@function.method.call"] = { fg = c_fn },
  ["@constructor"] = { fg = c_type },

  ["@operator"] = { fg = c_op },

  ["@keyword"] = { fg = c_kw },
  ["@keyword.coroutine"] = { fg = c_kw },
  ["@keyword.function"] = { fg = c_kw },
  ["@keyword.operator"] = { fg = c_op }, -- and / or / not / in
  ["@keyword.import"] = { fg = c_import },
  ["@keyword.type"] = { fg = c_kw },
  ["@keyword.modifier"] = { fg = c_kw },
  ["@keyword.repeat"] = { fg = c_kw },
  ["@keyword.return"] = { fg = c_kw, bold = true },
  ["@keyword.debug"] = { fg = p.red },
  ["@keyword.exception"] = { fg = c_kw },
  ["@keyword.conditional"] = { fg = c_kw },
  ["@keyword.conditional.ternary"] = { fg = c_op },
  ["@keyword.directive"] = { fg = c_import },
  ["@keyword.directive.define"] = { fg = c_import },

  ["@punctuation.delimiter"] = { fg = c_delim },
  ["@punctuation.bracket"] = { fg = c_brkt },
  ["@punctuation.special"] = { fg = p.mint },

  ["@comment"] = { fg = p.olive, italic = it },
  ["@comment.documentation"] = { fg = p.gold, italic = it },
  ["@comment.error"] = { fg = p.bg, bg = p.red, bold = true },
  ["@comment.warning"] = { fg = p.bg, bg = p.amber, bold = true },
  ["@comment.todo"] = { fg = p.bg, bg = p.rose_hot, bold = true },
  ["@comment.note"] = { fg = p.bg, bg = p.mint, bold = true },

  ["@markup.strong"] = { bold = true },
  ["@markup.italic"] = { italic = true },
  ["@markup.strikethrough"] = { strikethrough = true },
  ["@markup.underline"] = { underline = true },
  ["@markup.heading"] = { fg = p.amber, bold = true },
  ["@markup.heading.1"] = { fg = c_fn, bold = true },
  ["@markup.heading.2"] = { fg = p.amber, bold = true },
  ["@markup.heading.3"] = { fg = c_kw, bold = true },
  ["@markup.heading.4"] = { fg = p.green, bold = true },
  ["@markup.heading.5"] = { fg = c_type, bold = true },
  ["@markup.heading.6"] = { fg = p.gold, bold = true },
  ["@markup.quote"] = { fg = p.gold, italic = true },
  ["@markup.math"] = { fg = p.mint },
  ["@markup.link"] = { fg = c_path },
  ["@markup.link.label"] = { fg = c_fn },
  ["@markup.link.url"] = { fg = c_path, underline = true },
  ["@markup.raw"] = { fg = p.mint },
  ["@markup.raw.block"] = { fg = p.mint },
  ["@markup.list"] = { fg = p.amber },
  ["@markup.list.checked"] = { fg = p.green },
  ["@markup.list.unchecked"] = { fg = p.dim },

  ["@diff.plus"] = { fg = p.green },
  ["@diff.minus"] = { fg = p.red },
  ["@diff.delta"] = { fg = p.blue },

  ["@tag"] = { fg = c_type },
  ["@tag.builtin"] = { fg = c_type },
  ["@tag.attribute"] = { fg = c_param },
  ["@tag.delimiter"] = { fg = c_delim },

  ["@none"] = {},
  ["@conceal"] = { fg = p.mute },
})

-- ---------------------------------------------------- LSP semantic tokens ---

hl({
  ["@lsp.type.class"] = { link = "@type" },
  ["@lsp.type.comment"] = {},
  ["@lsp.type.decorator"] = { link = "@attribute" },
  ["@lsp.type.enum"] = { link = "@type" },
  ["@lsp.type.enumMember"] = { link = "@constant" },
  ["@lsp.type.event"] = { link = "@type" },
  ["@lsp.type.function"] = { link = "@function" },
  ["@lsp.type.interface"] = { link = "@type" },
  ["@lsp.type.keyword"] = { link = "@keyword" },
  ["@lsp.type.macro"] = { link = "@function.macro" },
  ["@lsp.type.method"] = { link = "@function.method" },
  ["@lsp.type.modifier"] = { link = "@keyword.modifier" },
  ["@lsp.type.namespace"] = { link = "@module" },
  ["@lsp.type.number"] = { link = "@number" },
  ["@lsp.type.operator"] = { link = "@operator" },
  ["@lsp.type.parameter"] = { link = "@variable.parameter" },
  ["@lsp.type.property"] = { link = "@property" },
  ["@lsp.type.regexp"] = { link = "@string.regexp" },
  ["@lsp.type.string"] = { link = "@string" },
  ["@lsp.type.struct"] = { link = "@type" },
  ["@lsp.type.type"] = { link = "@type" },
  ["@lsp.type.typeParameter"] = { link = "@type.definition" },
  ["@lsp.type.variable"] = { link = "@variable" },
  ["@lsp.mod.deprecated"] = { strikethrough = true },
  ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
  ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
  ["@lsp.typemod.variable.readonly"] = { link = "@constant" },
  ["@lsp.typemod.property.readonly"] = { link = "@property" },

  LspReferenceText = { bg = p.bg_hard },
  LspReferenceRead = { bg = p.bg_hard },
  LspReferenceWrite = { bg = p.bg_hard, underline = true },
  LspReferenceTarget = { bg = p.bg_hard },
  LspInlayHint = { fg = p.mute, bg = p.none, italic = true },
  LspSignatureActiveParameter = { fg = p.amber, bold = true },
  LspCodeLens = { fg = p.mute },
  LspCodeLensSeparator = { fg = p.mute },
  LspInfoBorder = { fg = p.mute },
  SnippetTabstop = { bg = p.sel },
})

-- ----------------------------------------------------------- diagnostics ---

hl({
  DiagnosticError = { fg = p.red },
  DiagnosticWarn = { fg = p.amber },
  DiagnosticInfo = { fg = p.cyan },
  DiagnosticHint = { fg = p.mint },
  DiagnosticOk = { fg = p.green },

  DiagnosticVirtualTextError = { fg = p.red },
  DiagnosticVirtualTextWarn = { fg = p.amber },
  DiagnosticVirtualTextInfo = { fg = p.cyan },
  DiagnosticVirtualTextHint = { fg = p.mint },
  DiagnosticVirtualTextOk = { fg = p.green },

  -- `sp` is the squiggle's own colour; without it the undercurl inherits the
  -- token's foreground, which is why an error under a string looked green.
  DiagnosticUnderlineError = { sp = p.red, undercurl = true },
  DiagnosticUnderlineWarn = { sp = p.amber, undercurl = true },
  DiagnosticUnderlineInfo = { sp = p.cyan, undercurl = true },
  DiagnosticUnderlineHint = { sp = p.mint, undercurl = true },
  DiagnosticUnderlineOk = { sp = p.green, undercurl = true },

  DiagnosticFloatingError = { fg = p.red },
  DiagnosticFloatingWarn = { fg = p.amber },
  DiagnosticFloatingInfo = { fg = p.cyan },
  DiagnosticFloatingHint = { fg = p.mint },
  DiagnosticFloatingOk = { fg = p.green },

  DiagnosticSignError = { fg = p.red },
  DiagnosticSignWarn = { fg = p.amber },
  DiagnosticSignInfo = { fg = p.cyan },
  DiagnosticSignHint = { fg = p.mint },
  DiagnosticSignOk = { fg = p.green },

  DiagnosticDeprecated = { sp = p.dim, strikethrough = true },
  DiagnosticUnnecessary = { fg = p.mute },
})

-- --------------------------------------------------------------- plugins ---

hl({
  -- Telescope, following the shell prompt rather than fzf's defaults: purple
  -- chevron and title, the prompt's path pink on the fuzzy-matched characters
  -- and the counter, and the same amber wash the editor uses for a visual
  -- selection instead of a solid bar.
  TelescopeNormal = { fg = p.fg, bg = float_bg },
  TelescopeBorder = { fg = p.mute, bg = float_bg },
  TelescopeTitle = { fg = p.gold, bg = float_bg },
  TelescopePromptNormal = { fg = p.fg, bg = float_bg },
  TelescopePromptBorder = { fg = p.mute, bg = float_bg },
  TelescopePromptTitle = { fg = p.bg, bg = p.purple, bold = true },
  TelescopePromptPrefix = { fg = p.purple, bold = true },
  TelescopePromptCounter = { fg = p.rose },
  TelescopeResultsTitle = { fg = p.gold, bg = float_bg },
  TelescopePreviewTitle = { fg = p.bg, bg = p.gold, bold = true },
  TelescopeSelection = { fg = pick_fg, bg = pick_bg },
  TelescopeSelectionCaret = { fg = p.rose_hot, bg = pick_bg, bold = true },
  TelescopeMultiSelection = { fg = p.green },
  TelescopeMultiIcon = { fg = p.green },
  TelescopeMatching = { fg = p.rose, bold = true },
  TelescopePreviewLine = { bg = p.sel },
  TelescopeResultsDiffAdd = { fg = p.green },
  TelescopeResultsDiffChange = { fg = p.blue },
  TelescopeResultsDiffDelete = { fg = p.red },

  -- gitsigns
  GitSignsAdd = { fg = p.green },
  GitSignsChange = { fg = p.blue },
  GitSignsDelete = { fg = p.red },
  GitSignsTopdelete = { fg = p.red },
  GitSignsChangedelete = { fg = p.orange },
  GitSignsUntracked = { fg = p.mute },
  GitSignsAddNr = { fg = p.green },
  GitSignsChangeNr = { fg = p.blue },
  GitSignsDeleteNr = { fg = p.red },
  GitSignsStagedAdd = { fg = p.gold },
  GitSignsStagedChange = { fg = p.gold },
  GitSignsStagedDelete = { fg = p.gold },
  GitSignsStagedChangedelete = { fg = p.gold },
  GitSignsStagedTopdelete = { fg = p.gold },
  GitSignsStagedUntracked = { fg = p.gold },
  GitSignsAddInline = { bg = p.diff_add },
  GitSignsDeleteInline = { bg = p.diff_del },
  GitSignsChangeInline = { bg = p.diff_txt },
  GitSignsCurrentLineBlame = { fg = p.mute, italic = true },

  -- which-key
  WhichKey = { fg = p.amber, bold = true },
  WhichKeyGroup = { fg = c_fn },
  WhichKeyDesc = { fg = p.fg },
  WhichKeySeparator = { fg = p.mute },
  WhichKeyFloat = { bg = float_bg },
  WhichKeyBorder = { fg = p.mute, bg = float_bg },
  WhichKeyTitle = { fg = p.gold, bg = float_bg },
  WhichKeyValue = { fg = p.gold },
  WhichKeyIcon = { fg = p.cyan },
  WhichKeyIconAzure = { fg = p.sky },
  WhichKeyIconBlue = { fg = p.blue },
  WhichKeyIconCyan = { fg = p.cyan },
  WhichKeyIconGreen = { fg = p.green },
  WhichKeyIconGrey = { fg = p.dim },
  WhichKeyIconOrange = { fg = p.orange },
  WhichKeyIconPurple = { fg = p.purple },
  WhichKeyIconRed = { fg = p.red },
  WhichKeyIconYellow = { fg = p.amber },
  WhichKeyNormal = { fg = p.fg, bg = float_bg },

  -- snacks
  SnacksNormal = { fg = p.fg, bg = float_bg },
  SnacksNormalNC = { fg = p.fg, bg = float_bg },
  SnacksWinBar = { fg = p.amber, bg = float_bg, bold = true },
  SnacksWinBarNC = { fg = p.mute, bg = float_bg },
  SnacksBackdrop = { bg = p.bg_dark },
  SnacksPickerMatch = { fg = p.rose, bold = true },
  SnacksPickerSelected = { fg = p.green },
  SnacksPickerDir = { fg = c_path },
  SnacksPickerFile = { fg = p.fg },
  SnacksPickerPrompt = { fg = p.purple, bold = true },
  SnacksPickerTitle = { fg = p.gold },
  SnacksPickerTotals = { fg = p.rose },
  SnacksPickerListCursorLine = { fg = pick_fg, bg = pick_bg },
  SnacksNotifierInfo = { fg = p.cyan, bg = float_bg },
  SnacksNotifierWarn = { fg = p.amber, bg = float_bg },
  SnacksNotifierError = { fg = p.red, bg = float_bg },
  SnacksNotifierDebug = { fg = p.dim, bg = float_bg },
  SnacksNotifierTrace = { fg = p.rose_hot, bg = float_bg },
  SnacksIndent = { fg = "#2f2f36" },
  SnacksIndentScope = { fg = p.mute },
  SnacksDashboardHeader = { fg = c_fn },
  SnacksDashboardIcon = { fg = p.amber },
  SnacksDashboardKey = { fg = p.rose_hot },
  SnacksDashboardDesc = { fg = p.fg },
  SnacksDashboardFooter = { fg = p.gold },

  -- fugitive / diffs
  diffAdded = { fg = p.green },
  diffRemoved = { fg = p.red },
  diffChanged = { fg = p.blue },
  diffOldFile = { fg = p.red },
  diffNewFile = { fg = p.green },
  diffFile = { fg = p.amber },
  diffLine = { fg = p.gold },
  diffIndexLine = { fg = p.mute },
  gitcommitSummary = { fg = p.fg },
  gitcommitOverflow = { fg = p.red },
  gitcommitComment = { fg = p.olive },
  gitcommitBranch = { fg = p.amber, bold = true },

  -- healthcheck / help
  healthError = { fg = p.red },
  healthWarning = { fg = p.amber },
  healthSuccess = { fg = p.green },
  helpHyperTextJump = { fg = c_path, underline = true },
  helpCommand = { fg = c_fn },
  helpExample = { fg = p.mint },
  helpHeader = { fg = p.amber, bold = true },
})

-- --------------------------------------------------------- :terminal ANSI ---
-- yazi, claude and eza all run inside :terminal buffers; without this they use
-- ghostty's default palette and clash with everything above.

if o.terminal then
  local ansi = {
    p.bg, p.red, p.green, p.amber, p.blue, p.pink, p.cyan, p.fg,
    p.dim, "#ff6b6b", "#8ce65c", "#ffd580", p.sky, "#ff9bff", p.mint, "#FFFFFF",
  }
  for i, colour in ipairs(ansi) do
    vim.g["terminal_color_" .. (i - 1)] = colour
  end
end
