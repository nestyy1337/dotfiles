vim.g.mapleader = ' '
-- vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)
vim.keymap.set('n', '<leader>pv', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

vim.keymap.set('x', '<leader>p', [["_dP]])

--thank you mr seth for this tech
vim.keymap.set({ 'n', 'v' }, '<leader>d', [["_d]])

vim.keymap.set('n', 'Q', '<nop>')
-- this consumes tow global keymaps as the trade-off

--type shit i use colemak btw
vim.keymap.set('n', '<C-y>', '<C-i>', { noremap = true, silent = true })

vim.keymap.set('i', '<C-c>', '<Esc>')

vim.keymap.set('n', '<C-f>', '<cmd>silent !tmux neww tmux-sessionizer<CR>')

vim.keymap.set('n', '<leader>q', '<cmd>Trouble quickfix toggle<cr>', { desc = 'Quickfix (Trouble)' })
vim.keymap.set('n', '<leader>k', '<cmd>lnext<CR>zz')
vim.keymap.set('n', '<leader>j', '<cmd>lprev<CR>zz')

vim.keymap.set('n', '<leader>s', [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set('n', '<leader>x', '<cmd>!chmod +x %<CR>', { silent = true })

-- xdd
vim.keymap.set('n', '<leader>ee', 'oif err != nil {<CR>}<Esc>Oreturn err<Esc>')

-- cuz im retarded
vim.api.nvim_create_user_command('W', 'w<bang>', { bang = true })
vim.api.nvim_create_user_command('Wq', 'wq', {})
