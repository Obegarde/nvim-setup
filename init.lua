
-- Plugin management with vim-plug
vim.cmd [[
call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.8' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'VonHeikemen/lsp-zero.nvim', {'branch': 'v4.x'}
Plug 'ziglang/zig.vim'
call plug#end()
]]

-- Basic settings
vim.opt.colorcolumn = "80"
vim.opt.relativenumber = true

-- Key bindings
vim.api.nvim_set_keymap('n', '<C-p>', ":lua require('telescope.builtin').find_files()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true })

-- Telescope setup
require('telescope').setup {}

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  sync_install = false,
  auto_install = true,
  ensure_installed = { "go", "gdscript", "zig" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  indent = { enable = true },
}

-- LSP setup
vim.opt.signcolumn = "yes"
local lspconfig_defaults = require('lspconfig').util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

-- LSP keybindings
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'go', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set({'n', 'x'}, '<F3>', function() vim.lsp.buf.format { async = true } end, opts)
  end,
})

-- Example LSP server setups
require('lspconfig').zls.setup {
  cmd = { "zls" },
  capabilities = require('cmp_nvim_lsp').default_capabilities(),
}

require('lspconfig').gdscript.setup {
  cmd = { 'nc', 'localhost', '6005' },
  filetypes = { 'gd', 'gdscript', 'gdscript3' },
  root_dir = require('lspconfig.util').root_pattern('project.godot', '.git'),
}

require('lspconfig').gopls.setup {
  cmd = { 'gopls' },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = require('lspconfig.util').root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- Diagnostics Management: Populate Location List without changing focus
local function update_location_list()
  local diagnostics = vim.diagnostic.get(0) -- Get diagnostics for the current buffer
  if #diagnostics > 0 then
    vim.diagnostic.setloclist({ open = false }) -- Populate Location List without opening it automatically
    vim.cmd('silent! lwindow') -- Open Location List without moving cursor
  else
    -- Close Location List if no diagnostics
    pcall(vim.cmd, 'lclose')
  end
end

-- Autocmd to update Location List on save
vim.api.nvim_create_autocmd("BufWritePost", {
  callback = function()
    update_location_list()
  end,
  desc = "Update Location List with diagnostics on save",
})

-- Diagnostic Configuration
vim.diagnostic.config({
  virtual_text = false, -- Disable inline diagnostic messages
  signs = {
	severity = vim.diagnostic.severity.ERROR
},         -- Show diagnostic signs in the gutter
  underline = {
	severity = vim.diagnostic.severity.ERROR
},     -- Underline problematic text
  update_in_insert = false,
  severity_sort = true,
  float={
	severity = vim.diagnostic.severity.ERROR
}, -- Sort diagnostics by severity
})

-- Keybindings for Location List Navigation
vim.keymap.set('n', 'LN', function()
  vim.cmd('lnext')  -- Go to the next item in the Location List
  vim.cmd('normal zz') -- Center the cursor on the screen
end, { noremap = true, silent = true, desc = "Next diagnostic" })

vim.keymap.set('n', 'LP', function()
  vim.cmd('lprev')  -- Go to the previous item in the Location List
  vim.cmd('normal zz') -- Center the cursor on the screen
end, { noremap = true, silent = true, desc = "Previous diagnostic" })

vim.keymap.set('n', 'LO', ':lopen<CR>', { noremap = true, silent = true, desc = "Open Location List" })
vim.keymap.set('n', 'LC', ':lclose<CR>', { noremap = true, silent = true, desc = "Close Location List" })

