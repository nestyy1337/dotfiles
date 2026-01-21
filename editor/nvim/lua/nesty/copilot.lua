return {
  'zbirenbaum/copilot.lua',
  config = function()
    require('copilot').setup {
      suggestion = {
        enabled = true,
        event = 'InsertEnter',
        -- auto_trigger = true,
        keymap = {
          accept = '<C-j>',
          accept_word = false,
          accept_line = false,
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
    }
  end,
}
