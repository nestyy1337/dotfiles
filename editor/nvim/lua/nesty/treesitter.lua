return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  version = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.install').prefer_git = true

    -- Optional setup (only needed if customizing install dir or other defaults)
    require('nvim-treesitter').setup {
      -- Example: custom install dir if desired
      -- install_dir = vim.fn.stdpath('data') .. '/site',
    }

    -- Install parsers for your languages (auto_install equivalent)
    require('nvim-treesitter').install {
      'rust',
      'bash',
      'c',
      'python',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'vim',
      'vimdoc',
      'javascript',
      'json',
      'yaml',
      'css',
      'scss',
      'go',
      'dockerfile',
      'sql',
      'toml',
      'markdown_inline',
      'regex',
      'ruby',
      'nix',
    }

    local filetypes = {
      'rust',
      'bash',
      'c',
      'python',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'vim',
      'vimdoc',
      'javascript',
      'json',
      'yaml',
      'css',
      'scss',
      'go',
      'dockerfile',
      'sql',
      'toml',
      'markdown_inline',
      'regex',
      'ruby',
      'nix',
    }
    for _, ft in ipairs(filetypes) do
      vim.api.nvim_create_autocmd('FileType', {
        pattern = ft,
        callback = function()
          vim.treesitter.start()
        end,
      })
    end

    -- Indent (experimental, disable for ruby as before)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    -- If you want to disable for ruby:
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'ruby',
      callback = function()
        vim.bo.indentexpr = ''
      end,
    })

    -- vim.keymap.set('n', '<C-space>', function()
    --   vim.treesitter.incremental_selection.init_selection()
    --   vim.treesitter.incremental_selection.node_incremental()
    -- end, { desc = 'Increment treesitter selection' })
    -- vim.keymap.set('n', '<bs>', vim.treesitter.incremental_selection.node_decremental, { desc = 'Decrement treesitter selection' })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'ruby',
      callback = function()
        vim.cmd 'setlocal syntax=on' -- Fallback to vim's regex if treesitter isn't sufficient
      end,
    })
  end,
}
