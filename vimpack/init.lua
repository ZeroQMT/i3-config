vim.opt.termguicolors = true

-- ============================================================================
-- OPTIONS
-- ============================================================================
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.cursorline     = false
vim.opt.scrolloff      = 10
vim.opt.wrap           = false

vim.opt.tabstop        = 4   -- python convention
vim.opt.shiftwidth     = 4
vim.opt.softtabstop    = 4
vim.opt.expandtab      = true
vim.opt.smartindent    = true

vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.hlsearch       = true
vim.opt.incsearch      = true

vim.opt.signcolumn     = "no"
vim.opt.colorcolumn    = "98"  -- black's default line length
vim.opt.showmode       = true
vim.opt.pumheight      = 10

vim.opt.swapfile       = false
vim.opt.undofile       = true
vim.opt.undodir        = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime     = 300
vim.opt.autoread       = true

vim.opt.mouse          = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.encoding       = "utf-8"
vim.opt.splitbelow     = true
vim.opt.splitright     = true

vim.opt.foldmethod     = "expr"
vim.opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel      = 99

vim.fn.mkdir(vim.fn.expand("~/.vim/undodir"), "p")

-- ============================================================================
-- KEYMAPS
-- ============================================================================
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>",    { desc = "Clear search highlights" })
vim.keymap.set("n", "n",         "nzzzv",               { desc = "Next result (centered)" })
vim.keymap.set("n", "N",         "Nzzzv",               { desc = "Prev result (centered)" })
vim.keymap.set("n", "<C-d>",     "<C-d>zz",             { desc = "Half page down" })
vim.keymap.set("n", "<C-u>",     "<C-u>zz",             { desc = "Half page up" })

-- Window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Indenting keeps selection
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Diagnostics
vim.keymap.set("n", "<leader>d",  function() vim.diagnostic.open_float({ scope = "line" }) end, { desc = "Line diagnostics" })
vim.keymap.set("n", "<leader>nd", function() vim.diagnostic.jump({ count = 1 }) end,            { desc = "Next diagnostic" })
vim.keymap.set("n", "<leader>pd", function() vim.diagnostic.jump({ count = -1 }) end,           { desc = "Prev diagnostic" })

-- ============================================================================
-- AUTOCMDS
-- ============================================================================
local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
  group   = augroup,
  pattern = { "*.py", "*.sh", "*.bash" },
  callback = function(args)
    if vim.bo[args.buf].buftype ~= "" then return end
    if not vim.bo[args.buf].modifiable then return end
    if vim.api.nvim_buf_get_name(args.buf) == "" then return end
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
      if c.name == "efm" then
        pcall(vim.lsp.buf.format, {
          bufnr      = args.buf,
          timeout_ms = 2000,
          filter     = function(cl) return cl.name == "efm" end,
        })
        break
      end
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group    = augroup,
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group    = augroup,
  callback = function()
    if vim.o.diff then return end
    local pos = vim.api.nvim_buf_get_mark(0, '"')
    if pos[1] >= 1 and pos[1] <= vim.api.nvim_buf_line_count(0) then
      pcall(vim.api.nvim_win_set_cursor, 0, pos)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group    = augroup,
  pattern  = { "markdown", "text", "gitcommit", "python" },
  callback = function()
    vim.opt_local.wrap      = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell     = true
  end,
})

-- ============================================================================
-- PLUGINS
-- ============================================================================
vim.pack.add({
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/echasnovski/mini.nvim",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-tree.lua",
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main", build = ":TSUpdate" },
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/creativenull/efmls-configs-nvim",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/goolord/alpha-nvim"
})

-- ============================================================================
-- TREESITTER
-- ============================================================================
require("nvim-treesitter").setup({})

vim.cmd.colorscheme("tokyonight")

-- Transparent background
for _, g in ipairs({ "Normal", "NormalNC", "EndOfBuffer", "NormalFloat", "FloatBorder",
  "SignColumn", "StatusLine", "StatusLineNC" }) do
  vim.api.nvim_set_hl(0, g, { bg = "none" })
end


local ts_parsers = { "python", "bash", "vim", "vimdoc", "markdown", "json", "yaml" }
local installed  = require("nvim-treesitter.config").get_installed()
local to_install = vim.tbl_filter(function(p) return not vim.tbl_contains(installed, p) end, ts_parsers)
if #to_install > 0 then require("nvim-treesitter").install(to_install) end

vim.api.nvim_create_autocmd("FileType", {
  group    = vim.api.nvim_create_augroup("TreeSitter", { clear = true }),
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if lang and vim.list_contains(require("nvim-treesitter").get_installed(), lang) then
      vim.treesitter.start(args.buf)
    end
  end,
})

-- ============================================================================
-- FILE TREE
-- ============================================================================
require("nvim-tree").setup({
  view     = { width = 30 },
  filters  = { dotfiles = false },
  renderer = { group_empty = true },
})
vim.api.nvim_set_hl(0, "NvimTreeNormal",       { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC",      { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeWinSeparator",  { fg = "#2a2a2a", bg = "none" })
vim.keymap.set("n", "<leader>e", function() require("nvim-tree.api").tree.toggle() end, { desc = "Toggle file tree" })

-- ============================================================================
-- FZF
-- ============================================================================
require("fzf-lua").setup({})
vim.keymap.set("n", "<leader>ff", function() require("fzf-lua").files() end,       { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function() require("fzf-lua").live_grep() end,   { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end,     { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", function() require("fzf-lua").help_tags() end,   { desc = "Help tags" })

-- ============================================================================
-- MINI
-- ============================================================================
require("mini.comment").setup({})
require("mini.surround").setup({})
require("mini.pairs").setup({})
require("mini.trailspace").setup({})
require("mini.bufremove").setup({})
-- require("mini.notify").setup({})
require("mini.icons").setup({})

-- ============================================================================
-- GITSIGNS
-- ============================================================================

require("gitsigns").setup({
  signs = {
    add          = { text = "▏" },
    change       = { text = "▏" },
    delete       = { text = "▏" },
    topdelete    = { text = "◦" },
    changedelete = { text = "●" },
  },
  current_line_blame = false,
})
vim.keymap.set("n", "]h", function() require("gitsigns").nav_hunk("next") end, { desc = "Next hunk" })
vim.keymap.set("n", "[h", function() require("gitsigns").nav_hunk("prev") end, { desc = "Prev hunk" })
vim.keymap.set("n", "<leader>hs", function() require("gitsigns").stage_hunk() end,   { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", function() require("gitsigns").reset_hunk() end,   { desc = "Reset hunk" })
vim.keymap.set("n", "<leader>hp", function() require("gitsigns").preview_hunk() end, { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Blame line" })

-- ============================================================================
-- MASON
-- ============================================================================
require("mason").setup({})

-- ============================================================================
-- COMPLETION
-- ============================================================================
require("blink.cmp").setup({
  keymap = {
    preset    = "none",
    ["<C-Space>"] = { "show", "hide" },
    ["<CR>"]      = { "accept", "fallback" },
    ["<C-j>"]     = { "select_next", "fallback" },
    ["<C-k>"]     = { "select_prev", "fallback" },
    ["<Tab>"]     = { "snippet_forward", "fallback" },
    ["<S-Tab>"]   = { "snippet_backward", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = { menu = { auto_show = true } },
  sources    = { default = { "lsp", "path", "buffer", "snippets" } },
  snippets   = { expand = function(s) require("luasnip").lsp_expand(s) end },
  fuzzy      = { implementation = "prefer_rust", prebuilt_binaries = { download = true } },
})

-- ============================================================================
-- LSP
-- ============================================================================
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs        = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "",
    },
  },
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = "rounded", source = true, focusable = false },
})

vim.lsp.config["*"] = {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
}

vim.lsp.config("pyright", {})
vim.lsp.config("bashls",  {})

vim.lsp.config("efm", {
  filetypes        = { "python", "sh" },
  init_options     = { documentFormatting = true },
  settings         = {
    languages = {
      python = { require("efmls-configs.linters.flake8"), require("efmls-configs.formatters.black") },
      sh     = { require("efmls-configs.linters.shellcheck"), require("efmls-configs.formatters.shfmt") },
    },
  },
})

vim.lsp.enable({ "pyright", "bashls", "efm" })

vim.api.nvim_create_autocmd("LspAttach", {
  group    = augroup,
  callback = function(ev)
    local opts = { noremap = true, silent = true, buffer = ev.buf }
    vim.keymap.set("n", "gd",          function() require("fzf-lua").lsp_definitions({ jump_to_single_result = true }) end, opts)
    vim.keymap.set("n", "<leader>fr",  function() require("fzf-lua").lsp_references() end,  opts)
    vim.keymap.set("n", "<leader>fs",  function() require("fzf-lua").lsp_document_symbols() end, opts)
    vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,      opts)
    vim.keymap.set("n", "K",           vim.lsp.buf.hover,        opts)
  end,
})

-- ============================================================================
-- FLOATING TERMINAL
-- ============================================================================
local term = { buf = nil, win = nil, open = false }

local function FloatingTerminal()
  if term.open and term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_close(term.win, false)
    term.open = false
    return
  end

  if not term.buf or not vim.api.nvim_buf_is_valid(term.buf) then
    term.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[term.buf].bufhidden = "hide"
  end

  local W = math.floor(vim.o.columns * 0.8)
  local H = math.floor(vim.o.lines * 0.8)
  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative = "editor",
    width    = W,
    height   = H,
    row      = math.floor((vim.o.lines - H) / 2),
    col      = math.floor((vim.o.columns - W) / 2),
    style    = "minimal",
    border   = "rounded",
  })
  vim.api.nvim_set_hl(0, "FloatTermNormal", { bg = "none" })
  vim.wo[term.win].winhighlight = "Normal:FloatTermNormal"

  local has_content = vim.api.nvim_buf_get_lines(term.buf, 0, 1, false)[1] ~= ""
  if not has_content then vim.fn.termopen(os.getenv("SHELL")) end

  term.open = true
  vim.cmd("startinsert")

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer   = term.buf,
    once     = true,
    callback = function()
      if term.open and term.win and vim.api.nvim_win_is_valid(term.win) then
        vim.api.nvim_win_close(term.win, false)
        term.open = false
      end
    end,
  })
end

vim.api.nvim_create_autocmd("TermOpen", {
  group    = augroup,
  callback = function()
    vim.opt_local.number         = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn     = "no"
  end,
})

vim.keymap.set("n", "<leader>t", FloatingTerminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<Esc>", function()
  if term.open and term.win and vim.api.nvim_win_is_valid(term.win) then
    vim.api.nvim_win_close(term.win, false)
    term.open = false
  end
end)

-- Start screen
local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')
dashboard.section.header.val = vim.split(
	[[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣴⢋⣔⣶⣿⢋⣙⣳⣤⣀⣠⣤⠐⠄⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣿⡾⣿⣿⣿⣿⣿⣿⣿⣬⣥⣤⣠⡦⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣿⣿⣿⣿⣿⣿⣿⣿⡟⠛⠆⢀⠀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣤⣄⣠⣤⣄⠄⡀⢠⣯⣿⣿⣿⣿⣿⣿⣾⣷⣤⢔⣊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣾⣽⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣭⡟⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⢀⣤⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⠀⠻⢿⣿⣉⠛⢻⣿⠉⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠸⠀⠀⣼⢯⣿⣿⣿⣿⣿⣿⣿⣿⣻⣿⣿⣿⢿⣿⣷⠠⢠⢏⣿⠉⠉⠩⠛⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢀⠄⠀⠓⣶⣯⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣇⣚⡁⠀⠁⢠⠀⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠈⠃⡀⠀⣿⣿⣿⣿⣿⣟⣿⣯⣷⣻⣽⣿⣯⣟⢻⣻⣿⣿⣿⣷⢶⠞⢗⣲⣄⡤⡂⠉⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⣹⠛⠏⢳⡀⠹⣿⣿⣿⣿⣿⣿⣿⣯⣤⣝⣿⣿⣿⣿⣿⣶⣷⣟⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣦⡿⠋⣗⠤⢹⡜⢛⠻⣿⣿⣷⣾⣿⣯⣧⡽⣿⣿⣿⣿⣷⣍⢳⢥⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡗⠍⣅⣴⣿⣄⡘⠆⠈⠨⡌⢻⣿⡗⣬⣼⢟⣫⡾⢿⣿⣿⣿⣿⡿⡄⢮⣆⠀⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢠⠦⢀⡀⠀⠀⠀⢇⢸⡭⠓⠁⠁⠜⠈⠄⠀⠱⡀⢻⣿⣾⡤⢼⣿⣖⣿⣿⣿⣿⣿⣷⡆⠀⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢀⣔⣋⣥⢋⢹⡀⠀⠀⢰⢸⢀⢴⣀⣤⠦⠀⠨⠃⠀⠒⢮⣿⣵⣧⣸⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⡄⠄⠀⠀⠀⠀⠀⠀⠀
⠀⣀⡆⡎⡀⠀⠀⠀⠀⠀⠀⠰⠀⠸⠀⠷⣶⣆⣶⡆⠀⠀⣀⣿⡿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⣰⠆⢀⡀⠆⠀⠀⠀⠀
⠀⢕⣿⢀⣱⠪⢧⢻⠇⢀⠀⠀⠀⠀⠀⠀⠙⠯⡄⣙⣧⢤⣷⠿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠛⣴⣵⡿⣣⢨⠄⠀⠀
⢰⡆⡜⡎⠁⠀⢰⠒⣾⢠⡄⠀⠀⠀⠀⠀⠀⠀⠸⢿⣿⠿⠁⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢦⣗⣈⢻⣄⡟⠅⣀⢠⡄
⠀⢿⠀⠐⢠⣆⠲⡶⡗⠱⡇⠀⠀⠀⠀⠀⠀⠀⠀⠈⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠩⣽⣿⣿⡳⣿⢴⡿⠅
⢰⢘⠀⢻⡄⢧⠸⣗⡧⢄⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⢠⣟⣾⡇⢹⠓⠀⠀
⠈⡈⡀⠀⠁⡈⠚⣿⣉⣓⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⠾⠃⣯⠀⡀⠀
⠀⢳⣤⡀⠀⢰⠀⠻⣿⡿⠀⠀⠀⠀⠀⠀⠀⢀⠀⢠⠎⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣳⠆⢱⡇⠘⣄
⠀⠈⠿⠹⠆⢀⡆⠈⠁⡇⠀⠀⠀⠀⠀⠀⡞⠃⣿⡏⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠻⢠⠀⡇⡀⢚
⠀⠀⠀⣼⠀⠸⠅⠀⠀⢺⠀⠀⠀⠀⠀⣼⡷⢋⣼⢷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⢾⣧⢰⠃⢠
⠀⠀⢀⠫⠀⣆⠀⠀⠀⢚⠄⠀⠀⠀⠀⠛⣠⠋⢸⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣻⡆⠘⠄⠈
⠀⠀⢀⡀⠇⠀⠀⡀⠀⣿⡸⣤⣤⣀⠀⢸⣧⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⣻⣇⢠⠀⡀
⠀⠀⣸⡇⢠⠀⠀⢠⠃⠘⣽⣿⣿⣿⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡗⢙⣮⠂⠀⠀
⠀⢰⣿⣿⣈⠀⠀⠠⠷⣠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠲⠄⢃⠀⠀
⠀⠘⣿⣿⣿⡄⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⠁⠀⠀⠀⠀
⠀⠀⣿⣿⣿⣧⣰⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢂⠂⡀⠀⠀⠀
        ]], '\n', { trimempty = true })
dashboard.section.header.opts.hl = 'Comment'
dashboard.section.buttons.val = {}
dashboard.section.footer.val = 'PookieVim v3000'
dashboard.section.footer.opts.hl = 'Comment'
alpha.setup(dashboard.opts)
