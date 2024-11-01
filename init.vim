call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v4.x'}
call plug#end()

" Basic settings
set colorcolumn=80
set relativenumber

" Key bindings
nnoremap <C-p> :lua require('telescope.builtin').find_files()<CR>
tnoremap <Esc> <C-\><C-n>

lua << EOF
-- Telescope setup
require('telescope').setup{}

-- Treesitter setup
require'nvim-treesitter.configs'.setup {
  sync_install = false,
  auto_install = true,
  ensure_installed = { "go", "gdscript" },  -- Now includes both Go and GDScript
  indent = { enable = true },
  highlight = {
    enable = true,              
    additional_vim_regex_highlighting = false, 
  },
}

-- LSP setup
vim.opt.signcolumn = 'yes'

local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
    vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  end,
})

-- GDScript LSP configuration
local util = require 'lspconfig.util'

require('lspconfig').gdscript.setup{
  cmd = vim.fn.has('nvim-0.8') == 1 
    and vim.lsp.rpc.connect('127.0.0.1', '6005')
    or { 'nc', 'localhost', '6005' },
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_dir = util.root_pattern('project.godot', '.git'),
}

-- Go LSP configuration
require('lspconfig').gopls.setup{
  cmd = {'gopls'},
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

EOF
