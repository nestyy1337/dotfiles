require 'configs.set'
require 'configs.remap'

vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.opt.showmode = false

vim.opt.clipboard = 'unnamedplus'

-- Enable break indent
vim.opt.breakindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.timeoutlen = 300

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

vim.opt.cursorline = false

-- shit for blink.cmp
vim.o.completeopt = 'menu,menuone,noinsert,noselect'

-- for _, path in ipairs(vim.fn.glob('/nix/store/*-nvim-treesitter-grammars', false, true)) do
--   vim.opt.runtimepath:append(path)
-- end
--
-- local grammar_path = vim.fn.glob '/nix/store/*-nvim-treesitter-grammars'
-- if grammar_path ~= '' then
--   require('nvim-treesitter').setup {
--     install_dir = grammar_path,
--   }
-- end

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  { import = 'nesty' },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

local augroup = vim.api.nvim_create_augroup
local nestyygroup = augroup('nestyy', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

function R(name)
  require('plenary.reload').reload_module(name)
end

vim.filetype.add {
  extension = {
    templ = 'templ',
  },
}

autocmd('TextYankPost', {
  group = yank_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank {
      higroup = 'IncSearch',
      timeout = 40,
    }
  end,
})

autocmd({ 'BufWritePre' }, {
  group = nestyygroup,
  pattern = '*',
  command = [[%s/\s\+$//e]],
})

vim.g.netrw_browse_split = 0

vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25
