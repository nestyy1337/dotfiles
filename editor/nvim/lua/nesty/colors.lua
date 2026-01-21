function ColorMyPencils(color)
  color = color or 'rose-pine-moon'
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
  vim.api.bg = 'none'
end

return {
  { 'ellisonleao/gruvbox.nvim', priority = 1000, config = true, opts = ... },
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup {
        disable_background = true,
        styles = {
          italic = false,
        },
      }

      ColorMyPencils()
    end,
  },
  {
    'rebelot/kanagawa.nvim',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        theme = 'dragon',
        commentStyle = { italic = true },
        keywordStyle = { italic = false },

        transparent = false,

        colors = {
          theme = {
            all = {
              ui = {
                bg_gutter = 'none',
              },
            },
          },
        },
      }
      ColorMyPencils 'kanagawa-dragon'
    end,
  },
}
