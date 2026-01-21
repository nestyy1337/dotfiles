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
          client.server_capabilities.semanticTokensProvider = nil
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
    -- Define servers with their specific configurations
    local servers = {
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
      pyright = {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = 'openFilesOnly',
              typeCheckingMode = 'basic',
              reportUnusedVariable = false,
              reportUnusedImport = false,
              autoImportCompletions = true, -- Enable auto-import suggestions
            },
            pythonPath = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX or vim.env.PYTHONPATH or vim.fn.getcwd() .. '/venv/bin/python',
          },
        },
      },
      rust_analyzer = {
        settings = {
          ['rust-analyzer'] = {
            checkOnSave = {
              command = 'clippy',
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
    -- Setup Mason
    require('mason').setup()
    -- Ensure tools are installed
    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      'stylua',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    -- Per blink.cmp documentation, set up LSP servers with capabilities
    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = require('blink.cmp').get_lsp_capabilities(server.capabilities)
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
