return {
  'folke/trouble.nvim',
  opts = {
    auto_close = true,
    auto_preview = false,
    max_items = 200,
    win = { size = 6 },
  },
  cmd = 'Trouble',
  keys = {
    {
      '<leader>xx',
      '<cmd>Trouble diagnostics toggle<cr>',
      desc = 'Diagnostics (Trouble)',
    },
    {
      '<leader>xX',
      '<cmd>Trouble diagnostics toggle filter.buf=0<cr>',
      desc = 'Buffer Diagnostics (Trouble)',
    },
    {
      '<C-j>',
      '<cmd>Trouble next jump = true, skip_groups = true<cr>',
      desc = 'Next (Trouble)',
    },
    {
      '<C-k>',
      '<cmd>Trouble prev jump = true, skip_groups = true<cr>',
      desc = 'Prev (Trouble)',
    },
  },
}
