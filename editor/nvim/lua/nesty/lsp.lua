local function prefer_system_bin(bin)
  local system_bin = '/run/current-system/sw/bin/' .. bin
  if vim.fn.executable(system_bin) == 1 then
    return system_bin
  end
  return bin
end

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'williamboman/mason.nvim', config = true },
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    'saghen/blink.cmp',
    'mfussenegger/nvim-lint',
    { 'j-hui/fidget.nvim', opts = {} },
    { 'folke/neodev.nvim', opts = {} },
  },
  config = function()
    require('lint').linters_by_ft = {
      python = { 'ruff' },
    }
    -- Enable diagnostics globally
    vim.diagnostic.enable()
    -- Configure diagnostics
    vim.diagnostic.config {
      virtual_text = {
        prefix = '●',
        spacing = 4,
        format = function(diagnostic)
          return diagnostic.message
        end,
      },
    }
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, { buffer = event.buf, desc = 'LSP: Signature Help' })
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end
        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
        map('<leader>w', vim.diagnostic.open_float, 'Show [E]rror Details')
        map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
        map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })
          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })
    local nixos_flake = vim.fn.expand '~/.config/nixos'
    local hostname = vim.fn.hostname()

    -- Define servers with their specific configurations
    local servers = {
      clangd = {
        cmd = {
          prefer_system_bin 'clangd',
          '--background-index',
          '--clang-tidy',
          '--completion-style=detailed',
          '--header-insertion=iwyu',
          '--pch-storage=memory',
          '--query-driver=/run/current-system/sw/bin/*,/nix/store/*/bin/clang++,/nix/store/*gcc-wrapper*/bin/*,/nix/store/*clang-wrapper*/bin/*',
        },
        init_options = {
          clangdFileStatus = true,
          usePlaceholders = true,
          completeUnimported = true,
          semanticHighlighting = true,
        },
      },
      gopls = {
        settings = {
          gopls = {
            usePlaceholders = true,
            completeFunctionCalls = true,
            matcher = 'fuzzy', -- or "CaseSensitive"
            symbolMatcher = 'fuzzy',
            -- This is the key one:
            deepCompletion = true,
          },
        },
      },
      ruff = {
        -- on_init = function(client)
        --   -- Detect and use the active virtual environment
        --   local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
        --   if venv then
        --     client.config.settings = vim.tbl_deep_extend('force', client.config.settings or {}, {
        --       interpreter = { venv .. '/bin/python' }
        --     })
        --   end
        -- end,
      },
      basedpyright = {
        cmd = { prefer_system_bin 'basedpyright-langserver', '--stdio' },
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
              typeCheckingMode = 'standard',
              autoImportCompletions = true,
              diagnosticSeverityOverrides = {
                reportUnusedVariable = 'none',
                reportUnusedImport = 'none',
              },
            },
          },
          python = {
            pythonPath = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX or vim.env.PYTHONPATH or vim.fn.getcwd() .. '/venv/bin/python',
          },
        },
      },
      rust_analyzer = {
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = true,
            check = {
              command = 'check',
            },
            completion = {
              autoimport = {
                enable = true,
              },
              postfix = {
                enable = true,
              },
            },
            imports = {
              granularity = {
                group = 'module',
              },
              prefix = 'self',
            },
            cargo = {
              buildScripts = {
                enable = true,
              },
              loadOutDirsFromCheck = true,
            },
            procMacro = {
              enable = true,
            },
          },
        },
      },
      zls = {},
      nixd = {
        cmd = { prefer_system_bin 'nixd' },
        settings = {
          nixd = {
            formatting = {
              command = { 'nixfmt' },
            },
            options = {
              nixos = {
                expr = ('(builtins.getFlake "%s").nixosConfigurations."%s".options'):format(nixos_flake, hostname),
              },
            },
          },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
          },
        },
      },
    }
    require('mason').setup()
    local mason_servers = vim.tbl_filter(function(server)
      return not vim.tbl_contains({
        'basedpyright',
        'nixd',
      }, server)
    end, vim.tbl_keys(servers or {}))

    local ensure_installed = vim.deepcopy(mason_servers)
    vim.list_extend(ensure_installed, {
      'stylua',
      'clang-format',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    local capabilities = require('blink.cmp').get_lsp_capabilities()
    capabilities.general = vim.tbl_deep_extend('force', capabilities.general or {}, {
      positionEncodings = { 'utf-16' },
    })

    for server_name, server in pairs(servers) do
      server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
      vim.lsp.config(server_name, server)
    end

    require('mason-lspconfig').setup {
      ensure_installed = mason_servers,
      automatic_enable = false,
    }
    vim.lsp.enable(vim.tbl_keys(servers or {}))
  end,
}
