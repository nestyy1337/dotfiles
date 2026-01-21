return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      words = { enabled = true },
      statuscolumn = { enabled = false },
    },
    keys = {
      {
        ']r',
        function()
          require('snacks').words.jump(1, true)
        end,
        desc = 'Next Reference',
      },
      {
        '[r',
        function()
          require('snacks').words.jump(-1, true)
        end,
        desc = 'Prev Reference',
      },
      {
        '<leader>lg',
        function()
          require('snacks').lazygit()
        end,
        desc = 'Lazygit',
      },
      {
        '<leader>gl',
        function()
          require('snacks').lazygit.log()
        end,
        desc = 'Lazygit Logs',
      },
      {
        '<leader>rN',
        function()
          require('snacks').rename.rename_file()
        end,
        desc = 'Fast Rename Current File',
      },
      {
        '<leader>dB',
        function()
          require('snacks').bufdelete()
        end,
        desc = 'Delete or Close Buffer  (Confirm)',
      },
      -- docs stuff
      {
        '<leader>vh',
        function()
          require('snacks').picker.help()
        end,
        desc = 'Help Pages',
      },
    },
  },
}
