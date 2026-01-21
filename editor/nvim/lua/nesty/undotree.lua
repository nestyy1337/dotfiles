return {
  -- other plugins
  {
    'mbbill/undotree',
    config = function()
      -- optional configuration
      vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', { noremap = true, silent = true })
    end,
  },
  -- other plugins
}
