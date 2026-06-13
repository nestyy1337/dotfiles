local function prefer_system_bin(bin)
  local system_bin = '/run/current-system/sw/bin/' .. bin
  if vim.fn.executable(system_bin) == 1 then
    return system_bin
  end
  return bin
end

return {
  'stevearc/conform.nvim',
  lazy = false,

  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_fallback = 'first' }
      end,
      desc = '[F]ormat buffer',
    },
  },

  opts = {
    notify_on_error = false,

    format_on_save = function(bufnr)
      local ft = vim.bo[bufnr].filetype
      local disabled = { c = true, cpp = true }
      return {
        timeout_ms = 500,
        lsp_fallback = not disabled[ft] and 'first' or nil,
      }
    end,

    -- Map filetypes to the tools you want:
    formatters_by_ft = {
      lua = { 'stylua' },
      python = {
        -- 'black',
        'ruff_fix',
        'ruff_format',
        'ruff_organize_imports',
      },
      rust = { 'rustfmt' },
      c = { 'clang_format' },
      cpp = { 'clang_format' },
      nix = { 'nixfmt' },
      go = { 'gofmt', 'goimports' },
      javascript = { 'prettier' },
      json = { 'prettier' },
      yaml = { 'prettier' },
      sh = { 'shfmt' },
    },

    -- Custom overrides or new formatter defs:
    formatters = {
      prettier = {
        args = {
          '--stdin-filepath',
          '$FILENAME',
          '--tab-width',
          '4',
          '--use-tabs',
          'false',
        },
      },
      shfmt = {
        prepend_args = { '-i', '4' },
      },
      clang_format = {
        command = prefer_system_bin 'clang-format',
      },
      -- black = {
      --   command = '/home/nestyy/.local/bin/black',
      -- },
    },
  },
}
