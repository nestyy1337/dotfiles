return {
  'saghen/blink.cmp',
  dependencies = 'rafamadriz/friendly-snippets',
  version = '*',
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },
    snippets = {
      preset = 'default',
    },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = {
          name = 'LSP',
          module = 'blink.cmp.sources.lsp',
          score_offset = 1000,
        },
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    signature = { enabled = true },

    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      trigger = {
        show_on_blocked_trigger_characters = { '*' },
        show_on_insert_on_trigger_character = true,
        show_in_snippet = true,
      },
      keyword = {
        range = 'full',
      },
      list = {
        selection = {
          preselect = false,
          auto_insert = true,
        },
      },
      menu = {
        draw = {
          treesitter = { 'lsp' },
        },
        auto_show = true,
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
      ghost_text = {
        enabled = vim.g.ai_cmp,
      },
    },

    cmdline = {
      enabled = true,
      keymap = {
        preset = 'cmdline',
        ['<Right>'] = false,
        ['<Left>'] = false,
      },
      completion = {
        list = { selection = { preselect = false } },
        menu = {
          auto_show = function(ctx)
            return vim.fn.getcmdtype() == ':'
          end,
        },
        ghost_text = { enabled = true },
      },
    },
  },
}
